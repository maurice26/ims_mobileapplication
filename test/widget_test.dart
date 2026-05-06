// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ims_mobileapp/main.dart';
import 'package:ims_mobileapp/screens/auth/login_screen.dart';

void main() {
  testWidgets('IMSApp launches with LoginScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: IMSApp()));

    // Initial state is unauthenticated, shows LoginScreen
    expect(find.textContaining('Login'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
