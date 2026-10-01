import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supervisacampo/app/routes.dart';
import 'package:supervisacampo/core/models/app_models.dart';
import 'package:supervisacampo/core/theme/app_theme.dart';
import 'package:supervisacampo/features/auth/login_screen.dart';
import 'package:supervisacampo/features/coordinator/coordinator_home_screen.dart';
import 'package:supervisacampo/features/coordinator/map_screen.dart';
import 'package:supervisacampo/features/supervisor/supervisor_home_screen.dart';
import 'package:supervisacampo/features/supervisor/supervisor_incident_screen.dart';
import 'package:supervisacampo/features/supervisor/visit_detail_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final repository = ref.read(mockRepositoryProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final user = repository.currentUser;
      final location = state.matchedLocation;
      if (user == null) {
        return location == AppRoutes.login ? null : AppRoutes.login;
      }

      final home = user.role == UserRole.supervisor
          ? AppRoutes.supervisor
          : AppRoutes.coordinator;
      if (location == AppRoutes.login) {
        return home;
      }
      final isSupervisorRoute =
          location == AppRoutes.supervisor ||
          location.startsWith('${AppRoutes.supervisorVisit}/') ||
          location == AppRoutes.supervisorIncident;
      final isCoordinatorRoute =
          location == AppRoutes.coordinator ||
          location == AppRoutes.coordinatorMap;
      if ((user.role == UserRole.supervisor && isCoordinatorRoute) ||
          (user.role == UserRole.coordinator && isSupervisorRoute)) {
        return home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => _buildPage(state, const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.supervisor,
        pageBuilder: (context, state) =>
            _buildPage(state, SupervisorHomeScreen(repository: repository)),
      ),
      GoRoute(
        path: '${AppRoutes.supervisorVisit}/:visitId',
        pageBuilder: (context, state) {
          final visitId = state.pathParameters['visitId'] ?? '';
          return _buildPage(
            state,
            VisitDetailScreen(visitId: visitId, repository: repository),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.supervisorIncident,
        pageBuilder: (context, state) =>
            _buildPage(state, SupervisorIncidentScreen(repository: repository)),
      ),
      GoRoute(
        path: AppRoutes.coordinator,
        pageBuilder: (context, state) =>
            _buildPage(state, CoordinatorHomeScreen(repository: repository)),
      ),
      GoRoute(
        path: AppRoutes.coordinatorMap,
        pageBuilder: (context, state) =>
            _buildPage(state, MapScreen(repository: repository)),
      ),
    ],
  );
});

CustomTransitionPage<void> _buildPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: AppMotion.standard,
    reverseTransitionDuration: AppMotion.standard,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.disableAnimationsOf(context)) {
        return child;
      }

      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.curve,
        reverseCurve: Curves.easeInOut,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.025, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
