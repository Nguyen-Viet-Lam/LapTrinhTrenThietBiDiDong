import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_controller.dart';
import '../models.dart';
import 'quest_widgets.dart';

class QuestsScreen extends ConsumerStatefulWidget {
  const QuestsScreen({super.key});
  @override
  ConsumerState<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends ConsumerState<QuestsScreen> {
  QuestStatus status = QuestStatus.active;
  String search = '';

  @override
  Widget build(BuildContext context) {
    final quests = ref.watch(appControllerProvider).myQuests.where((quest) {
      final matchesStatus = quest.status == status;
      final term = search.trim().toLowerCase();
      return matchesStatus &&
          (term.isEmpty ||
              quest.title.toLowerCase().contains(term) ||
              quest.category.toLowerCase().contains(term));
    }).toList();
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            TextField(
              onChanged: (value) => setState(() => search = value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Tìm theo tên hoặc danh mục',
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<QuestStatus>(
              segments: const [
                ButtonSegment(
                  value: QuestStatus.active,
                  label: Text('Đang làm'),
                  icon: Icon(Icons.play_circle_outline),
                ),
                ButtonSegment(
                  value: QuestStatus.completed,
                  label: Text('Đã xong'),
                  icon: Icon(Icons.check_circle_outline),
                ),
                ButtonSegment(
                  value: QuestStatus.archived,
                  label: Text('Lưu trữ'),
                  icon: Icon(Icons.archive_outlined),
                ),
              ],
              selected: {status},
              showSelectedIcon: false,
              onSelectionChanged: (value) =>
                  setState(() => status = value.first),
            ),
            const SizedBox(height: 16),
            if (quests.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 54,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      const Text('Không có nhiệm vụ phù hợp.'),
                    ],
                  ),
                ),
              )
            else
              ...quests.map((quest) => QuestCard(quest: quest)),
          ],
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton.extended(
            heroTag: 'quest-add',
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              builder: (_) => const CreateQuestSheet(),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Quest mới'),
          ),
        ),
      ],
    );
  }
}
