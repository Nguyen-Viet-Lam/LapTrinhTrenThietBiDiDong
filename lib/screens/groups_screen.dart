import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../app_controller.dart';
import '../models.dart';
import 'quest_widgets.dart';

class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({super.key});

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen> {
  bool refreshing = false;
  String? error;

  Future<void> refresh() async {
    setState(() {
      refreshing = true;
      error = null;
    });
    try {
      await ref.read(appControllerProvider).fetchGroups();
    } catch (e) {
      if (mounted) setState(() => error = 'Không thể tải danh sách nhóm.');
    } finally {
      if (mounted) setState(() => refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(appControllerProvider).myGroups;

    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _join(context, ref),
                  icon: const Icon(Icons.group_add_outlined),
                  label: const Text('Nhập mã mời'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _create(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo nhóm'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
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
                        color: Theme.of(context).colorScheme.onErrorContainer,
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
          else if (groups.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Column(
                  children: [
                    Icon(Icons.groups_outlined, size: 56),
                    SizedBox(height: 8),
                    Text('Bạn chưa tham gia nhóm nào.'),
                  ],
                ),
              ),
            )
          else
            ...groups.map(
              (group) => Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 28,
                    child: Text(
                      group.name.isNotEmpty
                          ? group.name.substring(0, 1).toUpperCase()
                          : 'G',
                    ),
                  ),
                  title: Text(
                    group.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 3),
                      Text('${group.members.length} thành viên • ${group.description}'),
                      if (group.inviteCode != null) ...[
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: group.inviteCode!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã sao chép mã mời: ${group.inviteCode}'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFBAE6FD)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.key, size: 13, color: Color(0xFF0284C7)),
                                const SizedBox(width: 4),
                                Text(
                                  'Mã: ${group.inviteCode}',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0369A1),
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.copy, size: 12, color: Color(0xFF0284C7)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder: (_) => GroupDetailSheet(groupId: group.id),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final description = TextEditingController();
    String? dialogError;
    bool saving = false;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tạo nhóm mới'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                maxLength: 80,
                decoration: const InputDecoration(
                  labelText: 'Tên nhóm *',
                  hintText: 'Tối đa 80 ký tự',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: description,
                maxLength: 300,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  hintText: 'Tối đa 300 ký tự',
                ),
              ),
              if (dialogError != null) ...[
                const SizedBox(height: 8),
                Text(
                  dialogError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      final n = name.text.trim();
                      if (n.isEmpty) {
                        setState(() => dialogError = 'Vui lòng nhập tên nhóm.');
                        return;
                      }
                      if (n.length > 80) {
                        setState(() => dialogError = 'Tên nhóm tối đa 80 ký tự.');
                        return;
                      }
                      setState(() {
                        saving = true;
                        dialogError = null;
                      });
                      try {
                        await ref
                            .read(appControllerProvider)
                            .createGroup(n, description.text.trim());
                        if (context.mounted) Navigator.pop(context);
                      } on ApiException catch (e) {
                        setState(() => dialogError = e.message);
                      } catch (e) {
                        setState(() => dialogError = 'Không thể tạo nhóm.');
                      } finally {
                        setState(() => saving = false);
                      }
                    },
              child: Text(saving ? 'Đang tạo...' : 'Tạo'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    description.dispose();
  }

  Future<void> _join(BuildContext context, WidgetRef ref) async {
    final code = TextEditingController();
    String? dialogError;
    bool joining = false;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tham gia nhóm'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: code,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Mã mời',
                  hintText: 'Ví dụ LIFE2026',
                ),
              ),
              if (dialogError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    dialogError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: joining ? null : () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: joining
                  ? null
                  : () async {
                      if (code.text.trim().isEmpty) {
                        setState(() => dialogError = 'Vui lòng nhập mã mời.');
                        return;
                      }
                      setState(() {
                        joining = true;
                        dialogError = null;
                      });
                      final message = await ref
                          .read(appControllerProvider)
                          .joinGroup(code.text.trim());
                      if (message == null && context.mounted) {
                        Navigator.pop(context);
                      } else {
                        setState(() {
                          dialogError = message;
                          joining = false;
                        });
                      }
                    },
              child: Text(joining ? 'Đang vào...' : 'Tham gia'),
            ),
          ],
        ),
      ),
    );
    code.dispose();
  }
}

class GroupDetailSheet extends ConsumerStatefulWidget {
  const GroupDetailSheet({required this.groupId, super.key});
  final String groupId;

  @override
  ConsumerState<GroupDetailSheet> createState() => _GroupDetailSheetState();
}

