// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart' as auth_mocks;

import 'package:perkii/firebase_options.dart';
import 'package:perkii/main.dart';
import 'package:perkii/pages/onboarding_page.dart';

void main() {

  TestWidgetsFlutterBinding.ensureInitialized();

  
  auth_mocks.setupFirebaseAuthMocks();


  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  testWidgets('App boots and shows OnBoard when signed out', (tester) async {
    
    await tester.pumpWidget(const MyApp());

    
    await tester.pump(); 
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    
    await tester.pumpAndSettle();

  
    expect(find.byType(OnBoard), findsOneWidget);
  });
}
