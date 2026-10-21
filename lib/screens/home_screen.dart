import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_controller.dart';
import '../models.dart';
import 'quest_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(appControllerProvider);
    final user = controller.currentUser!;
    final active = controller.myQuests
        .where((quest) => quest.status == QuestStatus.active)
        .take(3)
        .toList();
    final levelStart = (user.level - 1) * (user.level - 1) * 100;
    final levelEnd = user.level * user.level * 100;
    final levelProgress = (user.xp - levelStart) / (levelEnd - levelStart);
    return RefreshIndicator(
      onRefresh: () async =>
          Future<void>.delayed(const Duration(milliseconds: 400)),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          Text(
            'Xin chào, ${user.displayName} 👋',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          const Text('Hôm nay mình tiến thêm một bước nhỏ nhé.'),
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        child: Text(
                          '${user.level}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cấp ${user.level}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              '${user.xp} XP • Còn ${levelEnd - user.xp} XP để lên cấp',
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            color: Colors.deepOrange,
                          ),
                          Text('${user.streak} ngày'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  LinearProgressIndicator(
                    value: levelProgress.clamp(0, 1),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.task_alt,
                  value:
                      '${controller.myQuests.where((q) => q.status == QuestStatus.completed).length}',
                  label: 'Đã xong',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.groups,
                  value: '${controller.myGroups.length}',
                  label: 'Nhóm',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.emoji_events,
                  value: '${_badgeCount(user)}',
                  label: 'Huy hiệu',
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Text(
                'Quest ưu tiên',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              FilledButton.tonalIcon(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (_) => const CreateQuestSheet(),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Tạo'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (active.isEmpty)
            const _EmptyHome()
          else
            ...active.map((quest) => QuestCard(quest: quest)),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.psychology_alt)),
              title: const Text('Gợi ý từ LifeQuest'),
              subtitle: const Text(
                'Chia mục tiêu lớn thành các bước 10–20 phút giúp bạn dễ bắt đầu hơn.',
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _badgeCount(AppUser user) => [
    user.xp >= 20,
    user.streak >= 3,
    user.streak >= 7,
    user.xp >= 300,
  ].where((value) => value).length;
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    ),
  );
}

class _EmptyHome extends StatelessWidget {
  const _EmptyHome();
  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline, size: 48),
          SizedBox(height: 8),
          Text('Bạn đã xử lý hết quest đang hoạt động!'),
        ],
      ),
    ),
  );
}
