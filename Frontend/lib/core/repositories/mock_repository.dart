import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:supervisacampo/core/models/app_models.dart';
import 'package:supervisacampo/core/repositories/remote_data_source.dart';
import 'package:supervisacampo/core/repositories/visits_repository.dart';
import 'package:uuid/uuid.dart';

class MockRepository implements VisitsRepository {
  MockRepository({this.storage, RemoteDataSource? remoteDataSource})
    : remoteDataSource = remoteDataSource ?? FakeRemoteDataSource() {
    _seed();
    _restore();
  }

  final Box<dynamic>? storage;
  final RemoteDataSource remoteDataSource;
  final List<AppUser> _users = [];
  final List<Visit> _visits = [];
  final List<Incident> _incidents = [];
  final List<CostCenter> _costCenters = [];
  final List<Assignment> _assignments = [];
  final List<NotificationItem> _notifications = [];
  final List<SatisfactionRecord> _satisfactions = [];
  final List<ReportItem> _reports = [];
  final Map<String, String> _demoPasswords = {
    'supervisor@demo.com': '123456',
    'coordinador@demo.com': '123456',
  };

  static const _uuid = Uuid();
  static const String supervisorId = 'sup-001';
  static const String coordinatorId = 'coord-001';
  @override
  AppUser? currentUser;

