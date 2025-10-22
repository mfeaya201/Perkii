// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart' as auth_mocks;

import 'package:perkii/firebase_options.dart';
import 'package:perkii/main.dart';
import 'package:perkii/pages/onboarding_page.dart';

void main() {
  // 1) Initialize the widgets binding
  TestWidgetsFlutterBinding.ensureInitialized();

  // 2) Install Firebase channel mocks (must run before initializeApp)
  auth_mocks.setupFirebaseAuthMocks();

  // 3) Initialize Firebase for tests
  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  testWidgets('App boots and shows OnBoard when signed out', (tester) async {
    // Build app
    await tester.pumpWidget(const MyApp());

    // First frame: expect splash while RoleGate resolves
    await tester.pump(); // kick the first frame
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Let streams/Futures settle
    await tester.pumpAndSettle();

    // Not signed in -> OnBoard
    expect(find.byType(OnBoard), findsOneWidget);
  });
}
