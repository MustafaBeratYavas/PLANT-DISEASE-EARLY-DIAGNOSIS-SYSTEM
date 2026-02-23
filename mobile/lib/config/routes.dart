import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../features/main/screens/main_wrapper_screen.dart';
import '../../features/settings/controllers/settings_controller.dart';
import '../../features/splash/screens/splash_screen.dart';

class AppRoutes {
  // Route path constants
  static const String splash = '/';
  static const String main = '/main';

  // Build navigation map
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      main: (context) => MainWrapperScreen(settingsController: getIt<SettingsController>()),
    };
  }
}