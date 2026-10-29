import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../models.dart';
import 'auth_repository.dart';
import 'quest_repository.dart';

class FakeAuthRepository implements IAuthRepository {
  final _controller = StreamController<User?>.broadcast();
  User? _user;

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  User? get currentUser => _user;

  @override
  Future<UserCredential> signIn(String email, String password) async {
    if (email == 'demo@lifequest.vn' && password == '123456') {
      return _createMockCredential(email);
    }
    throw 'Email hoặc mật khẩu không chính xác.';
  }

  @override
  Future<UserCredential> signUp(String email, String password) async {
    return _createMockCredential(email);
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(null);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> updatePassword(String newPassword) async {}

  UserCredential _createMockCredential(String email) {
    throw UnimplementedError();
  }
}

class FakeQuestRepository implements IQuestRepository {
  final List<Quest> _quests = [];
  final _controller = StreamController<List<Quest>>.broadcast();

  FakeQuestRepository({List<Quest>? initialQuests}) {
    if (initialQuests != null) _quests.addAll(initialQuests);
  }

  @override
  Stream<List<Quest>> streamQuests({String? ownerId, String? groupId}) {
    return _controller.stream;
  }

  @override
  Future<List<Quest>> getQuests({
    String? ownerId,
    String? groupId,
    String? status,
  }) async {
    var result = List<Quest>.from(_quests);
    if (groupId != null) {
      result = result.where((q) => q.groupId == groupId).toList();
    } else if (ownerId != null) {
      result = result.where((q) => q.ownerId == ownerId).toList();
    }
    if (status != null) {
      result = result.where((q) => q.status.name == status).toList();
    }
    return result;
  }

  @override
  Future<Quest> createQuest(Quest quest) async {
    final finalQuest = quest.id.isEmpty
        ? quest.copyWith(id: 'mock-quest-${_quests.length + 1}')
        : quest;
    _quests.insert(0, finalQuest);
    _controller.add(_quests);
    return finalQuest;
  }

  @override
  Future<Quest> updateQuest(String questId, Map<String, dynamic> data) async {
    final idx = _quests.indexWhere((q) => q.id == questId);
    if (idx >= 0) {
      var current = _quests[idx];
      if (data.containsKey('title')) {
        current = current.copyWith(title: data['title'] as String);
      }
      if (data.containsKey('description')) {
        current = current.copyWith(description: data['description'] as String);
      }
      _quests[idx] = current;
      _controller.add(_quests);
      return current;
    }
    throw Exception('Nhiệm vụ không tồn tại');
  }

  @override
  Future<void> toggleStep(String questId, String stepId, bool isDone) async {
    final idx = _quests.indexWhere((q) => q.id == questId);
    if (idx >= 0) {
      final q = _quests[idx];
      final updatedSteps = q.steps.map((s) {
        if (s.id == stepId) {
          return s.copyWith(isDone: isDone);
        }
        return s;
      }).toList();
      _quests[idx] = q.copyWith(steps: updatedSteps);
      _controller.add(_quests);
    }
  }

  @override
  Future<CompleteQuestResult> completeQuest(
    String questId,
    String userId,
  ) async {
    final idx = _quests.indexWhere((q) => q.id == questId);
    if (idx < 0) throw Exception('Nhiệm vụ không tồn tại');

    final q = _quests[idx];
    if (q.status == QuestStatus.completed || q.xpAwarded) {
      return CompleteQuestResult(xpAwarded: 0, idempotent: true, quest: q);
    }

    final updated = q.copyWith(
      status: QuestStatus.completed,
      xpAwarded: true,
      completedAt: DateTime.now(),
    );
    _quests[idx] = updated;
    _controller.add(_quests);
    return CompleteQuestResult(
      xpAwarded: q.xpReward,
      idempotent: false,
      quest: updated,
    );
  }

  @override
  Future<void> archiveQuest(String questId) async {
    final idx = _quests.indexWhere((q) => q.id == questId);
    if (idx >= 0) {
      _quests[idx] = _quests[idx].copyWith(status: QuestStatus.archived);
      _controller.add(_quests);
    }
  }

  @override
  Future<void> deleteQuest(String questId) async {
    _quests.removeWhere((q) => q.id == questId);
    _controller.add(_quests);
  }
}
