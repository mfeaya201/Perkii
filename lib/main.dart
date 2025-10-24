// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

// Pages
import 'package:perkii/pages/home_page.dart';
import 'package:perkii/pages/onboarding_page.dart';
import 'package:perkii/pages/login_screen.dart';
import 'package:perkii/pages/register_page.dart';
import 'package:perkii/pages/user_profile.dart';
import 'package:perkii/pages/favorites_page.dart';
import 'package:perkii/pages/notification_page.dart';
import 'package:perkii/pages/business_details_page.dart';
import 'package:perkii/pages/business_home_dashboard.dart';
import 'package:perkii/pages/manage_deals_page.dart';
import 'package:perkii/pages/create_deal_page.dart';
import 'package:perkii/pages/edit_deal_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase BEFORE runApp
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('[main] Firebase initialized');
    }
  } catch (e) {
    // Ignore duplicate-app errors on hot reload, rethrow others
    final msg = e.toString().toLowerCase();
    if (!msg.contains('duplicate-app') &&
        !msg.contains('already exists')) {
      rethrow;
    } else {
      debugPrint('[main] Firebase duplicate app (safe to ignore)');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.white,
        colorScheme: ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.grey[800]!,
          surface: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey[600],
          elevation: 0,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.white),
          displayMedium: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),

      // Landing is decided by auth + Firestore role
      home: const RoleGate(),

      // Static routes that don't need dynamic arguments
      routes: {
        '/onboarding': (context) => const OnBoard(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const UserProfile(),
        '/favorites': (context) => const FavoritesPage(),
        '/notifications': (context) => const NotificationPage(),
        '/business/home': (context) => const BusinessHomeDashboard(),
        '/business/deals': (context) => const ManageDealsPage(),
        '/business/create-deal': (context) => const CreateDealPage(),
        '/business/edit-deal': (context) => const EditDealPage(),
      },

      // Dynamic routes that require arguments
      onGenerateRoute: (settings) {
        if (settings.name == '/business-details') {
          final args = (settings.arguments is Map)
              ? settings.arguments as Map<String, dynamic>
              : const <String, dynamic>{};

          final String? businessId = args['businessId'] as String?;
          final String businessName =
              (args['businessName'] as String?) ?? 'Business';
          final int businessIndex =
              (args['businessIndex'] is int) ? args['businessIndex'] as int : 0;

          if (businessId == null || businessId.isEmpty) {
            // Guard page if required arg missing
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: Text('Missing businessId',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            );
          }

          return MaterialPageRoute(
            builder: (_) => BusinessDetailsPage(
              businessId: businessId,
              businessName: businessName,
              businessIndex: businessIndex,
            ),
          );
        }
        return null;
      },
    );
  }
}

/// Decides which screen to show on app start:
/// - Not logged in → OnBoard (landing)
/// - Logged in + accountType == 'business' → BusinessHomeDashboard
/// - Otherwise (users/unknown) → OnBoard (or change to HomePage if you prefer)
class RoleGate extends StatelessWidget {
  const RoleGate({super.key});

  Future<Widget> _pickStartPage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('[RoleGate] No user signed in → OnBoard');
      return const OnBoard();
    }

    try {
      final snap =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      final data = snap.data() ?? {};
      final rawType = data['accountType'];
      final accountType = (rawType is String) ? rawType.trim().toLowerCase() : null;

      debugPrint(
          '[RoleGate] uid=${user.uid} email=${user.email} accountType=$accountType');

      if (accountType == 'business') {
        return const BusinessHomeDashboard();
      }
      // Landing for all non-business accounts
      // If you want regular users to see HomePage instead, return const HomePage();
      return const OnBoard();
    } catch (e) {
      debugPrint('[RoleGate] Error reading role: $e → OnBoard (fallback)');
      return const OnBoard();
    }
  }

  @override
  Widget build(BuildContext context) {
    // React to auth state (e.g., logout/login while app is open)
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _Splash();
        }
        if (!snap.hasData) {
          debugPrint('[RoleGate] auth: not logged in → OnBoard');
          return const OnBoard();
        }

        return FutureBuilder<Widget>(
          future: _pickStartPage(),
          builder: (context, roleSnap) {
            if (roleSnap.connectionState != ConnectionState.done) {
              return const _Splash();
            }
            return roleSnap.data ?? const OnBoard();
          },
        );
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
