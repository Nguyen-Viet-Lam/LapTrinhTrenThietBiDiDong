import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../api/api_exception.dart';
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
              if (quest.imageUrl != null && quest.imageUrl!.isNotEmpty) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    quest.imageUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 70,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.photo_outlined, size: 18),
                            SizedBox(width: 6),
                            Text('Ảnh bối cảnh nhiệm vụ', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
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
                  if (quest.createdByAi) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'AI',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (quest.dueAt != null)
                    Text(
                      DateFormat('dd/MM, HH:mm').format(quest.dueAt!.toLocal()),
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

class QuestDetailSheet extends ConsumerStatefulWidget {
  const QuestDetailSheet({required this.questId, super.key});
  final String questId;

  @override
  ConsumerState<QuestDetailSheet> createState() => _QuestDetailSheetState();
}

class _QuestDetailSheetState extends ConsumerState<QuestDetailSheet> {
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(appControllerProvider);
    final quest = controller.quests
        .where((item) => item.id == widget.questId)
        .firstOrNull;

    if (quest == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Nhiệm vụ không còn tồn tại.')),
      );
    }

    final isOwner = quest.ownerId == controller.currentUserId;
    final isActive = quest.status == QuestStatus.active;

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
              if (quest.imageUrl != null && quest.imageUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    quest.imageUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 90,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.photo_camera_back_outlined),
                            SizedBox(width: 8),
                            Text('Ảnh bối cảnh đời thực'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Row(
                children: [
                  Expanded(
                    child: Text(
                      quest.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  PopupMenuButton<String>(
                    enabled: !busy,
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          showDragHandle: true,
                          builder: (_) => EditQuestSheet(quest: quest),
                        );
                      } else if (value == 'archive') {
                        setState(() => busy = true);
                        try {
                          await controller.archiveQuest(quest.id);
                          if (context.mounted) Navigator.pop(context);
                        } finally {
                          if (mounted) setState(() => busy = false);
                        }
                      } else if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Xóa nhiệm vụ?'),
                            content: const Text(
                              'Bạn có chắc chắn muốn xóa nhiệm vụ này không? Thao tác này không thể hoàn tác.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Hủy'),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.error,
                                ),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Xóa'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          setState(() => busy = true);
                          try {
                            await controller.deleteQuest(quest.id);
                            if (context.mounted) Navigator.pop(context);
                          } finally {
                            if (mounted) setState(() => busy = false);
                          }
                        }
                      } else if (value == 'report' && context.mounted) {
                        await showReportDialog(context, ref, 'quest', quest.id);
                      }
                    },
                    itemBuilder: (_) => [
                      if (isActive)
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Chỉnh sửa'),
                        ),
                      if (isActive)
                        const PopupMenuItem(
                          value: 'archive',
                          child: Text('Lưu trữ'),
                        ),
                      if (isOwner)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Xóa nhiệm vụ',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'report',
                        child: Text('Báo cáo vi phạm'),
                      ),
                    ],
                  ),
                ],
              ),
              if (quest.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(quest.description),
              ],
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text(quest.category),
                    avatar: const Icon(Icons.category, size: 16),
                  ),
                  Chip(
                    label: Text(
                      switch (quest.difficulty) {
                        QuestDifficulty.easy => 'Dễ (+20 XP)',
                        QuestDifficulty.medium => 'Vừa (+40 XP)',
                        QuestDifficulty.hard => 'Khó (+70 XP)',
                      },
                    ),
                  ),
                  if (quest.dueAt != null)
                    Chip(
                      label: Text(
                        'Hạn: ${DateFormat('dd/MM/yyyy HH:mm').format(quest.dueAt!.toLocal())}',
                      ),
                      avatar: const Icon(Icons.alarm, size: 16),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Tiến độ ${(quest.progress * 100).round()}%',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: quest.progress),
              const SizedBox(height: 16),
              if (quest.steps.isEmpty)
                const Text('Nhiệm vụ không có bước con.')
              else
                ...quest.steps.map(
                  (step) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: step.isDone,
                    title: Text(step.title),
                    onChanged: (quest.status == QuestStatus.completed || busy)
                        ? null
                        : (_) async {
                            setState(() => busy = true);
                            try {
                              await controller.toggleStep(quest.id, step.id);
                            } finally {
                              if (mounted) setState(() => busy = false);
                            }
                          },
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: (quest.status == QuestStatus.completed || busy)
                    ? null
                    : () async {
                        setState(() => busy = true);
                        try {
                          final result = await controller.completeQuest(
                            quest.id,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result.idempotent
                                      ? 'Nhiệm vụ đã hoàn thành trước đó.'
                                      : 'Hoàn thành! Bạn nhận +${result.xpAwarded} XP 🎉',
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        } on ApiException catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(e.message)));
                          }
                        } finally {
                          if (mounted) setState(() => busy = false);
                        }
                      },
                icon: busy
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.celebration),
                label: Text(
                  busy
                      ? 'Đang xử lý...'
                      : (quest.status == QuestStatus.completed
                          ? 'Đã hoàn thành'
                          : 'Hoàn thành nhiệm vụ'),
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
    this.initialDescription = '',
    this.initialSteps = const [],
    this.initialCategory = 'Sức khỏe',
    this.initialDifficulty = QuestDifficulty.easy,
    this.initialImageUrl,
    this.createdByAi = false,
    this.groupId,
    super.key,
  });

  final String initialTitle;
  final String initialDescription;
  final List<String> initialSteps;
  final String initialCategory;
  final QuestDifficulty initialDifficulty;
  final String? initialImageUrl;
  final bool createdByAi;
  final String? groupId;

  @override
  ConsumerState<CreateQuestSheet> createState() => _CreateQuestSheetState();
}

