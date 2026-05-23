import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/map/presentation/map_screen.dart';
import 'go_router_refresh_stream.dart';

class AppRouter {
  final AuthCubit authCubit;
  AppRouter(this.authCubit);

  late final GoRouter router = GoRouter(
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    
    initialLocation: '/login',
    redirect: (context, state) {
      final authState = authCubit.state;
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToRegister = state.matchedLocation == '/register';
      if (authState is AuthUnauthenticated || authState is AuthInitial) {
        if (isGoingToLogin || isGoingToRegister) return null;
        return '/login';
      } 
      if (authState is AuthAuthenticated) {
        if (isGoingToLogin || isGoingToRegister) return '/map';
      }
      return null;
    },
    
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => const MapScreen(),
      ),
    ],
  );
}