import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'core/di/service_locator.dart';
import 'core/l10n/app_localizations.dart';
import 'features/settings/controllers/settings_controller.dart';

void main() {
  runZonedGuarded(() async {
    // Initialize flutter engine
    WidgetsFlutterBinding.ensureInitialized();

    // Setup dependency injection
    await setupServiceLocator();

    // Set fullscreen mode
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Configure overlay style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),);

    runApp(const GreenHealerApp());
  }, (error, stack) {
    // Log fatal errors
    debugPrint('Fatal error: $error\n$stack');
  });
}

class GreenHealerApp extends StatelessWidget {
  const GreenHealerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get settings controller
    final settingsController = getIt<SettingsController>();

    // Build reactive material app
    return ListenableBuilder(
      listenable: settingsController,
      builder: (context, child) {
        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: settingsController.themeMode,
          locale: settingsController.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          initialRoute: AppRoutes.splash,
          routes: AppRoutes.getRoutes(),
        );
      },
    );
  }
}