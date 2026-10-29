import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import '../models.dart';

abstract class IGroupRepository {
  Stream<List<QuestGroup>> streamUserGroups(String userId);
  Future<List<QuestGroup>> getUserGroups(String userId);
  Future<QuestGroup?> getGroup(String groupId);
  Future<QuestGroup> createGroup(String name, String description, String ownerId, String ownerName);
  Future<String?> joinGroupByInviteCode(String inviteCode, String userId, String displayName);
  Future<void> leaveGroup(String groupId, String userId);
  Future<void> removeMember(String groupId, String memberId);
  Future<void> transferOwnership(String groupId, String newOwnerId);
  Future<void> deleteGroup(String groupId);
  Stream<List<GroupChatMessage>> streamGroupMessages(String groupId);
  Future<void> sendGroupMessage(String groupId, GroupChatMessage message);
}

class FirestoreGroupRepository implements IGroupRepository {
  FirestoreGroupRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _groupsCol =>
      _firestore.collection('groups');

  @override
  Stream<List<QuestGroup>> streamUserGroups(String userId) {
    return _groupsCol.snapshots().map((snapshot) {
      final list = <QuestGroup>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final membersList = (data['members'] as List<dynamic>? ?? [])
            .map((m) => GroupMember.fromJson(m as Map<String, dynamic>))
            .toList();

        final isMember = membersList.any((m) => m.id == userId);
        if (isMember) {
          list.add(QuestGroup.fromJson(data));
        }
      }
      return list;
    });
  }

  @override
  Future<List<QuestGroup>> getUserGroups(String userId) async {
    final snapshot = await _groupsCol.get();
    final list = <QuestGroup>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final membersList = (data['members'] as List<dynamic>? ?? [])
          .map((m) => GroupMember.fromJson(m as Map<String, dynamic>))
          .toList();

      final isMember = membersList.any((m) => m.id == userId);
      if (isMember) {
        list.add(QuestGroup.fromJson(data));
      }
    }
    return list;
  }

  @override
  Future<QuestGroup?> getGroup(String groupId) async {
    final doc = await _groupsCol.doc(groupId).get();
    if (!doc.exists || doc.data() == null) return null;
    return QuestGroup.fromJson(doc.data()!);
  }

  @override
  Future<QuestGroup> createGroup(
    String name,
    String description,
    String ownerId,
    String ownerName,
  ) async {
    final docRef = _groupsCol.doc();
    final inviteCode = _generateInviteCode();
    final codeHash = sha256.convert(utf8.encode(inviteCode)).toString();

    final ownerMember = GroupMember(
      id: ownerId,
      displayName: ownerName,
      role: 'owner',
      joinedAt: DateTime.now(),
    );

    final group = QuestGroup(
      id: docRef.id,
      name: name.trim(),
      description: description.trim(),
      ownerId: ownerId,
      inviteCode: inviteCode,
      createdAt: DateTime.now(),
      members: [ownerMember],
    );

    final data = group.toJson();
    data['inviteCodeHash'] = codeHash;
    data['createdAt'] = FieldValue.serverTimestamp();
    await docRef.set(data);

    // Initial Welcome Message
    final initialMessage = GroupChatMessage(
      id: 'welcome-${docRef.id}',
      groupId: docRef.id,
      senderId: 'system',
      senderName: 'LifeQuest Bot',
      content:
          'Chào mừng bạn đến với nhóm "${name.trim()}"! Cùng rủ nhau đi chơi thể thao, học tập và rèn luyện thói quen tốt 🏸🏃💻',
      createdAt: DateTime.now(),
      isSelf: false,
    );
    await sendGroupMessage(docRef.id, initialMessage);

    return group;
  }

  @override
  Future<String?> joinGroupByInviteCode(
    String inviteCode,
    String userId,
    String displayName,
  ) async {
    final trimmedCode = inviteCode.trim().toUpperCase();
    final codeHash = sha256.convert(utf8.encode(trimmedCode)).toString();

    final query = await _groupsCol
        .where('inviteCodeHash', isEqualTo: codeHash)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return 'Mã mời không tồn tại hoặc đã hết hạn.';
    }

    final groupDoc = query.docs.first;
    final group = QuestGroup.fromJson(groupDoc.data());

    if (group.members.any((m) => m.id == userId)) {
      return 'Bạn đã là thành viên của nhóm này.';
    }

    final newMember = GroupMember(
      id: userId,
      displayName: displayName,
      role: 'member',
      joinedAt: DateTime.now(),
    );

    final updatedMembers = [...group.members, newMember];
    await groupDoc.reference.update({
      'members': updatedMembers.map((m) => m.toJson()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return null;
  }

  @override
  Future<void> leaveGroup(String groupId, String userId) async {
    final group = await getGroup(groupId);
    if (group == null) return;

    final updatedMembers = group.members.where((m) => m.id != userId).toList();
    await _groupsCol.doc(groupId).update({
      'members': updatedMembers.map((m) => m.toJson()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> removeMember(String groupId, String memberId) async {
    await leaveGroup(groupId, memberId);
  }

  @override
  Future<void> transferOwnership(String groupId, String newOwnerId) async {
    final group = await getGroup(groupId);
    if (group == null) return;

    final updatedMembers = group.members.map<Map<String, dynamic>>((m) {
      if (m.id == newOwnerId) return m.copyWith(role: 'owner').toJson();
      if (m.role == 'owner') return m.copyWith(role: 'member').toJson();
      return m.toJson();
    }).toList();

    await _groupsCol.doc(groupId).update({
      'ownerId': newOwnerId,
      'members': updatedMembers,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    await _groupsCol.doc(groupId).delete();
  }

  @override
  Stream<List<GroupChatMessage>> streamGroupMessages(String groupId) {
    return _groupsCol
        .doc(groupId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => GroupChatMessage.fromJson(doc.data()))
          .toList();
    });
  }

  @override
  Future<void> sendGroupMessage(String groupId, GroupChatMessage message) async {
    final docRef = _groupsCol.doc(groupId).collection('messages').doc();
    final data = message.toJson();
    data['id'] = docRef.id;
    data['createdAt'] = FieldValue.serverTimestamp();
    await docRef.set(data);
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
