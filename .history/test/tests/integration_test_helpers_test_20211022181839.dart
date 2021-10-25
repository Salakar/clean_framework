import 'package:clean_framework/clean_framework_tests.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  enableLogsInConsole();
  testWidgets('Integration test helpers', (tester) async {
    await startTest(tester, () async => await tester.pumpWidget(MaterialApp()));

    expectLater(didWidgetAppear('HomePage'), throwsException);
  });
}