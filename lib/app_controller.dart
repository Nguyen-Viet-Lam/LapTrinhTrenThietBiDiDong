import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/api_client.dart';
import 'api/api_exception.dart';
import 'models.dart';

final appControllerProvider = ChangeNotifierProvider<AppController>((ref) {
  throw UnimplementedError('AppController must be overridden at bootstrap');
});


class AppController extends ChangeNotifier {
  AppController(this.apiClient);

  final ApiClient apiClient;

  AppUser? currentUser;
  UserStats? stats;
  List<Quest> quests = [];
  List<QuestGroup> groups = [];
  List<AppNotification> notifications = [];
  List<BlockedUser> blockedUsers = [];
  bool isReady = false;
  bool isLoading = false;
  String? error;

  String? get currentUserId => currentUser?.id;
  bool get isAdmin => currentUser?.isAdmin ?? false;
  Set<String> get blockedUserIds => blockedUsers.map((u) => u.id).toSet();

  List<Quest> get myQuests => quests;
  List<QuestGroup> get myGroups => groups;
  List<AppNotification> get myNotifications => notifications;

  static Future<AppController> create({
    ApiClient? client,
    SharedPreferences? preferences,
  }) async {
    final prefs = preferences ?? await SharedPreferences.getInstance();
    late AppController controller;
    final api = client ??
        ApiClient(
          preferences: prefs,
          onUnauthorized: () {
            controller.handleUnauthorized();
          },
        );
    controller = AppController(api);
    await controller.init();
    return controller;
  }

  void handleUnauthorized() {
    currentUser = null;
    stats = null;
    quests = [];
    groups = [];
    notifications = [];
    blockedUsers = [];
    notifyListeners();
  }

  Future<void> init() async {
    try {

      if (currentUser == null) {
        await apiClient.loadToken();
        if (apiClient.token != null && apiClient.token!.isNotEmpty) {
          final res = await apiClient.get<Map<String, dynamic>>('/me');
          if (res.data != null) {
            currentUser = AppUser.fromJson(res.data!);
            await refreshAllData();
          }
        }
      }
    } catch (_) {
      await apiClient.clearToken();
      currentUser = null;
    } finally {
      isReady = true;
      notifyListeners();
    }
  }

  Future<void> refreshAllData() async {
    if (currentUser == null) return;
    try {
      await Future.wait([
        fetchStats(),
        fetchQuests(),
        fetchGroups(),
        fetchNotifications(),
        fetchBlockedUsers(),
      ]);
    } catch (_) {}
  }

  // ------------------ Auth ------------------

