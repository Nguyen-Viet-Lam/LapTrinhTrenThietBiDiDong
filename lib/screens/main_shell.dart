import 'package:flutter/material.dart';

import 'ai_screen.dart';
import 'groups_screen.dart';
import 'home_screen.dart';
import 'notifications_sheet.dart';
import 'profile_screen.dart';
import 'quests_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;
  static const pages = [
    HomeScreen(),
    QuestsScreen(),
    AiScreen(),
    GroupsScreen(),
    ProfileScreen(),
  ];
  static const titles = ['Hôm nay', 'Nhiệm vụ', 'Trợ lý AI', 'Nhóm', 'Cá nhân'];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(titles[index]),
      actions: [
        IconButton(
          tooltip: 'Thông báo',
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            showDragHandle: true,
            isScrollControlled: true,
            builder: (_) => const NotificationsSheet(),
          ),
          icon: const Icon(Icons.notifications_outlined),
        ),
      ],
    ),
    body: IndexedStack(index: index, children: pages),
    bottomNavigationBar: NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (value) => setState(() => index = value),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Trang chủ',
        ),
        NavigationDestination(
          icon: Icon(Icons.task_alt_outlined),
          selectedIcon: Icon(Icons.task_alt),
          label: 'Quest',
        ),
        NavigationDestination(
          icon: Icon(Icons.auto_awesome_outlined),
          selectedIcon: Icon(Icons.auto_awesome),
          label: 'AI',
        ),
        NavigationDestination(
          icon: Icon(Icons.groups_outlined),
          selectedIcon: Icon(Icons.groups),
          label: 'Nhóm',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Cá nhân',
        ),
      ],
    ),
  );
}
