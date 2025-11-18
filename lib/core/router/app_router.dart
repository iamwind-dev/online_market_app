import 'package:flutter/material.dart';
import '../config/route_name.dart';
import '../../feature/splash/presentation/screen/splash_page.dart';
import '../../feature/login/presentation/screen/login_page.dart';
import '../../feature/signup/presentation/screen/signup_page.dart';
import '../../feature/home/presentation/screen/home_screen.dart';
import '../../feature/product/presentation/screen/product_screen.dart';
import '../../feature/productdetail/presentation/screen/productdetail_screen.dart';
import '../../feature/menudetail/presentation/screen/menudetail_screen.dart';
import '../../feature/user/presentation/screen/user_screen.dart';
import '../../feature/review/presentation/screen/review_page.dart';
import '../../feature/cart/presentation/screen/cart_page.dart';
import '../../feature/payment/presentation/screen/payment_page.dart';
import '../../feature/order/presentation/order_detail/screen/order_detail_page.dart';
import '../../feature/order/presentation/order/screen/order_page.dart';
import '../../feature/search/presentation/screen/search_screen.dart';
import '../../feature/product/presentation/screen/category_product_screen.dart';

/// Quản lý navigation và routing của ứng dụng
/// Sử dụng onGenerateRoute để tạo route động
class AppRouter {
  AppRouter._();

  /// Generate route based on route settings
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.splash:
        return _buildRoute(
          settings,
          const SplashPage(),
        );

      case RouteName.home:
        return _buildRoute(
          settings,
          const HomeScreen(),
        );

      case RouteName.login:
        return _buildRoute(
          settings,
          const LoginPage(),
        );

      case RouteName.register:
        return _buildRoute(
          settings,
          const SignUpPage(),
        );

      case RouteName.productList:
        return _buildRoute(
          settings,
          const ProductScreen(),
        );

      case RouteName.productDetail:
        return _buildRoute(
          settings,
          const ProductDetailScreen(),
        );

      case RouteName.menuDetail:
        return _buildRoute(
          settings,
          const MenuDetailScreen(),
        );

      case RouteName.user:
        return _buildRoute(
          settings,
          const UserScreen(),
        );

      case RouteName.reviews:
        return _buildRoute(
          settings,
          const ReviewPage(),
        );

      case RouteName.cart:
        return _buildRoute(
          settings,
          const CartPage(),
        );

      case RouteName.checkout:
        return _buildRoute(
          settings,
          const PaymentPage(),
        );

      case RouteName.orderDetail:
        return _buildRoute(
          settings,
          OrderDetailPage(
            orderId: settings.arguments as String?,
          ),
        );

      case RouteName.orderList:
        return _buildRoute(
          settings,
          const OrderPage(),
        );

      case RouteName.search:
        return _buildRoute(
          settings,
          const SearchScreen(),
        );

      case RouteName.categoryProducts:
        final args = settings.arguments as Map<String, String>?;
        return _buildRoute(
          settings,
          CategoryProductScreen(
            categoryId: args?['categoryId'] ?? '',
            categoryName: args?['categoryName'] ?? 'Danh mục',
          ),
        );

      case RouteName.profile:
        return _buildRoute(
          settings,
          const _PlaceholderScreen(title: 'Profile Screen'),
        );

      default:
        return _buildRoute(
          settings,
          const _NotFoundScreen(),
        );
    }
  }

  /// Build MaterialPageRoute with settings
  static MaterialPageRoute _buildRoute(
    RouteSettings settings,
    Widget page,
  ) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }

  /// Navigate to named route
  static Future<T?> navigateTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate to named route and remove all previous routes
  static Future<T?> navigateAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Navigate to named route and replace current route
  static Future<T?> navigateAndReplace<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, void>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Go back to previous route
  static void goBack(BuildContext context, {Object? result}) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, result);
    }
  }
}

/// Placeholder screen for development
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => AppRouter.goBack(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Screen hiển thị khi không tìm thấy route
class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('404'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy trang',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => AppRouter.goBack(context),
              icon: const Icon(Icons.home),
              label: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    );
  }
}
