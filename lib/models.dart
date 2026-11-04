import 'dart:math';

enum QuestDifficulty { easy, medium, hard }

enum QuestStatus { active, completed, archived }

class QuestStep {
  const QuestStep({required this.id, required this.title, this.isDone = false});

  final String id;
  final String title;
  final bool isDone;

  QuestStep copyWith({String? title, bool? isDone}) => QuestStep(
    id: id,
    title: title ?? this.title,
    isDone: isDone ?? this.isDone,
  );

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'isDone': isDone};

  factory QuestStep.fromJson(Map<String, dynamic> json) => QuestStep(
    id: json['id'] as String,
    title: json['title'] as String,
    isDone: json['isDone'] as bool? ?? false,
  );
}

class UserBadge {
  const UserBadge({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
  };

  factory UserBadge.fromJson(Map<String, dynamic> json) => UserBadge(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
  );
}

class Quest {
  const Quest({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.status,
    required this.steps,
    required this.createdAt,
    this.dueAt,
    this.completedAt,
    this.groupId,
    this.assigneeId,
    this.createdByAi = false,
    this.xpReward = 20,
    this.xpAwarded = false,
    this.imageUrl,
  });

  final String id;
  final String ownerId;
  final String title;
  final String description;
  final String category;
  final QuestDifficulty difficulty;
  final QuestStatus status;
  final List<QuestStep> steps;
  final DateTime createdAt;
  final DateTime? dueAt;
  final DateTime? completedAt;
  final String? groupId;
  final String? assigneeId;
  final bool createdByAi;
  final int xpReward;
  final bool xpAwarded;
  final String? imageUrl;

  double get progress => steps.isEmpty
      ? (status == QuestStatus.completed ? 1.0 : 0.0)
      : steps.where((step) => step.isDone).length / steps.length;

  Quest copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    String? category,
    QuestDifficulty? difficulty,
    QuestStatus? status,
    List<QuestStep>? steps,
    DateTime? dueAt,
    DateTime? completedAt,
    String? groupId,
    String? assigneeId,
    bool? createdByAi,
    int? xpReward,
    bool? xpAwarded,
    String? imageUrl,
  }) => Quest(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    title: title ?? this.title,
    description: description ?? this.description,
    category: category ?? this.category,
    difficulty: difficulty ?? this.difficulty,
    status: status ?? this.status,
    steps: steps ?? this.steps,
    createdAt: createdAt,
    dueAt: dueAt ?? this.dueAt,
    completedAt: completedAt ?? this.completedAt,
    groupId: groupId ?? this.groupId,
    assigneeId: assigneeId ?? this.assigneeId,
    createdByAi: createdByAi ?? this.createdByAi,
    xpReward: xpReward ?? this.xpReward,
    xpAwarded: xpAwarded ?? this.xpAwarded,
    imageUrl: imageUrl ?? this.imageUrl,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'ownerId': ownerId,
    'title': title,
    'description': description,
    'category': category,
    'difficulty': difficulty.name,
    'status': status.name,
    'steps': steps.map((step) => step.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'dueAt': dueAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'groupId': groupId,
    'assigneeId': assigneeId,
    'createdByAi': createdByAi,
    'xpReward': xpReward,
    'xpAwarded': xpAwarded,
    if (imageUrl != null) 'imageUrl': imageUrl,
  };

  factory Quest.fromJson(Map<String, dynamic> json) => Quest(
    id: json['id'] as String,
    ownerId: json['ownerId'] as String,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    category: json['category'] as String? ?? 'Khác',
    difficulty: QuestDifficulty.values.byName(json['difficulty'] as String),
    status: QuestStatus.values.byName(json['status'] as String),
    steps: (json['steps'] as List<dynamic>? ?? [])
        .map((item) => QuestStep.fromJson(item as Map<String, dynamic>))
        .toList(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    dueAt: json['dueAt'] == null
        ? null
        : DateTime.parse(json['dueAt'] as String),
    completedAt: json['completedAt'] == null
        ? null
        : DateTime.parse(json['completedAt'] as String),
    groupId: json['groupId'] as String?,
    assigneeId: json['assigneeId'] as String?,
    createdByAi: json['createdByAi'] as bool? ?? false,
    xpReward: json['xpReward'] as int? ?? 20,
    xpAwarded: json['xpAwarded'] as bool? ?? false,
    imageUrl: json['imageUrl'] as String?,
  );
}

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.xp = 0,
    this.streak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    this.onboardingCompleted = false,
    this.interests = const [],
    this.notificationsEnabled = true,
    this.darkMode = false,
    this.badges = const [],
    this.createdAt,
    this.role = 'user',
  });

  final String id;
  final String email;
  final String displayName;
  final int xp;
  final int streak;
  final int longestStreak;
  final String? lastActiveDate;
  final bool onboardingCompleted;
  final List<String> interests;
  final bool notificationsEnabled;
  final bool darkMode;
  final List<UserBadge> badges;
  final DateTime? createdAt;
  final String role;

  int get level => levelForXp(xp);
  bool get isAdmin => role == 'admin' || email == 'lam@lifequest.vn' || email.contains('admin');

  AppUser copyWith({
    String? displayName,
    int? xp,
    int? streak,
    int? longestStreak,
    String? lastActiveDate,
    bool? onboardingCompleted,
    List<String>? interests,
    bool? notificationsEnabled,
    bool? darkMode,
    List<UserBadge>? badges,
    String? role,
  }) => AppUser(
    id: id,
    email: email,
    displayName: displayName ?? this.displayName,
    xp: xp ?? this.xp,
    streak: streak ?? this.streak,
    longestStreak: longestStreak ?? this.longestStreak,
    lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    interests: interests ?? this.interests,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    darkMode: darkMode ?? this.darkMode,
    badges: badges ?? this.badges,
    createdAt: createdAt,
    role: role ?? this.role,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'xp': xp,
    'streak': streak,
    'longestStreak': longestStreak,
    'lastActiveDate': lastActiveDate,
    'onboardingCompleted': onboardingCompleted,
    'interests': interests,
    'notificationsEnabled': notificationsEnabled,
    'darkMode': darkMode,
    'badges': badges.map((b) => b.toJson()).toList(),
    'createdAt': createdAt?.toIso8601String(),
    'role': role,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    email: json['email'] as String,
    displayName: json['displayName'] as String,
    xp: json['xp'] as int? ?? 0,
    streak: json['streak'] as int? ?? 0,
    longestStreak: json['longestStreak'] as int? ?? 0,
    lastActiveDate: json['lastActiveDate'] as String?,
    onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
    interests: List<String>.from(json['interests'] as List<dynamic>? ?? []),
    notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    darkMode: json['darkMode'] as bool? ?? false,
    badges: (json['badges'] as List<dynamic>? ?? [])
        .map((item) => UserBadge.fromJson(item as Map<String, dynamic>))
        .toList(),
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
    role: json['role'] as String? ??
        (json['email'] == 'lam@lifequest.vn' || json['email'] == 'demo@lifequest.vn' || (json['email']?.toString().contains('admin') ?? false)
            ? 'admin'
            : 'user'),
  );
}

