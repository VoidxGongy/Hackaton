enum UserRole { supervisor, coordinator }
enum VisitStatus { planned, inProgress, completed, blocked }
enum IncidentStatus { open, inReview, closed }
enum SyncStatus { pending, synced, error }
enum ChecklistResult { cumple, noCumple, sinMarcar }
enum TrendType { up, down, stable }

class DemoCoordinates {
  const DemoCoordinates._();

  static const latitude = 10.9878;
  static const longitude = -74.7889;
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.region,
    required this.department,
    required this.score,
    this.identityNumber,
    this.primaryCostCenterId,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String region;
  final String department;
  final int score;
  final String? identityNumber;
  final String? primaryCostCenterId;
}

class CostCenter {
  const CostCenter({
    required this.id,
    required this.name,
    required this.manager,
    required this.progress,
    required this.status,
    this.lat = DemoCoordinates.latitude,
    this.lng = DemoCoordinates.longitude,
    this.radiusMeters = 100,
    this.address = '',
  });

  final String id;
  final String name;
  final String manager;
  final double progress;
  final String status;
  final double lat;
  final double lng;
  final double radiusMeters;
  final String address;
}

class ChecklistItem {
  const ChecklistItem({
    required this.id,
    required this.title,
    bool? done,
    ChecklistResult? result,
    this.observation = '',
    this.photoPath,
    this.priority = 'Media',
    this.deviceTime,
    this.serverTime,
  }) : result =
           result ??
           (done == true ? ChecklistResult.cumple : ChecklistResult.sinMarcar);

  final String id;
  final String title;
  final ChecklistResult result;
  final String observation;
  final String? photoPath;
  final String priority;
  final DateTime? deviceTime;
  final DateTime? serverTime;
  bool get done => result == ChecklistResult.cumple;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'result': result.name,
    'observation': observation,
    'photoPath': photoPath,
    'priority': priority,
    'deviceTime': deviceTime?.toIso8601String(),
    'serverTime': serverTime?.toIso8601String(),
  };

  factory ChecklistItem.fromJson(Map<dynamic, dynamic> json) => ChecklistItem(
    id: json['id'] as String,
    title: json['title'] as String,
    result: ChecklistResult.values.byName(json['result'] as String),
    observation: json['observation'] as String? ?? '',
    photoPath: json['photoPath'] as String?,
    priority: json['priority'] as String? ?? 'Media',
    deviceTime: _dateFromJson(json['deviceTime']),
    serverTime: _dateFromJson(json['serverTime']),
  );
}

class Visit {
  Visit({
    required this.id,
    required this.title,
    required this.location,
    required this.status,
    required this.supervisorId,
    required this.coordinatorId,
    required this.startTime,
    required this.plannedEnd,
    required this.gps,
    required this.checklist,
    required this.observations,
    required this.priority,
    this.costCenterId,
    this.scheduledAt,
    this.checkInAt,
    this.checkInLat,
    this.checkInLng,
    this.gpsAccuracy,
    this.distanceMeters,
    this.inRange,
    this.checkOutAt,
    this.justification,
    this.generalComments = '',
    this.syncStatus = SyncStatus.pending,
    this.syncError,
    this.deviceTime,
    this.serverTime,
  });

