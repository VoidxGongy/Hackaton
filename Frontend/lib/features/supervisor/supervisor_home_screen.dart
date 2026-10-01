import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supervisacampo/app/routes.dart';
import 'package:supervisacampo/core/models/app_models.dart';
import 'package:supervisacampo/core/repositories/visits_repository.dart';
import 'package:supervisacampo/core/theme/app_theme.dart';
import 'package:supervisacampo/core/widgets/design_system.dart';

class SupervisorHomeScreen extends StatefulWidget {
  const SupervisorHomeScreen({super.key, required this.repository});

  final VisitsRepository repository;

  @override
  State<SupervisorHomeScreen> createState() => _SupervisorHomeScreenState();
}

class _SupervisorHomeScreenState extends State<SupervisorHomeScreen> {
  int _selectedIndex = 0;
  bool _showAllVisits = false;
  bool _isSyncing = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      if (!results.contains(ConnectivityResult.none) &&
          widget.repository.pendingSyncCount > 0) {
        _syncPending();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _syncPending() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    await widget.repository.syncPending();
    if (mounted) setState(() => _isSyncing = false);
  }

  List<({IconData icon, String label})> get _items => const [
    (icon: Icons.calendar_month_rounded, label: 'Visitas'),
    (icon: Icons.warning_amber_rounded, label: 'Novedades'),
    (icon: Icons.cloud_queue_rounded, label: 'Pendientes'),
    (icon: Icons.person_rounded, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    final supervisorId = widget.repository.currentUser?.id;
    final visits = widget.repository.visits
        .where((visit) => visit.supervisorId == supervisorId)
        .toList();
    final visitIds = visits.map((visit) => visit.id).toSet();
    final incidents = widget.repository.incidents
        .where((incident) => visitIds.contains(incident.visitId))
        .toList();
    final notifications = widget.repository.notifications;

    final body = switch (_selectedIndex) {
      0 =>
        _showAllVisits
            ? _visitsView(visits)
            : _dashboardView(visits, incidents, notifications),
      1 => _incidentsView(incidents),
      2 => _syncView(),
      _ => _profileView(),
    };

    return Scaffold(
      appBar: _selectedIndex == 0
          ? null
          : AppBar(
              title: Text(_items[_selectedIndex].label),
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
        currentIndex: _selectedIndex,
        onItemTapped: (value) => setState(() {
          _selectedIndex = value;
          _showAllVisits = false;
        }),
        items: _items,
      ),
    );
  }

  Widget _dashboardView(
    List<Visit> visits,
    List<Incident> incidents,
    List<NotificationItem> notifications,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
            decoration: const BoxDecoration(
              color: AppColors.baldosa,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Buenos días, ${widget.repository.currentUser?.name ?? 'supervisor'}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: AppColors.dotacion,
                      child: Text(
                        (widget.repository.currentUser?.name ?? 'S')
                            .split(' ')
                            .take(2)
                            .map(
                              (part) =>
                                  part.isEmpty ? '' : part[0].toUpperCase(),
                            )
                            .join(),
                        style: const TextStyle(
                          color: AppColors.papel,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 15,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StreamBuilder<List<ConnectivityResult>>(
                      stream: Connectivity().onConnectivityChanged,
                      initialData: const [ConnectivityResult.wifi],
                      builder: (context, snapshot) {
                        final offline =
                            snapshot.data?.contains(ConnectivityResult.none) ??
                            false;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 9,
                              color: offline
                                ? AppColors.tinta
                                  : AppColors.success,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              offline ? 'Sin conexión' : 'En línea',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.m),
                        onTap: () => setState(() => _selectedIndex = 2),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 7,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.cloud_queue_rounded,
                                size: 17,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  '${widget.repository.pendingSyncCount} pendientes por sincronizar',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(color: AppColors.dotacion),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Visitas del día',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      '${visits.length} programadas',
                      style: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => setState(() => _showAllVisits = true),
                    child: const Text('Ver todas'),
                  ),
                ),
                const SizedBox(height: 11),
                if (visits.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Text(
                      'No tienes visitas asignadas hoy. Cuando el coordinador te asigne una, aparecerá aquí.',
                    ),
                  )
                else
                  ...visits.map(
                    (visit) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _visitCard(visit),
                    ),
                  ),
                if (incidents.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Novedades recientes',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _selectedIndex = 1),
                        child: const Text('Ver todas'),
                      ),
                    ],
                  ),
                  Text(
                    '${incidents.length} novedades requieren seguimiento',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
                if (notifications.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    notifications.first.title,
                    style: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _visitsView(List<Visit> visits) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Visitas del día',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _showAllVisits = false),
              child: const Text('Resumen'),
            ),
          ],
        ),
        ...visits.map(
          (visit) => Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _visitCard(visit),
          ),
        ),
      ],
    );
  }

  Widget _visitCard(Visit visit) {
    final center = widget.repository.costCenterForVisit(visit.id);
    return VisitTicket(
      visit: visit,
      centerName: center?.name,
      onTap: () => context.push('${AppRoutes.supervisorVisit}/${visit.id}'),
    );
  }

  Widget _incidentsView(List<Incident> incidents) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Novedades',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              onPressed: () => context.push('/supervisor/incident'),
              icon: const Icon(Icons.add_circle_outline_rounded),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...incidents.map(
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
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      HazardTag(
                        priority: incident.priority,
                        label: 'Prioridad ${incident.priority.toLowerCase()}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  StatusPill(
                    label: switch (incident.status) {
                      IncidentStatus.open => 'Abierta',
                      IncidentStatus.inReview => 'En revisión',
                      IncidentStatus.closed => 'Cerrada',
                    },
                    color: incident.status == IncidentStatus.closed
                        ? AppColors.verde
                        : AppColors.dotacion,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    incident.details,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
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
                          incident.location,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      if (incident.status != IncidentStatus.closed)
                        TextButton(
                          onPressed: () {
                            widget.repository.updateIncident(
                              incident.id,
                              status: IncidentStatus.closed,
                            );
                            setState(() {});
                          },
                          child: const Text('Resolver'),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _syncView() {
    final syncs = widget.repository.syncRecords;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Sincronización',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        ...syncs.map(
          (sync) => Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.linea)),
            ),
            child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sync.name,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sync.timestamp,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        if (sync.error != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            sync.error!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.danger),
                          ),
                        ],
                      ],
                    ),
                  ),
                  StatusBadge(
                    label: sync.status,
                    color: sync.status == 'Sincronizado'
                        ? AppColors.success
                        : sync.status == 'Error'
                            ? AppColors.danger
                            : AppColors.warning,
                    background: sync.status == 'Sincronizado'
                        ? AppColors.successSoft
                        : sync.status == 'Error'
                            ? AppColors.dangerSoft
                            : AppColors.warningSoft,
                  ),
                  if (sync.status == 'Error')
                    TextButton(
                      onPressed: _syncPending,
                      child: const Text('Reintentar'),
                    ),
                ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        PrimaryButton(
          label: 'Sincronizar ahora',
          icon: Icons.sync_rounded,
          isLoading: _isSyncing,
          onPressed: _syncPending,
        ),
      ],
    );
  }

  Widget _profileView() {
    final user = widget.repository.currentUser;
    final userVisits = widget.repository.visits
        .where((visit) => visit.supervisorId == user?.id)
        .toList();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primarySoft,
                  child: Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.name ?? 'Supervisor',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Supervisor · ${user?.region ?? 'Barranquilla'}',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    StatusBadge(
                      label: 'Rendimiento ${user?.score ?? 0}%',
                      color: AppColors.success,
                      background: AppColors.successSoft,
                    ),
                    StatusBadge(
                      label: '${userVisits.length} visitas asignadas',
                      color: AppColors.primary,
                      background: AppColors.primarySoft,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Acciones rápidas',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        _actionTile(
          icon: Icons.qr_code_rounded,
          label: 'Escaneo QR',
          description: 'Preparado para lectura de códigos',
        ),
        _actionTile(
          icon: Icons.location_on_outlined,
          label: 'GPS',
          description: 'Ubicación validada al registrar cada visita',
        ),
        _actionTile(
          icon: Icons.photo_camera_outlined,
          label: 'Evidencias',
          description: 'Adjuntar fotos con respaldo local',
        ),
        const SizedBox(height: 18),
        PrimaryButton(
          label: 'Cerrar sesión',
          icon: Icons.logout_rounded,
          onPressed: () {
            widget.repository.logout();
            context.go(AppRoutes.login);
          },
        ),
      ],
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