class _CreateQuestSheetState extends ConsumerState<CreateQuestSheet> {
  late String? imageUrl = widget.initialImageUrl;
  late final TextEditingController title = TextEditingController(
    text: widget.initialTitle,
  );
  late final TextEditingController description = TextEditingController(
    text: widget.initialDescription,
  );
  late final TextEditingController steps = TextEditingController(
    text: widget.initialSteps.join('\n'),
  );
  late QuestDifficulty difficulty = widget.initialDifficulty;
  late String category = widget.initialCategory;
  late String? selectedGroupId = widget.groupId;
  DateTime? dueAt;
  String? assigneeId;
  bool saving = false;
  String? error;

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    steps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(appControllerProvider);
    final group = selectedGroupId != null
        ? controller.groups
            .where((g) => g.id == selectedGroupId)
            .firstOrNull
        : null;

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
              Text(
                widget.createdByAi ? 'Duyệt bản nháp AI' : 'Tạo nhiệm vụ',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (imageUrl != null && imageUrl!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl!,
                        height: 130,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 70,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: const Text('Ảnh đính kèm từ AI Vision'),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: IconButton.filledTonal(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => setState(() => imageUrl = null),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: title,
                maxLength: 80,
                decoration: const InputDecoration(
                  labelText: 'Tên nhiệm vụ *',
                  hintText: 'Tối đa 80 ký tự',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: description,
                maxLength: 500,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  hintText: 'Tối đa 500 ký tự',
                ),
              ),
              const SizedBox(height: 10),
              if (widget.groupId == null && controller.groups.isNotEmpty) ...[
                DropdownButtonFormField<String?>(
                  isExpanded: true,
                  initialValue: selectedGroupId,
                  decoration: const InputDecoration(
                    labelText: 'Phạm vi nhiệm vụ',
                    prefixIcon: Icon(Icons.hub_outlined),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Cá nhân (Chỉ mình tôi)', overflow: TextOverflow.ellipsis),
                    ),
                    ...controller.groups.map(
                      (g) => DropdownMenuItem<String?>(
                        value: g.id,
                        child: Text('${g.name} (Nhóm)', overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() {
                    selectedGroupId = value;
                    assigneeId = null;
                  }),
                ),
                const SizedBox(height: 10),
              ],
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Danh mục'),
                items:
                    const [
                          'Sức khỏe',
                          'Học tập',
                          'Công việc',
                          'Gia đình',
                          'Khác',
                        ]
                        .map(
                          (item) =>
                              DropdownMenuItem(value: item, child: Text(item)),
                        )
                        .toList(),
                onChanged: (value) => setState(() => category = value!),
              ),
              const SizedBox(height: 10),
              SegmentedButton<QuestDifficulty>(
                segments: const [
                  ButtonSegment(
                    value: QuestDifficulty.easy,
                    label: Text('Dễ (+20)'),
                  ),
                  ButtonSegment(
                    value: QuestDifficulty.medium,
                    label: Text('Vừa (+40)'),
                  ),
                  ButtonSegment(
                    value: QuestDifficulty.hard,
                    label: Text('Khó (+70)'),
                  ),
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
                  labelText: 'Các bước (mỗi dòng một bước, tối đa 160 ký tự/bước)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 10),
              if (group != null) ...[
                DropdownButtonFormField<String?>(
                  isExpanded: true,
                  initialValue: assigneeId,
                  decoration: const InputDecoration(
                    labelText: 'Giao cho thành viên (tùy chọn)',
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Cả nhóm (ai cũng có thể làm)'),
                    ),
                    ...group.members.map(
                      (m) => DropdownMenuItem<String?>(
                        value: m.id,
                        child: Text('${m.displayName} (${m.role})'),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => assigneeId = value),
                ),
                const SizedBox(height: 10),
              ],
              OutlinedButton.icon(
                onPressed: () async {
                  final now = DateTime.now();
                  final date = await showDatePicker(
                    context: context,
                    firstDate: now,
                    lastDate: now.add(const Duration(days: 365)),
                    initialDate: dueAt ?? now,
                  );
                  if (date != null && context.mounted) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    final hour = time?.hour ?? 20;
                    final minute = time?.minute ?? 0;
                    setState(
                      () => dueAt = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        hour,
                        minute,
                      ),
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
              if (error != null) ...[
                const SizedBox(height: 10),
                Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: saving
                    ? null
                    : () async {
                        final titleText = title.text.trim();
                        if (titleText.isEmpty) {
                          setState(
                            () => error = 'Vui lòng nhập tên nhiệm vụ.',
                          );
                          return;
                        }
                        if (titleText.length > 80) {
                          setState(
                            () => error = 'Tên nhiệm vụ tối đa 80 ký tự.',
                          );
                          return;
                        }
                        final descText = description.text.trim();
                        if (descText.length > 500) {
                          setState(
                            () => error = 'Mô tả nhiệm vụ tối đa 500 ký tự.',
                          );
                          return;
                        }

                        final stepLines = steps.text
                            .split('\n')
                            .map((s) => s.trim())
                            .where((s) => s.isNotEmpty)
                            .toList();

                        for (final s in stepLines) {
                          if (s.length > 160) {
                            setState(
                              () => error =
                                  'Mỗi bước tối đa 160 ký tự: "${s.substring(0, 20)}..."',
                            );
                            return;
                          }
                        }

                        setState(() {
                          saving = true;
                          error = null;
                        });

                        try {
                          await ref
                              .read(appControllerProvider)
                              .addQuest(
                                title: titleText,
                                description: descText,
                                category: category,
                                difficulty: difficulty,
                                steps: stepLines,
                                dueAt: dueAt,
                                createdByAi: widget.createdByAi,
                                groupId: selectedGroupId,
                                assigneeId: assigneeId,
                                imageUrl: imageUrl,
                              );
                          if (context.mounted) Navigator.pop(context);
                        } on ApiException catch (e) {
                          setState(() => error = e.message);
                        } catch (e) {
                          setState(
                            () => error = 'Không thể lưu nhiệm vụ. Thử lại.',
                          );
                        } finally {
                          if (mounted) setState(() => saving = false);
                        }
                      },
                child: Text(saving ? 'Đang lưu...' : 'Lưu nhiệm vụ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditQuestSheet extends ConsumerStatefulWidget {
  const EditQuestSheet({required this.quest, super.key});
  final Quest quest;

  @override
  ConsumerState<EditQuestSheet> createState() => _EditQuestSheetState();
}

class _EditQuestSheetState extends ConsumerState<EditQuestSheet> {
  late final TextEditingController title = TextEditingController(
    text: widget.quest.title,
  );
  late final TextEditingController description = TextEditingController(
    text: widget.quest.description,
  );
  late QuestDifficulty difficulty = widget.quest.difficulty;
  late String category = widget.quest.category;
  late DateTime? dueAt = widget.quest.dueAt;
  bool saving = false;
  String? error;

  @override
  void dispose() {
    title.dispose();
    description.dispose();
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
              'Chỉnh sửa nhiệm vụ',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: title,
              maxLength: 80,
              decoration: const InputDecoration(labelText: 'Tên nhiệm vụ *'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: description,
              maxLength: 500,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Mô tả'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: category,
              decoration: const InputDecoration(labelText: 'Danh mục'),
              items:
                  const ['Sức khỏe', 'Học tập', 'Công việc', 'Gia đình', 'Khác']
                      .map(
                        (item) =>
                            DropdownMenuItem(value: item, child: Text(item)),
                      )
                      .toList(),
              onChanged: (value) => setState(() => category = value!),
            ),
            const SizedBox(height: 10),
            SegmentedButton<QuestDifficulty>(
              segments: const [
                ButtonSegment(
                  value: QuestDifficulty.easy,
                  label: Text('Dễ (+20)'),
                ),
                ButtonSegment(
                  value: QuestDifficulty.medium,
                  label: Text('Vừa (+40)'),
                ),
                ButtonSegment(
                  value: QuestDifficulty.hard,
                  label: Text('Khó (+70)'),
                ),
              ],
              selected: {difficulty},
              onSelectionChanged: (value) =>
                  setState(() => difficulty = value.first),
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
                if (date != null && context.mounted) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  final hour = time?.hour ?? 20;
                  final minute = time?.minute ?? 0;
                  setState(
                    () => dueAt = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      hour,
                      minute,
                    ),
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
            if (error != null) ...[
              const SizedBox(height: 10),
              Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      final titleText = title.text.trim();
                      if (titleText.isEmpty) {
                        setState(
                          () => error = 'Vui lòng nhập tên nhiệm vụ.',
                        );
                        return;
                      }
                      if (titleText.length > 80) {
                        setState(
                          () => error = 'Tên nhiệm vụ tối đa 80 ký tự.',
                        );
                        return;
                      }
                      final descText = description.text.trim();
                      if (descText.length > 500) {
                        setState(
                          () => error = 'Mô tả nhiệm vụ tối đa 500 ký tự.',
                        );
                        return;
                      }

                      setState(() {
                        saving = true;
                        error = null;
                      });

                      try {
                        await ref
                            .read(appControllerProvider)
                            .updateQuest(
                              widget.quest.id,
                              title: titleText,
                              description: descText,
                              category: category,
                              difficulty: difficulty,
                              dueAt: dueAt,
                            );
                        if (context.mounted) Navigator.pop(context);
                      } on ApiException catch (e) {
                        setState(() => error = e.message);
                      } catch (e) {
                        setState(
                          () => error = 'Không thể cập nhật nhiệm vụ.',
                        );
                      } finally {
                        if (mounted) setState(() => saving = false);
                      }
                    },
              child: Text(saving ? 'Đang lưu...' : 'Lưu thay đổi'),
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
  final controller = TextEditingController();
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Báo cáo nội dung'),
      content: StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              isExpanded: true,
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
                        (item) =>
                            DropdownMenuItem(value: item, child: Text(item)),
                      )
                      .toList(),
              onChanged: (value) => setState(() => reason = value!),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              maxLength: 500,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Chi tiết thêm (tùy chọn)',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () async {
            final detail = controller.text.trim();
            final finalReason = detail.isNotEmpty ? '$reason: $detail' : reason;
            try {
              await ref
                  .read(appControllerProvider)
                  .report(type, id, finalReason);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã gửi báo cáo vi phạm.')),
                );
              }
            } on ApiException catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(e.message)));
              }
            }
          },
          child: const Text('Gửi báo cáo'),
        ),
      ],
    ),
  );
  controller.dispose();
}
