import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_controller.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock users list for Admin User Management demonstration
  List<Map<String, dynamic>> managedUsers = [
    {
      'id': 'lam-admin',
      'displayName': 'Lãm',
      'email': 'lam@lifequest.vn',
      'role': 'admin',
      'xp': 450,
      'status': 'active',
    },
    {
      'id': 'ky-user',
      'displayName': 'Kỳ',
      'email': 'ky@lifequest.vn',
      'role': 'user',
      'xp': 280,
      'status': 'active',
    },
    {
      'id': 'loi-user',
      'displayName': 'Lợi',
      'email': 'loi@lifequest.vn',
      'role': 'user',
      'xp': 190,
      'status': 'active',
    },
    {
      'id': 'tuan-user',
      'displayName': 'Tuấn (Khách)',
      'email': 'tuan@lifequest.vn',
      'role': 'user',
      'xp': 50,
      'status': 'active',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(appControllerProvider);
    final isAdmin = controller.isAdmin;

    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: !isAdmin
          ? _buildAccessDenied(context, controller)
          : Column(
              children: [
                Container(
                  color: const Color(0xFF060D1E),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFF38BDF8),
                    indicatorWeight: 3,
                    labelColor: const Color(0xFF38BDF8),
                    unselectedLabelColor: const Color(0xFF64748B),
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    tabs: const [
                      Tab(icon: Icon(Icons.dashboard_outlined), text: 'Tổng quan'),
                      Tab(icon: Icon(Icons.people_alt_outlined), text: 'Người dùng'),
                      Tab(icon: Icon(Icons.security_outlined), text: 'Báo cáo & An toàn'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(context, controller),
                      _buildUsersTab(context, controller),
                      _buildReportsTab(context, controller),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  /// Authorization Guard: Shown when current user does not have Admin privileges
  Widget _buildAccessDenied(BuildContext context, AppController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1933),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.5)),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 48,
                  color: Color(0xFF38BDF8),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Khu vực Quản trị viên (Admin Only)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Tài khoản của bạn hiện đang ở vai trò "Người dùng thông thường" (User). Bạn cần được cấp quyền Quản trị viên để truy cập trang này.',
                style: TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8), height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text(
                    'Quay về Trang trước',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tab 1: System Overview & Metrics (Deep Ocean Glass - Hình 2)
  Widget _buildOverviewTab(BuildContext context, AppController controller) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Overview Banner (Deep Ocean Glass)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF07142E), Color(0xFF0E2552)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.shield, color: Color(0xFF38BDF8), size: 28),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bảng điều khiển Quản trị viên LifeQuest',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Deep Ocean Glass • Toàn quyền giám sát hệ thống, kiểm duyệt và phân quyền.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF7DD3FC)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Metrics Grid Header
        const Text(
          'Chỉ số hoạt động toàn hệ thống',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.people_alt,
                color: const Color(0xFF38BDF8),
                title: 'Tổng tài khoản',
                value: '${managedUsers.length + 120}',
                sub: '+14 tuần này',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.task_alt,
                color: const Color(0xFF06B6D4),
                title: 'Nhiệm vụ hệ thống',
                value: '${controller.quests.length + 340}',
                sub: '88% hoàn thành',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.groups,
                color: const Color(0xFFA855F7),
                title: 'Nhóm đang chạy',
                value: '${controller.groups.length + 42}',
                sub: 'Realtime SSE Hub',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.auto_awesome,
                color: const Color(0xFFF59E0B),
                title: 'AI Quest Plans',
                value: '186',
                sub: 'Lọc an toàn: 100%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Server Status Card
        const Text(
          'Tình trạng Hệ thống & Máy chủ',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1933),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildServerRow(
                title: 'Backend REST API',
                status: 'Hoạt động (Healthy)',
                url: 'http://localhost:3000/api',
                isOk: true,
              ),
              Divider(height: 24, color: Colors.white.withValues(alpha: 0.1)),
              _buildServerRow(
                title: 'Server-Sent Events (SSE Realtime)',
                status: 'Đang phát sóng (Live Hub)',
                url: '/api/groups/:id/events',
                isOk: true,
              ),
              Divider(height: 24, color: Colors.white.withValues(alpha: 0.1)),
              _buildServerRow(
                title: 'Cơ sở dữ liệu SQLite',
                status: 'Đã kết nối (lifequest.db)',
                url: 'WAL Mode Active • 9 Bảng',
                isOk: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required String sub,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1933),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildServerRow({
    required String title,
    required String status,
    required String url,
    required bool isOk,
  }) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOk ? const Color(0xFF10B981) : Colors.red,
            boxShadow: [
              BoxShadow(
                color: (isOk ? const Color(0xFF10B981) : Colors.red).withValues(alpha: 0.6),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.white),
              ),
              Text(
                url,
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF7DD3FC)),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
          ),
          child: Text(
            status,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF34D399)),
          ),
        ),
      ],
    );
  }
  /// Tab 2: User Management & Role Assignment (Deep Ocean Glass)
  Widget _buildUsersTab(BuildContext context, AppController controller) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            const Text(
              'Danh sách Người dùng & Phân quyền',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
              ),
              child: Text(
                '${managedUsers.length} tài khoản',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        ...managedUsers.map((u) {
          final isUserAdmin = u['role'] == 'admin';
          final isBlocked = u['status'] == 'blocked';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1933),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isUserAdmin
                    ? const Color(0xFF38BDF8).withValues(alpha: 0.5)
                    : const Color(0xFF38BDF8).withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: isUserAdmin
                      ? const Color(0xFF0284C7).withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isUserAdmin
                      ? const Color(0xFF38BDF8).withValues(alpha: 0.2)
                      : const Color(0xFF1E293B),
                  child: Text(
                    u['displayName'].toString().substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: isUserAdmin ? const Color(0xFF38BDF8) : const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            u['displayName'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isUserAdmin
                                  ? const Color(0xFF38BDF8).withValues(alpha: 0.2)
                                  : const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isUserAdmin
                                    ? const Color(0xFF38BDF8).withValues(alpha: 0.4)
                                    : const Color(0xFF334155),
                              ),
                            ),
                            child: Text(
                              isUserAdmin ? 'ADMIN' : 'USER',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: isUserAdmin ? const Color(0xFF38BDF8) : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${u['email']} • ${u['xp']} XP',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF7DD3FC)),
                      ),
                    ],
                  ),
                ),
                // Actions: Change Role / Block Toggle
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF7DD3FC)),
                  color: const Color(0xFF0F172A),
                  onSelected: (val) {
                    setState(() {
                      if (val == 'toggle_role') {
                        u['role'] = isUserAdmin ? 'user' : 'admin';
                      } else if (val == 'toggle_status') {
                        u['status'] = isBlocked ? 'active' : 'blocked';
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã cập nhật tài khoản ${u['displayName']}')),
                    );
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'toggle_role',
                      child: Row(
                        children: [
                          Icon(isUserAdmin ? Icons.arrow_downward : Icons.arrow_upward, size: 16, color: const Color(0xFF38BDF8)),
                          const SizedBox(width: 8),
                          Text(
                            isUserAdmin ? 'Hạ cấp xuống User' : 'Thăng cấp lên Admin',
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle_status',
                      child: Row(
                        children: [
                          Icon(isBlocked ? Icons.lock_open : Icons.block, size: 16, color: Colors.redAccent),
                          const SizedBox(width: 8),
                          Text(
                            isBlocked ? 'Mở khóa tài khoản' : 'Khóa tài khoản',
                            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// Tab 3: Content Moderation & Reports (Deep Ocean Glass)
  Widget _buildReportsTab(BuildContext context, AppController controller) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Báo cáo Vi phạm Nội dung & An toàn',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        const SizedBox(height: 6),
        const Text(
          'Deep Ocean Glass • Duyệt các báo cáo từ cộng đồng về nhiệm vụ, bình luận hoặc người dùng.',
          style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 16),

        _buildReportItem(
          targetType: 'Nhiệm vụ',
          targetName: 'Thử thách thức khuya 48 tiếng liên tục',
          reporterName: 'Gia Huy (ban@lifequest.vn)',
          reason: 'Nội dung có thể gây nguy hại sức khỏe, vi phạm tiêu chuẩn cộng đồng.',
          time: '10 phút trước',
        ),
        _buildReportItem(
          targetType: 'Người dùng',
          targetName: 'User spam tin nhắn quảng cáo',
          reporterName: 'Thu Trang (trang@lifequest.vn)',
          reason: 'Spam đường link lạ vào phần mô tả nhiệm vụ nhóm.',
          time: '1 giờ trước',
        ),
      ],
    );
  }

  Widget _buildReportItem({
    required String targetType,
    required String targetName,
    required String reporterName,
    required String reason,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1933),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.15),
            blurRadius: 14,
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                ),
                child: Text(
                  targetType,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
                ),
              ),
              const Spacer(),
              Text(time, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            targetName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            reason,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 12),
          Text(
            'Người báo cáo: $reporterName',
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF7DD3FC), fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  foregroundColor: const Color(0xFF94A3B8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã bỏ qua báo cáo')),
                  );
                },
                child: const Text('Bỏ qua', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xử lý và gỡ bỏ nội dung vi phạm!')),
                  );
                },
                child: const Text('Xử lý / Gỡ bỏ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
