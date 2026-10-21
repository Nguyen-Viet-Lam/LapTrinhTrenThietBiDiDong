import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_controller.dart';
import 'screens/auth_screens.dart';
import 'screens/main_shell.dart';

class LifeQuestApp extends ConsumerStatefulWidget {
  const LifeQuestApp({super.key});

  @override
  ConsumerState<LifeQuestApp> createState() => _LifeQuestAppState();
}

class _LifeQuestAppState extends ConsumerState<LifeQuestApp> {
  GoRouter? _router;

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(appControllerProvider);
    _router ??= GoRouter(
      refreshListenable: controller,
      initialLocation: '/login',
      redirect: (context, state) {
        final loggedIn = controller.currentUser != null;
        final onAuth =
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';
        if (!loggedIn && !onAuth) return '/login';
        if (loggedIn &&
            !controller.currentUser!.onboardingCompleted &&
            state.matchedLocation != '/onboarding') {
          return '/onboarding';
        }
        if (loggedIn &&
            controller.currentUser!.onboardingCompleted &&
            (onAuth || state.matchedLocation == '/onboarding')) {
          return '/app';
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
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(path: '/app', builder: (context, state) => const MainShell()),
      ],
    );
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF5B5BD6),
      brightness: controller.currentUser?.darkMode == true
          ? Brightness.dark
          : Brightness.light,
    );
    return MaterialApp.router(
      title: 'LifeQuest',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: scheme.surface,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: scheme.outlineVariant),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
