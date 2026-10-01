import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supervisacampo/app/routes.dart';
import 'package:supervisacampo/core/models/app_models.dart';
import 'package:supervisacampo/core/repositories/mock_repository.dart';
import 'package:supervisacampo/core/theme/app_theme.dart';
import 'package:supervisacampo/core/widgets/design_system.dart';

final mockRepositoryProvider = Provider<MockRepository>(
  (ref) => MockRepository(),
);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _error;
  bool _isLoading = false;
  late final AnimationController _wordmarkController;
  late final Animation<double> _wordmarkReveal;

  @override
  void initState() {
    super.initState();
    _wordmarkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _wordmarkReveal = CurvedAnimation(
      parent: _wordmarkController,
      curve: Curves.easeOutCubic,
    );
    _wordmarkController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _wordmarkController.value = 1;
    }
  }

  Future<void> _submit(MockRepository repository) async {
    if (!_formKey.currentState!.validate() || _isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) {
      return;
    }

    final user = repository.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    setState(() => _isLoading = false);
    if (user == null) {
      setState(
        () => _error =
            'Correo o contraseña incorrectos. Revísalos e intenta de nuevo.',
      );
      return;
    }

    context.go(
      user.role == UserRole.supervisor
          ? AppRoutes.supervisor
          : AppRoutes.coordinator,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _wordmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = ref.read(mockRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.baldosa,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _TileGridPainter())),
            LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 36,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          AnimatedBuilder(
                            animation: _wordmarkReveal,
                            builder: (context, child) => ShaderMask(
                              blendMode: BlendMode.dstIn,
                              shaderCallback: (bounds) {
                                final reveal = _wordmarkReveal.value;
                                return LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: const [
                                    Colors.white,
                                    Colors.white,
                                    Colors.transparent,
                                    Colors.transparent,
                                  ],
                                  stops: [
                                    0,
                                    reveal,
                                    (reveal + 0.025).clamp(0, 1),
                                    1,
                                  ],
                                ).createShader(bounds);
                              },
                              child: child,
                            ),
                            child: const SuthonWordmark(fontSize: 72),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Control de visitas en campo',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.papel,
                              border: Border.all(color: AppColors.linea),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Iniciar sesión',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge,
                                  ),
                                  const SizedBox(height: 18),
                                  AppTextField(
                                    label: 'Correo electrónico',
                                    hint: 'usuario@empresa.com',
                                    controller: _emailController,
                                    prefixIcon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Ingresa tu correo.';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Ingresa un correo válido.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  AppTextField(
                                    label: 'Contraseña',
                                    hint: 'Ingresa tu contraseña',
                                    controller: _passwordController,
                                    prefixIcon: Icons.lock_outline_rounded,
                                    obscureText: true,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _submit(repository),
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                            ? 'Ingresa tu contraseña.'
                                            : null,
                                  ),
                                  if (_error != null) ...[
                                    const SizedBox(height: 14),
                                    ErrorState(message: _error!),
                                  ],
                                  const SizedBox(height: 18),
                                  PrimaryButton(
                                    label: 'Ingresar',
                                    icon: Icons.login_rounded,
                                    isLoading: _isLoading,
                                    onPressed: () => _submit(repository),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            'Versión 1.0 · Acceso de demostración',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TileGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const tileSize = 28.0;
    final paint = Paint()
      ..color = AppColors.linea.withValues(alpha: 0.4)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += tileSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += tileSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TileGridPainter oldDelegate) => false;
}
