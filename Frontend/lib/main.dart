import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supervisacampo/app/app.dart';
import 'package:supervisacampo/features/auth/login_screen.dart';
import 'package:supervisacampo/core/repositories/mock_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final storage = await Hive.openBox<dynamic>('suthon_offline');
  final repository = MockRepository(storage: storage);
  runApp(
    ProviderScope(
      overrides: [mockRepositoryProvider.overrideWithValue(repository)],
      child: const SupervisaCampoApp(),
    ),
  );
}
