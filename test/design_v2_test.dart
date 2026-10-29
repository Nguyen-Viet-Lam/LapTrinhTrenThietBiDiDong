import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/screens/design_v2_widgets.dart';

void main() {
  group('Design System v2 Widgets Tests', () {
    testWidgets('AnimatedCounter hiển thị đúng giá trị và hậu tố', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCounter(
              value: 120,
              suffix: ' XP',
            ),
          ),
        ),
      );

      // Đợi hoàn thành animation
      await tester.pumpAndSettle();
      expect(find.text('120 XP'), findsOneWidget);
    });

    testWidgets('ProgressRing hiển thị đúng widget trung tâm và không bị lỗi paint', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressRing(
              progress: 0.75,
              centerWidget: Text('75%'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('75%'), findsOneWidget);
    });
  });
}
