import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supervisacampo/app/router.dart';
import 'package:supervisacampo/core/theme/app_theme.dart';

class SupervisaCampoApp extends ConsumerWidget {
  const SupervisaCampoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      initialData: const [ConnectivityResult.wifi],
      builder: (context, snapshot) {
        final isOffline =
            snapshot.data?.contains(ConnectivityResult.none) ?? false;
        return MaterialApp.router(
          title: 'Suthon',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          routerConfig: router,
          builder: (context, child) {
            final appContent = Stack(
              children: [
                ?child,
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: isOffline
                          ? Container(
                              key: const ValueKey('offline-banner'),
                              color: Colors.amber.shade100,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              alignment: Alignment.center,
                              child: const Text('Sin conexión temporal'),
                            )
                          : const SizedBox.shrink(
                              key: ValueKey('online-banner'),
                            ),
                    ),
                  ),
                ),
              ],
            );

            if (defaultTargetPlatform == TargetPlatform.linux) {
              final screenSize = MediaQuery.sizeOf(context);
              return ColoredBox(
                color: const Color(0xFFE9EDF3),
                child: Center(
                  child: Container(
                    width: screenSize.width < 430 ? screenSize.width : 430,
                    height: screenSize.height,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: appContent,
                  ),
                ),
              );
            }

            return appContent;
          },
        );
      },
    );
  }
}