  void _seed() {
    _users.addAll([
      const AppUser(
        id: supervisorId,
        name: 'Laura Méndez',
        email: 'supervisor@demo.com',
        role: UserRole.supervisor,
        region: 'Zona Norte',
        department: 'Servicios de aseo',
        score: 94,
      ),
      const AppUser(
        id: coordinatorId,
        name: 'Andrés Pardo',
        email: 'coordinador@demo.com',
        role: UserRole.coordinator,
        region: 'Barranquilla',
        department: 'Operaciones',
        score: 97,
      ),
    ]);

    _costCenters.addAll([
      const CostCenter(
        id: 'cc-1',
        name: 'Edificio Torres del Parque',
        manager: 'M. Rojas',
        progress: 0.74,
        status: 'En servicio',
        lat: DemoCoordinates.latitude,
        lng: DemoCoordinates.longitude,
        radiusMeters: 100,
        address: 'Carrera 53 # 76-115, Barranquilla',
      ),
      const CostCenter(
        id: 'cc-2',
        name: 'Conjunto Residencial Alameda',
        manager: 'D. Torres',
        progress: 0.62,
        status: 'En servicio',
        lat: DemoCoordinates.latitude + 0.004,
        lng: DemoCoordinates.longitude - 0.003,
        radiusMeters: 120,
        address: 'Calle 84 # 42F-20, Barranquilla',
      ),
      const CostCenter(
        id: 'cc-3',
        name: 'Centro Comercial Plaza Norte',
        manager: 'S. Ruiz',
        progress: 0.81,
        status: 'En servicio',
        lat: DemoCoordinates.latitude - 0.003,
        lng: DemoCoordinates.longitude + 0.004,
        radiusMeters: 150,
        address: 'Carrera 46 # 93-10, Barranquilla',
      ),
    ]);

    _visits.addAll([
      Visit(
        id: 'vis-101',
        title: 'Limpieza diaria · Torres del Parque',
        location: 'Carrera 53 # 76-115, Barranquilla',
        status: VisitStatus.inProgress,
        supervisorId: supervisorId,
        coordinatorId: coordinatorId,
        startTime: DateTime.now().subtract(const Duration(hours: 2)),
        plannedEnd: DateTime.now().add(const Duration(hours: 2)),
        gps: '${DemoCoordinates.latitude}, ${DemoCoordinates.longitude}',
        priority: 'Alta',
        costCenterId: 'cc-1',
        scheduledAt: DateTime.now().subtract(const Duration(hours: 2)),
        checkInAt: DateTime.now().subtract(const Duration(hours: 2)),
        checkInLat: DemoCoordinates.latitude,
        checkInLng: DemoCoordinates.longitude,
        gpsAccuracy: 8,
        distanceMeters: 18,
        inRange: true,
        deviceTime: DateTime.now().subtract(const Duration(hours: 2)),
        syncStatus: SyncStatus.synced,
        checklist: [
          const ChecklistItem(
            id: 'chk-1',
            title: 'Limpieza de zonas comunes',
            done: true,
            priority: 'Alta',
          ),
          const ChecklistItem(
            id: 'chk-2',
            title: 'Desinfección de baños',
            done: true,
            priority: 'Alta',
          ),
          const ChecklistItem(
            id: 'chk-3',
            title: 'Manejo de residuos',
            priority: 'Media',
          ),
          const ChecklistItem(
            id: 'chk-4',
            title: 'Brillado de pisos',
            priority: 'Media',
          ),
        ],
        observations: ['Verificar reposición de bolsas para residuos.'],
      ),
      Visit(
        id: 'vis-102',
        title: 'Servicio de aseo · Conjunto Alameda',
        location: 'Calle 84 # 42F-20, Barranquilla',
        status: VisitStatus.planned,
        supervisorId: supervisorId,
        coordinatorId: coordinatorId,
        startTime: DateTime.now().add(const Duration(hours: 3)),
        plannedEnd: DateTime.now().add(const Duration(hours: 5)),
        gps:
            '${DemoCoordinates.latitude + 0.004}, ${DemoCoordinates.longitude - 0.003}',
        priority: 'Media',
        costCenterId: 'cc-2',
        scheduledAt: DateTime.now().add(const Duration(hours: 3)),
        checklist: [
          const ChecklistItem(
            id: 'chk-5',
            title: 'Limpieza de zonas comunes',
            priority: 'Alta',
          ),
          const ChecklistItem(
            id: 'chk-6',
            title: 'Limpieza de vidrios',
            priority: 'Media',
          ),
          const ChecklistItem(
            id: 'chk-7',
            title: 'Desinfección de baños',
            priority: 'Alta',
          ),
        ],
        observations: [],
      ),
      Visit(
        id: 'vis-103',
        title: 'Servicio de aseo · Plaza Norte',
        location: 'Carrera 46 # 93-10, Barranquilla',
        status: VisitStatus.completed,
        supervisorId: supervisorId,
        coordinatorId: coordinatorId,
        startTime: DateTime.now().subtract(const Duration(days: 1)),
        plannedEnd: DateTime.now()
            .subtract(const Duration(days: 1))
            .add(const Duration(hours: 3)),
        gps:
            '${DemoCoordinates.latitude - 0.003}, ${DemoCoordinates.longitude + 0.004}',
        priority: 'Baja',
        costCenterId: 'cc-3',
        scheduledAt: DateTime.now().subtract(const Duration(days: 1)),
        checkInAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        checkInLat: DemoCoordinates.latitude - 0.003,
        checkInLng: DemoCoordinates.longitude + 0.004,
        gpsAccuracy: 11,
        distanceMeters: 32,
        inRange: true,
        checkOutAt: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
        deviceTime: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        syncStatus: SyncStatus.synced,
        checklist: [
          const ChecklistItem(
            id: 'chk-8',
            title: 'Brillado de pisos',
            done: true,
          ),
          const ChecklistItem(
            id: 'chk-9',
            title: 'Limpieza de vidrios',
            done: true,
          ),
        ],
        observations: ['Servicio completado satisfactoriamente.'],
      ),
    ]);

    _incidents.addAll([
      Incident(
        id: 'inc-1',
        visitId: 'vis-101',
        title: 'Falta de insumos de limpieza',
        details: 'Se requiere reponer bolsas industriales y desinfectante para baños.',
        location: 'Edificio Torres del Parque',
        status: IncidentStatus.inReview,
        priority: 'Alta',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        syncStatus: SyncStatus.synced,
      ),
      Incident(
        id: 'inc-2',
        visitId: 'vis-102',
        title: 'Derrame sin atender en lobby',
        details: 'Se reporta líquido derramado en el acceso principal.',
        location: 'Conjunto Residencial Alameda',
        status: IncidentStatus.open,
        priority: 'Media',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        syncStatus: SyncStatus.synced,
      ),
    ]);

    _assignments.addAll([
      const Assignment(
        id: 'as-1',
        supervisorId: supervisorId,
        costCenterId: 'cc-1',
        status: 'Asignado',
        visitId: 'vis-101',
      ),
      const Assignment(
        id: 'as-2',
        supervisorId: supervisorId,
        costCenterId: 'cc-2',
        status: 'Pendiente',
        visitId: 'vis-102',
      ),
    ]);

    _notifications.addAll([
      const NotificationItem(
        id: 'nt-1',
        title: 'Sincronización completa',
        message: 'Se actualizaron 7 registros de visita.',
        time: 'Hace 5 min',
        read: true,
      ),
      const NotificationItem(
        id: 'nt-2',
        title: 'Novedad criticidad media',
        message: 'Se requiere revisión de la planta Norte.',
        time: 'Hace 18 min',
        read: false,
      ),
      const NotificationItem(
        id: 'nt-3',
        title: 'Aviso de GPS',
        message: 'Se detectó salida de radio próximo a la zona de control.',
        time: 'Hace 1 h',
        read: false,
      ),
    ]);

    _satisfactions.addAll([
      const SatisfactionRecord(
        id: 'sat-1',
        visitId: 'vis-103',
        score: 5,
        comment: 'Excelente coordinación y puntualidad.',
      ),
      const SatisfactionRecord(
        id: 'sat-2',
        visitId: 'vis-101',
        score: 4,
        comment: 'La atención fue rápida, pero se requiere seguimiento.',
      ),
    ]);

    _reports.addAll([
      const ReportItem(
        id: 'rep-1',
        title: 'Cumplimiento general',
        value: '87%',
        trend: TrendType.up,
        delta: '+5.2%',
      ),
      const ReportItem(
        id: 'rep-2',
        title: 'Novedades abiertas',
        value: '12',
        trend: TrendType.down,
        delta: '-3',
      ),
      const ReportItem(
        id: 'rep-3',
        title: 'Satisfacción',
        value: '4.6/5',
        trend: TrendType.up,
        delta: '+0.3',
      ),
    ]);
  }

