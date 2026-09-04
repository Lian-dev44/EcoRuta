import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'app_scope.dart';
import 'screens/auth_screens.dart';
import 'screens/main_shell.dart';

class EcoRutaApp extends StatelessWidget {
  final AppController controller;

  const EcoRutaApp({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return EcoRutaScope(
      controller: controller,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EcoRuta',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32),
          ),
          scaffoldBackgroundColor: const Color(0xFFF7F9F6),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE1E7E0)),
            ),
          ),
        ),
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final controller = EcoRutaScope.of(context);

    if (controller.initializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: controller.isLoggedIn
          ? const EcoRutaMainShell(key: ValueKey('main'))
          : const LoginScreen(key: ValueKey('login')),
    );
  }
}