  final String id;
  final String title;
  final String location;
  VisitStatus status;
  final String supervisorId;
  final String coordinatorId;
  DateTime startTime;
  DateTime plannedEnd;
  String gps;
  List<ChecklistItem> checklist;
  List<String> observations;
  String priority;
  String? costCenterId;
  DateTime? scheduledAt;
  DateTime? checkInAt;
  double? checkInLat;
  double? checkInLng;
  double? gpsAccuracy;
  double? distanceMeters;
  bool? inRange;
  DateTime? checkOutAt;
  String? justification;
  String generalComments;
  SyncStatus syncStatus;
  String? syncError;
  DateTime? deviceTime;
  DateTime? serverTime;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'location': location,
    'status': status.name,
    'supervisorId': supervisorId,
    'coordinatorId': coordinatorId,
    'startTime': startTime.toIso8601String(),
    'plannedEnd': plannedEnd.toIso8601String(),
    'gps': gps,
    'checklist': checklist.map((item) => item.toJson()).toList(),
    'observations': observations,
    'priority': priority,
    'costCenterId': costCenterId,
    'scheduledAt': scheduledAt?.toIso8601String(),
    'checkInAt': checkInAt?.toIso8601String(),
    'checkInLat': checkInLat,
    'checkInLng': checkInLng,
    'gpsAccuracy': gpsAccuracy,
    'distanceMeters': distanceMeters,
    'inRange': inRange,
    'checkOutAt': checkOutAt?.toIso8601String(),
    'justification': justification,
    'generalComments': generalComments,
    'syncStatus': syncStatus.name,
    'syncError': syncError,
    'deviceTime': deviceTime?.toIso8601String(),
    'serverTime': serverTime?.toIso8601String(),
  };

  factory Visit.fromJson(Map<dynamic, dynamic> json) => Visit(
    id: json['id'] as String,
    title: json['title'] as String,
    location: json['location'] as String,
    status: VisitStatus.values.byName(json['status'] as String),
    supervisorId: json['supervisorId'] as String,
    coordinatorId: json['coordinatorId'] as String,
    startTime: DateTime.parse(json['startTime'] as String),
    plannedEnd: DateTime.parse(json['plannedEnd'] as String),
    gps: json['gps'] as String,
    checklist: (json['checklist'] as List<dynamic>)
        .map((item) => ChecklistItem.fromJson(item as Map<dynamic, dynamic>))
        .toList(),
    observations: (json['observations'] as List<dynamic>).cast<String>(),
    priority: json['priority'] as String,
    costCenterId: json['costCenterId'] as String?,
    scheduledAt: _dateFromJson(json['scheduledAt']),
    checkInAt: _dateFromJson(json['checkInAt']),
    checkInLat: (json['checkInLat'] as num?)?.toDouble(),
    checkInLng: (json['checkInLng'] as num?)?.toDouble(),
    gpsAccuracy: (json['gpsAccuracy'] as num?)?.toDouble(),
    distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
    inRange: json['inRange'] as bool?,
    checkOutAt: _dateFromJson(json['checkOutAt']),
    justification: json['justification'] as String?,
    generalComments: json['generalComments'] as String? ?? '',
    syncStatus: SyncStatus.values.byName(json['syncStatus'] as String),
    syncError: json['syncError'] as String?,
    deviceTime: _dateFromJson(json['deviceTime']),
    serverTime: _dateFromJson(json['serverTime']),
  );
}

class Incident {
  Incident({
    required this.id,
    required this.visitId,
    required this.title,
    required this.details,
    required this.location,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.photoPath,
    this.coordinatorComment = '',
    this.syncStatus = SyncStatus.pending,
    this.syncError,
    this.deviceTime,
    this.serverTime,
  });

  final String id;
  final String visitId;
  final String title;
  final String details;
  final String location;
  IncidentStatus status;
  final String priority;
  final DateTime createdAt;
  String? photoPath;
  String coordinatorComment;
  SyncStatus syncStatus;
  String? syncError;
  final DateTime? deviceTime;
  DateTime? serverTime;

  Map<String, dynamic> toJson() => {
    'id': id,
    'visitId': visitId,
    'title': title,
    'details': details,
    'location': location,
    'status': status.name,
    'priority': priority,
    'createdAt': createdAt.toIso8601String(),
    'photoPath': photoPath,
    'coordinatorComment': coordinatorComment,
    'syncStatus': syncStatus.name,
    'syncError': syncError,
    'deviceTime': deviceTime?.toIso8601String(),
    'serverTime': serverTime?.toIso8601String(),
  };

  factory Incident.fromJson(Map<dynamic, dynamic> json) => Incident(
    id: json['id'] as String,
    visitId: json['visitId'] as String,
    title: json['title'] as String,
    details: json['details'] as String,
    location: json['location'] as String,
    status: IncidentStatus.values.byName(json['status'] as String),
    priority: json['priority'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    photoPath: json['photoPath'] as String?,
    coordinatorComment: json['coordinatorComment'] as String? ?? '',
    syncStatus: SyncStatus.values.byName(json['syncStatus'] as String),
    syncError: json['syncError'] as String?,
    deviceTime: _dateFromJson(json['deviceTime']),
    serverTime: _dateFromJson(json['serverTime']),
  );
}

DateTime? _dateFromJson(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

class Assignment {
  const Assignment({
    required this.id,
    required this.supervisorId,
    required this.costCenterId,
    required this.status,
    required this.visitId,
  });

  final String id;
  final String supervisorId;
  final String costCenterId;
  final String status;
  final String visitId;
}

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.read,
  });

  final String id;
  final String title;
  final String message;
  final String time;
  final bool read;
}

class SatisfactionRecord {
  const SatisfactionRecord({
    required this.id,
    required this.visitId,
    required this.score,
    required this.comment,
  });

  final String id;
  final String visitId;
  final int score;
  final String comment;
}

class SyncRecord {
  const SyncRecord({
    required this.id,
    required this.name,
    required this.timestamp,
    required this.status,
    this.error,
  });

  final String id;
  final String name;
  final String timestamp;
  final String status;
  final String? error;
}

class ReportItem {
  const ReportItem({
    required this.id,
    required this.title,
    required this.value,
    required this.trend,
    required this.delta,
  });

  final String id;
  final String title;
  final String value;
  final TrendType trend;
  final String delta;
}