  @override
  AppUser? login(String email, String password) {
    currentUser = null;
    for (final user in _users) {
      if (user.email == email && _demoPasswords[user.email] == password) {
        currentUser = user;
        return user;
      }
    }
    return null;
  }

  @override
  void logout() {
    currentUser = null;
  }

  @override
  List<Visit> get visits => List.unmodifiable(_visits);
  @override
  List<Incident> get incidents => List.unmodifiable(_incidents);
  @override
  List<CostCenter> get costCenters => List.unmodifiable(_costCenters);
  @override
  List<Assignment> get assignments => List.unmodifiable(_assignments);
  @override
  List<AppUser> get users => List.unmodifiable(_users);
  @override
  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  @override
  List<SatisfactionRecord> get satisfaction =>
      List.unmodifiable(_satisfactions);
  @override
  List<SyncRecord> get syncRecords => [
    for (final visit in _visits)
      SyncRecord(
        id: visit.id,
        name: 'Visita · ${visit.title}',
        timestamp: visit.deviceTime?.toLocal().toString() ?? 'Sin enviar',
        status: _syncStatusLabel(visit.syncStatus),
        error: visit.syncError,
      ),
    for (final incident in _incidents)
      SyncRecord(
        id: incident.id,
        name: 'Novedad · ${incident.title}',
        timestamp: incident.deviceTime?.toLocal().toString() ?? 'Sin enviar',
        status: _syncStatusLabel(incident.syncStatus),
        error: incident.syncError,
      ),
  ];
  @override
  int get pendingSyncCount =>
      _visits.where((visit) => visit.syncStatus != SyncStatus.synced).length +
      _incidents
          .where((incident) => incident.syncStatus != SyncStatus.synced)
          .length;
  @override
  List<ReportItem> get reports => List.unmodifiable(_reports);

  @override
  AppUser? userById(String id) =>
      _users.where((user) => user.id == id).firstOrNull;

  @override
  Visit? visitById(String id) =>
      _visits.where((visit) => visit.id == id).firstOrNull;

  @override
  CostCenter? costCenterForVisit(String visitId) {
    final visit = visitById(visitId);
    return visit == null
        ? null
        : _costCenters
              .where((center) => center.id == visit.costCenterId)
              .firstOrNull;
  }

  void toggleChecklistItem(String visitId, String id) {
    final visit = visitById(visitId);
    final item = visit?.checklist.where((value) => value.id == id).firstOrNull;
    if (item == null) return;
    setChecklistResult(
      visitId,
      id,
      item.done ? ChecklistResult.sinMarcar : ChecklistResult.cumple,
    );
  }

