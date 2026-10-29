import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_exception.dart';
import '../app_controller.dart';
import '../models.dart';
import 'profile_screen.dart';
import 'quest_widgets.dart';

class VisionPreset {
  const VisionPreset({
    required this.id,
    required this.name,
    required this.icon,
    required this.imageUrl,
    required this.suggestedNote,
  });

  final String id;
  final String name;
  final IconData icon;
  final String imageUrl;
  final String suggestedNote;
}

const visionPresets = [
  VisionPreset(
    id: 'badminton',
    name: 'Sân cầu lông',
    icon: Icons.sports_tennis,
    imageUrl:
        'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=800&q=80',
    suggestedNote: 'Tập phát cầu chính xác và đánh đôi 30 phút rèn phản xạ',
  ),
  VisionPreset(
    id: 'volleyball',
    name: 'Sân bóng rổ / chuyền',
    icon: Icons.sports_basketball,
    imageUrl:
        'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800&q=80',
    suggestedNote: 'Luyện đệm bóng và thi đấu giao lưu tăng thể lực',
  ),
  VisionPreset(
    id: 'gym',
    name: 'Phòng Gym',
    icon: Icons.fitness_center,
    imageUrl:
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&q=80',
    suggestedNote: 'Buổi tập ngực và cơ vai kèm 15 phút cardio',
  ),
  VisionPreset(
    id: 'study',
    name: 'Góc học tập / Đồ án',
    icon: Icons.laptop_chromebook,
    imageUrl:
        'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800&q=80',
    suggestedNote: 'Ôn tập môn Thiết bị di động và hoàn thiện slide báo cáo',
  ),
  VisionPreset(
    id: 'park',
    name: 'Công viên chạy bộ',
    icon: Icons.directions_run,
    imageUrl:
        'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=800&q=80',
    suggestedNote: 'Chạy bộ 3km hít thở không khí trong lành buổi sáng',
  ),
];

