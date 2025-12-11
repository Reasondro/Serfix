import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:serfix/app/layout/layout_scaffold_with_nav.dart';
import 'package:serfix/app/routing/routes.dart';
import 'package:serfix/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:serfix/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:serfix/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:serfix/features/doctor/dashboard/presentation/screens/doctor_dashboard_screen.dart';
import 'package:serfix/features/doctor/capture/presentation/screens/doctor_capture_screen.dart';
import 'package:serfix/features/doctor/screenings/presentation/screens/doctor_screenings_screen.dart';
import 'package:serfix/features/doctor/profile/presentation/screens/doctor_profile_screen.dart';
import 'package:serfix/features/doctor/screening/presentation/screens/screening_detail_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class RoutingService {
  final AuthCubit authCubit;

  RoutingService({required this.authCubit});

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: Routes.signIn,
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (BuildContext context, GoRouterState state) {
      final UserAuthState authState = authCubit.state;
      final String currentPath = state.matchedLocation;

      final bool isAuthRoute =
          currentPath == Routes.signIn || currentPath == Routes.signUp;

      if (authState is AuthLoading) {
        return null;
      }

      // Handle authenticated state - redirect to dashboard
      if (authState is AuthAuthenticated) {
        if (isAuthRoute) {
          return Routes.doctorDashboard;
        }
        return null;
      }

      // Handle unauthenticated state - redirect to sign in
      if (!isAuthRoute) {
        return Routes.signIn;
      }

      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        name: Routes.signIn,
        path: Routes.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        name: Routes.signUp,
        path: Routes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),

      // Doctor Routes with Navigation Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final authState = authCubit.state;
          if (authState is AuthAuthenticated) {
            return LayoutScaffoldWithNav(
              navigationShell: navigationShell,
              shellLocation: state.matchedLocation,
            );
          }
          return const SizedBox.shrink();
        },
        branches: [
          // Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: Routes.dashboard,
                path: Routes.doctorDashboard,
                builder: (context, state) => const DoctorDashboardScreen(),
              ),
            ],
          ),
          // Capture
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: Routes.capture,
                path: Routes.doctorCapture,
                builder: (context, state) => const DoctorCaptureScreen(),
              ),
            ],
          ),
          // Screenings
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: Routes.screenings,
                path: Routes.doctorScreenings,
                builder: (context, state) => const DoctorScreeningsScreen(),
                routes: [
                  GoRoute(
                    name: Routes.screeningDetail,
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ScreeningDetailScreen(screeningId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: Routes.profile,
                path: Routes.doctorProfile,
                builder: (context, state) => const DoctorProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