class _GroupDetailSheetState extends ConsumerState<GroupDetailSheet> {
  StreamSubscription<GroupEvent>? _sseSub;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _subscribeSse();
  }

  void _subscribeSse() {
    final controller = ref.read(appControllerProvider);
    _sseSub = controller.subscribeGroupEvents(widget.groupId).listen(
      (event) {
        if (!mounted) return;
        setState(() => isConnected = true);
        if (event.type == 'group.deleted') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nhóm đã bị giải tán bởi trưởng nhóm.')),
          );
          Navigator.pop(context);
          return;
        }

        // Auto reload group and quests
        controller.getGroupDetail(widget.groupId);
        controller.fetchQuests(groupId: widget.groupId);
      },
      onError: (_) {
        if (mounted) setState(() => isConnected = false);
      },
    );
  }

  @override
  void dispose() {
    _sseSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(appControllerProvider);
    final group = controller.groups
        .where((item) => item.id == widget.groupId)
        .firstOrNull;

    if (group == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Nhóm không còn tồn tại.')),
      );
    }

    final isOwner = group.ownerId == controller.currentUserId;
    final groupQuests = controller.quests
        .where(
          (quest) =>
              quest.groupId == group.id && quest.status != QuestStatus.archived,
        )
        .toList();

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .88,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    group.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isConnected
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.grey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isConnected ? Colors.green : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isConnected ? 'Realtime SSE' : 'Đang kết nối',
                        style: TextStyle(
                          fontSize: 12,
                          color: isConnected ? Colors.green.shade800 : Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(group.description),
            const SizedBox(height: 16),
            if (isOwner && group.inviteCode != null)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.qr_code_2, color: Color(0xFF38BDF8), size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MÃ MỜI THÀNH VIÊN',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              'Hiệu lực bảo mật trong 7 ngày',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.4)),
                          ),
                          child: const Text(
                            'Chủ nhóm',
                            style: TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            group.inviteCode!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                              letterSpacing: 3,
                            ),
                          ),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF0284C7),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: group.inviteCode!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Đã sao chép mã mời: ${group.inviteCode!}'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('Sao chép'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Thành viên (${group.members.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ...group.members
                .where((m) => !controller.blockedUserIds.contains(m.id))
                .map((member) {
                  final isSelf = member.id == controller.currentUserId;
                  final isMemberOwner = member.role == 'owner';

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Text(
                        member.displayName.isNotEmpty
                            ? member.displayName.substring(0, 1).toUpperCase()
                            : 'U',
                      ),
                    ),
                    title: Text(member.displayName),
                    subtitle: Text(
                      isMemberOwner ? 'Trưởng nhóm' : 'Thành viên',
                    ),
                    trailing: isSelf
                        ? null
                        : PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'transfer') {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Chuyển quyền trưởng nhóm?'),
                                    content: Text(
                                      'Bạn có chắc chắn muốn chuyển quyền trưởng nhóm cho "${member.displayName}"?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Hủy'),
                                      ),
                                      FilledButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Chuyển quyền'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  try {
                                    await controller.transferGroupOwnership(
                                      group.id,
                                      member.id,
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Đã chuyển quyền trưởng nhóm.'),
                                        ),
                                      );
                                    }
                                  } on ApiException catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(e.message)),
                                      );
                                    }
                                  }
                                }
                              } else if (value == 'remove') {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Xóa thành viên?'),
                                    content: Text(
                                      'Bạn có chắc chắn muốn xóa "${member.displayName}" khỏi nhóm?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Hủy'),
                                      ),
                                      FilledButton(
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Theme.of(context).colorScheme.error,
                                        ),
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Xóa'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  try {
                                    await controller.removeGroupMember(
                                      group.id,
                                      member.id,
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Đã xóa thành viên khỏi nhóm.'),
                                        ),
                                      );
                                    }
                                  } on ApiException catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(e.message)),
                                      );
                                    }
                                  }
                                }
                              } else if (value == 'block') {
                                await controller.blockUser(member.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Đã chặn ${member.displayName}.')),
                                  );
                                }
                              } else if (value == 'report' && context.mounted) {
                                await showReportDialog(context, ref, 'user', member.id);
                              }
                            },
                            itemBuilder: (_) => [
                              if (isOwner && !isMemberOwner) ...[
                                const PopupMenuItem(
                                  value: 'transfer',
                                  child: Text('Chuyển quyền trưởng nhóm'),
                                ),
                                const PopupMenuItem(
                                  value: 'remove',
                                  child: Text('Xóa khỏi nhóm', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                              const PopupMenuItem(
                                value: 'block',
                                child: Text('Chặn người dùng'),
                              ),
                              const PopupMenuItem(
                                value: 'report',
                                child: Text('Báo cáo'),
                              ),
                            ],
                          ),
                  );
                }),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Quest nhóm',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder: (_) => CreateQuestSheet(groupId: group.id),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo quest nhóm'),
                ),
              ],
            ),
            if (groupQuests.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Chưa có quest nhóm.'),
              )
            else
              ...groupQuests.map((quest) => QuestCard(quest: quest)),
            const SizedBox(height: 18),
            if (!isOwner)
              OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Rời nhóm?'),
                      content: Text('Bạn có chắc chắn muốn rời nhóm "${group.name}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Hủy'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Rời nhóm'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await controller.leaveGroup(group.id);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Rời nhóm'),
              )
            else
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Giải tán nhóm?'),
                      content: Text(
                        'Toàn bộ quest nhóm và thành viên sẽ bị giải tán. Thao tác này không thể hoàn tác.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Hủy'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Giải tán nhóm'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await controller.deleteGroup(group.id);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Giải tán nhóm'),
              ),
          ],
        ),
      ),
    );
  }
}
