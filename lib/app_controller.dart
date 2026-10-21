import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'models.dart';

final appControllerProvider = ChangeNotifierProvider<AppController>((ref) {
  throw UnimplementedError('AppController must be overridden at bootstrap');
});

class AppController extends ChangeNotifier {
  AppController._(this._preferences);

  static const _storageKey = 'lifequest_database_v1';
  static const _uuid = Uuid();
  final SharedPreferences _preferences;

  List<AppUser> users = [];
  List<Quest> quests = [];
  List<QuestGroup> groups = [];
  List<AppNotification> notifications = [];
  List<SafetyReport> reports = [];
  Set<String> blockedUserIds = {};
  String? currentUserId;
  bool isReady = false;

  AppUser? get currentUser {
    if (currentUserId == null) return null;
    return users.where((user) => user.id == currentUserId).firstOrNull;
  }

  List<Quest> get myQuests =>
      quests
          .where(
            (quest) =>
                quest.ownerId == currentUserId ||
                quest.assigneeId == currentUserId ||
                (quest.groupId != null &&
                    myGroups.any((group) => group.id == quest.groupId)),
          )
          .toList()
        ..sort(
          (a, b) =>
              (a.dueAt ?? DateTime(2099)).compareTo(b.dueAt ?? DateTime(2099)),
        );

