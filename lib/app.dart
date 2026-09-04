import 'dart:async';

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
        home: controller.repositoryOverride != null
            ? const _AuthGate()
            : const _BrandSplashGate(),
      ),
    );
  }
}

class _BrandSplashGate extends StatefulWidget {
  const _BrandSplashGate();

  @override
  State<_BrandSplashGate> createState() => _BrandSplashGateState();
}

class _BrandSplashGateState extends State<_BrandSplashGate> {
  bool _showApp = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showApp = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      child: _showApp
          ? const _AuthGate(key: ValueKey('auth-gate'))
          : const _EcoRutaSplash(key: ValueKey('brand-splash')),
    );
  }
}

class _EcoRutaSplash extends StatelessWidget {
  const _EcoRutaSplash({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF7),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Image.asset(
                      'assets/branding/splash_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(99),
                    color: colorScheme.primary,
                    backgroundColor: const Color(0xFFDDE8D9),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Tu próxima aventura comienza aquí',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF37553B),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate({super.key});

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
