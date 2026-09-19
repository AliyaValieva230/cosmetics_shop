import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../state/auth_notifier.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/catalog_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/product_form_screen.dart';
import '../screens/access_denied_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/manager/product_manage_screen.dart';
import '../screens/manager/order_manage_screen.dart';
import '../screens/admin/user_manage_screen.dart';

final router = GoRouter(
  initialLocation: '/catalog',
  redirect: (context, state) {
    final auth = context.read<AuthNotifier>();
    final logged = auth.isLoggedIn;
    final role = auth.role;
    final path = state.matchedLocation;

    final publicRoutes = ['/login', '/register'];
    final isPublic = publicRoutes.contains(path);

    if (!logged && !isPublic) return '/login';
    if (logged && isPublic) return '/catalog';

    if (path.startsWith('/manager') && !(role == 'manager' || role == 'admin')) {
      return '/access-denied';
    }
    if (path.startsWith('/admin') && role != 'admin') {
      return '/access-denied';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/catalog', builder: (_, __) => const CatalogScreen()),
    GoRoute(
      path: '/product/:id',
      builder: (_, s) => ProductDetailScreen(id: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/product-form',
      builder: (_, s) => ProductFormScreen(productId: s.uri.queryParameters['id']),
    ),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/access-denied', builder: (_, __) => const AccessDeniedScreen()),
    GoRoute(path: '/manager/products', builder: (_, __) => const ProductManageScreen()),
    GoRoute(path: '/manager/orders', builder: (_, __) => const OrderManageScreen()),
    GoRoute(path: '/admin/users', builder: (_, __) => const UserManageScreen()),
  ],
);