class AiScreen extends ConsumerStatefulWidget {
  const AiScreen({super.key});
  @override
  ConsumerState<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends ConsumerState<AiScreen> {
  int tabIndex = 0; // 0: Text Plan, 1: Vision Quest

  // Text Plan State
  final goal = TextEditingController(
    text: 'Ôn thi môn Lập trình thiết bị di động trong 7 ngày',
  );
  final constraints = TextEditingController();
  QuestDifficulty difficulty = QuestDifficulty.easy;

  // Vision Quest State
  int selectedPresetIndex = 0;
  late final TextEditingController visionNote = TextEditingController(
    text: visionPresets[0].suggestedNote,
  );
  late final TextEditingController customImageUrl = TextEditingController();
  bool useCustomImage = false;

  AiQuestDraft? draft;
  String? error;
  bool isUnsafeError = false;
  bool loading = false;

  @override
  void dispose() {
    goal.dispose();
    constraints.dispose();
    visionNote.dispose();
    customImageUrl.dispose();
    super.dispose();
  }

  void onSelectPreset(int index) {
    setState(() {
      selectedPresetIndex = index;
      useCustomImage = false;
      visionNote.text = visionPresets[index].suggestedNote;
    });
  }

  Future<void> generateTextPlan() async {
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

  Future<void> generateVisionPlan() async {
    final activeUrl = useCustomImage && customImageUrl.text.trim().isNotEmpty
        ? customImageUrl.text.trim()
        : visionPresets[selectedPresetIndex].imageUrl;
    final contextName = visionPresets[selectedPresetIndex].name;
    final noteText = visionNote.text.trim();

    setState(() {
      loading = true;
      error = null;
      isUnsafeError = false;
      draft = null;
    });

    try {
      final result = await ref
          .read(appControllerProvider)
          .generateVisionQuest(
            contextLabel: contextName,
            photoUrl: activeUrl,
            userNote: noteText.isEmpty ? null : noteText,
            difficulty: difficulty,
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
          error = 'Chưa thể phân tích ảnh lúc này. Vui lòng thử lại sau.';
          isUnsafeError = false;
        });
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activePhotoUrl = useCustomImage && customImageUrl.text.trim().isNotEmpty
        ? customImageUrl.text.trim()
        : visionPresets[selectedPresetIndex].imageUrl;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        // Mode Switcher
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(
              value: 0,
              icon: Icon(Icons.edit_note),
              label: Text('Mục tiêu chữ'),
            ),
            ButtonSegment(
              value: 1,
              icon: Icon(Icons.camera_alt_outlined),
              label: Text('📸 AI Thị giác'),
            ),
          ],
          selected: {tabIndex},
          onSelectionChanged: (set) => setState(() {
            tabIndex = set.first;
            error = null;
            isUnsafeError = false;
            draft = null;
          }),
        ),
        const SizedBox(height: 14),

        // Safety Banner
        Card(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'AI chỉ tạo bản nháp. Bạn luôn được xem lại, sửa đổi và quyết định trước khi lưu nhiệm vụ.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        if (tabIndex == 0) ...[
          // ================== TAB 0: TEXT PLAN ==================
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
              hintText:
                  'Ví dụ: Ôn thi môn Lập trình thiết bị di động trong 7 ngày',
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
        ] else ...[
          // ================== TAB 1: VISION QUEST ==================
          Text(
            'Chọn bối cảnh chụp ảnh thực tế:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: visionPresets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final preset = visionPresets[idx];
                final isSelected = !useCustomImage && selectedPresetIndex == idx;
                return ChoiceChip(
                  avatar: Icon(preset.icon, size: 18),
                  label: Text(preset.name),
                  selected: isSelected,
                  onSelected: (_) => onSelectPreset(idx),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Photo Preview Card
          Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    activePhotoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.image_not_supported_outlined, size: 36),
                            SizedBox(height: 6),
                            Text('Hình ảnh minh chứng bối cảnh'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lens_blur_outlined, color: Colors.greenAccent, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          visionPresets[selectedPresetIndex].name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: visionNote,
            maxLength: 160,
            decoration: const InputDecoration(
              labelText: 'Mục tiêu hoặc lưu ý tại địa điểm (tùy chọn)',
              hintText: 'Ví dụ: Tập giao cầu và đánh đôi 30 phút rèn phản xạ',
            ),
          ),
        ],

        const SizedBox(height: 10),
        Text(
          'Mức độ thử thách:',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        SegmentedButton<QuestDifficulty>(
          segments: const [
            ButtonSegment(
              value: QuestDifficulty.easy,
              label: Text('Dễ (3 bước)'),
            ),
            ButtonSegment(
              value: QuestDifficulty.medium,
              label: Text('Vừa (5 bước)'),
            ),
            ButtonSegment(
              value: QuestDifficulty.hard,
              label: Text('Khó (7 bước)'),
            ),
          ],
          selected: {difficulty},
          onSelectionChanged: (value) => setState(() => difficulty = value.first),
        ),
        const SizedBox(height: 18),

        FilledButton.icon(
          onPressed: loading
              ? null
              : (tabIndex == 0 ? generateTextPlan : generateVisionPlan),
          icon: loading
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(tabIndex == 0 ? Icons.auto_awesome : Icons.camera_enhance),
          label: Text(
            loading
                ? 'Đang phân tích và tạo...'
                : (tabIndex == 0
                    ? 'Tạo kế hoạch an toàn'
                    : '📸 Phân tích ảnh & Tạo nhiệm vụ'),
          ),
        ),

        // Error Card
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
                        isUnsafeError
                            ? Icons.warning_amber_rounded
                            : Icons.info_outline,
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

        // Draft Result Card
        if (draft != null) ...[
          const SizedBox(height: 22),
          Row(
            children: [
              const Icon(Icons.fact_check_outlined),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bản nháp đề xuất (${draft!.steps.length} bước • ~${draft!.estimatedMinutes} phút)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(draft!.description, style: Theme.of(context).textTheme.bodyMedium),
          if (draft!.imageUrl != null && draft!.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                draft!.imageUrl!,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
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
                initialImageUrl: draft!.imageUrl,
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
}
