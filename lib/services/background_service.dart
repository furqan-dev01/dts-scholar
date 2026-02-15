import 'package:workmanager/workmanager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_notification_service.dart';

const String fetchNoticesTask = "fetchNoticesTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case fetchNoticesTask:
        // Initialize Firebase
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp();
        }

        // Get school_id from shared preferences
        final prefs = await SharedPreferences.getInstance();
        final schoolId = prefs.getString('school_id');

        if (schoolId == null) {
          return Future.value(true);
        }

        // Initialize Notification Service
        await LocalNotificationService.instance.init();

        try {
          // Get last check time or default to 15 mins ago if never checked
          final lastCheckEpoch = prefs.getInt('last_notification_check_time');
          final now = DateTime.now();

          DateTime lastCheckTime;
          if (lastCheckEpoch != null) {
            lastCheckTime = DateTime.fromMillisecondsSinceEpoch(lastCheckEpoch);
          } else {
            // Fallback for first run
            lastCheckTime = now.subtract(const Duration(minutes: 15));
          }

          final timestamp = Timestamp.fromDate(lastCheckTime);

          final snapshot = await FirebaseFirestore.instance
              .collection('notices')
              .where('school_id', isEqualTo: schoolId)
              .where('created_at', isGreaterThan: timestamp)
              .get();

          // Update last check time
          await prefs.setInt(
            'last_notification_check_time',
            now.millisecondsSinceEpoch,
          );

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final title = data['title'] as String? ?? 'New Notice';
            final message = data['message'] as String? ?? '';
            final id = doc.id.hashCode;

            // Trigger notification
            await LocalNotificationService.instance.showNotification(
              id: id,
              title: title,
              body: message,
              payload: doc.id,
            );
          }
        } catch (e) {
          print('Error in background task: $e');
          return Future.value(false);
        }
        break;
    }
    return Future.value(true);
  });
}

class BackgroundService {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // TODO: Set to false in production
    );
  }

  static Future<void> registerPeriodicTask() async {
    await Workmanager().registerPeriodicTask(
      "1",
      fetchNoticesTask,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 10),
    );
  }
}