int levelForXp(int xp) {
  if (xp <= 0) return 1;
  return (sqrt(xp / 100)).floor() + 1;
}

class GroupMember {
  const GroupMember({
    required this.id,
    required this.displayName,
    required this.role,
    this.joinedAt,
  });

  final String id;
  final String displayName;
  final String role; // 'owner' | 'member'
  final DateTime? joinedAt;

  bool get isOwner => role == 'owner';

  GroupMember copyWith({
    String? id,
    String? displayName,
    String? role,
    DateTime? joinedAt,
  }) =>
      GroupMember(
        id: id ?? this.id,
        displayName: displayName ?? this.displayName,
        role: role ?? this.role,
        joinedAt: joinedAt ?? this.joinedAt,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'role': role,
    'joinedAt': joinedAt?.toIso8601String(),
  };

  factory GroupMember.fromJson(Map<String, dynamic> json) => GroupMember(
    id: json['id'] as String,
    displayName: json['displayName'] as String? ?? '',
    role: json['role'] as String? ?? 'member',
    joinedAt: json['joinedAt'] == null
        ? null
        : DateTime.parse(json['joinedAt'] as String),
  );
}

class QuestGroup {
  const QuestGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.members,
    required this.createdAt,
    this.inviteCode,
  });

  final String id;
  final String name;
  final String description;
  final String ownerId;
  final String? inviteCode;
  final List<GroupMember> members;
  final DateTime createdAt;

  List<String> get memberIds => members.map((m) => m.id).toList();

  QuestGroup copyWith({
    String? name,
    String? description,
    String? ownerId,
    String? inviteCode,
    List<GroupMember>? members,
  }) => QuestGroup(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    ownerId: ownerId ?? this.ownerId,
    inviteCode: inviteCode ?? this.inviteCode,
    members: members ?? this.members,
    createdAt: createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'ownerId': ownerId,
    'inviteCode': inviteCode,
    'members': members.map((m) => m.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory QuestGroup.fromJson(Map<String, dynamic> json) => QuestGroup(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    ownerId: json['ownerId'] as String,
    inviteCode: json['inviteCode'] as String?,
    members: (json['members'] as List<dynamic>? ?? [])
        .map((item) => GroupMember.fromJson(item as Map<String, dynamic>))
        .toList(),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

class UserStats {
  const UserStats({
    required this.xp,
    required this.level,
    required this.xpToNextLevel,
    required this.streak,
    required this.active,
    required this.completed,
    required this.archived,
    this.badges = const [],
  });

  final int xp;
  final int level;
  final int xpToNextLevel;
  final int streak;
  final int active;
  final int completed;
  final int archived;
  final List<UserBadge> badges;

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
    xp: json['xp'] as int? ?? 0,
    level: json['level'] as int? ?? 1,
    xpToNextLevel: json['xpToNextLevel'] as int? ?? 100,
    streak: json['streak'] as int? ?? 0,
    active: json['active'] as int? ?? 0,
    completed: json['completed'] as int? ?? 0,
    archived: json['archived'] as int? ?? 0,
    badges: (json['badges'] as List<dynamic>? ?? [])
        .map((b) => UserBadge.fromJson(b as Map<String, dynamic>))
        .toList(),
  );
}

class BlockedUser {
  const BlockedUser({required this.id, required this.displayName});

  final String id;
  final String displayName;

  factory BlockedUser.fromJson(Map<String, dynamic> json) => BlockedUser(
    id: json['id'] as String,
    displayName: json['displayName'] as String? ?? '',
  );
}

class AiQuestDraft {
  const AiQuestDraft({
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.steps,
    required this.safetyNote,
    required this.source,
    this.imageUrl,
  });

  final String title;
  final String description;
  final String category;
  final QuestDifficulty difficulty;
  final int estimatedMinutes;
  final List<String> steps;
  final String safetyNote;
  final String source;
  final String? imageUrl;

  AiQuestDraft copyWith({
    String? title,
    String? description,
    String? category,
    QuestDifficulty? difficulty,
    int? estimatedMinutes,
    List<String>? steps,
    String? safetyNote,
    String? source,
    String? imageUrl,
  }) => AiQuestDraft(
    title: title ?? this.title,
    description: description ?? this.description,
    category: category ?? this.category,
    difficulty: difficulty ?? this.difficulty,
    estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    steps: steps ?? this.steps,
    safetyNote: safetyNote ?? this.safetyNote,
    source: source ?? this.source,
    imageUrl: imageUrl ?? this.imageUrl,
  );

  factory AiQuestDraft.fromJson(Map<String, dynamic> json) => AiQuestDraft(
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    category: json['category'] as String? ?? 'Khác',
    difficulty: QuestDifficulty.values.byName(
      json['difficulty'] as String? ?? 'easy',
    ),
    estimatedMinutes: json['estimatedMinutes'] as int? ?? 15,
    steps: List<String>.from(json['steps'] as List<dynamic>? ?? []),
    safetyNote: json['safetyNote'] as String? ?? '',
    source: json['source'] as String? ?? 'mock',
    imageUrl: json['imageUrl'] as String?,
  );
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.userId,
    this.isRead = false,
  });

  final String id;
  final String? userId;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    userId: userId,
    title: title,
    body: body,
    createdAt: createdAt,
    isRead: isRead ?? this.isRead,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'body': body,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        userId: json['userId'] as String?,
        title: json['title'] as String,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        isRead: json['isRead'] as bool? ?? false,
      );
}

