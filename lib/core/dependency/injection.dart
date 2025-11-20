import 'package:get_it/get_it.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../services/auth/auth_service.dart';
import '../services/category_service.dart';
import '../services/mon_an_service.dart';
import '../services/nguyen_lieu_service.dart';
import '../services/gian_hang_service.dart';
import '../services/danh_muc_nguyen_lieu_service.dart';
import '../services/navigation_state_service.dart';
import '../utils/app_logger.dart';

/// Dependency Injection Container
/// Sử dụng GetIt để quản lý dependencies
final getIt = GetIt.instance;

/// Initialize all dependencies
Future<void> initDependencies() async {
  AppLogger.info('🚀 Initializing dependencies...');

  // ==================== Services ====================
  
  // Local Storage Service - Singleton
  final localStorageService = await LocalStorageService.getInstance();
  getIt.registerSingleton<LocalStorageService>(localStorageService);
  AppLogger.info('✅ LocalStorageService registered');

  // API Service - Singleton
  getIt.registerLazySingleton<ApiService>(
    () => ApiService(getIt<LocalStorageService>()),
  );
  AppLogger.info('✅ ApiService registered');

  // Auth Service - Singleton
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(localStorage: getIt<LocalStorageService>()),
  );
  AppLogger.info('✅ AuthService registered');

  // Category Service - Singleton
  getIt.registerLazySingleton<CategoryService>(
    () => CategoryService(),
  );
  AppLogger.info('✅ CategoryService registered');

  // MonAn Service - Singleton
  getIt.registerLazySingleton<MonAnService>(
    () => MonAnService(),
  );
  AppLogger.info('✅ MonAnService registered');

  // NguyenLieu Service - Singleton
  getIt.registerLazySingleton<NguyenLieuService>(
    () => NguyenLieuService(),
  );
  AppLogger.info('✅ NguyenLieuService registered');

  // GianHang Service - Singleton
  getIt.registerLazySingleton<GianHangService>(
    () => GianHangService(),
  );
  AppLogger.info('✅ GianHangService registered');

  // DanhMucNguyenLieu Service - Singleton
  getIt.registerLazySingleton<DanhMucNguyenLieuService>(
    () => DanhMucNguyenLieuService(),
  );
  AppLogger.info('✅ DanhMucNguyenLieuService registered');

  // NavigationState Service - Singleton
  getIt.registerLazySingleton<NavigationStateService>(
    () => NavigationStateService(getIt<LocalStorageService>().prefs),
  );
  AppLogger.info('✅ NavigationStateService registered');

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
