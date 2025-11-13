import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/config/app_config.dart';
import 'core/config/route_name.dart';
import 'core/dependency/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize dependencies
  await initDependencies();

  // Log app startup
  AppLogger.info('🎉 Starting ${AppConfig.appName}...');
  AppLogger.info('📱 Environment: ${AppConfig.environment}');
  AppLogger.info('🌐 Base URL: ${AppConfig.baseUrl}');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      
      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // Routing
      initialRoute: RouteName.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
      
      // Builder for error handling
      builder: (context, child) {
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
