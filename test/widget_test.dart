import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wearwise/main.dart';

void main() {
  testWidgets('App should load successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WearWiseApp());

    // Verify that the app loads with home screen
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
    
    // Verify bottom navigation exists
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
