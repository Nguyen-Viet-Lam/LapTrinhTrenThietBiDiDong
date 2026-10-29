import 'package:cloud_firestore/cloud_firestore.dart';
import '../models.dart';

abstract class ISafetyRepository {
  Future<void> createReport(SafetyReport report);
  Stream<List<SafetyReport>> streamReports();
  Future<void> updateReportStatus(String reportId, String status);
  Future<void> blockUser(String userId, String blockedUid, String? displayName);
  Future<void> unblockUser(String userId, String blockedUid);
  Stream<List<BlockedUser>> streamBlockedUsers(String userId);
}

class FirestoreSafetyRepository implements ISafetyRepository {
  FirestoreSafetyRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<void> createReport(SafetyReport report) async {
    final docRef = _firestore.collection('safetyReports').doc();
    final data = report.toJson();
    data['id'] = docRef.id;
    data['createdAt'] = FieldValue.serverTimestamp();
    data['status'] = 'pending';
    await docRef.set(data);
  }

  @override
  Stream<List<SafetyReport>> streamReports() {
    return _firestore
        .collection('safetyReports')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SafetyReport.fromJson(doc.data()))
          .toList();
    });
  }

  @override
  Future<void> updateReportStatus(String reportId, String status) async {
    await _firestore.collection('safetyReports').doc(reportId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> blockUser(String userId, String blockedUid, String? displayName) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('blockedUsers')
        .doc(blockedUid);

    await docRef.set({
      'id': blockedUid,
      'displayName': displayName ?? 'Người dùng',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> unblockUser(String userId, String blockedUid) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('blockedUsers')
        .doc(blockedUid)
        .delete();
  }

  @override
  Stream<List<BlockedUser>> streamBlockedUsers(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('blockedUsers')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return BlockedUser(
          id: doc.id,
          displayName: data['displayName'] as String? ?? 'Người dùng',
        );
      }).toList();
    });
  }
}
