import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supervisacampo/app/routes.dart';
import 'package:supervisacampo/core/models/app_models.dart';
import 'package:supervisacampo/core/repositories/visits_repository.dart';
import 'package:supervisacampo/core/theme/app_theme.dart';
import 'package:supervisacampo/core/widgets/design_system.dart';

class CoordinatorHomeScreen extends StatefulWidget {
  const CoordinatorHomeScreen({super.key, required this.repository});

  final VisitsRepository repository;

  @override
  State<CoordinatorHomeScreen> createState() => _CoordinatorHomeScreenState();
}

class _CoordinatorHomeScreenState extends State<CoordinatorHomeScreen> {
  int _selectedIndex = 0;
  String _visitFilter = 'Todas';
  String _visitSupervisorFilter = 'Todos';
  DateTime? _visitDateFilter;
  String _incidentPriorityFilter = 'Todas';
  String _incidentStatusFilter = 'Todos';

  Future<void> _createSupervisor() async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController();
    final email = TextEditingController();
    final identity = TextEditingController();
    final password = TextEditingController();
    final centers = widget.repository.costCenters;
    String? centerId = centers.firstOrNull?.id;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, refreshDialog) => AlertDialog(
          title: const Text('Crear supervisor'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogField(name, 'Nombre completo'),
                  _dialogField(email, 'Correo electrónico', keyboardType: TextInputType.emailAddress),
                  _dialogField(identity, 'Cédula'),
                  _dialogField(password, 'Contraseña', obscureText: true),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: centerId,
                    decoration: const InputDecoration(labelText: 'Centro de costo'),
                    items: centers.map((center) => DropdownMenuItem(
                      value: center.id,
                      child: Text(
                        center.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )).toList(),
                    onChanged: (value) => refreshDialog(() => centerId = value),
                    validator: (value) => value == null ? 'Selecciona un centro.' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true && centerId != null && mounted) {
      try {
        widget.repository.createSupervisor(
          name: name.text,
          email: email.text,
          password: password.text,
          identityNumber: identity.text,
          costCenterId: centerId!,
        );
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Supervisor creado.')),
        );
      } on ArgumentError catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message.toString())),
        );
      }
    }

    name.dispose();
    email.dispose();
    identity.dispose();
    password.dispose();
  }

  Future<void> _createVisit() async {
    final supervisors = widget.repository.users
        .where((user) => user.role == UserRole.supervisor)
        .toList();
    final centers = widget.repository.costCenters;
    if (supervisors.isEmpty || centers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Crea un supervisor y un centro de costo antes de asignar.')),
      );
      return;
    }
    String supervisorId = supervisors.first.id;
    String centerId = centers.first.id;
    String priority = 'Media';
    var scheduledDate = DateTime.now();
    var scheduledTime = TimeOfDay.now();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, refreshDialog) => AlertDialog(
          title: const Text('Asignar visita'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: supervisorId,
                  decoration: const InputDecoration(labelText: 'Supervisor'),
                  items: supervisors
                      .map(
                        (user) => DropdownMenuItem(
                          value: user.id,
                          child: Text(
                            user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => refreshDialog(() => supervisorId = value ?? supervisorId),
                ),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: centerId,
                  decoration: const InputDecoration(labelText: 'Centro de costo'),
                  items: centers
                      .map(
                        (center) => DropdownMenuItem(
                          value: center.id,
                          child: Text(
                            center.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => refreshDialog(() => centerId = value ?? centerId),
                ),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: priority,
                  decoration: const InputDecoration(labelText: 'Prioridad'),
                  items: const ['Alta', 'Media', 'Baja'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                  onChanged: (value) => refreshDialog(() => priority = value ?? priority),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: dialogContext,
                      initialDate: scheduledDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) refreshDialog(() => scheduledDate = picked);
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text('${scheduledDate.day}/${scheduledDate.month}/${scheduledDate.year}'),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showTimePicker(context: dialogContext, initialTime: scheduledTime);
                    if (picked != null) refreshDialog(() => scheduledTime = picked);
                  },
                  icon: const Icon(Icons.access_time),
                  label: Text(scheduledTime.format(dialogContext)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Asignar')),
          ],
        ),
      ),
    );
    if (confirmed == true && mounted) {
      final scheduledAt = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        scheduledTime.hour,
        scheduledTime.minute,
      );
      widget.repository.createVisit(
        supervisorId: supervisorId,
        costCenterId: centerId,
        scheduledAt: scheduledAt,
        priority: priority,
      );
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visita asignada correctamente.')),
      );
    }
  }

  Future<void> _manageIncident(Incident incident) async {
    final comment = TextEditingController(text: incident.coordinatorComment);
    var status = incident.status;
    final result = await showDialog<({IncidentStatus status, String comment})>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, refreshDialog) => AlertDialog(
          title: Text(incident.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(incident.details),
              if (incident.photoPath != null) ...[
                const SizedBox(height: 10),
                Image.file(
                  File(incident.photoPath!),
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Text('No se pudo cargar la fotografía.'),
                ),
              ],
              const SizedBox(height: 12),
              DropdownButtonFormField<IncidentStatus>(
                isExpanded: true,
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Estado'),
                items: const [
                  DropdownMenuItem(value: IncidentStatus.open, child: Text('Abierta')),
                  DropdownMenuItem(value: IncidentStatus.inReview, child: Text('En revisión')),
                  DropdownMenuItem(value: IncidentStatus.closed, child: Text('Cerrada')),
                ],
                onChanged: (value) => refreshDialog(() => status = value ?? status),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: comment,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Comentario del coordinador'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                (status: status, comment: comment.text),
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
    comment.dispose();
    if (result != null) {
      widget.repository.updateIncident(
        incident.id,
        status: result.status,
        coordinatorComment: result.comment,
      );
      if (mounted) setState(() {});
    }
  }

  Future<void> _showVisitDetails(Visit visit) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(visit.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(visit.location),
              const SizedBox(height: 10),
              Text('Llegada: ${visit.checkInAt?.toLocal() ?? 'Sin registrar'}'),
              Text('Hora recibida por servidor: ${visit.serverTime?.toLocal() ?? 'Pendiente de sincronización'}'),
              Text('Salida: ${visit.checkOutAt?.toLocal() ?? 'Sin registrar'}'),
              Text('Distancia: ${visit.distanceMeters?.round() ?? '—'} m'),
              Text('Precisión GPS: ${visit.gpsAccuracy?.round() ?? '—'} m'),
              if (visit.justification != null)
                Text('Justificación: ${visit.justification}'),
              const SizedBox(height: 10),
              const Text('Actividades revisadas'),
              ...visit.checklist.map(
                (item) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.title),
                      subtitle: Text(
                        '${item.result == ChecklistResult.cumple ? 'Cumple' : item.result == ChecklistResult.noCumple ? 'No cumple' : 'Sin marcar'}'
                        '${item.observation.isEmpty ? '' : ' · ${item.observation}'}',
                      ),
                    ),
                    if (item.photoPath != null)
                      Image.file(
                        File(item.photoPath!),
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Text('No se pudo cargar la fotografía.'),
                      ),
                  ],
                ),
              ),
              if (visit.generalComments.isNotEmpty)
                Text('Comentario final: ${visit.generalComments}'),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.push(AppRoutes.coordinatorMap);
                },
                icon: const Icon(Icons.map_outlined),
                label: const Text('Abrir mapa de supervisión'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  Widget _dialogField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    bool obscureText = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(labelText: label),
      validator: (value) =>
          value == null || value.trim().isEmpty ? 'Completa este campo.' : null,
    ),
  );

  List<({IconData icon, String label})> get _items => const [
    (icon: Icons.shield_rounded, label: 'Inicio'),
    (icon: Icons.calendar_month_rounded, label: 'Visitas'),
    (icon: Icons.map_rounded, label: 'Mapa'),
    (icon: Icons.list_alt_rounded, label: 'Novedades'),
  ];

  @override
  Widget build(BuildContext context) {
    final body = switch (_selectedIndex) {
      0 => _dashboardView(),
      1 => _visitsView(),
      2 => _mapView(),
      3 => _incidentsView(),
      4 => _supervisorsView(),
      5 => _assignmentsView(),
      _ => _reportsView(),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex < _items.length
              ? (_selectedIndex == 0 ? 'Panel de control' : _items[_selectedIndex].label)
              : _selectedIndex == 4
              ? 'Supervisores'
              : _selectedIndex == 5
              ? 'Asignaciones'
              : 'Reportes',
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () {
              widget.repository.logout();
              context.go(AppRoutes.login);
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(child: AnimatedPageContainer(child: body)),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _selectedIndex < _items.length ? _selectedIndex : 0,
        onItemTapped: (value) => setState(() => _selectedIndex = value),
        items: _items,
      ),
    );
  }

  Widget _dashboardView() {
    final reports = widget.repository.reports;
    final incidents = widget.repository.incidents;
    final visits = widget.repository.visits;
    final completedCount = visits.where((visit) => visit.status == VisitStatus.completed).length;
    final pendingCount = visits.where((visit) => visit.status == VisitStatus.planned).length;
    final outOfRangeCount = visits.where((visit) => visit.inRange == false).length;
    final checklistItems = visits.expand((visit) => visit.checklist).toList();
    final markedItems = checklistItems.where((item) => item.result != ChecklistResult.sinMarcar);
    final compliance = markedItems.isEmpty
        ? 0
        : (markedItems.where((item) => item.result == ChecklistResult.cumple).length * 100 /
                markedItems.length)
            .round();
    final openIncidents = incidents.where((item) => item.status != IncidentStatus.closed).length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.l),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buenos días,',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.repository.currentUser?.name ?? 'Coordinador',
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Coordinación de operaciones',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(
                  (widget.repository.currentUser?.name ?? 'C')
                      .split(' ')
                      .take(2)
                      .map((part) => part.isEmpty ? '' : part[0].toUpperCase())
                      .join(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.papel,
            border: Border.all(color: AppColors.linea),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: compliance.toDouble()),
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => Text(
                  '${value.round()}%',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.dotacion,
                    height: 0.95,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    '$completedCount de ${visits.length} visitas realizadas hoy',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final metric in [
          ('Realizadas', '$completedCount', AppColors.verde),
          ('Pendientes', '$pendingCount', AppColors.dotacion),
          ('Fuera de rango', '$outOfRangeCount', AppColors.rojo),
          ('Novedades abiertas', '$openIncidents', AppColors.precaucion),
        ])
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.linea)),
            ),
            child: Row(
              children: [
                Expanded(child: Text(metric.$1)),
                Text(
                  metric.$2,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: metric.$3 == AppColors.precaucion
                        ? AppColors.tinta
                        : metric.$3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        if (incidents.isNotEmpty) ...[
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.danger,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Novedades que requieren atención',
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$openIncidents reportes pendientes de seguimiento',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        Text(
          'KPI y reportes',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ...reports.map(
          (report) => AppCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          report.value,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(
                    label: report.delta,
                    color: report.trend == TrendType.down
                        ? AppColors.danger
                        : AppColors.success,
                    background: report.trend == TrendType.down
                        ? AppColors.dangerSoft
                        : AppColors.successSoft,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Ver mapa de monitoreo',
          icon: Icons.map_rounded,
          onPressed: () => context.push(AppRoutes.coordinatorMap),
        ),
        const SizedBox(height: 14),
        Text(
          'Accesos rápidos',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _quickAction(
              'Supervisores',
              Icons.groups_rounded,
              () => setState(() => _selectedIndex = 4),
            ),
            _quickAction(
              'Asignar visita',
              Icons.assignment_rounded,
              () => setState(() => _selectedIndex = 5),
            ),
            _quickAction(
              'Reportes',
              Icons.bar_chart_rounded,
              () => setState(() => _selectedIndex = 6),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickAction(String label, IconData icon, VoidCallback onPressed) {
    return ActionChip(
      avatar: Icon(icon, size: 17, color: AppColors.primary),
      label: Text(label),
      onPressed: onPressed,
      backgroundColor: Colors.white,
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.m),
      ),
    );
  }

  Widget _visitsView() {
    final visits = widget.repository.visits;
    final supervisors = widget.repository.users
        .where((user) => user.role == UserRole.supervisor)
        .toList();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          '${visits.length} visitas programadas',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _visitFilter,
              decoration: const InputDecoration(labelText: 'Filtrar estado'),
              items: const ['Todas', 'Pendiente', 'En curso', 'Realizada', 'Bloqueada']
                  .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _visitFilter = value ?? 'Todas'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _visitSupervisorFilter,
              decoration: const InputDecoration(labelText: 'Filtrar supervisor'),
              items: [
                const DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                ...supervisors.map(
                  (user) => DropdownMenuItem(value: user.id, child: Text(user.name)),
                ),
              ],
              onChanged: (value) =>
                  setState(() => _visitSupervisorFilter = value ?? 'Todos'),
            ),
            TextButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _visitDateFilter ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _visitDateFilter = picked);
              },
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(
                _visitDateFilter == null
                    ? 'Filtrar por fecha'
                    : 'Fecha: ${_visitDateFilter!.day}/${_visitDateFilter!.month}/${_visitDateFilter!.year}',
              ),
            ),
            if (_visitDateFilter != null)
              TextButton(
                onPressed: () => setState(() => _visitDateFilter = null),
                child: const Text('Quitar filtro de fecha'),
              ),
            const SizedBox(height: 8),
          ],
        ),
        ...visits.where((visit) {
          final status = switch (visit.status) {
            VisitStatus.planned => 'Pendiente',
            VisitStatus.inProgress => 'En curso',
            VisitStatus.completed => 'Realizada',
            VisitStatus.blocked => 'Bloqueada',
          };
          final scheduled = visit.scheduledAt ?? visit.startTime;
          final dateMatches = _visitDateFilter == null ||
              (scheduled.year == _visitDateFilter!.year &&
                  scheduled.month == _visitDateFilter!.month &&
                  scheduled.day == _visitDateFilter!.day);
          return (_visitFilter == 'Todas' || status == _visitFilter) &&
              (_visitSupervisorFilter == 'Todos' ||
                  visit.supervisorId == _visitSupervisorFilter) &&
              dateMatches;
        }).map(
          (visit) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primarySoft,
                  child: Icon(Icons.apartment_rounded, color: AppColors.primary),
                ),
                title: Text(visit.title),
                subtitle: Text(
                  '${visit.location}\n${visit.startTime.hour.toString().padLeft(2, '0')}:${visit.startTime.minute.toString().padLeft(2, '0')} · ${visit.priority}',
                ),
                isThreeLine: true,
                onTap: () => _showVisitDetails(visit),
                trailing: StatusBadge(
                  label: switch (visit.status) {
                    VisitStatus.planned => 'Pendiente',
                    VisitStatus.inProgress => 'En curso',
                    VisitStatus.completed => 'Realizada',
                    VisitStatus.blocked => 'Bloqueada',
                  },
                  color: visit.status == VisitStatus.completed
                      ? AppColors.success
                      : AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _incidentsView() {
    final incidents = widget.repository.incidents;
    final filteredIncidents = incidents.where((incident) {
      final priorityMatches = _incidentPriorityFilter == 'Todas' ||
          incident.priority == _incidentPriorityFilter;
      final status = _incidentStatusLabel(incident.status);
      final statusMatches = _incidentStatusFilter == 'Todos' ||
          status == _incidentStatusFilter;
      return priorityMatches && statusMatches;
    });
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          '${incidents.length} novedades registradas',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _incidentPriorityFilter,
                decoration: const InputDecoration(labelText: 'Prioridad'),
                items: const ['Todas', 'Alta', 'Media', 'Baja']
                    .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (value) => setState(() => _incidentPriorityFilter = value ?? 'Todas'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _incidentStatusFilter,
                decoration: const InputDecoration(labelText: 'Estado'),
                items: const ['Todos', 'Abierta', 'En revisión', 'Cerrada']
                    .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (value) => setState(() => _incidentStatusFilter = value ?? 'Todos'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...filteredIncidents.map(
          (incident) => Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.linea)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          incident.title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      HazardTag(priority: incident.priority),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    incident.details,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          incident.location,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      StatusPill(
                        label: _incidentStatusLabel(incident.status),
                        color: incident.status == IncidentStatus.closed
                            ? AppColors.verde
                            : AppColors.dotacion,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (incident.coordinatorComment.isNotEmpty)
                    Text('Comentario: ${incident.coordinatorComment}'),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _manageIncident(incident),
                      icon: const Icon(Icons.edit_note_rounded),
                      label: const Text('Gestionar'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _mapView() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Mapa de supervisión',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: SizedBox(
            height: (MediaQuery.sizeOf(context).height * 0.42)
                .clamp(280.0, 360.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.l),
              child: Container(
                color: const Color(0xFFEFF8FF),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: _RoadPainter()),
                    ),
                    ...[
                      (
                        point: const Alignment(-0.65, -0.32),
                        label: 'Ana Gómez',
                        color: AppColors.primary,
                      ),
                      (
                        point: const Alignment(0.42, 0.38),
                        label: 'Luis Ortega',
                        color: AppColors.success,
                      ),
                      (
                        point: const Alignment(0.72, -0.58),
                        label: 'Plaza Norte',
                        color: AppColors.warning,
                      ),
                    ].map(
                      (marker) => Align(
                        alignment: marker.point,
                        child: Tooltip(
                          message: marker.label,
                          child: Semantics(
                            label: '${marker.label}, ubicación activa',
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: marker.color,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.person_pin_circle_rounded,
                                color: marker.color,
                                size: 25,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          _MapLegendItem(
                            label: 'Supervisor',
                            color: AppColors.primary,
                          ),
                          _MapLegendItem(
                            label: 'En operación',
                            color: AppColors.success,
                          ),
                          _MapLegendItem(
                            label: 'Atención',
                            color: AppColors.warning,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _supervisorsView() {
    final supervisors = widget.repository.users
        .where((user) => user.role == UserRole.supervisor)
        .toList();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Supervisores',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        ...supervisors.map(
          (supervisor) => AppCard(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
              title: Text(supervisor.name),
              subtitle: Text(supervisor.region),
              trailing: StatusBadge(
                label: '${supervisor.score}%',
                color: AppColors.success,
                background: AppColors.successSoft,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'Crear supervisor',
          icon: Icons.person_add_alt_1_rounded,
          onPressed: _createSupervisor,
        ),
      ],
    );
  }

  Widget _assignmentsView() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Asignaciones',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        ...widget.repository.assignments.map((assignment) {
          final supervisor = widget.repository.userById(
            assignment.supervisorId,
          );
          final costCenter = widget.repository.costCenters
              .where((item) => item.id == assignment.costCenterId)
              .firstOrNull;
          return AppCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Visita: ${assignment.visitId}',
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Supervisor: ${supervisor?.name ?? 'Sin asignar'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Centro: ${costCenter?.name ?? 'No definido'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  StatusBadge(
                    label: assignment.status,
                    color: AppColors.primary,
                    background: AppColors.primarySoft,
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 18),
        PrimaryButton(
          label: 'Asignar visita',
          icon: Icons.assignment_rounded,
          onPressed: _createVisit,
        ),
      ],
    );
  }

  Widget _reportsView() {
    final satisfaction = widget.repository.satisfaction;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Reportes y satisfacción',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        ...satisfaction.map(
          (item) => AppCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Visita ${item.visitId}',
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (index) => Icon(
                          index < item.score
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: AppColors.warning,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.comment,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        PrimaryButton(
          label: 'Exportar reporte',
          icon: Icons.download_rounded,
          onPressed: _exportVisits,
        ),
      ],
    );
  }

  Future<void> _exportVisits() async {
    String cell(Object? value) =>
        '"${(value?.toString() ?? '').replaceAll('"', '""')}"';
    final rows = <String>[
      ['Centro de costo', 'Supervisor', 'Estado', 'Programada', 'Llegada', 'Salida', 'Distancia m', 'Dentro de rango', 'Cumplimiento %']
          .map(cell)
          .join(','),
      ...widget.repository.visits.map((visit) {
        final supervisor = widget.repository.userById(visit.supervisorId);
        final marked = visit.checklist.where(
          (item) => item.result != ChecklistResult.sinMarcar,
        );
        final rate = marked.isEmpty
            ? 0
            : (marked.where((item) => item.result == ChecklistResult.cumple).length *
                    100 /
                    marked.length)
                .round();
        return [
          visit.title,
          supervisor?.name,
          switch (visit.status) {
            VisitStatus.planned => 'Pendiente',
            VisitStatus.inProgress => 'En curso',
            VisitStatus.completed => 'Realizada',
            VisitStatus.blocked => 'Bloqueada',
          },
          visit.scheduledAt,
          visit.checkInAt,
          visit.checkOutAt,
          visit.distanceMeters?.round(),
          visit.inRange == null ? '' : visit.inRange! ? 'Sí' : 'No',
          '$rate%',
        ].map(cell).join(',');
      }),
    ];
    try {
      final file = File('${Directory.systemTemp.path}/suthon-historial-visitas.csv');
      await file.writeAsString(rows.join('\r\n'));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Historial compatible con Excel guardado en ${file.path}')),
        );
      }
    } on FileSystemException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No fue posible exportar el historial: ${error.message}')),
        );
      }
    }
  }

  String _incidentStatusLabel(IncidentStatus status) => switch (status) {
    IncidentStatus.open => 'Abierta',
    IncidentStatus.inReview => 'En revisión',
    IncidentStatus.closed => 'Cerrada',
  };
}

class _RoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD7E6F8)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.08, size.height * 0.8)
      ..lineTo(size.width * 0.2, size.height * 0.62)
      ..lineTo(size.width * 0.42, size.height * 0.58)
      ..lineTo(size.width * 0.69, size.height * 0.3)
      ..lineTo(size.width * 0.88, size.height * 0.43)
      ..lineTo(size.width * 0.96, size.height * 0.24);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapLegendItem extends StatelessWidget {
  const _MapLegendItem({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: color, size: 10),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

extension _IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
