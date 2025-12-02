import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';                       // FlutterFire CLI generates this
import 'app_router.dart';                             // Your route logic
import 'theme.dart';                                  // Your theme file

// Providers
import 'providers/auth_provider.dart';
import 'providers/dog_provider.dart';
import 'providers/plan_provider.dart';
import 'providers/activity_provider.dart';
import 'providers/analyzer_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const WoofFitApp());
}

class WoofFitApp extends StatelessWidget {
  const WoofFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<DogProvider>(
          create: (_) => DogProvider(),
        ),
        ChangeNotifierProvider<PlanProvider>(
          create: (_) => PlanProvider(),
        ),
        ChangeNotifierProvider<ActivityProvider>(
          create: (_) => ActivityProvider(),
        ),
        ChangeNotifierProvider<AnalyzerProvider>(
          create: (_) => AnalyzerProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'WoofFit',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),                          // From theme.dart
  home: const AuthWrapper(),
      ),
    );
  }
}
// <--- IMPORTANT: THIS BRACE ENDS THE APP WIDGET


// ------------------------------------------------------
// PASTE AUTHWRAPPER BELOW THIS LINE
// ------------------------------------------------------

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.user == null) {
      return const OnboardingScreen();
    } else {
      return const HomeScreen();
    }
  }
}
