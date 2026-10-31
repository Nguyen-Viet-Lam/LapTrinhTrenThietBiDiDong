import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future<void> _showScanOrImportQuestDialog(BuildContext context) async {
    final textController = TextEditingController();
    String? dialogError;
    bool processing = false;
    Map<String, dynamic>? parsedQuest;

    void parseQrString(String input) {
      final trimmed = input.trim();
      if (trimmed.isEmpty) return;

      try {
        if (trimmed.startsWith('lifequest://quest')) {
          final uri = Uri.parse(trimmed);
          final title = uri.queryParameters['title'] ?? 'Nhiệm vụ làm chung';
          final desc = uri.queryParameters['desc'] ?? '';
          final cat = uri.queryParameters['cat'] ?? 'Khác';
          final diffStr = uri.queryParameters['diff'] ?? 'medium';
          final stepsStr = uri.queryParameters['steps'] ?? '';
          final xpStr = uri.queryParameters['xp'] ?? '50';
          final img = uri.queryParameters['img'];

          final steps = stepsStr.split('|||').where((s) => s.trim().isNotEmpty).toList();
          final diff = QuestDifficulty.values.firstWhere(
            (d) => d.name == diffStr,
            orElse: () => QuestDifficulty.medium,
          );

          parsedQuest = {
            'title': title,
            'description': desc,
            'category': cat,
            'difficulty': diff,
            'steps': steps.isNotEmpty ? steps : ['Thực hiện nhiệm vụ cùng bạn bè'],
            'xp': int.tryParse(xpStr) ?? 50,
            'imageUrl': img,
          };
          dialogError = null;
        } else {
          parsedQuest = {
            'title': trimmed,
            'description': 'Nhiệm vụ nhận từ bạn bè qua mã chia sẻ.',
            'category': 'Khác',
            'difficulty': QuestDifficulty.medium,
            'steps': ['Bắt đầu thực hiện', 'Hoàn tất cùng bạn bè'],
            'xp': 50,
            'imageUrl': null,
          };
          dialogError = null;
        }
      } catch (e) {
        dialogError = 'Mã QR không đúng định dạng LifeQuest: $e';
      }
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              MediaQuery.viewInsetsOf(ctx).bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner,
                          color: Color(0xFF0284C7),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quét / Nhập QR Nhiệm vụ',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Nhận nhiệm vụ rèn luyện từ bạn bè để cùng làm chung!',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      labelText: 'Dán mã QR hoặc liên kết nhiệm vụ',
                      hintText: 'lifequest://quest?title=... hoặc bấm Dán',
                      prefixIcon: const Icon(Icons.link),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.paste),
                        tooltip: 'Dán từ clipboard',
                        onPressed: () async {
                          final data = await Clipboard.getData('text/plain');
                          if (data?.text != null) {
                            textController.text = data!.text!;
                            setModalState(() {
                              parseQrString(data.text!);
                            });
                          }
                        },
                      ),
                    ),
                    onChanged: (val) {
                      setModalState(() {
                        parseQrString(val);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'Thử nhanh:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.sports_tennis, size: 14),
                        label: const Text('🏸 Kèo Cầu lông HUTECH', style: TextStyle(fontSize: 12)),
                        onPressed: () {
                          const sample = 'lifequest://quest?title=K%C3%A8o%20C%E1%BA%A7u%20l%C3%B4ng%20HUTECH%20r%C3%A8n%20ph%E1%BA%A3n%20x%E1%BA%A1&desc=%C4%90%C3%A1nh%20c%E1%BA%A7u%20l%C3%B4ng%20%C4%91%C3%B4i%20c%C3%B9ng%20b%E1%BA%A1n%20b%C3%A8%20sau%20gi%E1%BB%9D%20h%E1%BB%8Dc&cat=S%E1%BB%A9c%20kh%E1%BB%8Fe&diff=medium&steps=Kh%E1%BB%9Fi%20%C4%91%E1%BB%99ng%20kh%E1%BB%9Bp%20c%E1%BB%95%20tay%20v%C3%A0%20g%E1%BB%91i|||T%E1%BA%ADp%20ph%C3%A1t%20c%E1%BA%A7u%20ch%C3%ADnh%20x%C3%A1c|||Thi%20%C4%91%E1%BA%A5u%20set%2021%20%C4%91i%E1%BB%83m&xp=100';
                          textController.text = sample;
                          setModalState(() {
                            parseQrString(sample);
                          });
                        },
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.directions_run, size: 14),
                        label: const Text('🏃 Chạy bộ 3km', style: TextStyle(fontSize: 12)),
                        onPressed: () {
                          const sample = 'lifequest://quest?title=Ch%E1%BA%A1y%20b%E1%BB%99%203km%20c%C3%B4ng%20vi%C3%AAn&desc=R%C3%A8n%20luy%E1%BB%87n%20s%E1%BB%A9c%20b%E1%BB%81n%20bu%E1%BB%95i%20s%C3%A1ng&cat=S%E1%BB%A9c%20kh%E1%BB%8Fe&diff=easy&steps=Kh%E1%BB%9Fi%20%C4%91%E1%BB%99ng%205%20ph%C3%BAt|||Ch%E1%BA%A1y%20%C4%91%E1%BB%81u%203km|||Gi%C3%A3n%20c%C6%A1&xp=60';
                          textController.text = sample;
                          setModalState(() {
                            parseQrString(sample);
                          });
                        },
                      ),
                    ],
                  ),
                  if (dialogError != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      dialogError!,
                      style: TextStyle(
                        color: Theme.of(ctx).colorScheme.error,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  if (parsedQuest != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.verified, color: Color(0xFF16A34A), size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  parsedQuest!['title'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF14532D),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '+${parsedQuest!['xp']} XP',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF15803D),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if ((parsedQuest!['description'] as String).isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              parsedQuest!['description'] as String,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF166534)),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            'Danh sách các bước (${(parsedQuest!['steps'] as List).length} bước):',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF166534),
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...((parsedQuest!['steps'] as List).asMap().entries.map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Text(
                                    '  • Bước ${e.key + 1}: ${e.value}',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF14532D)),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: processing
                          ? null
                          : () async {
                              setModalState(() => processing = true);
                              try {
                                await ref.read(appControllerProvider).addQuest(
                                      title: parsedQuest!['title'] as String,
                                      description: parsedQuest!['description'] as String,
                                      category: parsedQuest!['category'] as String,
                                      difficulty: parsedQuest!['difficulty'] as QuestDifficulty,
                                      steps: List<String>.from(parsedQuest!['steps'] as List),
                                      imageUrl: parsedQuest!['imageUrl'] as String?,
                                    );
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '🎉 Đã nhận nhiệm vụ "${parsedQuest!['title']}" thành công! Cùng rèn luyện nhé!',
                                      ),
                                      backgroundColor: const Color(0xFF16A34A),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  refresh();
                                }
                              } catch (e) {
                                setModalState(() {
                                  dialogError = 'Không thể lưu nhiệm vụ: $e';
                                  processing = false;
                                });
                              }
                            },
                      icon: const Icon(Icons.add_task),
                      label: Text(
                        processing ? 'Đang nạp nhiệm vụ...' : '🚀 Nhận làm chung nhiệm vụ này ngay!',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) => setState(() => search = value),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Tìm theo tên hoặc danh mục',
                      ),
                    ),
                  ),
                  if (!isAdmin) ...[
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.qr_code_scanner),
                      tooltip: 'Quét & Nhập QR nhiệm vụ',
                      onPressed: () => _showScanOrImportQuestDialog(context),
                    ),
                  ],
                ],
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
