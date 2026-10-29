import 'package:cloud_firestore/cloud_firestore.dart';
import '../models.dart';

abstract class IQuestRepository {
  Stream<List<Quest>> streamQuests({String? ownerId, String? groupId});
  Future<List<Quest>> getQuests({String? ownerId, String? groupId, String? status});
  Future<Quest> createQuest(Quest quest);
  Future<Quest> updateQuest(String questId, Map<String, dynamic> data);
  Future<void> toggleStep(String questId, String stepId, bool isDone);
  Future<CompleteQuestResult> completeQuest(String questId, String userId);
  Future<void> archiveQuest(String questId);
  Future<void> deleteQuest(String questId);
}

class FirestoreQuestRepository implements IQuestRepository {
  FirestoreQuestRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _questsCol =>
      _firestore.collection('quests');

  @override
  Stream<List<Quest>> streamQuests({String? ownerId, String? groupId}) {
    Query<Map<String, dynamic>> query = _questsCol;
    if (groupId != null && groupId.isNotEmpty) {
      query = query.where('groupId', isEqualTo: groupId);
    } else if (ownerId != null && ownerId.isNotEmpty) {
      query = query.where('ownerId', isEqualTo: ownerId);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Quest.fromJson(doc.data()))
          .toList();
    });
  }

  @override
  Future<List<Quest>> getQuests({
    String? ownerId,
    String? groupId,
    String? status,
  }) async {
    Query<Map<String, dynamic>> query = _questsCol;
    if (groupId != null && groupId.isNotEmpty) {
      query = query.where('groupId', isEqualTo: groupId);
    } else if (ownerId != null && ownerId.isNotEmpty) {
      query = query.where('ownerId', isEqualTo: ownerId);
    }

    if (status != null && status.isNotEmpty) {
      query = query.where('status', isEqualTo: status);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => Quest.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<Quest> createQuest(Quest quest) async {
    final docRef = _questsCol.doc(quest.id.isNotEmpty ? quest.id : null);
    final finalQuest = quest.copyWith(id: docRef.id);
    final data = finalQuest.toJson();
    data['createdAt'] = FieldValue.serverTimestamp();
    await docRef.set(data);
    return finalQuest;
  }

  @override
  Future<Quest> updateQuest(String questId, Map<String, dynamic> data) async {
    final updateData = Map<String, dynamic>.from(data);
    updateData['updatedAt'] = FieldValue.serverTimestamp();
    await _questsCol.doc(questId).update(updateData);
    final doc = await _questsCol.doc(questId).get();
    return Quest.fromJson(doc.data()!);
  }

  @override
  Future<void> toggleStep(String questId, String stepId, bool isDone) async {
    final docRef = _questsCol.doc(questId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final quest = Quest.fromJson(snapshot.data()!);
      final updatedSteps = quest.steps.map((step) {
        if (step.id == stepId) {
          return step.copyWith(isDone: isDone);
        }
        return step;
      }).toList();

      final doneCount = updatedSteps.where((s) => s.isDone).length;
      final progress = updatedSteps.isEmpty ? 0.0 : doneCount / updatedSteps.length;

      transaction.update(docRef, {
        'steps': updatedSteps.map((s) => s.toJson()).toList(),
        'progress': progress,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<CompleteQuestResult> completeQuest(String questId, String userId) async {
    final questRef = _questsCol.doc(questId);
    final userRef = _firestore.collection('users').doc(userId);

    return await _firestore.runTransaction((transaction) async {
      final questDoc = await transaction.get(questRef);
      if (!questDoc.exists) {
        throw Exception('Nhiệm vụ không tồn tại.');
      }

      final quest = Quest.fromJson(questDoc.data()!);
      final userDoc = await transaction.get(userRef);

      // Idempotency check: Nếu đã hoàn thành hoặc đã cộng XP
      if (quest.status == QuestStatus.completed || quest.xpAwarded) {
        return CompleteQuestResult(
          xpAwarded: 0,
          idempotent: true,
          quest: quest,
        );
      }

      final int xpToAdd = quest.xpReward;
      final updatedQuest = quest.copyWith(
        status: QuestStatus.completed,
        xpAwarded: true,
        completedAt: DateTime.now(),
      );

      transaction.update(questRef, {
        'status': 'completed',
        'xpAwarded': true,
        'completedAt': FieldValue.serverTimestamp(),
      });

      if (userDoc.exists && userDoc.data() != null) {
        final currentXp = (userDoc.data()!['xp'] as int?) ?? 0;
        final currentStreak = (userDoc.data()!['streak'] as int?) ?? 0;
        final newXp = currentXp + xpToAdd;

        // Level = floor(sqrt(newXp / 100)) + 1
        int newLevel = 1;
        while ((newLevel * newLevel) * 100 <= newXp) {
          newLevel++;
        }

        final nowStr = DateTime.now().toIso8601String().substring(0, 10);
        final lastActive = userDoc.data()!['lastActiveDate'] as String?;
        int newStreak = currentStreak;

        if (lastActive != nowStr) {
          newStreak = currentStreak + 1;
        }

        transaction.update(userRef, {
          'xp': newXp,
          'level': newLevel,
          'streak': newStreak,
          'lastActiveDate': nowStr,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return CompleteQuestResult(
        xpAwarded: xpToAdd,
        idempotent: false,
        quest: updatedQuest,
      );
    });
  }

  @override
  Future<void> archiveQuest(String questId) async {
    await _questsCol.doc(questId).update({
      'status': 'archived',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteQuest(String questId) async {
    await _questsCol.doc(questId).delete();
  }
}

