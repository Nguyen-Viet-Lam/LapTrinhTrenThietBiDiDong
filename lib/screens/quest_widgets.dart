import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../app_controller.dart';
import '../models.dart';

class QuestCard extends ConsumerWidget {
  const QuestCard({required this.quest, super.key});
  final Quest quest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = switch (quest.difficulty) {
      QuestDifficulty.easy => Colors.green,
      QuestDifficulty.medium => Colors.orange,
      QuestDifficulty.hard => Colors.red,
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          isScrollControlled: true,
          builder: (_) => QuestDetailSheet(questId: quest.id),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      quest.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    '+${quest.xpReward} XP',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (quest.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  quest.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: quest.progress,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(quest.category),
                  const Spacer(),
                  if (quest.dueAt != null)
                    Text(
                      DateFormat('dd/MM, HH:mm').format(quest.dueAt!),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestDetailSheet extends ConsumerWidget {
  const QuestDetailSheet({required this.questId, super.key});
  final String questId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(appControllerProvider);
    final quest = controller.quests
        .where((item) => item.id == questId)
        .firstOrNull;
    if (quest == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Nhiệm vụ không còn tồn tại.')),
      );
    }
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      quest.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'archive') {
                        await controller.archiveQuest(quest.id);
                        if (context.mounted) Navigator.pop(context);
                      }
                      if (value == 'report' && context.mounted) {
                        await showReportDialog(context, ref, 'quest', quest.id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'archive', child: Text('Lưu trữ')),
                      PopupMenuItem(value: 'report', child: Text('Báo cáo')),
                    ],
                  ),
                ],
              ),
              if (quest.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(quest.description),
              ],
              const SizedBox(height: 20),
              Text(
                'Tiến độ ${(quest.progress * 100).round()}%',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: quest.progress),
              const SizedBox(height: 16),
              if (quest.steps.isEmpty)
                const Text('Nhiệm vụ không có bước con.'),
              ...quest.steps.map(
                (step) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: step.isDone,
                  title: Text(step.title),
                  onChanged: quest.status == QuestStatus.completed
                      ? null
                      : (_) => controller.toggleStep(quest.id, step.id),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: quest.status == QuestStatus.completed
                    ? null
                    : () async {
                        final xp = await controller.completeQuest(quest.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Hoàn thành! Bạn nhận $xp XP.'),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                icon: const Icon(Icons.celebration),
                label: Text(
                  quest.status == QuestStatus.completed
                      ? 'Đã hoàn thành'
                      : 'Hoàn thành nhiệm vụ',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateQuestSheet extends ConsumerStatefulWidget {
  const CreateQuestSheet({
    this.initialTitle = '',
    this.initialSteps = const [],
    this.createdByAi = false,
    this.groupId,
    super.key,
  });
  final String initialTitle;
  final List<String> initialSteps;
  final bool createdByAi;
  final String? groupId;
  @override
  ConsumerState<CreateQuestSheet> createState() => _CreateQuestSheetState();
}

class _CreateQuestSheetState extends ConsumerState<CreateQuestSheet> {
  late final TextEditingController title = TextEditingController(
    text: widget.initialTitle,
  );
  final description = TextEditingController();
  late final TextEditingController steps = TextEditingController(
    text: widget.initialSteps.join('\n'),
  );
  QuestDifficulty difficulty = QuestDifficulty.easy;
  String category = 'Sức khỏe';
  DateTime? dueAt;
  bool saving = false;

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    steps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.createdByAi ? 'Duyệt bản nháp AI' : 'Tạo nhiệm vụ',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: title,
              maxLength: 80,
              decoration: const InputDecoration(labelText: 'Tên nhiệm vụ'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: description,
              maxLength: 300,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Mô tả'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: category,
              decoration: const InputDecoration(labelText: 'Danh mục'),
              items:
                  const ['Sức khỏe', 'Học tập', 'Công việc', 'Gia đình', 'Khác']
                      .map(
                        (item) =>
                            DropdownMenuItem(value: item, child: Text(item)),
                      )
                      .toList(),
              onChanged: (value) => category = value!,
            ),
            const SizedBox(height: 10),
            SegmentedButton<QuestDifficulty>(
              segments: const [
                ButtonSegment(value: QuestDifficulty.easy, label: Text('Dễ')),
                ButtonSegment(
                  value: QuestDifficulty.medium,
                  label: Text('Vừa'),
                ),
                ButtonSegment(value: QuestDifficulty.hard, label: Text('Khó')),
              ],
              selected: {difficulty},
              onSelectionChanged: (value) =>
                  setState(() => difficulty = value.first),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: steps,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Các bước (mỗi dòng một bước)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () async {
                final now = DateTime.now();
                final date = await showDatePicker(
                  context: context,
                  firstDate: now,
                  lastDate: now.add(const Duration(days: 365)),
                  initialDate: dueAt ?? now,
                );
                if (date != null) {
                  setState(
                    () => dueAt = DateTime(date.year, date.month, date.day, 20),
                  );
                }
              },
              icon: const Icon(Icons.event),
              label: Text(
                dueAt == null
                    ? 'Chọn hạn hoàn thành'
                    : DateFormat('dd/MM/yyyy, HH:mm').format(dueAt!),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (title.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vui lòng nhập tên nhiệm vụ.'),
                          ),
                        );
                        return;
                      }
                      setState(() => saving = true);
                      await ref
                          .read(appControllerProvider)
                          .addQuest(
                            title: title.text,
                            description: description.text,
                            category: category,
                            difficulty: difficulty,
                            steps: steps.text.split('\n'),
                            dueAt: dueAt,
                            createdByAi: widget.createdByAi,
                            groupId: widget.groupId,
                          );
                      if (context.mounted) Navigator.pop(context);
                    },
              child: const Text('Lưu nhiệm vụ'),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> showReportDialog(
  BuildContext context,
  WidgetRef ref,
  String type,
  String id,
) async {
  var reason = 'Nội dung không phù hợp';
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Báo cáo nội dung'),
      content: StatefulBuilder(
        builder: (context, setState) => DropdownButtonFormField<String>(
          initialValue: reason,
          items:
              const [
                    'Nội dung không phù hợp',
                    'Quấy rối',
                    'Lừa đảo',
                    'Nguy hiểm',
                    'Khác',
                  ]
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
          onChanged: (value) => setState(() => reason = value!),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () async {
            await ref.read(appControllerProvider).report(type, id, reason);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Gửi báo cáo'),
        ),
      ],
    ),
  );
}
