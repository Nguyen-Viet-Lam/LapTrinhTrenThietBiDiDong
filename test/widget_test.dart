import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/app.dart';
import 'package:lifequest/app_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('hiển thị màn hình đăng nhập và tài khoản demo', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = await AppController.create();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appControllerProvider.overrideWith((ref) => controller)],
        child: const LifeQuestApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Chào mừng trở lại'), findsOneWidget);
    expect(find.text('demo@lifequest.vn'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsOneWidget);
  });
}
