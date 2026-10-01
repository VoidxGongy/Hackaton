import 'package:supervisacampo/core/models/app_models.dart';

abstract interface class VisitsRepository {
  AppUser? get currentUser;
  List<Visit> get visits;
  List<Incident> get incidents;
  List<CostCenter> get costCenters;
  List<Assignment> get assignments;
  List<AppUser> get users;
  List<NotificationItem> get notifications;
  List<SatisfactionRecord> get satisfaction;
  List<SyncRecord> get syncRecords;
  List<ReportItem> get reports;
  int get pendingSyncCount;

  AppUser? login(String email, String password);
  void logout();
  AppUser? userById(String id);
  Visit? visitById(String id);
  CostCenter? costCenterForVisit(String visitId);
  void setChecklistResult(
    String visitId,
    String itemId,
    ChecklistResult result, {
    String? observation,
    String? photoPath,
  });
  void addObservation(String visitId, String text);
  void checkInVisit(
    String id, {
    required DateTime deviceTime,
    required double latitude,
    required double longitude,
    required double accuracy,
    required double distanceMeters,
    String? justification,
  });
  void checkoutVisit(String id, {String generalComments = ''});
  void createIncident(
    String visitId,
    String title,
    String details, {
    String priority = 'Media',
    String? photoPath,
  });
  void updateIncident(
    String id, {
    IncidentStatus? status,
    String? coordinatorComment,
  });
  AppUser createSupervisor({
    required String name,
    required String email,
    required String password,
    required String identityNumber,
    required String costCenterId,
  });
  Visit createVisit({
    required String supervisorId,
    required String costCenterId,
    required DateTime scheduledAt,
    required String priority,
  });
  void registerSatisfaction(String visitId, int score, String comment);
  Future<void> syncPending();
  Future<String> saveEvidence(String sourcePath);
}
