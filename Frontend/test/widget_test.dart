import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supervisacampo/app/app.dart';
import 'package:supervisacampo/core/models/app_models.dart';
import 'package:supervisacampo/core/repositories/mock_repository.dart';
import 'package:supervisacampo/core/widgets/design_system.dart';

void main() {
  test('demo accounts authenticate with the documented credentials', () {
    final repository = MockRepository();

    expect(
      repository.login('supervisor@demo.com', '123456')?.role,
      UserRole.supervisor,
    );
    expect(
      repository.login('coordinador@demo.com', '123456')?.role,
      UserRole.coordinator,
    );
    expect(repository.login('supervisor@demo.com', 'incorrecto'), isNull);
    expect(repository.currentUser, isNull);
  });

  testWidgets('login form renders without errors', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SupervisaCampoApp()));
    await tester.pumpAndSettle();

    expect(find.byType(SuthonWordmark), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Ingresar'), findsOneWidget);
  });

  testWidgets('login rejects invalid credentials without opening a dashboard', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: SupervisaCampoApp()));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).first,
      'supervisor@demo.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'incorrecto');
    await tester.tap(find.text('Ingresar'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Correo o contraseña incorrectos. Revísalos e intenta de nuevo.',
      ),
      findsOneWidget,
    );
    expect(find.text('Resumen del día'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('login and supervisor dashboard fit mobile widths', (
    tester,
  ) async {
    for (final width in [360.0, 375.0, 390.0, 412.0, 430.0]) {
      await tester.binding.setSurfaceSize(Size(width, 800));
      await tester.pumpWidget(
        ProviderScope(key: ValueKey(width), child: const SupervisaCampoApp()),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Login at $width px');
      expect(find.byType(SuthonWordmark), findsOneWidget, reason: '$width px');
      expect(find.text('Ingresar'), findsOneWidget, reason: '$width px');

      await tester.enterText(
        find.byType(TextFormField).first,
        'supervisor@demo.com',
      );
      await tester.enterText(find.byType(TextFormField).last, '123456');
      await tester.ensureVisible(find.text('Ingresar'));
      await tester.tap(find.text('Ingresar'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Dashboard at $width px');
      expect(find.text('Visitas del día'), findsOneWidget);
    }

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('animated page container respects reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: AnimatedPageContainer(child: Text('Contenido accesible')),
        ),
      ),
    );

    expect(find.text('Contenido accesible'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AnimatedPageContainer),
        matching: find.byType(FadeTransition),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byType(AnimatedPageContainer),
        matching: find.byType(SlideTransition),
      ),
      findsNothing,
    );
  });

  testWidgets('form controls remain visible with enlarged text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const AppTextField(label: 'Correo'),
                    const SizedBox(height: 16),
                    PrimaryButton(label: 'Continuar', onPressed: () {}),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Correo'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('coordinator can open the responsive monitoring map', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    await tester.pumpWidget(const ProviderScope(child: SupervisaCampoApp()));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).first,
      'coordinador@demo.com',
    );
    await tester.enterText(find.byType(TextFormField).last, '123456');
    await tester.ensureVisible(find.text('Ingresar'));
    await tester.tap(find.text('Ingresar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('visitas realizadas hoy'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Ver mapa de monitoreo'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Ver mapa de monitoreo'));
    await tester.pumpAndSettle();
    expect(find.text('Mapa operativo'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('supervisor can open a visit and return to the dashboard', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    await tester.pumpWidget(const ProviderScope(child: SupervisaCampoApp()));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).first,
      'supervisor@demo.com',
    );
    await tester.enterText(find.byType(TextFormField).last, '123456');
    await tester.tap(find.text('Ingresar'));
    await tester.pumpAndSettle();
    expect(find.text('Visitas del día'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'Supervisor home');

    await tester.ensureVisible(find.byType(VisitTicket).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(VisitTicket).first);
    await tester.pumpAndSettle();
    expect(find.text('Llegada registrada'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'Visit details');

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Visitas del día'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'Return to visits');

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'Supervisor profile');
    await tester.scrollUntilVisible(
      find.text('Cerrar sesión'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'Logout');
    await tester.binding.setSurfaceSize(null);
  });
}
