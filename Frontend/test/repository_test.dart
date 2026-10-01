import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:supervisacampo/core/models/app_models.dart';
import 'package:supervisacampo/core/repositories/mock_repository.dart';
import 'package:supervisacampo/core/repositories/remote_data_source.dart';

void main() {
  test(
    'visit, checklist and incident records keep UUIDs and sync idempotently',
    () async {
      final remote = _ImmediateRemoteDataSource();
      final repository = MockRepository(remoteDataSource: remote);
      final visit = repository.createVisit(
        supervisorId: MockRepository.supervisorId,
        costCenterId: 'cc-1',
        scheduledAt: DateTime(2026, 5, 20, 9),
        priority: 'Alta',
      );

      expect(_isUuid(visit.id), isTrue);
      expect(visit.checklist.every((item) => _isUuid(item.id)), isTrue);

      final item = visit.checklist.first;
      repository.setChecklistResult(
        visit.id,
        item.id,
        ChecklistResult.noCumple,
        observation: 'Hace falta desinfectante.',
      );
      repository.checkInVisit(
        visit.id,
        deviceTime: DateTime(2026, 5, 20, 9),
        latitude: DemoCoordinates.latitude,
        longitude: DemoCoordinates.longitude,
        accuracy: 8,
        distanceMeters: 20,
      );
      repository.checkoutVisit(visit.id, generalComments: 'Turno finalizado.');
      repository.createIncident(
        visit.id,
        'Falta de insumos de limpieza',
        'Reponer desinfectante.',
        priority: 'Alta',
      );

      final restored = Visit.fromJson(visit.toJson());
      expect(restored.checklist.first.result, ChecklistResult.noCumple);
      expect(restored.checkInLat, DemoCoordinates.latitude);
      expect(restored.generalComments, 'Turno finalizado.');

      await repository.syncPending();
      final remoteVisitCount = remote.visitsById.length;
      final remoteIncidentCount = remote.incidentsById.length;
      await repository.syncPending();

      expect(visit.syncStatus, SyncStatus.synced);
      expect(repository.pendingSyncCount, 0);
      expect(remote.visitsById.containsKey(visit.id), isTrue);
      expect(
        remote.incidentsById.containsKey(repository.incidents.last.id),
        isTrue,
      );
      expect(remote.visitsById.length, remoteVisitCount);
      expect(remote.incidentsById.length, remoteIncidentCount);
      expect(remote.visitsById.keys.toSet().length, remote.visitsById.length);
    },
  );

  test('failed remote sync leaves an error that can be retried', () async {
    final remote = _ImmediateRemoteDataSource()..forceErrors = true;
    final repository = MockRepository(remoteDataSource: remote);
    final visit = repository.createVisit(
      supervisorId: MockRepository.supervisorId,
      costCenterId: 'cc-1',
      scheduledAt: DateTime(2026, 5, 20, 9),
      priority: 'Media',
    );

    await repository.syncPending();
    expect(visit.syncStatus, SyncStatus.error);
    expect(visit.syncError, contains('desconectado'));

    remote.forceErrors = false;
    await repository.syncPending();
    expect(visit.syncStatus, SyncStatus.synced);
    expect(visit.syncError, isNull);
  });

  test(
    'Hive restores visits, checklist, incidents and evidence references',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'suthon-hive-test-',
      );
      try {
        Hive.init(directory.path);
        final box = await Hive.openBox<dynamic>('offline');
        final repository = MockRepository(storage: box);
        final visit = repository.createVisit(
          supervisorId: MockRepository.supervisorId,
          costCenterId: 'cc-1',
          scheduledAt: DateTime(2026, 5, 20, 9),
          priority: 'Alta',
        );
        repository.setChecklistResult(
          visit.id,
          visit.checklist.first.id,
          ChecklistResult.cumple,
          observation: 'Zona común limpia.',
          photoPath: '${directory.path}/evidence.jpg',
        );
        repository.createIncident(
          visit.id,
          'Derrame sin atender en lobby',
          'Requiere atención.',
          photoPath: '${directory.path}/incident.jpg',
        );
        await box.flush();
        await box.close();

        final reopenedBox = await Hive.openBox<dynamic>('offline');
        final restoredRepository = MockRepository(storage: reopenedBox);
        final restoredVisit = restoredRepository.visitById(visit.id)!;
        expect(restoredVisit.checklist.first.observation, 'Zona común limpia.');
        expect(
          restoredVisit.checklist.first.photoPath,
          '${directory.path}/evidence.jpg',
        );
        expect(
          restoredRepository.incidents.last.title,
          'Derrame sin atender en lobby',
        );
        await reopenedBox.close();
      } finally {
        await Hive.deleteBoxFromDisk('offline');
        await directory.delete(recursive: true);
      }
    },
  );
}

bool _isUuid(String value) => RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
).hasMatch(value);

class _ImmediateRemoteDataSource implements RemoteDataSource {
  final Map<String, Map<String, dynamic>> visitsById = {};
  final Map<String, Map<String, dynamic>> incidentsById = {};
  bool forceErrors = false;

  @override
  Future<void> upsertVisit(Map<String, dynamic> visit) async {
    if (forceErrors) throw StateError('Servidor desconectado.');
    visitsById[visit['id'] as String] = Map.of(visit);
  }

  @override
  Future<void> upsertIncident(Map<String, dynamic> incident) async {
    if (forceErrors) throw StateError('Servidor desconectado.');
    incidentsById[incident['id'] as String] = Map.of(incident);
  }
}
