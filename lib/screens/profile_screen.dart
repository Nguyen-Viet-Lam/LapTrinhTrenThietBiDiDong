import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_exception.dart';
import '../app_controller.dart';
import '../models.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(appControllerProvider);
    final user = controller.currentUser;
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 44,
                child: Text(
                  user.displayName.isNotEmpty
                      ? user.displayName.substring(0, 1).toUpperCase()
                      : 'U',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                user.displayName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(user.email),
              const SizedBox(height: 6),
              Chip(
                avatar: const Icon(Icons.stars, size: 18),
                label: Text('Cấp ${user.level} • ${user.xp} XP • Chuỗi ${user.streak} ngày'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Giao diện tối'),
                value: user.darkMode,
                onChanged: (value) =>
                    controller.updateSettings(darkMode: value),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: const Text('Nhắc nhiệm vụ'),
                subtitle: const Text('Cho phép thông báo trong ứng dụng'),
                value: user.notificationsEnabled,
                onChanged: (value) =>
                    controller.updateSettings(notificationsEnabled: value),
              ),
            ],
          ),
        ),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.emoji_events_outlined),
                title: const Text('Huy hiệu'),
                subtitle: Text(
                  user.badges.isEmpty
                      ? 'Chưa mở khóa huy hiệu'
                      : user.badges.map((b) => b.name).join(' • '),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showBadges(context, user.badges),
              ),
              ListTile(
                leading: const Icon(Icons.lock_reset),
                title: const Text('Đổi mật khẩu'),
                subtitle: const Text('Cập nhật mật khẩu tài khoản'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (_) => const ChangePasswordSheet(),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('Tài khoản đã chặn'),
                subtitle: Text('${controller.blockedUsers.length} tài khoản'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (_) => const BlockedUsersSheet(),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.shield_outlined),
                title: const Text('Trung tâm an toàn'),
                subtitle: const Text('Nguyên tắc, báo cáo và quyền riêng tư'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (_) => const SafetyCenterSheet(),
                ),
              ),
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Giới thiệu'),
                subtitle: Text(
                  'LifeQuest 1.0.0 • Đồ án Lập trình thiết bị di động',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: controller.logout,
          icon: const Icon(Icons.logout),
          label: const Text('Đăng xuất'),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => _confirmDelete(context, controller),
          child: const Text('Xóa tài khoản'),
        ),
      ],
    );
  }

  void _showBadges(BuildContext context, List<UserBadge> badges) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Huy hiệu của bạn (${badges.length})',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              if (badges.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text('Chưa mở khóa huy hiệu nào. Hãy hoàn thành quest nhé!'),
                  ),
                )
              else
                ...badges.map(
                  (b) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(Icons.emoji_events, color: Colors.amber),
                    ),
                    title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(b.description),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AppController controller,
  ) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tài khoản?'),
        content: const Text(
          'Toàn bộ quest cá nhân và dữ liệu tài khoản sẽ bị xóa hoàn toàn khỏi máy chủ. Thao tác này không thể hoàn tác.',
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
            child: const Text('Xóa vĩnh viễn'),
          ),
        ],
      ),
    );
    if (accepted == true) {
      await controller.deleteAccount();
    }
  }
}

class ChangePasswordSheet extends ConsumerStatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  ConsumerState<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<ChangePasswordSheet> {
  final currentPassword = TextEditingController();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();
  bool saving = false;
  String? error;

  @override
  void dispose() {
    currentPassword.dispose();
    newPassword.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final curr = currentPassword.text;
    final next = newPassword.text;
    final conf = confirmPassword.text;

    if (curr.isEmpty) {
      setState(() => error = 'Vui lòng nhập mật khẩu hiện tại.');
      return;
    }
    if (next.length < 6) {
      setState(() => error = 'Mật khẩu mới cần ít nhất 6 ký tự.');
      return;
    }
    if (next != conf) {
      setState(() => error = 'Xác nhận mật khẩu mới không khớp.');
      return;
    }

    setState(() {
      saving = true;
      error = null;
    });

    try {
      await ref.read(appControllerProvider).changePassword(curr, next);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đổi mật khẩu thành công!')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
    } catch (_) {
      if (mounted) setState(() => error = 'Không thể đổi mật khẩu lúc này.');
    } finally {
      if (mounted) setState(() => saving = false);
    }
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
              'Đổi mật khẩu',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: currentPassword,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu hiện tại',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPassword,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu mới (tối thiểu 6 ký tự)',
                prefixIcon: Icon(Icons.lock_reset),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPassword,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Xác nhận mật khẩu mới',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: saving ? null : submit,
              child: Text(saving ? 'Đang cập nhật...' : 'Cập nhật mật khẩu'),
            ),
          ],
        ),
      ),
    ),
  );
}

class BlockedUsersSheet extends ConsumerWidget {
  const BlockedUsersSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(appControllerProvider);
    final blocked = controller.blockedUsers;

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Tài khoản đã chặn (${blocked.length})',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Quest nhóm do những tài khoản này tạo sẽ bị ẩn khỏi danh sách của bạn.',
                style: TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: blocked.isEmpty
                  ? const Center(child: Text('Bạn chưa chặn tài khoản nào.'))
                  : ListView.builder(
                      itemCount: blocked.length,
                      itemBuilder: (context, index) {
                        final item = blocked[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              item.displayName.isNotEmpty
                                  ? item.displayName.substring(0, 1).toUpperCase()
                                  : 'U',
                            ),
                          ),
                          title: Text(item.displayName),
                          trailing: FilledButton.tonal(
                            onPressed: () async {
                              await controller.unblockUser(item.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Đã bỏ chặn ${item.displayName}.'),
                                  ),
                                );
                              }
                            },
                            child: const Text('Bỏ chặn'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class SafetyCenterSheet extends StatelessWidget {
  const SafetyCenterSheet({super.key});
  @override
  Widget build(BuildContext context) => SafeArea(
    child: SizedBox(
      height: MediaQuery.sizeOf(context).height * .82,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        children: [
          Text(
            'Trung tâm an toàn',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 14),
          const _SafetyItem(
            icon: Icons.favorite_outline,
            title: 'Tiến bộ không áp lực',
            body:
                'Bạn có thể dừng, giảm độ khó hoặc bỏ qua streak. LifeQuest không dùng cảm giác tội lỗi để thúc ép.',
          ),
          const _SafetyItem(
            icon: Icons.psychology_outlined,
            title: 'AI có giới hạn',
            body:
                'AI chỉ gợi ý bản nháp và có thể sai. Không dùng AI thay cho chuyên gia y tế, pháp lý hoặc tài chính.',
          ),
          const _SafetyItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Bảo vệ riêng tư',
            body:
                'Không nhập mật khẩu, địa chỉ, số giấy tờ hoặc bí mật vào mục tiêu và nội dung AI.',
          ),
          const _SafetyItem(
            icon: Icons.report_outlined,
            title: 'Báo cáo và chặn',
            body:
                'Bạn có thể báo cáo quest hoặc thành viên từ menu chi tiết. Người bị báo cáo không xem được báo cáo.',
          ),
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nếu bạn đang gặp nguy hiểm',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Hãy liên hệ ngay người đáng tin cậy hoặc dịch vụ khẩn cấp tại nơi bạn đang sống. LifeQuest không phải dịch vụ ứng phó khẩn cấp.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    ),
  );
}

class _SafetyItem extends StatelessWidget {
  const _SafetyItem({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(body),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
