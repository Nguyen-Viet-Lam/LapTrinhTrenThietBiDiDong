import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/models.dart';
import 'package:lifequest/repositories/fake_repositories.dart';

void main() {
  group('FakeQuestRepository Tests', () {
    late FakeQuestRepository repo;

    setUp(() {
      repo = FakeQuestRepository();
    });

    test('createQuest thêm nhiệm vụ và trả về quest có id', () async {
      final newQuest = Quest(
        id: '',
        ownerId: 'user-1',
        title: 'Chạy bộ 3km',
        description: 'Buổi sáng công viên',
        category: 'Sức khỏe',
        difficulty: QuestDifficulty.easy,
        status: QuestStatus.active,
        steps: [
          const QuestStep(id: 's1', title: 'Khởi động 5p', isDone: false),
          const QuestStep(id: 's2', title: 'Chạy bền', isDone: false),
        ],
        createdAt: DateTime.now(),
        xpReward: 20,
      );

      final created = await repo.createQuest(newQuest);
      expect(created.id, isNotEmpty);
      expect(created.title, 'Chạy bộ 3km');

      final quests = await repo.getQuests(ownerId: 'user-1');
      expect(quests.length, 1);
      expect(quests.first.id, created.id);
    });

    test('toggleStep cập nhật trạng thái bước con và tiến độ', () async {
      final quest = await repo.createQuest(
        Quest(
          id: 'q1',
          ownerId: 'user-1',
          title: 'Học bài',
          description: '',
          category: 'Học tập',
          difficulty: QuestDifficulty.easy,
          status: QuestStatus.active,
          steps: [
            const QuestStep(id: 's1', title: 'Đọc sách', isDone: false),
            const QuestStep(id: 's2', title: 'Làm bài tập', isDone: false),
          ],
          createdAt: DateTime.now(),
        ),
      );

      await repo.toggleStep(quest.id, 's1', true);
      final updated = (await repo.getQuests(ownerId: 'user-1')).first;
      expect(updated.steps.first.isDone, isTrue);
      expect(updated.progress, 0.5);
    });

    test('completeQuest idempotent: lần đầu cộng XP, lần hai trả 0 XP', () async {
      final quest = await repo.createQuest(
        Quest(
          id: 'q2',
          ownerId: 'user-1',
          title: 'Đi ngủ sớm',
          description: '',
          category: 'Sức khỏe',
          difficulty: QuestDifficulty.easy,
          status: QuestStatus.active,
          steps: [],
          createdAt: DateTime.now(),
          xpReward: 20,
        ),
      );

      final result1 = await repo.completeQuest(quest.id, 'user-1');
      expect(result1.xpAwarded, 20);
      expect(result1.idempotent, isFalse);
      expect(result1.quest.status, QuestStatus.completed);

      final result2 = await repo.completeQuest(quest.id, 'user-1');
      expect(result2.xpAwarded, 0);
      expect(result2.idempotent, isTrue);
    });
  });
}