  Future<String?> login(String email, String password) async {
    final normalized = email.trim().toLowerCase();
    if (!normalized.contains('@')) return 'Email không hợp lệ.';
    if (password.isEmpty) return 'Vui lòng nhập mật khẩu.';

    try {
      final res = await apiClient.post<Map<String, dynamic>>('/auth/login', data: {
        'email': normalized,
        'password': password,
      });
      final data = res.data!;
      final token = data['token'] as String;
      await apiClient.setToken(token);
      currentUser = AppUser.fromJson(data['user'] as Map<String, dynamic>);
      await refreshAllData();
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (e) {
      return 'Không thể đăng nhập. Vui lòng kiểm tra lại.';
    }
  }

  Future<String?> register(String name, String email, String password) async {
    final trimmedName = name.trim();
    final normalized = email.trim().toLowerCase();
    if (trimmedName.length < 2) return 'Vui lòng nhập tên ít nhất 2 ký tự.';
    if (!normalized.contains('@')) return 'Email không hợp lệ.';
    if (password.length < 6) return 'Mật khẩu cần ít nhất 6 ký tự.';

    try {
      final res = await apiClient.post<Map<String, dynamic>>('/auth/register', data: {
        'displayName': trimmedName,
        'email': normalized,
        'password': password,
      });
      final data = res.data!;
      final token = data['token'] as String;
      await apiClient.setToken(token);
      currentUser = AppUser.fromJson(data['user'] as Map<String, dynamic>);
      await refreshAllData();
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (e) {
      return 'Không thể đăng ký. Vui lòng thử lại.';
    }
  }

  Future<void> logout() async {
    await apiClient.clearToken();
    handleUnauthorized();
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    if (currentPassword.isEmpty) {
      throw const ApiException(400, 'Vui lòng nhập mật khẩu hiện tại.');
    }
    if (newPassword.length < 6) {
      throw const ApiException(400, 'Mật khẩu mới cần ít nhất 6 ký tự.');
    }
    await apiClient.post<Map<String, dynamic>>('/auth/change-password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  // ------------------ Profile ------------------

  Future<void> completeOnboarding(List<String> interests) async {
    final res = await apiClient.patch<Map<String, dynamic>>('/me', data: {
      'onboardingCompleted': true,
      'interests': interests,
    });
    if (res.data != null) {
      currentUser = AppUser.fromJson(res.data!);
      notifyListeners();
    }
  }

  Future<void> updateSettings({
    bool? darkMode,
    bool? notificationsEnabled,
    String? displayName,
    List<String>? interests,
  }) async {
    final Map<String, dynamic> data = {};
    if (darkMode != null) data['darkMode'] = darkMode;
    if (notificationsEnabled != null) {
      data['notificationsEnabled'] = notificationsEnabled;
    }
    if (displayName != null) data['displayName'] = displayName;
    if (interests != null) data['interests'] = interests;

    final res = await apiClient.patch<Map<String, dynamic>>('/me', data: data);
    if (res.data != null) {
      currentUser = AppUser.fromJson(res.data!);
      notifyListeners();
    }
  }

  Future<void> deleteAccount() async {
    await apiClient.delete('/me');
    await logout();
  }

  // ------------------ Stats ------------------

  Future<void> fetchStats() async {

    try {
      final res = await apiClient.get<Map<String, dynamic>>('/stats');
      if (res.data != null) {
        stats = UserStats.fromJson(res.data!);
        if (currentUser != null && stats != null) {
          currentUser = currentUser!.copyWith(
            xp: stats!.xp,
            streak: stats!.streak,
            badges: stats!.badges,
          );
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  // ------------------ Quests ------------------

  Future<void> fetchQuests({
    String? status,
    String? groupId,
    String? q,
  }) async {

    try {
      final query = <String, dynamic>{};
      if (status != null && status.isNotEmpty) query['status'] = status;
      if (groupId != null && groupId.isNotEmpty) query['groupId'] = groupId;
      if (q != null && q.isNotEmpty) query['q'] = q;

      final res = await apiClient.get<List<dynamic>>(
        '/quests',
        queryParameters: query,
      );
      if (res.data != null) {
        quests = res.data!
            .map((item) => Quest.fromJson(item as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (_) {
      rethrow;
    }
  }

  Future<Quest> addQuest({
    required String title,
    required String description,
    required String category,
    required QuestDifficulty difficulty,
    required List<String> steps,
    DateTime? dueAt,
    String? groupId,
    String? assigneeId,
    bool createdByAi = false,
    String? imageUrl,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw const ApiException(400, 'Vui lòng nhập tên nhiệm vụ.');
    }
    if (trimmedTitle.length > 80) {
      throw const ApiException(400, 'Tên nhiệm vụ tối đa 80 ký tự.');
    }
    if (description.trim().length > 500) {
      throw const ApiException(400, 'Mô tả tối đa 500 ký tự.');
    }
    final cleanSteps = steps
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    for (final step in cleanSteps) {
      if (step.length > 160) {
        throw const ApiException(400, 'Mỗi bước tối đa 160 ký tự.');
      }
    }

    final res = await apiClient.post<Map<String, dynamic>>('/quests', data: {
      'title': trimmedTitle,
      'description': description.trim(),
      'category': category,
      'difficulty': difficulty.name,
      'steps': cleanSteps,
      'dueAt': dueAt?.toIso8601String(),
      'groupId': groupId,
      'assigneeId': assigneeId,
      'createdByAi': createdByAi,
      if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
    });

    var newQuest = Quest.fromJson(res.data!);
    if (imageUrl != null && imageUrl.isNotEmpty && newQuest.imageUrl == null) {
      newQuest = newQuest.copyWith(imageUrl: imageUrl);
    }
    quests.insert(0, newQuest);
    await fetchStats();
    notifyListeners();
    return newQuest;
  }

  Future<Quest> updateQuest(
    String id, {
    String? title,
    String? description,
    String? category,
    QuestDifficulty? difficulty,
    DateTime? dueAt,
  }) async {
    final Map<String, dynamic> data = {};
    if (title != null) {
      final t = title.trim();
      if (t.isEmpty) throw const ApiException(400, 'Tên nhiệm vụ không được rỗng.');
      if (t.length > 80) throw const ApiException(400, 'Tên nhiệm vụ tối đa 80 ký tự.');
      data['title'] = t;
    }
    if (description != null) {
      final d = description.trim();
      if (d.length > 500) throw const ApiException(400, 'Mô tả tối đa 500 ký tự.');
      data['description'] = d;
    }
    if (category != null) data['category'] = category;
    if (difficulty != null) data['difficulty'] = difficulty.name;
    if (dueAt != null) data['dueAt'] = dueAt.toIso8601String();

    final res = await apiClient.patch<Map<String, dynamic>>(
      '/quests/$id',
      data: data,
    );
    final updated = Quest.fromJson(res.data!);
    final idx = quests.indexWhere((q) => q.id == id);
    if (idx >= 0) {
      quests[idx] = updated;
    }
    notifyListeners();
    return updated;
  }

  Future<void> deleteQuest(String id) async {
    await apiClient.delete('/quests/$id');
    quests.removeWhere((q) => q.id == id);
    await fetchStats();
    notifyListeners();
  }

  Future<int> toggleStep(String questId, String stepId) async {

    final res = await apiClient.post<Map<String, dynamic>>(
      '/quests/$questId/steps/$stepId/toggle',
    );
    final updated = Quest.fromJson(res.data!);
    final idx = quests.indexWhere((q) => q.id == questId);
    if (idx >= 0) {
      quests[idx] = updated;
    }
    notifyListeners();
    return (updated.progress * 100).round();
  }

  Future<CompleteQuestResult> completeQuest(String questId) async {

    final res = await apiClient.post<Map<String, dynamic>>(
      '/quests/$questId/complete',
    );
    final data = res.data!;
    final xpAwarded = data['xpAwarded'] as int? ?? 0;
    final idempotent = data['idempotent'] as bool? ?? false;
    final updatedQuest = Quest.fromJson(data['quest'] as Map<String, dynamic>);

    if (data['user'] != null) {
      currentUser = AppUser.fromJson(data['user'] as Map<String, dynamic>);
    }

    final idx = quests.indexWhere((q) => q.id == questId);
    if (idx >= 0) {
      quests[idx] = updatedQuest;
    }

    await fetchStats();
    await fetchNotifications();
    notifyListeners();

    return CompleteQuestResult(
      xpAwarded: xpAwarded,
      idempotent: idempotent,
      quest: updatedQuest,
    );
  }

  Future<void> archiveQuest(String questId) async {
    final res = await apiClient.post<Map<String, dynamic>>(
      '/quests/$questId/archive',
    );
    final updated = Quest.fromJson(res.data!);
    final idx = quests.indexWhere((q) => q.id == questId);
    if (idx >= 0) {
      quests[idx] = updated;
    }
    await fetchStats();
    notifyListeners();
  }

  // ------------------ Groups ------------------

  Future<void> fetchGroups() async {

    try {
      final res = await apiClient.get<List<dynamic>>('/groups');
      if (res.data != null) {
        groups = res.data!
            .map((item) => QuestGroup.fromJson(item as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (_) {
      rethrow;
    }
  }

  Future<QuestGroup> getGroupDetail(String groupId) async {
    final res = await apiClient.get<Map<String, dynamic>>('/groups/$groupId');
    final detail = QuestGroup.fromJson(res.data!);
    final idx = groups.indexWhere((g) => g.id == groupId);
    if (idx >= 0) {
      groups[idx] = detail;
    } else {
      groups.add(detail);
    }
    notifyListeners();
    return detail;
  }

  Future<QuestGroup> createGroup(String name, String description) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const ApiException(400, 'Vui lòng nhập tên nhóm.');
    }
    if (trimmedName.length > 80) {
      throw const ApiException(400, 'Tên nhóm tối đa 80 ký tự.');
    }
    if (description.trim().length > 300) {
      throw const ApiException(400, 'Mô tả tối đa 300 ký tự.');
    }

    final res = await apiClient.post<Map<String, dynamic>>('/groups', data: {
      'name': trimmedName,
      'description': description.trim(),
    });
    final created = QuestGroup.fromJson(res.data!);
    groups.insert(0, created);
    notifyListeners();
    return created;
  }

  Future<String?> joinGroup(String inviteCode) async {
    final code = inviteCode.trim();
    if (code.isEmpty) return 'Vui lòng nhập mã mời.';

    try {
      final res = await apiClient.post<Map<String, dynamic>>('/groups/join', data: {
        'inviteCode': code,
      });
      final joined = QuestGroup.fromJson(res.data!);
      final idx = groups.indexWhere((g) => g.id == joined.id);
      if (idx >= 0) {
        groups[idx] = joined;
      } else {
        groups.insert(0, joined);
      }
      await fetchQuests();
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (e) {
      return 'Không thể tham gia nhóm. Vui lòng kiểm tra mã mời.';
    }
  }

  Future<void> leaveGroup(String groupId) async {
    await apiClient.post('/groups/$groupId/leave');
    groups.removeWhere((g) => g.id == groupId);
    await fetchQuests();
    notifyListeners();
  }

  Future<void> removeGroupMember(String groupId, String userId) async {
    await apiClient.delete('/groups/$groupId/members/$userId');
    await getGroupDetail(groupId);
  }

  Future<void> transferGroupOwnership(String groupId, String userId) async {
    final res = await apiClient.post<Map<String, dynamic>>(
      '/groups/$groupId/transfer',
      data: {'userId': userId},
    );
    final updated = QuestGroup.fromJson(res.data!);
    final idx = groups.indexWhere((g) => g.id == groupId);
    if (idx >= 0) {
      groups[idx] = updated;
    }
    notifyListeners();
  }

  Future<void> deleteGroup(String groupId) async {
    await apiClient.delete('/groups/$groupId');
    groups.removeWhere((g) => g.id == groupId);
    await fetchQuests();
    notifyListeners();
  }

  Stream<GroupEvent> subscribeGroupEvents(String groupId) {
    return apiClient.subscribeGroupEvents(groupId);
  }

  // ------------------ Group Chat ------------------

  final Map<String, List<GroupChatMessage>> _groupMessages = {};

  List<GroupChatMessage> getGroupMessages(String groupId) {
    if (!_groupMessages.containsKey(groupId)) {
      _groupMessages[groupId] = [
        GroupChatMessage(
          id: 'welcome-$groupId',
          groupId: groupId,
          senderId: 'system',
          senderName: 'LifeQuest Bot',
          content:
              'Chào mừng các thành viên đến với không gian nhóm! Hãy cùng nhau rủ bạn bè đi chơi thể thao, học tập và rèn luyện thói quen tốt 🏸🏃💻',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          isSelf: false,
        ),
      ];
    }
    return _groupMessages[groupId]!;
  }

  void sendGroupMessage(String groupId, String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;

    final user = currentUser;
    final msg = GroupChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      groupId: groupId,
      senderId: user?.id ?? 'me',
      senderName: user?.displayName ?? 'Tôi',
      content: trimmed,
      createdAt: DateTime.now(),
      isSelf: true,
    );

    getGroupMessages(groupId).add(msg);
    notifyListeners();
    _postMessage('/groups/$groupId/messages', trimmed, () => loadGroupMessages(groupId));
  }

  /// Tải lịch sử chat nhóm từ máy chủ (SQLite) và thay thế bộ nhớ đệm.
  Future<void> loadGroupMessages(String groupId) async {
    try {
      final res = await apiClient.get<List<dynamic>>('/groups/$groupId/messages');
      final list = (res.data ?? [])
          .map((m) => GroupChatMessage.fromJson(m as Map<String, dynamic>))
          .toList();
      if (list.isEmpty) return;
      _groupMessages[groupId] = list;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _postMessage(String path, String content, Future<void> Function() reload) async {
    try {
      await apiClient.post<Map<String, dynamic>>(path, data: {'content': content});
      await reload();
    } catch (_) {}
  }

  // ------------------ Direct 1-1 Chat ------------------

  final Map<String, List<DirectMessage>> _directMessages = {};

  List<DirectMessage> getDirectMessages(String peerId) {
    if (!_directMessages.containsKey(peerId)) {
      final currentUserId = currentUser?.id ?? '';
      _directMessages[peerId] = [
        DirectMessage(
          id: 'welcome-$peerId',
          senderId: peerId,
          receiverId: currentUserId,
          senderName: 'Bạn bè LifeQuest',
          content:
              'Chào bạn! Rất vui được kết nối. Hôm nay cùng hẹn nhau đi tập thể thao hoặc rèn luyện thói quen nhé! 🏸⚽',
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          isSelf: false,
        ),
      ];
    }
    return _directMessages[peerId]!;
  }

  void sendDirectMessage(String peerId, String peerName, String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;

    final user = currentUser;
    final msg = DirectMessage(
      id: 'dm-${DateTime.now().millisecondsSinceEpoch}',
      senderId: user?.id ?? 'me',
      receiverId: peerId,
      senderName: user?.displayName ?? 'Tôi',
      content: trimmed,
      createdAt: DateTime.now(),
      isSelf: true,
    );

    getDirectMessages(peerId).add(msg);
    notifyListeners();
    _postMessage('/messages/$peerId', trimmed, () => loadDirectMessages(peerId));
  }

  /// Tải hội thoại 1-1 từ máy chủ (SQLite) và thay thế bộ nhớ đệm.
  Future<void> loadDirectMessages(String peerId) async {
    try {
      final res = await apiClient.get<List<dynamic>>('/messages/$peerId');
      final list = (res.data ?? [])
          .map((m) => DirectMessage.fromJson(m as Map<String, dynamic>))
          .toList();
      if (list.isEmpty) return;
      _directMessages[peerId] = list;
      notifyListeners();
    } catch (_) {}
  }

  // ------------------ AI ------------------

  Future<AiQuestDraft> generateAiPlan(
    String goal,
    QuestDifficulty difficulty, {
    String? constraints,
  }) async {
    final trimmedGoal = goal.trim();
    if (trimmedGoal.length < 5) {
      throw const ApiException(400, 'Hãy mô tả mục tiêu rõ hơn một chút (tối thiểu 5 ký tự).');
    }
    if (trimmedGoal.length > 300) {
      throw const ApiException(400, 'Mục tiêu tối đa 300 ký tự.');
    }

    final res = await apiClient.post<Map<String, dynamic>>('/ai/quest-plan', data: {
      'goal': trimmedGoal,
      'difficulty': difficulty.name,
      if (constraints != null && constraints.isNotEmpty)
        'constraints': constraints,
    });

    return AiQuestDraft.fromJson(res.data!);
  }

  Future<AiQuestDraft> generateVisionQuest({
    required String contextLabel,
    required String photoUrl,
    String? userNote,
    QuestDifficulty difficulty = QuestDifficulty.medium,
  }) async {
    final note = userNote?.trim() ?? '';
    final isUnsafe = [
      'tự tử',
      'tự hại',
      'chế bom',
      'giết người',
      'xâm hại trẻ em',
      'hack tài khoản',
    ].any((t) => note.toLowerCase().contains(t));

    if (isUnsafe) {
      throw const ApiException(
        422,
        'Nội dung không phù hợp chuẩn mực an toàn cộng đồng.',
      );
    }

    final goal = note.isNotEmpty
        ? 'Hoạt động $contextLabel: $note'
        : 'Hoạt động trải nghiệm thực tế tại $contextLabel';

    try {
      final draft = await generateAiPlan(
        goal,
        difficulty,
        constraints:
            'Bối cảnh địa điểm thực tế: $contextLabel. Đề xuất hoạt động thể chất hoặc phát triển cá nhân phù hợp.',
      );
      String cat = draft.category;
      if (cat == 'Khác') {
        final lower = contextLabel.toLowerCase();
        if (lower.contains('học') ||
            lower.contains('đồ án') ||
            lower.contains('làm việc') ||
            lower.contains('study')) {
          cat = 'Học tập';
        } else if (lower.contains('công việc')) {
          cat = 'Công việc';
        } else {
          cat = 'Sức khỏe';
        }
      }
      return draft.copyWith(imageUrl: photoUrl, category: cat);
    } catch (e) {
      if (e is ApiException && e.statusCode == 422) {
        rethrow;
      }
      return _generateFallbackVisionDraft(
        contextLabel,
        photoUrl,
        note,
        difficulty,
      );
    }
  }

  AiQuestDraft _generateFallbackVisionDraft(
    String contextLabel,
    String photoUrl,
    String note,
    QuestDifficulty difficulty,
  ) {
    final count = switch (difficulty) {
      QuestDifficulty.easy => 3,
      QuestDifficulty.medium => 5,
      QuestDifficulty.hard => 7,
    };

    final lower = contextLabel.toLowerCase();
    String category = 'Sức khỏe';
    List<String> stepTemplates;

    if (lower.contains('cầu lông') || lower.contains('badminton')) {
      stepTemplates = [
        'Khởi động khớp cổ tay, khớp vai và cổ chân 5 phút',
        'Luyện tập các bước di chuyển chân cơ bản trên sân (footwork)',
        'Đánh đôi hoặc tập cầu bền 20 hiệp cùng đồng đội',
        'Tập kỹ thuật đập cầu (smash) và bỏ nhỏ sát lưới',
        'Thi đấu giao hữu 1 set 21 điểm tính điểm nghiêm túc',
        'Thả lỏng cơ bắp và bù nước điện giải sau trận đấu',
        'Ghi lại cảm nghĩ và số điểm đạt được trong buổi tập',
      ];
    } else if (lower.contains('bóng chuyền') ||
        lower.contains('bóng rổ') ||
        lower.contains('volleyball')) {
      stepTemplates = [
        'Khởi động toàn thân và kéo giãn dây chằng gối',
        'Tập cảm giác bóng (chuyền 2 tay, đệm bóng bước một)',
        'Tập phối hợp tấn công đập bóng và chắn bóng theo cặp',
        'Thi đấu đối kháng tập trung vào vị trí bọc lót',
        'Chạy bền thả lỏng nhẹ 2 vòng sân',
        'Họp đội ngắn rút kinh nghiệm các pha bóng đẹp',
        'Lau dọn sân bãi và cất dụng cụ thể thao',
      ];
    } else if (lower.contains('gym') || lower.contains('thể hình')) {
      stepTemplates = [
        'Khởi động làm nóng người trên máy chạy bộ 5 phút',
        'Thực hiện bài tập phức hợp chính (Squat/Bench Press/Deadlift) 3 hiệp',
        'Tập bài bổ trợ cô lập nhóm cơ mục tiêu',
        'Gập bụng hoặc Plank 3 hiệp 45 giây',
        'Giãn cơ tĩnh và uống whey hoặc nước khoáng',
        'Ghi chép mức tạ và số rep hoàn thành vào nhật ký tập',
        'Chuẩn bị bữa ăn giàu protein phục hồi cơ bắp',
      ];
    } else if (lower.contains('học') ||
        lower.contains('đồ án') ||
        lower.contains('làm việc') ||
        lower.contains('study')) {
      category = 'Học tập';
      stepTemplates = [
        'Dọn gọn bàn học, chuẩn bị tài liệu và bật chế độ tập trung',
        'Phân rã mục tiêu lớn thành 2 việc nhỏ cần hoàn thành hôm nay',
        'Chạy phiên Pomodoro 25 phút tập trung cao độ vào việc 1',
        'Nghỉ ngắn 5 phút đi lại và uống nước',
        'Tiếp tục phiên Pomodoro 25 phút cho việc thứ 2',
        'Review code hoặc kiểm tra lại nội dung bài tập',
        'Sao lưu mã nguồn lên Git và dọn dẹp không gian học tập',
      ];
    } else if (lower.contains('chạy') ||
        lower.contains('công viên') ||
        lower.contains('park')) {
      stepTemplates = [
        'Kiểm tra giày chạy và buộc dây chắc chắn',
        'Xoay khớp gối và ép cơ đùi trước khi xuất phát',
        'Chạy bộ nhịp nhàng duy trì vùng nhịp tim Zone 2 trong 20 phút',
        'Tăng tốc biến tốc 3 lượt 100m cuối buổi',
        'Đi bộ thả lỏng 5 phút đưa nhịp tim về bình thường',
        'Kéo giãn toàn bộ cơ bắp chân và cơ đùi sau',
        'Ghi lại quãng đường và tốc độ trung bình (Pace)',
      ];
    } else {
      stepTemplates = [
        'Quan sát bối cảnh và xác định mục tiêu rèn luyện',
        'Chuẩn bị trang thiết bị và tư thế sẵn sàng',
        'Thực hiện thử thách chính với tinh thần tập trung',
        'Ghi nhận khoảnh khắc ý nghĩa và chia sẻ với bạn bè',
        'Hoàn tất các bước còn lại và đánh giá mức độ hài lòng',
        'Dọn dẹp khu vực và nghỉ ngơi phục hồi năng lượng',
        'Tự thưởng một điểm XP tinh thần xứng đáng',
      ];
    }

    final selectedSteps = stepTemplates.take(count).toList();
    final title = note.isNotEmpty
        ? 'Hoạt động $contextLabel: $note'
        : 'Nhiệm vụ tại $contextLabel';

    return AiQuestDraft(
      title: title.length > 80 ? title.substring(0, 80) : title,
      description:
          'Nhiệm vụ đời thường được AI thị giác đề xuất dựa trên hình ảnh thực tế tại $contextLabel.',
      category: category,
      difficulty: difficulty,
      estimatedMinutes: count * 12,
      steps: selectedSteps,
      safetyNote:
          'Được tạo từ phân tích thị giác bối cảnh. Hãy kiểm tra an toàn sân bãi và thể lực trước khi tập.',
      source: 'vision_template',
      imageUrl: photoUrl,
    );
  }

  // ------------------ Notifications ------------------

  Future<void> fetchNotifications() async {
    try {
      final res = await apiClient.get<List<dynamic>>('/notifications');
      if (res.data != null) {
        notifications = res.data!
            .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> markNotificationsRead() async {
    try {
      await apiClient.post('/notifications/read-all');
      notifications = notifications
          .map((item) => item.copyWith(isRead: true))
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  // ------------------ Safety & Reports ------------------

  Future<void> report(String targetType, String targetId, String reason) async {
    final r = reason.trim();
    if (r.isEmpty) throw const ApiException(400, 'Vui lòng cung cấp lý do báo cáo.');
    if (r.length > 500) throw const ApiException(400, 'Lý do báo cáo tối đa 500 ký tự.');

    await apiClient.post('/reports', data: {
      'targetType': targetType,
      'targetId': targetId,
      'reason': r,
    });
  }

  Future<void> fetchBlockedUsers() async {
    try {
      final res = await apiClient.get<List<dynamic>>('/blocks');
      if (res.data != null) {
        blockedUsers = res.data!
            .map((item) => BlockedUser.fromJson(item as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> blockUser(String userId) async {
    await apiClient.post('/blocks', data: {'userId': userId});
    await fetchBlockedUsers();
    await fetchQuests();
    notifyListeners();
  }

  Future<void> unblockUser(String userId) async {
    await apiClient.delete('/blocks/$userId');
    await fetchBlockedUsers();
    await fetchQuests();
    notifyListeners();
  }
}
