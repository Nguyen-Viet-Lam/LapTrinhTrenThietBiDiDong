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
  String selectedCategory = 'Tất cả';
  String search = '';
  bool refreshing = false;
  String? error;

  Future<void> refresh() async {
    setState(() {
      refreshing = true;
      error = null;
    });
    try {
      await ref.read(appControllerProvider).fetchQuests();
    } catch (e) {
      if (mounted) setState(() => error = 'Không thể tải danh sách quest.');
    } finally {
      if (mounted) setState(() => refreshing = false);
    }
  }

  Widget _buildDiscoveryChip(String name, IconData icon) {
    final isSelected = selectedCategory == name;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        avatar: Icon(
          icon,
          size: 16,
          color: isSelected ? Colors.white : const Color(0xFF0284C7),
        ),
        label: Text(name),
        labelStyle: TextStyle(
          fontSize: 12.5,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? Colors.white : const Color(0xFF334155),
        ),
        selectedColor: const Color(0xFF0284C7),
        backgroundColor: const Color(0xFFF1F5F9),
        checkmarkColor: Colors.white,
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
          ),
        ),
        onSelected: (_) => setState(() => selectedCategory = name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(appControllerProvider);
    final isAdmin = controller.isAdmin;
    final quests = controller.myQuests.where((quest) {
      final matchesStatus = quest.status == status;
      final matchesCategory = selectedCategory == 'Tất cả' ||
          quest.category.trim().toLowerCase() == selectedCategory.trim().toLowerCase();
      final term = search.trim().toLowerCase();
      return matchesStatus &&
          matchesCategory &&
          (term.isEmpty ||
              quest.title.toLowerCase().contains(term) ||
              quest.category.toLowerCase().contains(term));
    }).toList();

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              if (isAdmin)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: Color(0xFF2563EB), size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Giám sát & Quản trị Nhiệm vụ',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Admin phụ trách giám sát và quản lý các thử thách của hệ thống. Admin không có nhiệm vụ cá nhân.',
                              style: TextStyle(fontSize: 12, color: Color(0xFF2563EB)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
              const SizedBox(height: 12),
              // Quest Discovery: 5 Trụ Cột Đời Thường & Danh Mục
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildDiscoveryChip('Tất cả', Icons.auto_awesome),
                    _buildDiscoveryChip('Sức khỏe', Icons.directions_run),
                    _buildDiscoveryChip('Học tập', Icons.school_outlined),
                    _buildDiscoveryChip('Công việc', Icons.work_outline),
                    _buildDiscoveryChip('Gia đình', Icons.family_restroom),
                    _buildDiscoveryChip('Khác', Icons.grid_view_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (error != null)
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          error!,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FilledButton.tonal(
                          onPressed: refresh,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (quests.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: [
                        Icon(
                          isAdmin ? Icons.shield_outlined : Icons.inbox_outlined,
                          size: 54,
                          color: const Color(0xFF2563EB),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isAdmin
                              ? 'Admin không có nhiệm vụ cá nhân'
                              : 'Không có nhiệm vụ phù hợp.',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        if (isAdmin) ...[
                          const SizedBox(height: 6),
                          const Text(
                            'Bạn đang quản lý hệ thống. Các nhiệm vụ được giao cho các thành viên Kỳ, Lợi, Tuấn.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              else
                ...quests.map((quest) => QuestCard(quest: quest)),
            ],
          ),
        ),
        if (!isAdmin)
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
