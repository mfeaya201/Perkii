import 'package:flutter/material.dart';
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

void main() {
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
        appBarTheme: AppBarTheme(
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
        textTheme: TextTheme(
          displayLarge: TextStyle(color: Colors.white),
          displayMedium: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: OnBoard(), //home: BusinessHomeDashboard(), to test

      routes: {
        '/onboarding': (context) => OnBoard(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
        '/profile': (context) => UserProfile(),
        '/favorites': (context) => FavoritesPage(),
        '/notifications': (context) => NotificationPage(),
        '/business/home': (context) => BusinessHomeDashboard(),
        '/business/deals': (context) => ManageDealsPage(),
        '/business/create-deal': (context) => CreateDealPage(),
        '/business/edit-deal': (context) => EditDealPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/business-details') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => BusinessDetailsPage(
              businessName: args['businessName'],
              businessIndex: args['businessIndex'],
            ),
          );
        }
        return null;
      },
    );
  }
}