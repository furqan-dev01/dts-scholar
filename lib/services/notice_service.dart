import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/firestore_config.dart';
import 'local_notification_service.dart';

class NoticeService {
  static final NoticeService instance = NoticeService._();
  NoticeService._();

  final ValueNotifier<List<QueryDocumentSnapshot>> noticesNotifier =
      ValueNotifier([]);
  bool _isLoaded = false;
  String? _currentSchoolId;

  StreamSubscription<QuerySnapshot>? _noticesSubscription;

  // Load notices only if not already loaded for this school
  void loadNoticesIfNeeded(String schoolId) {
    if (_currentSchoolId == schoolId && _noticesSubscription != null) return;
    _setupNoticeListener(schoolId);
  }

  // Set up real-time listener
  void _setupNoticeListener(String schoolId) {
    _currentSchoolId = schoolId;

    // Cancel existing subscription if any
    _noticesSubscription?.cancel();

    try {
      _noticesSubscription = FirestoreConfig.noticesCollection
          .where('school_id', isEqualTo: schoolId)
          .snapshots()
          .listen(
            (snapshot) {
              final docs = snapshot.docs.toList();

              // Check for new notices and trigger notification
              if (_isLoaded) {
                for (var change in snapshot.docChanges) {
                  if (change.type == DocumentChangeType.added) {
                    final data = change.doc.data() as Map<String, dynamic>;
                    final title = data['title'] as String? ?? 'New Notice';
                    final message = data['message'] as String? ?? '';

                    // Trigger local notification
                    LocalNotificationService.instance.showNotification(
                      id: change.doc.id.hashCode,
                      title: title,
                      body: message,
                      payload: change.doc.id,
                    );
                  }
                }
              }

              // Sort locally (newest first)
              docs.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;
                final aTime = aData['created_at'] as Timestamp?;
                final bTime = bData['created_at'] as Timestamp?;

                if (aTime == null) return -1;
                if (bTime == null) return 1;
                return bTime.compareTo(aTime); // Descending
              });

              noticesNotifier.value = docs;
              _isLoaded = true;
            },
            onError: (e) {
              debugPrint('Error listening to notices: $e');
            },
          );
    } catch (e) {
      debugPrint('Error setting up notice listener: $e');
    }
  }

  Future<void> addNotice(Map<String, dynamic> data) async {
    await FirestoreConfig.noticesCollection.add(data);
    // No need to manually fetch, listener will update
  }

  Future<void> deleteNotice(String docId) async {
    await FirestoreConfig.noticesCollection.doc(docId).delete();
    // No need to manually fetch, listener will update
  }

  // Clear state on logout
  void clear() {
    _noticesSubscription?.cancel();
    _noticesSubscription = null;
    noticesNotifier.value = [];
    _isLoaded = false;
    _currentSchoolId = null;
  }
}
