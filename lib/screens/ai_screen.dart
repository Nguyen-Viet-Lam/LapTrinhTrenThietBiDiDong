import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_exception.dart';
import '../app_controller.dart';
import '../models.dart';
import 'profile_screen.dart';
import 'quest_widgets.dart';

class AiScreen extends ConsumerStatefulWidget {
  const AiScreen({super.key});
  @override
  ConsumerState<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends ConsumerState<AiScreen> {
  final goal = TextEditingController(
    text: 'Ôn thi môn Lập trình thiết bị di động trong 7 ngày',
  );
  final constraints = TextEditingController();
  QuestDifficulty difficulty = QuestDifficulty.easy;
  AiQuestDraft? draft;
  String? error;
  bool isUnsafeError = false;
  bool loading = false;

  @override
  void dispose() {
    goal.dispose();
    constraints.dispose();
    super.dispose();
  }

  Future<void> generate() async {
    final goalText = goal.text.trim();
    if (goalText.length < 5) {
      setState(() {
        error = 'Hãy mô tả mục tiêu rõ hơn một chút (ít nhất 5 ký tự).';
        isUnsafeError = false;
      });
      return;
    }
    if (goalText.length > 300) {
      setState(() {
        error = 'Mục tiêu không quá 300 ký tự.';
        isUnsafeError = false;
      });
      return;
    }

    setState(() {
      loading = true;
      error = null;
      isUnsafeError = false;
      draft = null;
    });

    try {
      final result = await ref
          .read(appControllerProvider)
          .generateAiPlan(
            goalText,
            difficulty,
            constraints: constraints.text.trim().isEmpty
                ? null
                : constraints.text.trim(),
          );
      if (mounted) setState(() => draft = result);
    } on ApiException catch (exception) {
      if (mounted) {
        setState(() {
          error = exception.message;
          isUnsafeError = exception.statusCode == 422;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          error = 'Chưa thể tạo kế hoạch lúc này. Vui lòng thử lại sau.';
          isUnsafeError = false;
        });
      }
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
        minLines: 2,
        maxLines: 4,
        maxLength: 300,
        decoration: const InputDecoration(
          hintText: 'Ví dụ: Ôn thi môn Lập trình thiết bị di động trong 7 ngày',
          alignLabelWithHint: true,
        ),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: constraints,
        maxLength: 200,
        decoration: const InputDecoration(
          labelText: 'Ràng buộc hoặc lưu ý (tùy chọn)',
          hintText: 'Ví dụ: Dành 30 phút mỗi tối sau 8h',
        ),
      ),
      const SizedBox(height: 10),
      SegmentedButton<QuestDifficulty>(
        segments: const [
          ButtonSegment(
            value: QuestDifficulty.easy,
            label: Text('Nhẹ nhàng (3 bước)'),
          ),
          ButtonSegment(
            value: QuestDifficulty.medium,
            label: Text('Cân bằng (5 bước)'),
          ),
          ButtonSegment(
            value: QuestDifficulty.hard,
            label: Text('Thử thách (7 bước)'),
          ),
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
        label: Text(loading ? 'Đang tạo kế hoạch...' : 'Tạo kế hoạch an toàn'),
      ),
      if (error != null) ...[
        const SizedBox(height: 14),
        Card(
          color: isUnsafeError
              ? Theme.of(context).colorScheme.errorContainer
              : Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isUnsafeError ? Icons.warning_amber_rounded : Icons.info_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isUnsafeError ? 'Cảnh báo an toàn' : 'Thông báo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
                if (isUnsafeError) ...[
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      showDragHandle: true,
                      builder: (_) => const SafetyCenterSheet(),
                    ),
                    child: const Text('Xem Trung tâm an toàn'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
      if (draft != null) ...[
        const SizedBox(height: 22),
        Row(
          children: [
            const Icon(Icons.fact_check_outlined),
            const SizedBox(width: 8),
            Text(
              'Bản nháp đề xuất (${draft!.steps.length} bước • ~${draft!.estimatedMinutes} phút)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(draft!.description, style: Theme.of(context).textTheme.bodyMedium),
        if (draft!.safetyNote.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    draft!.safetyNote,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        ...draft!.steps.asMap().entries.map(
          (entry) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(child: Text('${entry.key + 1}')),
              title: Text(entry.value),
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (_) => CreateQuestSheet(
              initialTitle: draft!.title,
              initialDescription: draft!.description,
              initialCategory: draft!.category,
              initialDifficulty: draft!.difficulty,
              initialSteps: draft!.steps,
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
