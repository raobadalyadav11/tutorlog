import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'services/firebase_service.dart';
import 'services/local_storage_service.dart';
import 'services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  await LocalStorageService.initialize();
  await SyncService.initialize();
  runApp(const ProviderScope(child: TutorLogApp()));
}

class TutorLogApp extends StatelessWidget {
  const TutorLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TutorLog',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