  @override
  void setChecklistResult(
    String visitId,
    String itemId,
    ChecklistResult result, {
    String? observation,
    String? photoPath,
  }) {
    final visit = _visits.where((item) => item.id == visitId).firstOrNull;
    if (visit == null) {
      return;
    }

    final index = visit.checklist.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final item = visit.checklist[index];
      visit.checklist[index] = ChecklistItem(
        id: item.id,
        title: item.title,
        result: result,
        observation: observation ?? item.observation,
        photoPath: photoPath ?? item.photoPath,
        priority: item.priority,
        deviceTime: DateTime.now(),
        serverTime: null,
      );
      visit.syncStatus = SyncStatus.pending;
      visit.syncError = null;
      _persist();
    }
  }

  @override
  void addObservation(String visitId, String text) {
    final visit = _visits.where((item) => item.id == visitId).firstOrNull;
    if (visit != null && text.trim().isNotEmpty) {
      visit.observations.add(text.trim());
      visit.syncStatus = SyncStatus.pending;
      _persist();
    }
  }

  @override
  void checkInVisit(
    String id, {
    required DateTime deviceTime,
    required double latitude,
    required double longitude,
    required double accuracy,
    required double distanceMeters,
    String? justification,
  }) {
    final visit = visitById(id);
    if (visit == null) return;
    visit.status = VisitStatus.inProgress;
    visit.checkInAt = deviceTime;
    visit.deviceTime = deviceTime;
    visit.checkInLat = latitude;
    visit.checkInLng = longitude;
    visit.gpsAccuracy = accuracy;
    visit.distanceMeters = distanceMeters;
    final center = costCenterForVisit(id);
    visit.inRange = center != null && distanceMeters <= center.radiusMeters;
    visit.justification = justification;
    visit.gps =
        '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
    visit.syncStatus = SyncStatus.pending;
    visit.syncError = null;
    _persist();
  }

  @override
  void checkoutVisit(String id, {String generalComments = ''}) {
    final visit = visitById(id);
    if (visit == null) return;
    visit.status = VisitStatus.completed;
    visit.checkOutAt = DateTime.now();
    visit.generalComments = generalComments.trim();
    visit.syncStatus = SyncStatus.pending;
    visit.syncError = null;
    _persist();
  }

  void updateGps(String id, String gps) {
    final visit = _visits.where((item) => item.id == id).firstOrNull;
    if (visit != null) {
      visit.gps = gps;
    }
  }

  @override
  void createIncident(
    String visitId,
    String title,
    String details, {
    String priority = 'Media',
    String? photoPath,
  }) {
    final visit = visitById(visitId);
    if (visit == null || title.trim().isEmpty || details.trim().isEmpty) {
      return;
    }
    _incidents.add(
      Incident(
        id: _uuid.v4(),
        visitId: visitId,
        title: title.trim(),
        details: details.trim(),
        location: costCenterForVisit(visitId)?.name ?? visit.location,
        status: IncidentStatus.open,
        priority: priority,
        createdAt: DateTime.now(),
        photoPath: photoPath,
        deviceTime: DateTime.now(),
      ),
    );
    visit.syncStatus = SyncStatus.pending;
    _persist();
  }

  void resolveIncident(String id) {
    updateIncident(id, status: IncidentStatus.closed);
  }

  @override
  void updateIncident(
    String id, {
    IncidentStatus? status,
    String? coordinatorComment,
  }) {
    final incident = _incidents.where((item) => item.id == id).firstOrNull;
    if (incident == null) return;
    if (status != null) incident.status = status;
    if (coordinatorComment != null) {
      incident.coordinatorComment = coordinatorComment.trim();
    }
    incident.syncStatus = SyncStatus.pending;
    _persist();
  }

  @override
  AppUser createSupervisor({
    required String name,
    required String email,
    required String password,
    required String identityNumber,
    required String costCenterId,
  }) {
    if (_users.any((user) => user.email.toLowerCase() == email.toLowerCase())) {
      throw ArgumentError('Ya existe un usuario con ese correo.');
    }
    final center = _costCenters
        .where((item) => item.id == costCenterId)
        .firstOrNull;
    if (center == null) throw ArgumentError('Selecciona un centro válido.');
    final user = AppUser(
      id: _uuid.v4(),
      name: name.trim(),
      email: email.trim().toLowerCase(),
      role: UserRole.supervisor,
      region: 'Barranquilla',
      department: 'Servicios de aseo',
      score: 0,
      identityNumber: identityNumber.trim(),
      primaryCostCenterId: costCenterId,
    );
    _users.add(user);
    _demoPasswords[user.email] = password;
    _persist();
    return user;
  }

  @override
  Visit createVisit({
    required String supervisorId,
    required String costCenterId,
    required DateTime scheduledAt,
    required String priority,
  }) {
    final supervisor = userById(supervisorId);
    final center = _costCenters
        .where((item) => item.id == costCenterId)
        .firstOrNull;
    if (supervisor?.role != UserRole.supervisor || center == null) {
      throw ArgumentError('Selecciona un supervisor y centro válidos.');
    }
    final visit = Visit(
      id: _uuid.v4(),
      title: 'Servicio de aseo · ${center.name}',
      location: center.address,
      status: VisitStatus.planned,
      supervisorId: supervisorId,
      coordinatorId: coordinatorId,
      startTime: scheduledAt,
      plannedEnd: scheduledAt.add(const Duration(hours: 2)),
      scheduledAt: scheduledAt,
      gps: '${center.lat}, ${center.lng}',
      priority: priority,
      costCenterId: costCenterId,
      deviceTime: DateTime.now(),
      checklist: [
        ChecklistItem(
          id: _uuid.v4(),
          title: 'Limpieza de zonas comunes',
          priority: 'Alta',
        ),
        ChecklistItem(
          id: _uuid.v4(),
          title: 'Desinfección de baños',
          priority: 'Alta',
        ),
        ChecklistItem(id: _uuid.v4(), title: 'Manejo de residuos'),
        ChecklistItem(id: _uuid.v4(), title: 'Brillado de pisos'),
        ChecklistItem(
          id: _uuid.v4(),
          title: 'Limpieza de vidrios',
          priority: 'Baja',
        ),
      ],
      observations: [],
    );
    _visits.add(visit);
    _assignments.add(
      Assignment(
        id: _uuid.v4(),
        supervisorId: supervisorId,
        costCenterId: costCenterId,
        status: 'Asignado',
        visitId: visit.id,
      ),
    );
    _persist();
    return visit;
  }

  @override
  void registerSatisfaction(String visitId, int score, String comment) {
    _satisfactions.add(
      SatisfactionRecord(
        id: 'sat-${_satisfactions.length + 1}',
        visitId: visitId,
        score: score,
        comment: comment,
      ),
    );
  }

  @override
  Future<void> syncPending() async {
    for (final visit in _visits.where(
      (item) => item.syncStatus != SyncStatus.synced,
    )) {
      try {
        await remoteDataSource.upsertVisit(visit.toJson());
        visit.syncStatus = SyncStatus.synced;
        visit.syncError = null;
        visit.serverTime = DateTime.now();
      } catch (error) {
        visit.syncStatus = SyncStatus.error;
        visit.syncError = error.toString();
      }

      _persist();
    }
    for (final incident in _incidents.where(
      (item) => item.syncStatus != SyncStatus.synced,
    )) {
      try {
        await remoteDataSource.upsertIncident(incident.toJson());
        incident.syncStatus = SyncStatus.synced;
        incident.syncError = null;
        incident.serverTime = DateTime.now();
      } catch (error) {
        incident.syncStatus = SyncStatus.error;
        incident.syncError = error.toString();
      }
      _persist();
    }
  }

  @override
  Future<String> saveEvidence(String sourcePath) async {
    final box = storage;
    if (box == null) return sourcePath;
    final hivePath = box.path;
    if (hivePath == null) return sourcePath;
    final separator = hivePath.lastIndexOf(Platform.pathSeparator);
    final directoryPath = separator < 0
        ? 'suthon-evidence'
        : '${hivePath.substring(0, separator)}${Platform.pathSeparator}suthon-evidence';
    final directory = await Directory(directoryPath).create(recursive: true);
    final targetPath =
        '${directory.path}${Platform.pathSeparator}${_uuid.v4()}.jpg';
    await File(sourcePath).copy(targetPath);
    return targetPath;
  }

  void _restore() {
    final savedVisits = storage?.get('visits');
    final savedIncidents = storage?.get('incidents');
    if (savedVisits is String) {
      final decoded = jsonDecode(savedVisits) as List<dynamic>;
      _visits
        ..clear()
        ..addAll(
          decoded.map((item) => Visit.fromJson(item as Map<String, dynamic>)),
        );
    }
    if (savedIncidents is String) {
      final decoded = jsonDecode(savedIncidents) as List<dynamic>;
      _incidents
        ..clear()
        ..addAll(
          decoded.map(
            (item) => Incident.fromJson(item as Map<String, dynamic>),
          ),
        );
    }
  }

  void _persist() {
    final box = storage;
    if (box == null) return;
    box.put(
      'visits',
      jsonEncode(_visits.map((visit) => visit.toJson()).toList()),
    );
    box.put(
      'incidents',
      jsonEncode(_incidents.map((incident) => incident.toJson()).toList()),
    );
  }

  String _syncStatusLabel(SyncStatus status) => switch (status) {
    SyncStatus.pending => 'Pendiente',
    SyncStatus.synced => 'Sincronizado',
    SyncStatus.error => 'Error',
  };
}

extension IterableExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
