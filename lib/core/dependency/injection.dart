import 'package:get_it/get_it.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../utils/app_logger.dart';

/// Dependency Injection Container
/// Sử dụng GetIt để quản lý dependencies
final getIt = GetIt.instance;

/// Initialize all dependencies
Future<void> initDependencies() async {
  AppLogger.info('🚀 Initializing dependencies...');

  // ==================== Services ====================
  
  // Local Storage Service - Singleton
  final localStorageService = LocalStorageService();
  await localStorageService.init();
  getIt.registerSingleton<LocalStorageService>(localStorageService);
  AppLogger.info('✅ LocalStorageService registered');

  // API Service - Singleton
  getIt.registerLazySingleton<ApiService>(
    () => ApiService(getIt<LocalStorageService>()),
  );
  AppLogger.info('✅ ApiService registered');

  // ==================== Repositories ====================
  // Register repositories here when created
  // Example:
  // getIt.registerLazySingleton<AuthRepository>(
  //   () => AuthRepositoryImpl(getIt<ApiService>()),
  // );

  // ==================== Use Cases / Interactors ====================
  // Register use cases here when created
  // Example:
  // getIt.registerLazySingleton<LoginUseCase>(
  //   () => LoginUseCase(getIt<AuthRepository>()),
  // );

  // ==================== BLoCs / Cubits ====================
  // Register BLoCs/Cubits as factories (new instance each time)
  // Example:
  // getIt.registerFactory<AuthBloc>(
  //   () => AuthBloc(
  //     loginUseCase: getIt<LoginUseCase>(),
  //     logoutUseCase: getIt<LogoutUseCase>(),
  //   ),
  // );

  AppLogger.info('✅ All dependencies initialized successfully');
}

/// Clear all dependencies (useful for testing)
Future<void> clearDependencies() async {
  await getIt.reset();
  AppLogger.info('🧹 All dependencies cleared');
}

/// Check if a dependency is registered
bool isDependencyRegistered<T extends Object>() {
  return getIt.isRegistered<T>();
}

/// Get a registered dependency
T getDependency<T extends Object>() {
  return getIt<T>();
}

/// Unregister a specific dependency
void unregisterDependency<T extends Object>() {
  if (isDependencyRegistered<T>()) {
    getIt.unregister<T>();
    AppLogger.info('🗑️ ${T.toString()} unregistered');
  }
}
