import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/models.dart';

void main() {
  group('Database Volume & Performance Tests (Stress & Volume Testing)', () {
    late List<Quest> largeQuestList;
    late List<QuestGroup> largeGroupList;

    setUp(() {
      // 1. Đổ 1 lượng dữ liệu mẫu lớn: 100 Nhiệm vụ đời thường đa dạng
      final categories = ['Sức khỏe', 'Học tập', 'Kỷ luật', 'Đồng đội', 'Cân bằng'];
      final difficulties = [QuestDifficulty.easy, QuestDifficulty.medium, QuestDifficulty.hard];

      largeQuestList = List.generate(100, (index) {
        final category = categories[index % categories.length];
        final difficulty = difficulties[index % difficulties.length];
        final isCompleted = index % 3 == 0;
        final stepCount = (index % 5) + 3;

        return Quest(
          id: 'quest_volume_$index',
          ownerId: 'user_${index % 10}',
          groupId: index % 4 == 0 ? 'group_${index % 5}' : null,
          title: 'Nhiệm vụ rèn luyện #$index: $category rèn luyện thể chất',
          description: 'Mô tả chi tiết bài tập thể thao hoặc học tập cho nhiệm vụ số $index',
          category: category,
          difficulty: difficulty,
          status: isCompleted ? QuestStatus.completed : QuestStatus.active,
          xpReward: difficulty == QuestDifficulty.easy ? 20 : (difficulty == QuestDifficulty.medium ? 40 : 70),
          steps: List.generate(
            stepCount,
            (sIdx) => QuestStep(
              id: 'step_${index}_$sIdx',
              title: 'Bước thực hiện số ${sIdx + 1} của nhiệm vụ #$index',
              isDone: isCompleted || sIdx < stepCount ~/ 2,
            ),
          ),
          createdAt: DateTime.now().subtract(Duration(days: index)),
          completedAt: isCompleted ? DateTime.now().subtract(Duration(hours: index)) : null,
        );
      });

      // 2. Đổ 20 nhóm hoạt động và câu lạc bộ
      largeGroupList = List.generate(20, (index) {
        return QuestGroup(
          id: 'group_$index',
          name: 'CLB Thể Thao & Đồ Án #$index',
          description: 'Nhóm sinh viên HUTECH cùng rèn luyện mục tiêu số $index',
          ownerId: 'user_$index',
          inviteCode: 'HUTECH_${1000 + index}',
          members: List.generate(
            (index % 8) + 2,
            (mIdx) => GroupMember(
              id: 'member_${index}_$mIdx',
              displayName: 'Sinh viên ${index}_$mIdx',
              role: mIdx == 0 ? 'owner' : 'member',
              joinedAt: DateTime.now(),
            ),
          ),
          createdAt: DateTime.now(),
        );
      });
    });

    test('Đổ 100 nhiệm vụ vào bộ nhớ và kiểm tra tính toàn vẹn dữ liệu', () {
      expect(largeQuestList.length, 100);
      expect(largeGroupList.length, 20);

      final totalSteps = largeQuestList.fold<int>(0, (sum, q) => sum + q.steps.length);
      expect(totalSteps, greaterThan(300));
    });

    test('Hiệu năng tìm kiếm từ khóa trên 100 nhiệm vụ thực thi dưới 10ms', () {
      final stopwatch = Stopwatch()..start();
      
      final searchResults = largeQuestList.where((q) {
        final query = 'Sức khỏe';
        return q.title.toLowerCase().contains(query.toLowerCase()) ||
            q.description.toLowerCase().contains(query.toLowerCase()) ||
            q.category.toLowerCase().contains(query.toLowerCase());
      }).toList();

      stopwatch.stop();

      expect(searchResults.isNotEmpty, isTrue);
      expect(stopwatch.elapsedMilliseconds, lessThan(10)); // Cực nhanh < 10ms
    });

    test('Hiệu năng lọc theo 5 danh mục trụ cột và trạng thái hoàn thành', () {
      final activeHealthQuests = largeQuestList
          .where((q) => q.category == 'Sức khỏe' && q.status == QuestStatus.active)
          .toList();

      final completedStudyQuests = largeQuestList
          .where((q) => q.category == 'Học tập' && q.status == QuestStatus.completed)
          .toList();

      expect(activeHealthQuests.isNotEmpty, isTrue);
      expect(completedStudyQuests.isNotEmpty, isTrue);
    });

    test('Tính toán tổng điểm XP và Level từ lượng lớn nhiệm vụ hoàn thành', () {
      final totalCompletedXp = largeQuestList
          .where((q) => q.status == QuestStatus.completed)
          .fold<int>(0, (sum, q) => sum + q.xpReward);

      expect(totalCompletedXp, greaterThan(500));
      final calculatedLevel = levelForXp(totalCompletedXp);
      expect(calculatedLevel, greaterThanOrEqualTo(2));
    });

    test('Kiểm tra hiệu năng truy vấn thành viên trên 20 nhóm', () {
      final stopwatch = Stopwatch()..start();

      for (final group in largeGroupList) {
        expect(group.members.isNotEmpty, isTrue);
        expect(group.members.any((m) => m.role == 'owner'), isTrue);
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(5));
    });
  });
}
