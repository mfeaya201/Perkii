import 'package:flutter/material.dart';
import 'package:perkii/pages/home_page.dart';
import 'package:perkii/pages/notification_page.dart';
import 'package:perkii/pages/onboarding_page.dart';
import 'package:perkii/pages/login_screen.dart';
import 'package:perkii/pages/user_profile.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp( 
      debugShowCheckedModeBanner: false,
      home: NotificationPage(),
    
    );
  }
}
