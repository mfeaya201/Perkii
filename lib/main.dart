import 'package:flutter/material.dart';
import 'package:perkii/pages/home_page.dart';
import 'package:perkii/pages/onboarding_page.dart';
import 'package:perkii/pages/login_screen.dart';
import 'package:perkii/pages/user_profile.dart';

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
      home: OnBoard(),
      routes: {
        '/onboarding': (context) => OnBoard(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomePage(),
        '/profile': (context) => UserProfile(),
      },
    );
  }
}