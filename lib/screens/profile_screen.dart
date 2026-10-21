import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(appControllerProvider);
    final user = controller.currentUser!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 44,
                child: Text(
                  user.displayName.substring(0, 1).toUpperCase(),
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
                label: Text('Cấp ${user.level} • ${user.xp} XP'),
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
                subtitle: Text(_badges(user.xp, user.streak)),
                trailing: const Icon(Icons.chevron_right),
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
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('Tài khoản đã chặn'),
                subtitle: Text('${controller.blockedUserIds.length} tài khoản'),
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
          onPressed: () => _confirmReset(context, controller),
          child: const Text('Khôi phục dữ liệu demo'),
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

  String _badges(int xp, int streak) {
    final result = <String>[];
    if (xp >= 20) result.add('Bước đầu tiên');
    if (streak >= 3) result.add('Chuỗi 3 ngày');
    if (streak >= 7) result.add('Bền bỉ 7 ngày');
    return result.isEmpty ? 'Chưa mở khóa huy hiệu' : result.join(' • ');
  }

  Future<void> _confirmReset(
    BuildContext context,
    AppController controller,
  ) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Khôi phục dữ liệu demo?'),
        content: const Text(
          'Toàn bộ thay đổi cục bộ sẽ được thay bằng dữ liệu mẫu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Khôi phục'),
          ),
        ],
      ),
    );
    if (accepted == true) await controller.resetDemoData();
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
          'Quest cá nhân và dữ liệu thông báo sẽ bị xóa. Thao tác này không thể hoàn tác.',
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
    if (accepted == true) await controller.deleteAccount();
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
