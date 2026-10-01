import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supervisacampo/core/models/app_models.dart';
import 'package:supervisacampo/core/repositories/visits_repository.dart';
import 'package:supervisacampo/core/theme/app_theme.dart';
import 'package:supervisacampo/core/widgets/design_system.dart';

class VisitDetailScreen extends ConsumerStatefulWidget {
  const VisitDetailScreen({
    super.key,
    required this.visitId,
    required this.repository,
  });

  final String visitId;
  final VisitsRepository repository;

  @override
  ConsumerState<VisitDetailScreen> createState() => _VisitDetailScreenState();
}

class _VisitDetailScreenState extends ConsumerState<VisitDetailScreen> {
  final TextEditingController _observationController = TextEditingController();
  final TextEditingController _incidentTitleController = TextEditingController(
    text: 'Falta de insumos de limpieza',
  );
  final TextEditingController _incidentDetailsController =
      TextEditingController(
        text: 'Se requiere reponer insumos para completar el servicio.',
      );
  final TextEditingController _commentsController = TextEditingController();
  String _incidentPriority = 'Media';
  String? _incidentPhotoPath;
  bool _isCheckingIn = false;

  @override
  void dispose() {
    _observationController.dispose();
    _incidentTitleController.dispose();
    _incidentDetailsController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visit = widget.repository.visitById(widget.visitId);
    if (visit == null) {
      return const Scaffold(body: Center(child: Text('Visita no encontrada')));
    }

    return Scaffold(
      appBar: AppBar(title: Text(visit.title)),
      body: SafeArea(
        child: AnimatedPageContainer(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              visit.title,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          StatusBadge(
                            label: _visitStatusLabel(visit.status),
                            color: visit.status == VisitStatus.completed
                                ? AppColors.success
                                : AppColors.primary,
                            background: visit.status == VisitStatus.completed
                                ? AppColors.successSoft
                                : AppColors.primarySoft,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              visit.location,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Inicio: ${visit.startTime.toLocal().toString().substring(11, 16)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: _isCheckingIn
                          ? 'Obteniendo GPS…'
                          : visit.checkInAt == null
                          ? 'Registrar llegada'
                          : 'Llegada registrada',
                      icon: Icons.gps_fixed_rounded,
                      isLoading: _isCheckingIn,
                      onPressed: () {
                        if (!_isCheckingIn && visit.checkInAt == null) {
                          _checkIn(visit);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SecondaryButton(
                      label: 'QR',
                      icon: Icons.qr_code_rounded,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Escaneo QR simulado'),
                            content: const Text(
                              'Código detectado: VIS-204-AK47',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cerrar'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (visit.checkInAt != null) ...[
                const SizedBox(height: 20),
                _arrivalStamp(visit),
              ],
              const SizedBox(height: 16),
              Text('Checklist', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                '${visit.checklist.where((item) => item.result != ChecklistResult.sinMarcar).length} de ${visit.checklist.length} revisadas',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              TweenAnimationBuilder<double>(
                tween: Tween(
                  begin: 0,
                  end: visit.checklist.isEmpty
                      ? 0
                      : visit.checklist
                                .where(
                                  (item) =>
                                      item.result != ChecklistResult.sinMarcar,
                                )
                                .length /
                            visit.checklist.length,
                ),
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : AppMotion.standard,
                curve: Curves.easeOutCubic,
                builder: (context, progress, _) => LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  backgroundColor: AppColors.linea,
                  color: AppColors.dotacion,
                ),
              ),
              const SizedBox(height: 10),
              InspectionSheet(
                items: visit.checklist,
                onResult: (item, result) =>
                    _setChecklistResult(visit.id, item, result),
                onObservationChanged: (item, observation) =>
                    _updateChecklistObservation(visit.id, item, observation),
                onAddPhoto: (item) => _pickChecklistPhoto(visit.id, item),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Observaciones',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      ...visit.observations.map(
                        (observation) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 8,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(observation)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Agregar observación',
                        hint: 'Escriba un comentario',
                        controller: _observationController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        label: 'Guardar observación',
                        icon: Icons.note_add_rounded,
                        onPressed: () {
                          widget.repository.addObservation(
                            visit.id,
                            _observationController.text,
                          );
                          _observationController.clear();
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Validación de ubicación',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Ubicación actual: ${visit.gps}',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      if (visit.inRange != null) ...[
                        const SizedBox(height: 8),
                        StatusBadge(
                          label: visit.inRange!
                              ? 'Dentro de rango'
                              : 'Fuera de rango',
                          color: visit.inRange!
                              ? AppColors.success
                              : AppColors.danger,
                          background: visit.inRange!
                              ? AppColors.successSoft
                              : AppColors.dangerSoft,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Distancia: ${visit.distanceMeters?.round() ?? '—'} m · Precisión GPS: ${visit.gpsAccuracy?.round() ?? '—'} m',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                      const SizedBox(height: 12),
                      PrimaryButton(
                        label: 'Actualizar ubicación',
                        icon: Icons.my_location_rounded,
                        onPressed: () {
                          _checkIn(visit);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Novedad',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Título',
                        hint: 'Falla detectada',
                        controller: _incidentTitleController,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Detalle',
                        hint: 'Describa la novedad',
                        controller: _incidentDetailsController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _incidentPriority,
                        decoration: const InputDecoration(
                          labelText: 'Prioridad',
                        ),
                        items: const ['Alta', 'Media', 'Baja']
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(
                          () => _incidentPriority = value ?? 'Media',
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _pickIncidentPhoto,
                        icon: const Icon(Icons.add_a_photo_outlined),
                        label: Text(
                          _incidentPhotoPath == null
                              ? 'Adjuntar fotografía'
                              : 'Fotografía adjunta',
                        ),
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        label: 'Registrar novedad',
                        icon: Icons.report_problem_rounded,
                        onPressed: () {
                          widget.repository.createIncident(
                            visit.id,
                            _incidentTitleController.text,
                            _incidentDetailsController.text,
                            priority: _incidentPriority,
                            photoPath: _incidentPhotoPath,
                          );
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Novedad registrada')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              AppTextField(
                label: 'Comentario final',
                hint: 'Resumen de la visita (opcional)',
                controller: _commentsController,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Registrar salida',
                icon: Icons.flag_rounded,
                onPressed: () {
                  widget.repository.checkoutVisit(
                    visit.id,
                    generalComments: _commentsController.text,
                  );
                  _showVisitSummary(visit);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _visitStatusLabel(VisitStatus status) => switch (status) {
    VisitStatus.planned => 'Programada',
    VisitStatus.inProgress => 'En curso',
    VisitStatus.completed => 'Completada',
    VisitStatus.blocked => 'Bloqueada',
  };

  Future<void> _checkIn(Visit visit) async {
    setState(() => _isCheckingIn = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception(
          'Activa la ubicación (GPS) del dispositivo e inténtalo de nuevo.',
        );
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception(
          'Se necesita permiso de ubicación para registrar el check-in.',
        );
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 20),
        ),
      );
      if (!mounted) return;
      if (position.accuracy > 100) {
        throw Exception(
          'La precisión del GPS es baja (${position.accuracy.round()} m). Intenta en un lugar abierto.',
        );
      }
      final center = widget.repository.costCenterForVisit(visit.id);
      if (center == null) {
        throw Exception('No se encontró la ubicación del centro de costo.');
      }
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        center.lat,
        center.lng,
      );
      String? justification;
      if (distance > center.radiusMeters) {
        justification = await _requestJustification(
          distance,
          center.radiusMeters,
        );
        if (justification == null) return;
      }
      widget.repository.checkInVisit(
        visit.id,
        deviceTime: DateTime.now(),
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        distanceMeters: distance,
        justification: justification,
      );
      HapticFeedback.mediumImpact();
      setState(() {});
    } catch (error) {
      if (mounted) {
        final message = error is LocationServiceDisabledException
            ? 'El GPS está apagado. Actívalo para continuar.'
            : error is PermissionDeniedException
            ? 'Permiso de ubicación denegado. Habilítalo en ajustes.'
            : error.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _isCheckingIn = false);
    }
  }

  Widget _arrivalStamp(Visit visit) {
    final inside = visit.inRange == true;
    final color = inside ? AppColors.verde : AppColors.rojo;
    final time = visit.checkInAt!.toLocal();
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.3, end: 1),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 420),
        curve: Curves.elasticOut,
        builder: (context, scale, child) => Transform.rotate(
          angle: -0.105,
          child: Transform.scale(scale: scale, child: child),
        ),
        child: Container(
          width: 154,
          height: 154,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          padding: const EdgeInsets.all(7),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'LLEGADA · ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: color, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  inside ? 'Dentro de rango' : 'Fuera de rango',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(color: color, fontWeight: FontWeight.w700),
                ),
                if (visit.distanceMeters != null)
                  Text(
                    '${visit.distanceMeters!.round()} m · GPS ${visit.gpsAccuracy?.round() ?? '—'} m',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _requestJustification(double distance, double radius) async {
    final controller = TextEditingController();
    final justification = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fuera del rango'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Estás a ${distance.round()} m del centro (radio: ${radius.round()} m). Escribe una justificación para continuar.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Justificación obligatoria',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    controller.dispose();
    return justification;
  }

  void _setChecklistResult(
    String visitId,
    ChecklistItem item,
    ChecklistResult result,
  ) {
    widget.repository.setChecklistResult(
      visitId,
      item.id,
      result,
      observation: item.observation,
      photoPath: item.photoPath,
    );
    setState(() {});
  }

  void _updateChecklistObservation(
    String visitId,
    ChecklistItem item,
    String observation,
  ) {
    widget.repository.setChecklistResult(
      visitId,
      item.id,
      item.result,
      observation: observation,
      photoPath: item.photoPath,
    );
  }

  Future<void> _pickChecklistPhoto(String visitId, ChecklistItem item) async {
    final path = await _pickCompressedPhoto();
    if (path == null) return;
    widget.repository.setChecklistResult(
      visitId,
      item.id,
      item.result,
      observation: item.observation,
      photoPath: path,
    );
    if (mounted) setState(() {});
  }

  Future<void> _pickIncidentPhoto() async {
    final path = await _pickCompressedPhoto();
    if (path != null && mounted) setState(() => _incidentPhotoPath = path);
  }

  Future<String?> _pickCompressedPhoto() async {
    try {
      final source = Platform.isLinux || Platform.isWindows || Platform.isMacOS
          ? ImageSource.gallery
          : ImageSource.camera;
      final picked = await ImagePicker().pickImage(source: source);
      if (picked == null) return null;
      final target =
          '${Directory.systemTemp.path}/suthon-${DateTime.now().microsecondsSinceEpoch}.jpg';
      final compressed = await FlutterImageCompress.compressAndGetFile(
        picked.path,
        target,
        minWidth: 800,
        minHeight: 800,
        quality: 70,
      );
      if (compressed == null) {
        throw StateError(
          'No fue posible comprimir la fotografía seleccionada.',
        );
      }
      return await widget.repository.saveEvidence(compressed.path);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo adjuntar la fotografía: $error')),
        );
      }
      return null;
    }
  }

  Future<void> _showVisitSummary(Visit visit) async {
    final completedVisit = widget.repository.visitById(visit.id) ?? visit;
    final arrival = completedVisit.checkInAt?.toLocal();
    final departure = completedVisit.checkOutAt?.toLocal();
    String formatTime(DateTime? value) => value == null
        ? 'Sin registrar'
        : '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Visita cerrada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _receiptRow('Llegada', formatTime(arrival)),
            _receiptRow(
              'Cumplidas',
              '${completedVisit.checklist.where((item) => item.result == ChecklistResult.cumple).length}',
            ),
            _receiptRow(
              'No cumplidas',
              '${completedVisit.checklist.where((item) => item.result == ChecklistResult.noCumple).length}',
            ),
            _receiptRow(
              'Novedades',
              '${widget.repository.incidents.where((item) => item.visitId == visit.id).length}',
            ),
            _receiptRow('Salida', formatTime(departure)),
            const SizedBox(height: 14),
            StatusPill(
              label: 'Visita cerrada',
              color: AppColors.verde,
              icon: Icons.check_circle_outline,
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(this.context);
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text(value, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(height: 1, color: AppColors.linea),
      ],
    ),
  );
}