class SafetyReport {
  const SafetyReport({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.reason,
    required this.createdAt,
    this.reporterId,
  });

  final String id;
  final String? reporterId;
  final String targetType;
  final String targetId;
  final String reason;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'reporterId': reporterId,
    'targetType': targetType,
    'targetId': targetId,
    'reason': reason,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SafetyReport.fromJson(Map<String, dynamic> json) => SafetyReport(
    id: json['id'] as String,
    reporterId: json['reporterId'] as String?,
    targetType: json['targetType'] as String,
    targetId: json['targetId'] as String,
    reason: json['reason'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

class GroupChatMessage {
  const GroupChatMessage({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.createdAt,
    this.isSelf = false,
  });

  final String id;
  final String groupId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime createdAt;
  final bool isSelf;

  Map<String, dynamic> toJson() => {
    'id': id,
    'groupId': groupId,
    'senderId': senderId,
    'senderName': senderName,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'isSelf': isSelf,
  };

  factory GroupChatMessage.fromJson(Map<String, dynamic> json) =>
      GroupChatMessage(
        id: json['id'] as String,
        groupId: json['groupId'] as String,
        senderId: json['senderId'] as String,
        senderName: json['senderName'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
        isSelf: json['isSelf'] as bool? ?? false,
      );
}

class CompleteQuestResult {
  const CompleteQuestResult({
    required this.xpAwarded,
    required this.idempotent,
    required this.quest,
  });

  final int xpAwarded;
  final bool idempotent;
  final Quest quest;
}


/// Mô hình tin nhắn trò chuyện trực tiếp 1-1 giữa hai thành viên
class DirectMessage {
  const DirectMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.senderName,
    required this.content,
    required this.createdAt,
    this.isSelf = false,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final String senderName;
  final String content;
  final DateTime createdAt;
  final bool isSelf;

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'receiverId': receiverId,
    'senderName': senderName,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'isSelf': isSelf,
  };

  factory DirectMessage.fromJson(Map<String, dynamic> json) => DirectMessage(
    id: json['id'] as String,
    senderId: json['senderId'] as String,
    receiverId: json['receiverId'] as String,
    senderName: json['senderName'] as String,
    content: json['content'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    isSelf: json['isSelf'] as bool? ?? false,
  );
}
