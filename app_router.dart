import 'package:flutter/material.dart';

// Screens
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/dog_profile_screen.dart';
import 'screens/edit_dog_profile_screen.dart';
import 'screens/tracker_screen.dart';
import 'screens/activity_history_screen.dart';
import 'screens/photo_analyzer_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/premium_screen.dart';
import 'screens/paywall_screen.dart';

class AppRouter {
  // Set initial screen — later we’ll replace with auth-based logic
  static const String initialRoute = '/onboarding';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case '/dogProfile':
        return MaterialPageRoute(builder: (_) => const DogProfileScreen());

      case '/editDogProfile':
        return MaterialPageRoute(builder: (_) => const EditDogProfileScreen());

      case '/tracker':
        return MaterialPageRoute(builder: (_) => const TrackerScreen());

      case '/activityHistory':
        return MaterialPageRoute(builder: (_) => const ActivityHistoryScreen());

      case '/analyzer':
        return MaterialPageRoute(builder: (_) => const PhotoAnalyzerScreen());

      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case '/premium':
        return MaterialPageRoute(builder: (_) => const PremiumScreen());

      case '/paywall':
        return MaterialPageRoute(builder: (_) => const PaywallScreen());

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            '404 — Page Not Found',
            style: TextStyle(
              fontSize: 22,
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
