import 'dart:async';

abstract interface class RemoteDataSource {
  Future<void> upsertVisit(Map<String, dynamic> visit);
  Future<void> upsertIncident(Map<String, dynamic> incident);
}

class FakeRemoteDataSource implements RemoteDataSource {
  final Map<String, Map<String, dynamic>> visitsById = {};
  final Map<String, Map<String, dynamic>> incidentsById = {};
  bool forceErrors = false;

  @override
  Future<void> upsertVisit(Map<String, dynamic> visit) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (forceErrors) throw StateError('Servidor de demostración no disponible.');
    visitsById[visit['id'] as String] = Map.of(visit);
  }

  @override
  Future<void> upsertIncident(Map<String, dynamic> incident) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (forceErrors) throw StateError('Servidor de demostración no disponible.');
    incidentsById[incident['id'] as String] = Map.of(incident);
  }
}
