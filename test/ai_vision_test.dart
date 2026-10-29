import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/api/api_exception.dart';
import 'package:lifequest/app_controller.dart';
import 'package:lifequest/models.dart';
import 'package:lifequest/screens/ai_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_controller_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeApiClient fakeApi;
  late AppController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'token': 'mock-valid-jwt-token'});
    final prefs = await SharedPreferences.getInstance();
    fakeApi = FakeApiClient(preferences: prefs);
    controller = AppController(fakeApi);
    fakeApi.onUnauthorized = controller.handleUnauthorized;
    await controller.init();
    await controller.login('demo@lifequest.vn', '123456');
  });

  group('AI Vision Quest Unit Tests', () {
    test('generateVisionQuest sinh bản nháp cầu lông với ảnh bối cảnh và 3 bước', () async {
      final draft = await controller.generateVisionQuest(
        contextLabel: 'Sân cầu lông',
        photoUrl: 'https://example.com/badminton.jpg',
        userNote: 'Tập phản xạ và giao cầu',
        difficulty: QuestDifficulty.easy,
      );

      expect(draft.imageUrl, 'https://example.com/badminton.jpg');
      expect(draft.steps.length, 3);
      expect(draft.category, 'Sức khỏe');
      expect(draft.difficulty, QuestDifficulty.easy);
      expect(draft.title, contains('Sân cầu lông'));
    });

    test('generateVisionQuest sinh bản nháp học tập với 7 bước khi chọn Hard', () async {
      final draft = await controller.generateVisionQuest(
        contextLabel: 'Góc học tập / Đồ án',
        photoUrl: 'https://example.com/study.jpg',
        userNote: 'Hoàn thành slide đồ án di động',
        difficulty: QuestDifficulty.hard,
      );

      expect(draft.imageUrl, 'https://example.com/study.jpg');
      expect(draft.steps.length, 7);
      expect(draft.category, 'Học tập');
      expect(draft.difficulty, QuestDifficulty.hard);
    });

    test('generateVisionQuest chặn từ khóa nguy hiểm và ném ApiException 422', () async {
      expect(
        () => controller.generateVisionQuest(
          contextLabel: 'Công viên',
          photoUrl: 'https://example.com/park.jpg',
          userNote: 'Kế hoạch tự tử tại công viên',
        ),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 422),
        ),
      );
    });

    test('addQuest lưu thành công nhiệm vụ mang theo imageUrl', () async {
      final quest = await controller.addQuest(
        title: 'Chơi cầu lông đôi 45 phút',
        description: 'Luyện tập thể lực cuối tuần',
        category: 'Sức khỏe',
        difficulty: QuestDifficulty.medium,
        steps: ['Khởi động 5 phút', 'Đánh 2 set', 'Thả lỏng'],
        imageUrl: 'https://example.com/badminton.jpg',
      );

      expect(quest.imageUrl, 'https://example.com/badminton.jpg');
      expect(controller.quests.first.imageUrl, 'https://example.com/badminton.jpg');
    });
  });

  group('AI Vision Screen Widget Tests', () {
    testWidgets('chuyển đổi tab sang AI Thị giác và hiển thị danh sách bối cảnh', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appControllerProvider.overrideWith((ref) => controller),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: AiScreen(),
            ),
          ),
        ),
      );

      // Mặc định đang ở tab Mục tiêu chữ
      expect(find.text('Mục tiêu chữ'), findsOneWidget);
      expect(find.text('📸 AI Thị giác'), findsOneWidget);
      expect(find.text('Bạn muốn đạt được điều gì?'), findsOneWidget);

      // Nhấn chuyển sang tab AI Thị giác
      await tester.tap(find.text('📸 AI Thị giác'));
      await tester.pumpAndSettle();

      // Kiểm tra các chip bối cảnh đời thực xuất hiện
      expect(find.text('Chọn bối cảnh chụp ảnh thực tế:'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Sân cầu lông'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Phòng Gym'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Góc học tập / Đồ án'), findsOneWidget);
      expect(find.text('📸 Phân tích ảnh & Tạo nhiệm vụ'), findsOneWidget);
    });
  });
}
