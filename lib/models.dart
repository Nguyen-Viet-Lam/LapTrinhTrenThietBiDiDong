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
    this.groupId,
    this.assigneeId,
    this.createdByAi = false,
    this.xpReward = 20,
    this.xpAwarded = false,
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
  final String? groupId;
  final String? assigneeId;
  final bool createdByAi;
  final int xpReward;
  final bool xpAwarded;

  double get progress => steps.isEmpty
      ? (status == QuestStatus.completed ? 1 : 0)
      : steps.where((step) => step.isDone).length / steps.length;

  Quest copyWith({
    String? title,
    String? description,
    String? category,
    QuestDifficulty? difficulty,
    QuestStatus? status,
    List<QuestStep>? steps,
    DateTime? dueAt,
    String? groupId,
    String? assigneeId,
    bool? createdByAi,
    int? xpReward,
    bool? xpAwarded,
  }) => Quest(
    id: id,
    ownerId: ownerId,
    title: title ?? this.title,
    description: description ?? this.description,
    category: category ?? this.category,
    difficulty: difficulty ?? this.difficulty,
    status: status ?? this.status,
    steps: steps ?? this.steps,
    createdAt: createdAt,
    dueAt: dueAt ?? this.dueAt,
    groupId: groupId ?? this.groupId,
    assigneeId: assigneeId ?? this.assigneeId,
    createdByAi: createdByAi ?? this.createdByAi,
    xpReward: xpReward ?? this.xpReward,
    xpAwarded: xpAwarded ?? this.xpAwarded,
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
    'groupId': groupId,
    'assigneeId': assigneeId,
    'createdByAi': createdByAi,
    'xpReward': xpReward,
    'xpAwarded': xpAwarded,
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
    groupId: json['groupId'] as String?,
    assigneeId: json['assigneeId'] as String?,
    createdByAi: json['createdByAi'] as bool? ?? false,
    xpReward: json['xpReward'] as int? ?? 20,
    xpAwarded: json['xpAwarded'] as bool? ?? false,
  );
}

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.password,
    this.xp = 0,
    this.streak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    this.onboardingCompleted = false,
    this.interests = const [],
    this.notificationsEnabled = true,
    this.darkMode = false,
  });

  final String id;
  final String email;
  final String displayName;
  final String password;
  final int xp;
  final int streak;
  final int longestStreak;
  final String? lastActiveDate;
  final bool onboardingCompleted;
  final List<String> interests;
  final bool notificationsEnabled;
  final bool darkMode;

  int get level => levelForXp(xp);

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
  }) => AppUser(
    id: id,
    email: email,
    displayName: displayName ?? this.displayName,
    password: password,
    xp: xp ?? this.xp,
    streak: streak ?? this.streak,
    longestStreak: longestStreak ?? this.longestStreak,
    lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    interests: interests ?? this.interests,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    darkMode: darkMode ?? this.darkMode,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'password': password,
    'xp': xp,
    'streak': streak,
    'longestStreak': longestStreak,
    'lastActiveDate': lastActiveDate,
    'onboardingCompleted': onboardingCompleted,
    'interests': interests,
    'notificationsEnabled': notificationsEnabled,
    'darkMode': darkMode,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    email: json['email'] as String,
    displayName: json['displayName'] as String,
    password: json['password'] as String,
    xp: json['xp'] as int? ?? 0,
    streak: json['streak'] as int? ?? 0,
    longestStreak: json['longestStreak'] as int? ?? 0,
    lastActiveDate: json['lastActiveDate'] as String?,
    onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
    interests: List<String>.from(json['interests'] as List<dynamic>? ?? []),
    notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    darkMode: json['darkMode'] as bool? ?? false,
  );
}

int levelForXp(int xp) {
  var level = 1;
  while (xp >= level * level * 100) {
    level++;
  }
  return level;
}

class QuestGroup {
  const QuestGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.inviteCode,
    required this.memberIds,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  final String ownerId;
  final String inviteCode;
  final List<String> memberIds;
  final DateTime createdAt;

  QuestGroup copyWith({List<String>? memberIds}) => QuestGroup(
    id: id,
    name: name,
    description: description,
    ownerId: ownerId,
    inviteCode: inviteCode,
    memberIds: memberIds ?? this.memberIds,
    createdAt: createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'ownerId': ownerId,
    'inviteCode': inviteCode,
    'memberIds': memberIds,
    'createdAt': createdAt.toIso8601String(),
  };

  factory QuestGroup.fromJson(Map<String, dynamic> json) => QuestGroup(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    ownerId: json['ownerId'] as String,
    inviteCode: json['inviteCode'] as String,
    memberIds: List<String>.from(json['memberIds'] as List<dynamic>),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final String userId;
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
        userId: json['userId'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        isRead: json['isRead'] as bool? ?? false,
      );
}

class SafetyReport {
  const SafetyReport({
    required this.id,
    required this.reporterId,
    required this.targetType,
    required this.targetId,
    required this.reason,
    required this.createdAt,
  });

  final String id;
  final String reporterId;
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
    reporterId: json['reporterId'] as String,
    targetType: json['targetType'] as String,
    targetId: json['targetId'] as String,
    reason: json['reason'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
