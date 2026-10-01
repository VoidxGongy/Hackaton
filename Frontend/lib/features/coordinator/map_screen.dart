import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supervisacampo/core/models/app_models.dart';
import 'package:supervisacampo/core/repositories/visits_repository.dart';
import 'package:supervisacampo/core/theme/app_theme.dart';
import 'package:supervisacampo/core/widgets/design_system.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key, required this.repository});

  final VisitsRepository repository;

  @override
  Widget build(BuildContext context) {
    final visits = repository.visits;
    final centers = repository.costCenters;
    final firstCenter = centers.isEmpty ? null : centers.first;
    final activeVisit = visits.where((item) => item.status == VisitStatus.inProgress).firstOrNull;
    final mapCenter = firstCenter == null
        ? const LatLng(DemoCoordinates.latitude, DemoCoordinates.longitude)
        : LatLng(firstCenter.lat, firstCenter.lng);

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa operativo')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 380 ? 16.0 : 20.0;
            final mapHeight = (constraints.maxHeight * 0.58).clamp(
              220.0,
              420.0,
            );
            return AnimatedPageContainer(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(horizontalPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: mapHeight,
                      child: AppCard(
                        padding: EdgeInsets.zero,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.l),
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: mapCenter,
                              initialZoom: 13,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName:
                                    'com.example.supervisacampo',
                              ),
                              MarkerLayer(
                                markers: [
                                  for (final center in centers)
                                    Marker(
                                      point: LatLng(center.lat, center.lng),
                                      width: 44,
                                      height: 52,
                                      child: Tooltip(
                                        message: '${center.name} · Centro de costo',
                                        child: const Icon(
                                          Icons.location_on,
                                          color: AppColors.warning,
                                          size: 34,
                                        ),
                                      ),
                                    ),
                                  for (final visit in visits)
                                    if (visit.checkInLat != null &&
                                        visit.checkInLng != null)
                                      Marker(
                                        point: LatLng(
                                          visit.checkInLat!,
                                          visit.checkInLng!,
                                        ),
                                        width: 44,
                                        height: 52,
                                        child: Tooltip(
                                          message:
                                              '${repository.userById(visit.supervisorId)?.name ?? 'Supervisor'} · ${visit.inRange == true ? 'Dentro de rango' : 'Fuera de rango'}',
                                          child: Icon(
                                            Icons.person_pin_circle_rounded,
                                            color: visit.inRange == true
                                                ? AppColors.success
                                                : AppColors.danger,
                                            size: 34,
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                              RichAttributionWidget(
                                attributions: [
                                  TextSourceAttribution('OpenStreetMap'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppCard(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.primarySoft,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_pin_circle_outlined,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activeVisit == null
                                      ? 'Visitas registradas'
                                      : 'Visita activa',
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  activeVisit?.title ??
                                      (visits.isEmpty
                                          ? 'Aún no hay visitas'
                                          : '${visits.length} visitas en seguimiento'),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge(
                            label: activeVisit == null
                                ? 'Centros'
                                : activeVisit.inRange == true
                                    ? 'En rango'
                                    : 'Fuera de rango',
                            color: activeVisit?.inRange == true
                                ? AppColors.success
                                : AppColors.warning,
                            background: activeVisit?.inRange == true
                                ? AppColors.successSoft
                                : AppColors.warningSoft,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