  List<QuestGroup> get myGroups =>
      groups.where((group) => group.memberIds.contains(currentUserId)).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<AppNotification> get myNotifications =>
      notifications.where((item) => item.userId == currentUserId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  static Future<AppController> create() async {
    final controller = AppController._(await SharedPreferences.getInstance());
    await controller._load();
    return controller;
  }

  Future<void> _load() async {
    final raw = _preferences.getString(_storageKey);
    if (raw == null) {
      _seed();
      await _save();
    } else {
      try {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        users = (data['users'] as List<dynamic>)
            .map((item) => AppUser.fromJson(item as Map<String, dynamic>))
            .toList();
        quests = (data['quests'] as List<dynamic>)
            .map((item) => Quest.fromJson(item as Map<String, dynamic>))
            .toList();
        groups = (data['groups'] as List<dynamic>)
            .map((item) => QuestGroup.fromJson(item as Map<String, dynamic>))
            .toList();
        notifications = (data['notifications'] as List<dynamic>? ?? [])
            .map(
              (item) => AppNotification.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        reports = (data['reports'] as List<dynamic>? ?? [])
            .map((item) => SafetyReport.fromJson(item as Map<String, dynamic>))
            .toList();
        blockedUserIds = Set<String>.from(
          data['blockedUserIds'] as List<dynamic>? ?? [],
        );
        currentUserId = data['currentUserId'] as String?;
      } on Object {
        _seed();
        await _save();
      }
    }
    isReady = true;
    notifyListeners();
  }

  void _seed() {
    final demo = AppUser(
      id: 'demo-user',
      email: 'demo@lifequest.vn',
      displayName: 'Minh Anh',
      password: _hash('123456'),
      xp: 160,
      streak: 3,
      longestStreak: 5,
      lastActiveDate: _dateKey(DateTime.now()),
      onboardingCompleted: true,
      interests: const ['Sức khỏe', 'Học tập'],
    );
    final friend = AppUser(
      id: 'friend-user',
      email: 'ban@lifequest.vn',
      displayName: 'Gia Huy',
      password: _hash('123456'),
      onboardingCompleted: true,
    );
    users = [demo, friend];
    quests = [
      Quest(
        id: 'sample-quest',
        ownerId: demo.id,
        title: 'Đi bộ 20 phút',
        description: 'Vận động nhẹ sau giờ học',
        category: 'Sức khỏe',
        difficulty: QuestDifficulty.easy,
        status: QuestStatus.active,
        steps: const [
          QuestStep(id: 's1', title: 'Chuẩn bị giày'),
          QuestStep(id: 's2', title: 'Đi bộ đủ 20 phút'),
          QuestStep(id: 's3', title: 'Uống nước'),
        ],
        createdAt: DateTime.now(),
        dueAt: DateTime.now().add(const Duration(hours: 6)),
      ),
    ];
    groups = [
      QuestGroup(
        id: 'sample-group',
        name: 'Nhóm sống khỏe',
        description: 'Cùng nhau xây dựng thói quen tốt',
        ownerId: demo.id,
        inviteCode: 'LIFE2026',
        memberIds: [demo.id, friend.id],
        createdAt: DateTime.now(),
      ),
    ];
    notifications = [
      AppNotification(
        id: 'welcome-notification',
        userId: demo.id,
        title: 'Chào mừng đến LifeQuest',
        body: 'Bắt đầu một nhiệm vụ nhỏ hôm nay nhé!',
        createdAt: DateTime.now(),
      ),
    ];
    currentUserId = null;
  }

  Future<void> _save() async {
    final data = {
      'users': users.map((item) => item.toJson()).toList(),
      'quests': quests.map((item) => item.toJson()).toList(),
      'groups': groups.map((item) => item.toJson()).toList(),
      'notifications': notifications.map((item) => item.toJson()).toList(),
      'reports': reports.map((item) => item.toJson()).toList(),
      'blockedUserIds': blockedUserIds.toList(),
      'currentUserId': currentUserId,
    };
    await _preferences.setString(_storageKey, jsonEncode(data));
  }

  Future<String?> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final normalized = email.trim().toLowerCase();
    final match = users.where((user) => user.email == normalized).firstOrNull;
    if (match == null || match.password != _hash(password)) {
      return 'Email hoặc mật khẩu không đúng.';
    }
    currentUserId = match.id;
    await _saveAndNotify();
    return null;
  }

  Future<String?> register(String name, String email, String password) async {
    final normalized = email.trim().toLowerCase();
    if (!normalized.contains('@')) return 'Email không hợp lệ.';
    if (password.length < 6) return 'Mật khẩu cần ít nhất 6 ký tự.';
    if (users.any((user) => user.email == normalized)) {
      return 'Email đã được sử dụng.';
    }
    final user = AppUser(
      id: _uuid.v4(),
      email: normalized,
      displayName: name.trim(),
      password: _hash(password),
    );
    users.add(user);
    currentUserId = user.id;
    await _saveAndNotify();
    return null;
  }

  Future<void> logout() async {
    currentUserId = null;
    await _saveAndNotify();
  }

  Future<void> completeOnboarding(List<String> interests) async {
    _replaceCurrentUser(
      currentUser!.copyWith(onboardingCompleted: true, interests: interests),
    );
    await _saveAndNotify();
  }

  Future<void> addQuest({
    required String title,
    required String description,
    required String category,
    required QuestDifficulty difficulty,
    required List<String> steps,
    DateTime? dueAt,
    String? groupId,
    bool createdByAi = false,
  }) async {
    final rewards = {
      QuestDifficulty.easy: 20,
      QuestDifficulty.medium: 40,
      QuestDifficulty.hard: 70,
    };
    quests.add(
      Quest(
        id: _uuid.v4(),
        ownerId: currentUserId!,
        title: title.trim(),
        description: description.trim(),
        category: category,
        difficulty: difficulty,
        status: QuestStatus.active,
        steps: steps
            .where((step) => step.trim().isNotEmpty)
            .map((step) => QuestStep(id: _uuid.v4(), title: step.trim()))
            .toList(),
        createdAt: DateTime.now(),
        dueAt: dueAt,
        groupId: groupId,
        createdByAi: createdByAi,
        xpReward: rewards[difficulty]!,
      ),
    );
    await _saveAndNotify();
  }

  Future<int> toggleStep(String questId, String stepId) async {
    final index = quests.indexWhere((quest) => quest.id == questId);
    if (index < 0) return 0;
    final quest = quests[index];
    final steps = quest.steps
        .map(
          (step) =>
              step.id == stepId ? step.copyWith(isDone: !step.isDone) : step,
        )
        .toList();
    quests[index] = quest.copyWith(steps: steps);
    await _saveAndNotify();
    return (quests[index].progress * 100).round();
  }

  Future<int> completeQuest(String questId) async {
    final index = quests.indexWhere((quest) => quest.id == questId);
    if (index < 0 || quests[index].status == QuestStatus.completed) return 0;
    final quest = quests[index];
    quests[index] = quest.copyWith(
      status: QuestStatus.completed,
      steps: quest.steps.map((step) => step.copyWith(isDone: true)).toList(),
      xpAwarded: true,
    );
    final user = currentUser!;
    final today = _dateKey(DateTime.now());
    final yesterday = _dateKey(
      DateTime.now().subtract(const Duration(days: 1)),
    );
    var streak = user.streak;
    if (user.lastActiveDate != today) {
      streak = user.lastActiveDate == yesterday ? user.streak + 1 : 1;
    }
    _replaceCurrentUser(
      user.copyWith(
        xp: user.xp + quest.xpReward,
        streak: streak,
        longestStreak: max(user.longestStreak, streak),
        lastActiveDate: today,
      ),
    );
    _notify(
      currentUserId!,
      'Hoàn thành nhiệm vụ!',
      '+${quest.xpReward} XP cho “${quest.title}”.',
    );
    await _saveAndNotify();
    return quest.xpReward;
  }

  Future<void> archiveQuest(String questId) async {
    final index = quests.indexWhere((quest) => quest.id == questId);
    if (index >= 0) {
      quests[index] = quests[index].copyWith(status: QuestStatus.archived);
    }
    await _saveAndNotify();
  }

  Future<QuestGroup> createGroup(String name, String description) async {
    final group = QuestGroup(
      id: _uuid.v4(),
      name: name.trim(),
      description: description.trim(),
      ownerId: currentUserId!,
      inviteCode: _inviteCode(),
      memberIds: [currentUserId!],
      createdAt: DateTime.now(),
    );
    groups.add(group);
    await _saveAndNotify();
    return group;
  }

  Future<String?> joinGroup(String code) async {
    final index = groups.indexWhere(
      (group) => group.inviteCode == code.trim().toUpperCase(),
    );
    if (index < 0) return 'Mã mời không hợp lệ hoặc đã hết hạn.';
    if (!groups[index].memberIds.contains(currentUserId)) {
      groups[index] = groups[index].copyWith(
        memberIds: [...groups[index].memberIds, currentUserId!],
      );
    }
    await _saveAndNotify();
    return null;
  }

  Future<void> leaveGroup(String groupId) async {
    final index = groups.indexWhere((group) => group.id == groupId);
    if (index < 0) return;
    final group = groups[index];
    if (group.ownerId == currentUserId) return;
    groups[index] = group.copyWith(
      memberIds: group.memberIds.where((id) => id != currentUserId).toList(),
    );
    await _saveAndNotify();
  }

  List<String> generateAiPlan(String goal, QuestDifficulty difficulty) {
    final normalized = goal.toLowerCase();
    const unsafe = [
      'tự tử',
      'tự hại',
      'giết',
      'chế bom',
      'ma túy',
      'hack tài khoản',
    ];
    if (unsafe.any(normalized.contains)) {
      throw const FormatException(
        'Mục tiêu này có dấu hiệu không an toàn. LifeQuest sẽ không biến nội dung nguy hiểm thành thử thách. Hãy tìm sự hỗ trợ từ người bạn tin tưởng hoặc dịch vụ trợ giúp tại nơi bạn sống.',
      );
    }
    final count = switch (difficulty) {
      QuestDifficulty.easy => 3,
      QuestDifficulty.medium => 5,
      QuestDifficulty.hard => 7,
    };
    final templates = [
      'Xác định kết quả nhỏ và an toàn cho “$goal”',
      'Chuẩn bị dụng cụ và dành một khoảng thời gian phù hợp',
      'Thực hiện bước đầu tiên trong 10 phút',
      'Ghi lại tiến độ và điều chỉnh nếu quá sức',
      'Tiếp tục phần quan trọng nhất của mục tiêu',
      'Nhờ một người tin cậy hỗ trợ hoặc phản hồi',
      'Tổng kết kết quả và lên bước tiếp theo',
    ];
    return templates.take(count).toList();
  }

  Future<void> report(String type, String targetId, String reason) async {
    reports.add(
      SafetyReport(
        id: _uuid.v4(),
        reporterId: currentUserId!,
        targetType: type,
        targetId: targetId,
        reason: reason,
        createdAt: DateTime.now(),
      ),
    );
    await _saveAndNotify();
  }

  Future<void> blockUser(String userId) async {
    if (userId != currentUserId) blockedUserIds.add(userId);
    await _saveAndNotify();
  }

  Future<void> markNotificationsRead() async {
    notifications = notifications
        .map(
          (item) =>
              item.userId == currentUserId ? item.copyWith(isRead: true) : item,
        )
        .toList();
    await _saveAndNotify();
  }

  Future<void> updateSettings({
    bool? darkMode,
    bool? notificationsEnabled,
  }) async {
    _replaceCurrentUser(
      currentUser!.copyWith(
        darkMode: darkMode,
        notificationsEnabled: notificationsEnabled,
      ),
    );
    await _saveAndNotify();
  }

  Future<void> deleteAccount() async {
    final uid = currentUserId!;
    users.removeWhere((user) => user.id == uid);
    quests.removeWhere(
      (quest) => quest.ownerId == uid && quest.groupId == null,
    );
    groups = groups
        .where((group) => group.ownerId != uid)
        .map(
          (group) => group.copyWith(
            memberIds: group.memberIds.where((id) => id != uid).toList(),
          ),
        )
        .toList();
    notifications.removeWhere((item) => item.userId == uid);
    currentUserId = null;
    await _saveAndNotify();
  }

  Future<void> resetDemoData() async {
    _seed();
    await _saveAndNotify();
  }

  void _replaceCurrentUser(AppUser user) {
    final index = users.indexWhere((item) => item.id == user.id);
    if (index >= 0) users[index] = user;
  }

  void _notify(String userId, String title, String body) {
    notifications.add(
      AppNotification(
        id: _uuid.v4(),
        userId: userId,
        title: title,
        body: body,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> _saveAndNotify() async {
    await _save();
    notifyListeners();
  }

  static String _hash(String value) =>
      sha256.convert(utf8.encode('lifequest:$value')).toString();
  static String _dateKey(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  static String _inviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
