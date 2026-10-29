import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_controller.dart';
import 'screens/admin_screen.dart';
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
            state.matchedLocation == '/register' ||
            state.matchedLocation == '/forgot-password';
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
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(path: '/app', builder: (context, state) => const MainShell()),
        GoRoute(path: '/admin', builder: (context, state) => const AdminScreen()),
      ],
    );

    // PHÂN TÁCH 2 PHONG CÁCH GIAO DIỆN (THEO HÌNH ẢNH YÊU CẦU):
    // 1. ADMIN -> Deep Abyss Ocean Dark Glass (Hình 2: Kính đại dương sâu thẳm, viền phát quang cyan)
    // 2. USER  -> Nova Glass / Ice Crystal Light Glass (Hình 1: Kính băng tuyết trong trẻo, bóng đổ xanh mềm)
    final isAdmin = controller.currentUser?.isAdmin == true;
    final isDark = controller.currentUser?.darkMode == true || isAdmin;

    final primaryColor = isAdmin ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
    final bgColor = isAdmin
        ? const Color(0xFF030712) // Deep Midnight Abyss
        : (isDark ? const Color(0xFF0F172A) : const Color(0xFFEEF5FC)); // Nova Glass Ice Canvas

    final surfaceColor = isAdmin
        ? const Color(0xFF0B172C) // Dark Frosted Glass
        : (isDark ? const Color(0xFF1E293B) : Colors.white); // Pure Frost Glass

    final borderColor = isAdmin
        ? const Color(0xFF38BDF8).withValues(alpha: 0.35) // Bioluminescent Cyan Rim
        : (isDark ? const Color(0xFF334155) : const Color(0xFFBAE6FD)); // Icy Frost Border

    final scheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: primaryColor,
      surface: surfaceColor,
    );

    return MaterialApp.router(
      title: 'LifeQuest - Quản lý Mục tiêu & Nhiệm vụ Gamification',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: bgColor,
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 1,
          backgroundColor: surfaceColor,
          foregroundColor: isDark ? Colors.white : const Color(0xFF0C1E3C),
          titleTextStyle: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0C1E3C),
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
          iconTheme: IconThemeData(
            color: isDark ? (isAdmin ? const Color(0xFF38BDF8) : Colors.white) : const Color(0xFF0C1E3C),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: isDark ? (isAdmin ? 6 : 0) : 3,
          shadowColor: isAdmin ? const Color(0xFF0284C7).withValues(alpha: 0.4) : const Color(0xFF0284C7).withValues(alpha: 0.12),
          color: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: borderColor, width: 1.2),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: isAdmin ? const Color(0xFF071124) : (isDark ? const Color(0xFF1E293B) : Colors.white),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: borderColor, width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: borderColor, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: scheme.error, width: 1.5),
          ),
          prefixIconColor: primaryColor,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: isAdmin ? const Color(0xFF030712) : Colors.white,
            elevation: 3,
            shadowColor: primaryColor.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: BorderSide(color: borderColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: surfaceColor,
          modalBackgroundColor: surfaceColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: borderColor, width: 1.2),
          ),
        ),
      ),
    );
  }
}
