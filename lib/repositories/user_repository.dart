import 'package:cloud_firestore/cloud_firestore.dart';
import '../models.dart';

abstract class IUserRepository {
  Stream<AppUser?> streamUserProfile(String userId);
  Future<AppUser?> getUserProfile(String userId);
  Future<void> saveUserProfile(AppUser user);
  Future<void> updateSettings(String userId, Map<String, dynamic> data);
  Future<UserStats> getUserStats(String userId);
  Future<List<AppUser>> getAllUsers(); // For admin
}

class FirestoreUserRepository implements IUserRepository {
  FirestoreUserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection('users');

  @override
  Stream<AppUser?> streamUserProfile(String userId) {
    return _usersCol.doc(userId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return AppUser.fromJson(doc.data()!);
    });
  }

  @override
  Future<AppUser?> getUserProfile(String userId) async {
    final doc = await _usersCol.doc(userId).get();
    if (!doc.exists || doc.data() == null) return null;
    return AppUser.fromJson(doc.data()!);
  }

  @override
  Future<void> saveUserProfile(AppUser user) async {
    final data = user.toJson();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _usersCol.doc(user.id).set(data, SetOptions(merge: true));
  }

  @override
  Future<void> updateSettings(String userId, Map<String, dynamic> data) async {
    final updateData = Map<String, dynamic>.from(data);
    updateData['updatedAt'] = FieldValue.serverTimestamp();
    await _usersCol.doc(userId).update(updateData);
  }

  @override
  Future<UserStats> getUserStats(String userId) async {
    final user = await getUserProfile(userId);
    final questsSnapshot = await _firestore
        .collection('quests')
        .where('ownerId', isEqualTo: userId)
        .get();

    int active = 0;
    int completed = 0;
    int archived = 0;

    for (final doc in questsSnapshot.docs) {
      final status = doc.data()['status'] as String? ?? 'active';
      if (status == 'completed') {
        completed++;
      } else if (status == 'archived') {
        archived++;
      } else {
        active++;
      }
    }

    final xp = user?.xp ?? 0;
    final level = user?.level ?? 1;
    final nextLevelXp = (level * level) * 100;
    final xpToNextLevel = (nextLevelXp - xp) > 0 ? (nextLevelXp - xp) : 0;

    return UserStats(
      xp: xp,
      level: level,
      xpToNextLevel: xpToNextLevel,
      streak: user?.streak ?? 0,
      active: active,
      completed: completed,
      archived: archived,
      badges: user?.badges ?? [],
    );
  }

  @override
  Future<List<AppUser>> getAllUsers() async {
    final snapshot = await _usersCol.get();
    return snapshot.docs
        .map((doc) => AppUser.fromJson(doc.data()))
        .toList();
  }
}

