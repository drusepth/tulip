import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/auth/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/stays/presentation/screens/stay_detail_screen.dart';
import '../features/stays/presentation/screens/stay_form_screen.dart';
import '../features/stays/presentation/screens/stay_list_screen.dart';
import '../features/map/presentation/screens/map_screen.dart';
import '../features/timeline/presentation/screens/timeline_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/collaboration/presentation/screens/invite_accept_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isInviteRoute = state.matchedLocation.startsWith('/invites/');

      // Still checking auth status
      if (authState.status == AuthStatus.unknown) {
        return null;
      }

      // Allow invite routes without auth (will redirect to login with pending token)
      if (isInviteRoute && !isAuthenticated) {
        return '/login?redirect=${Uri.encodeComponent(state.matchedLocation)}';
      }

      // Redirect to login if not authenticated
      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      // Redirect to home if authenticated and on auth route
      if (isAuthenticated && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main app with bottom navigation shell
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/map',
            name: 'map',
            builder: (context, state) => const MapScreen(),
          ),
          GoRoute(
            path: '/timeline',
            name: 'timeline',
            builder: (context, state) => const TimelineScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Stay routes (outside shell for full screen)
      GoRoute(
        path: '/stays',
        name: 'stays',
        builder: (context, state) => const StayListScreen(),
      ),
      GoRoute(
        path: '/stays/new',
        name: 'stay-new',
        builder: (context, state) => const StayFormScreen(),
      ),
      GoRoute(
        path: '/stays/:id',
        name: 'stay-detail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return StayDetailScreen(stayId: id);
        },
      ),
      GoRoute(
        path: '/stays/:id/edit',
        name: 'stay-edit',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return StayFormScreen(stayId: id);
        },
      ),

      // Notifications
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),

      // Invite acceptance
      GoRoute(
        path: '/invites/:token',
        name: 'invite-accept',
        builder: (context, state) {
          final token = state.pathParameters['token']!;
          return InviteAcceptScreen(token: token);
        },
      ),
    ],
  );
});

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const MainBottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/stays/new'),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class MainBottomNav extends ConsumerWidget {
  const MainBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;
    if (location == '/map') currentIndex = 1;
    if (location == '/timeline') currentIndex = 2;
    if (location == '/profile') currentIndex = 3;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/map');
            break;
          case 2:
            context.go('/timeline');
            break;
          case 3:
            context.go('/profile');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.timeline_outlined),
          activeIcon: Icon(Icons.timeline),
          label: 'Timeline',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
