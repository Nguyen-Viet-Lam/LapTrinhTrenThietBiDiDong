import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_controller.dart';
import '../models.dart';
import 'quest_widgets.dart';

class AiScreen extends ConsumerStatefulWidget {
  const AiScreen({super.key});
  @override
  ConsumerState<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends ConsumerState<AiScreen> {
  final goal = TextEditingController();
  QuestDifficulty difficulty = QuestDifficulty.easy;
  List<String>? plan;
  String? error;
  bool loading = false;

  @override
  void dispose() {
    goal.dispose();
    super.dispose();
  }

  Future<void> generate() async {
    if (goal.text.trim().length < 5) {
      setState(() => error = 'Hãy mô tả mục tiêu rõ hơn một chút.');
      return;
    }
    setState(() {
      loading = true;
      error = null;
      plan = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 650));
    try {
      final result = ref
          .read(appControllerProvider)
          .generateAiPlan(goal.text.trim(), difficulty);
      if (mounted) setState(() => plan = result);
    } on FormatException catch (exception) {
      if (mounted) setState(() => error = exception.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
    children: [
      Card(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.shield_outlined),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'AI chỉ tạo bản nháp. Bạn luôn được xem, sửa và quyết định trước khi lưu. Không nhập thông tin riêng tư hoặc bí mật.',
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      Text(
        'Bạn muốn đạt được điều gì?',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 10),
      TextField(
        controller: goal,
        minLines: 3,
        maxLines: 5,
        maxLength: 300,
        decoration: const InputDecoration(
          hintText: 'Ví dụ: Ôn thi môn Lập trình thiết bị di động trong 7 ngày',
          alignLabelWithHint: true,
        ),
      ),
      const SizedBox(height: 10),
      SegmentedButton<QuestDifficulty>(
        segments: const [
          ButtonSegment(value: QuestDifficulty.easy, label: Text('Nhẹ nhàng')),
          ButtonSegment(value: QuestDifficulty.medium, label: Text('Cân bằng')),
          ButtonSegment(value: QuestDifficulty.hard, label: Text('Thử thách')),
        ],
        selected: {difficulty},
        onSelectionChanged: (value) => setState(() => difficulty = value.first),
      ),
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: loading ? null : generate,
        icon: loading
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.auto_awesome),
        label: const Text('Tạo kế hoạch an toàn'),
      ),
      if (error != null)
        Card(
          color: Theme.of(context).colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(error!),
          ),
        ),
      if (plan != null) ...[
        const SizedBox(height: 22),
        Row(
          children: [
            const Icon(Icons.fact_check_outlined),
            const SizedBox(width: 8),
            Text(
              'Bản nháp đề xuất',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...plan!.asMap().entries.map(
          (entry) => Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${entry.key + 1}')),
              title: Text(entry.value),
            ),
          ),
        ),
        const SizedBox(height: 10),
        FilledButton.tonalIcon(
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (_) => CreateQuestSheet(
              initialTitle: goal.text.trim(),
              initialSteps: plan!,
              createdByAi: true,
            ),
          ),
          icon: const Icon(Icons.edit_note),
          label: const Text('Xem lại và lưu thành quest'),
        ),
      ],
    ],
  );
}
