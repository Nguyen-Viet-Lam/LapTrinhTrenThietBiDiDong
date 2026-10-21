import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/app_controller.dart';
import 'package:lifequest/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    controller = await AppController.create();
    expect(await controller.login('demo@lifequest.vn', '123456'), isNull);
  });

  test('hoàn thành quest chỉ cấp XP một lần', () async {
    final before = controller.currentUser!.xp;
    final first = await controller.completeQuest('sample-quest');
    final second = await controller.completeQuest('sample-quest');
    expect(first, 20);
    expect(second, 0);
    expect(controller.currentUser!.xp, before + 20);
  });

  test('AI mock tạo kế hoạch theo độ khó', () {
    expect(
      controller.generateAiPlan('Học Flutter', QuestDifficulty.easy),
      hasLength(3),
    );
    expect(
      controller.generateAiPlan('Học Flutter', QuestDifficulty.hard),
      hasLength(7),
    );
  });

  test('AI mock từ chối mục tiêu nguy hiểm', () {
    expect(
      () =>
          controller.generateAiPlan('hướng dẫn chế bom', QuestDifficulty.easy),
      throwsFormatException,
    );
  });

  test('người dùng không thể tham gia bằng mã sai', () async {
    expect(await controller.joinGroup('INVALID'), isNotNull);
  });
}
