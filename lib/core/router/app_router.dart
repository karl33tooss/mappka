import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/map/presentation/map_screen.dart';
import '../../features/camera/presentation/camera_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/shell/presentation/main_scaffold.dart';
import 'go_router_refresh_stream.dart';

// Root navigator key is needed to separate global navigation (like login) from nested navigation (tabs)
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  final AuthCubit authCubit;
  AppRouter(this.authCubit);

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    
    initialLocation: '/login',
    
    // Auth redirect logic remains untouched
    redirect: (context, state) {
      final authState = authCubit.state;
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToRegister = state.matchedLocation == '/register';
      
      if (authState is AuthUnauthenticated || authState is AuthInitial) {
        if (isGoingToLogin || isGoingToRegister) return null;
        return '/login';
      } 
      
      if (authState is AuthAuthenticated) {
        // If authenticated user tries to go to login, redirect to the main tab (map)
        if (isGoingToLogin || isGoingToRegister) return '/map';
      }
      return null;
    },
    
    routes: [
      // --- UNPROTECTED ROUTES (Auth) ---
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // --- PROTECTED ROUTES (Main App with Bottom Navigation) ---
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Map
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),
          // Branch 1: Camera
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/camera',
                builder: (context, state) => const CameraScreen(),
              ),
            ],
          ),
          // Branch 2: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}