import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_controller.dart';
import '../models.dart';
import 'quest_widgets.dart';

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(appControllerProvider).myGroups;
    return ListView(
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
        if (groups.isEmpty)
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
                  child: Text(group.name.substring(0, 1).toUpperCase()),
                ),
                title: Text(
                  group.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  '${group.memberIds.length} thành viên • ${group.description}',
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
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final description = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo nhóm mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Tên nhóm'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: description,
              decoration: const InputDecoration(labelText: 'Mô tả'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              if (name.text.trim().isEmpty) return;
              await ref
                  .read(appControllerProvider)
                  .createGroup(name.text, description.text);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
    name.dispose();
    description.dispose();
  }

  Future<void> _join(BuildContext context, WidgetRef ref) async {
    final code = TextEditingController();
    String? error;
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
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () async {
                final message = await ref
                    .read(appControllerProvider)
                    .joinGroup(code.text);
                if (message == null && context.mounted) {
                  Navigator.pop(context);
                } else {
                  setState(() => error = message);
                }
              },
              child: const Text('Tham gia'),
            ),
          ],
        ),
      ),
    );
    code.dispose();
  }
}

class GroupDetailSheet extends ConsumerWidget {
  const GroupDetailSheet({required this.groupId, super.key});
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(appControllerProvider);
    final group = controller.groups
        .where((item) => item.id == groupId)
        .firstOrNull;
    if (group == null) {
      return const Center(child: Text('Nhóm không còn tồn tại.'));
    }
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
            Text(group.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(group.description),
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: ListTile(
                leading: const Icon(Icons.key),
                title: Text(
                  group.inviteCode,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                subtitle: const Text('Mã mời demo'),
                trailing: IconButton(
                  tooltip: 'Sao chép',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: group.inviteCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã sao chép mã mời.')),
                    );
                  },
                  icon: const Icon(Icons.copy),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Thành viên (${group.memberIds.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ...group.memberIds
                .where((id) => !controller.blockedUserIds.contains(id))
                .map((id) {
                  final user = controller.users
                      .where((item) => item.id == id)
                      .firstOrNull;
                  if (user == null) return const SizedBox.shrink();
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Text(user.displayName.substring(0, 1)),
                    ),
                    title: Text(user.displayName),
                    subtitle: Text(
                      id == group.ownerId ? 'Trưởng nhóm' : 'Thành viên',
                    ),
                    trailing: id == controller.currentUserId
                        ? null
                        : PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'block') controller.blockUser(id);
                              if (value == 'report') {
                                showReportDialog(context, ref, 'user', id);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'block',
                                child: Text('Chặn'),
                              ),
                              PopupMenuItem(
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
                  label: const Text('Tạo'),
                ),
              ],
            ),
            if (groupQuests.isEmpty)
              const Text('Chưa có quest nhóm.')
            else
              ...groupQuests.map((quest) => QuestCard(quest: quest)),
            const SizedBox(height: 18),
            if (group.ownerId != controller.currentUserId)
              OutlinedButton.icon(
                onPressed: () async {
                  await controller.leaveGroup(group.id);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Rời nhóm'),
              ),
          ],
        ),
      ),
    );
  }
}
