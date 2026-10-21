import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/models.dart';

void main() {
  group('gamification', () {
    test('level tăng theo ngưỡng bình phương', () {
      expect(levelForXp(0), 1);
      expect(levelForXp(99), 1);
      expect(levelForXp(100), 2);
      expect(levelForXp(399), 2);
      expect(levelForXp(400), 3);
    });

    test('progress checklist được tính chính xác', () {
      final quest = Quest(
        id: 'q1',
        ownerId: 'u1',
        title: 'Test',
        description: '',
        category: 'Học tập',
        difficulty: QuestDifficulty.easy,
        status: QuestStatus.active,
        steps: const [
          QuestStep(id: '1', title: 'A', isDone: true),
          QuestStep(id: '2', title: 'B'),
        ],
        createdAt: DateTime(2026),
      );
      expect(quest.progress, .5);
      expect(Quest.fromJson(quest.toJson()).progress, .5);
    });
  });
}
