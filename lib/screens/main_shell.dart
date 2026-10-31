import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app_controller.dart';
import '../models.dart';
import 'admin_screen.dart';
import 'ai_screen.dart';
import 'groups_screen.dart';
import 'home_screen.dart';
import 'notifications_sheet.dart';
import 'profile_screen.dart';
import 'quests_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});
  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int index = 0;



  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(appControllerProvider);
    final user = controller.currentUser;
    final isAdmin = controller.isAdmin;
    final unreadCount = controller.notifications.where((n) => !n.isRead).length;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 860;
    final isDark = Theme.of(context).brightness == Brightness.dark || isAdmin;

    // THEME PALETTES:
    // ADMIN: Deep Abyss Midnight Ocean Glass (Hình 2)
    // USER:  Nova Glass / Ice Crystal Light Glass (Hình 1)
    final glassBarBg = isAdmin
        ? const Color(0xFF060D1E) // Deep Abyss Navy Glass
        : (isDark ? const Color(0xFF1E293B) : Colors.white.withValues(alpha: 0.95)); // Nova Frost Glass

    final glassBorder = isAdmin
        ? const Color(0xFF38BDF8).withValues(alpha: 0.25)
        : (isDark ? const Color(0xFF334155) : const Color(0xFFBAE6FD));

    final primaryAccent = isAdmin ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
    final textHeadingColor = isAdmin ? Colors.white : (isDark ? Colors.white : const Color(0xFF0C1E3C));

    final pages = isAdmin
        ? const [
            HomeScreen(),
            QuestsScreen(),
            AdminScreen(),
            GroupsScreen(),
            ProfileScreen(),
          ]
        : const [
            HomeScreen(),
            QuestsScreen(),
            AiScreen(),
            GroupsScreen(),
            ProfileScreen(),
          ];

    final titles = isAdmin
        ? const [
            'Bảng điều khiển Quản trị',
            'Giám sát Nhiệm vụ Hệ thống',
            'Kiểm duyệt & An toàn Hệ thống',
            'Quản lý Nhóm & CLB',
            'Hồ sơ Quản trị viên',
          ]
        : const [
            'Trang chủ LifeQuest',
            'Nhiệm vụ của bạn',
            'Trợ lý AI Lập kế hoạch & Thị giác',
            'Nhóm & Đồng đội',
            'Hồ sơ Cá nhân',
          ];

    if (index >= pages.length) {
      index = 0;
    }

    if (isDesktop) {
      // Desktop / Web View with Left Sidebar (Slidebar)
      return Scaffold(
        body: Row(
          children: [
            // Left Sidebar (Slidebar)
            _buildDesktopSidebar(context, controller, user, isAdmin, glassBarBg, glassBorder, primaryAccent, textHeadingColor),

            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  // Desktop Topbar
                  Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: glassBarBg,
                      border: Border(bottom: BorderSide(color: glassBorder)),
                      boxShadow: [
                        BoxShadow(
                          color: isAdmin
                              ? const Color(0xFF0284C7).withValues(alpha: 0.15)
                              : const Color(0xFF0284C7).withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          titles[index],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: textHeadingColor,
                          ),
                        ),
                        const Spacer(),
                        // Role Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isAdmin
                                ? const Color(0xFF38BDF8).withValues(alpha: 0.15)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isAdmin ? const Color(0xFF38BDF8) : const Color(0xFFBAE6FD),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isAdmin ? Icons.shield_outlined : Icons.person_outline,
                                size: 14,
                                color: primaryAccent,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isAdmin ? 'Quản trị viên (Admin)' : 'Thành viên (User)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: primaryAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Notification Icon
                        IconButton(
                          tooltip: 'Thông báo',
                          onPressed: () => showModalBottomSheet<void>(
                            context: context,
                            showDragHandle: true,
                            isScrollControlled: true,
                            builder: (_) => const NotificationsSheet(),
                          ),
                          icon: Badge(
                            isLabelVisible: unreadCount > 0,
                            label: Text('$unreadCount'),
                            backgroundColor: primaryAccent,
                            child: Icon(Icons.notifications_outlined, color: textHeadingColor),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Active Page
                  Expanded(
                    child: IndexedStack(index: index, children: pages),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile View with Slidebar (Drawer) and Bottom Navigation Bar
    return Scaffold(
      appBar: AppBar(
        backgroundColor: glassBarBg,
        title: Text(
          titles[index],
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: textHeadingColor),
        ),
        actions: [
          // Admin quick shortcut icon if admin
          if (isAdmin)
            IconButton(
              tooltip: 'Trang Quản trị Admin',
              icon: Icon(
                Icons.admin_panel_settings,
                color: index == 5 ? primaryAccent : const Color(0xFF64748B),
              ),
              onPressed: () => setState(() => index = 5),
            ),
          IconButton(
            tooltip: 'Thông báo',
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              isScrollControlled: true,
              builder: (_) => const NotificationsSheet(),
            ),
            icon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text('$unreadCount'),
              backgroundColor: primaryAccent,
              child: Icon(Icons.notifications_outlined, color: textHeadingColor),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      drawer: _buildMobileDrawer(context, controller, user, isAdmin, glassBarBg, glassBorder, primaryAccent, textHeadingColor),
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: glassBarBg,
          border: Border(top: BorderSide(color: glassBorder)),
          boxShadow: [
            BoxShadow(
              color: isAdmin
                  ? const Color(0xFF0284C7).withValues(alpha: 0.2)
                  : const Color(0xFF0284C7).withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: isAdmin
              ? const Color(0xFF38BDF8).withValues(alpha: 0.2)
              : const Color(0xFFBAE6FD).withValues(alpha: 0.4),
          selectedIndex: index > 4 ? 0 : index,
          onDestinationSelected: (i) => setState(() => index = i),
          destinations: isAdmin
              ? [
                  NavigationDestination(
                    icon: const Icon(Icons.dashboard_outlined, color: Color(0xFF94A3B8)),
                    selectedIcon: Icon(Icons.dashboard, color: primaryAccent),
                    label: 'Admin',
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.assignment_outlined, color: Color(0xFF94A3B8)),
                    selectedIcon: Icon(Icons.assignment, color: primaryAccent),
                    label: 'Nhiệm vụ',
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.admin_panel_settings_outlined, color: Color(0xFF94A3B8)),
                    selectedIcon: Icon(Icons.admin_panel_settings, color: primaryAccent),
                    label: 'Kiểm duyệt',
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.groups_outlined, color: Color(0xFF94A3B8)),
                    selectedIcon: Icon(Icons.groups, color: primaryAccent),
                    label: 'CLB Nhóm',
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.shield_outlined, color: Color(0xFF94A3B8)),
                    selectedIcon: Icon(Icons.shield, color: primaryAccent),
                    label: 'Hồ sơ',
                  ),
                ]
              : [
                  NavigationDestination(
                    icon: const Icon(Icons.home_outlined, color: Color(0xFF64748B)),
                    selectedIcon: Icon(Icons.home, color: primaryAccent),
                    label: 'Trang chủ',
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.task_alt_outlined, color: Color(0xFF64748B)),
                    selectedIcon: Icon(Icons.task_alt, color: primaryAccent),
                    label: 'Nhiệm vụ',
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.auto_awesome_outlined, color: Color(0xFF64748B)),
                    selectedIcon: Icon(Icons.auto_awesome, color: primaryAccent),
                    label: 'AI Plan',
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.groups_outlined, color: Color(0xFF64748B)),
                    selectedIcon: Icon(Icons.groups, color: primaryAccent),
                    label: 'CLB Nhóm',
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.person_outline, color: Color(0xFF64748B)),
                    selectedIcon: Icon(Icons.person, color: primaryAccent),
                    label: 'Hồ sơ',
                  ),
                ],
        ),
      ),
    );
  }

  /// Desktop Sidebar (Slidebar)
  Widget _buildDesktopSidebar(
    BuildContext context,
    AppController controller,
    AppUser? user,
    bool isAdmin,
    Color bg,
    Color border,
    Color primary,
    Color textCol,
  ) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: bg,
        border: Border(right: BorderSide(color: border)),
      ),
      child: Column(
        children: [
          // App Logo Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isAdmin
                          ? [const Color(0xFF0369A1), const Color(0xFF0284C7)]
                          : [const Color(0xFF0284C7), const Color(0xFF38BDF8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LifeQuest',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: textCol,
                      ),
                    ),
                    Text(
                      isAdmin ? 'ADMIN OCEAN' : 'NOVA GLASS',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: border),

          // User Mini Profile Card
          if (user != null)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isAdmin
                    ? const Color(0xFF0A1832).withValues(alpha: 0.8)
                    : const Color(0xFFF0F7FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: primary.withValues(alpha: 0.2),
                    child: Text(
                      user.displayName.isNotEmpty
                          ? user.displayName.substring(0, 1).toUpperCase()
                          : 'U',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textCol),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isAdmin ? 'ADMIN' : 'USER',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _buildSidebarItem(0, Icons.home_outlined, Icons.home, isAdmin ? 'Bảng điều khiển' : 'Trang chủ', isAdmin, primary, textCol),
                _buildSidebarItem(1, Icons.task_alt_outlined, Icons.task_alt, isAdmin ? 'Giám sát Nhiệm vụ' : 'Nhiệm vụ', isAdmin, primary, textCol),
                _buildSidebarItem(2, isAdmin ? Icons.admin_panel_settings_outlined : Icons.auto_awesome_outlined, isAdmin ? Icons.admin_panel_settings : Icons.auto_awesome, isAdmin ? 'Kiểm duyệt & An toàn' : 'Trợ lý AI', isAdmin, primary, textCol),
                _buildSidebarItem(3, Icons.groups_outlined, Icons.groups, isAdmin ? 'Quản lý Nhóm' : 'Nhóm & Đồng đội', isAdmin, primary, textCol),
                _buildSidebarItem(4, isAdmin ? Icons.shield_outlined : Icons.person_outline, isAdmin ? Icons.shield : Icons.person, isAdmin ? 'Hồ sơ Quản trị' : 'Trang User (Hồ sơ)', isAdmin, primary, textCol),
              ],
            ),
          ),

          // Logout Item
          Divider(height: 1, color: border),
          Padding(
            padding: const EdgeInsets.all(12),
            child: InkWell(
              onTap: () async {
                await controller.logout();
                if (context.mounted) context.go('/login');
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: isAdmin
                      ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                      : const Color(0xFFFFF1F2),
                  border: Border.all(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: Color(0xFFEF4444)),
                    SizedBox(width: 10),
                    Text(
                      'Đăng xuất',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    int itemIndex,
    IconData icon,
    IconData activeIcon,
    String label,
    bool isAdmin,
    Color primary,
    Color textCol, {
    bool isBadge = false,
  }) {
    final isSelected = index == itemIndex;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? (isAdmin ? const Color(0xFF38BDF8).withValues(alpha: 0.15) : const Color(0xFFEFF6FF))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: isSelected
            ? Border.all(color: isAdmin ? const Color(0xFF38BDF8).withValues(alpha: 0.4) : const Color(0xFFBAE6FD))
            : null,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        dense: true,
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? primary : (isAdmin ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          size: 20,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? primary : textCol,
          ),
        ),
        trailing: isBadge
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: primary),
                ),
                child: Text(
                  'HOT',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
              )
            : null,
        onTap: () => setState(() => index = itemIndex),
      ),
    );
  }

  /// Mobile Drawer
  Widget _buildMobileDrawer(
    BuildContext context,
    AppController controller,
    AppUser? user,
    bool isAdmin,
    Color bg,
    Color border,
    Color primary,
    Color textCol,
  ) {
    return Drawer(
      backgroundColor: bg,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: border)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: primary.withValues(alpha: 0.2),
                    child: Text(
                      user?.displayName.isNotEmpty == true
                          ? user!.displayName.substring(0, 1).toUpperCase()
                          : 'U',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'LifeQuest User',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: textCol),
                        ),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(fontSize: 11, color: isAdmin ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildSidebarItem(0, Icons.home_outlined, Icons.home, isAdmin ? 'Bảng điều khiển' : 'Trang chủ', isAdmin, primary, textCol),
                  _buildSidebarItem(1, Icons.task_alt_outlined, Icons.task_alt, isAdmin ? 'Giám sát Nhiệm vụ' : 'Nhiệm vụ', isAdmin, primary, textCol),
                  _buildSidebarItem(2, isAdmin ? Icons.admin_panel_settings_outlined : Icons.auto_awesome_outlined, isAdmin ? Icons.admin_panel_settings : Icons.auto_awesome, isAdmin ? 'Kiểm duyệt & An toàn' : 'Trợ lý AI', isAdmin, primary, textCol),
                  _buildSidebarItem(3, Icons.groups_outlined, Icons.groups, isAdmin ? 'Quản lý Nhóm' : 'Nhóm & Đồng đội', isAdmin, primary, textCol),
                  _buildSidebarItem(4, isAdmin ? Icons.shield_outlined : Icons.person_outline, isAdmin ? Icons.shield : Icons.person, isAdmin ? 'Hồ sơ Quản trị' : 'Hồ sơ người dùng', isAdmin, primary, textCol),
                ],
              ),
            ),
            Divider(color: border),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFEF4444)),
              title: const Text('Đăng xuất', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
              onTap: () async {
                Navigator.pop(context);
                await controller.logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
