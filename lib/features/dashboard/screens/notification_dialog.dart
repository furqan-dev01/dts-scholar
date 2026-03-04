import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../theme/app_colors.dart';
import '../../../services/loading_service.dart';

class NotificationDialog extends StatefulWidget {
  const NotificationDialog({super.key});

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  String? _schoolId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchoolId();
  }

  Future<void> _loadSchoolId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? schoolId = prefs.getString('school_id');
      if (schoolId == null) {
        final docId = prefs.getString('user_uid') ?? prefs.getString('student_id');
        if (docId != null) {
          final doc = await FirebaseFirestore.instance.collection('students').doc(docId).get();
          if (doc.exists) {
            final data = doc.data() as Map<String, dynamic>;
            schoolId = data['school_id']?.toString();
          }
        }
      }
      if (mounted) {
        setState(() {
          _schoolId = schoolId;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      int hour = date.hour;
      final int minute = date.minute;
      final String period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) {
        hour -= 12;
      } else if (hour == 0) {
        hour = 12;
      }
      return "$hour:${minute.toString().padLeft(2, '0')} $period";
    } else if (diff.inDays < 7) {
      const weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
      return weekdays[date.weekday - 1];
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = MediaQuery.sizeOf(context).width * 0.9;
    final dialogHeight = MediaQuery.sizeOf(context).height * 0.7;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.deepBlue, Color(0xFF003380), AppColors.maroon],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.notifications_active_rounded, color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Text(
                        "Notifications",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Builder(
                      builder: (context) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          LoadingService().show();
                        });
                        return const SizedBox.shrink();
                      },
                    )
                  : _schoolId == null
                      ? Builder(
                          builder: (context) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              LoadingService().hide();
                            });
                            return const Center(
                              child: Text("Unable to load notifications"),
                            );
                          },
                        )
                      : StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('notices')
                              .where('school_id', isEqualTo: _schoolId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                LoadingService().hide();
                              });
                              return Center(child: Text("Error: ${snapshot.error}"));
                            }
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                LoadingService().show();
                              });
                              return const SizedBox.shrink();
                            }
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              LoadingService().hide();
                            });
                            final List<QueryDocumentSnapshot> notices = List.from(snapshot.data?.docs ?? []);
                            notices.sort((a, b) {
                              final t1 = (a.data() as Map<String, dynamic>)['created_at'] as Timestamp?;
                              final t2 = (b.data() as Map<String, dynamic>)['created_at'] as Timestamp?;
                              if (t1 == null) return 1;
                              if (t2 == null) return -1;
                              return t2.compareTo(t1);
                            });
                            if (notices.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                          color: AppColors.deepBlue.withOpacity(0.08),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.notifications_none_rounded,
                                          size: 40,
                                          color: AppColors.deepBlue.withOpacity(0.5),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      const Text(
                                        "No notifications yet",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.deepBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: notices.length,
                              itemBuilder: (context, index) {
                                final notice = notices[index].data() as Map<String, dynamic>;
                                final title = notice['title'] ?? 'No Title';
                                final message = notice['message'] ?? '';
                                final timestamp = notice['created_at'] as Timestamp?;
                                final timeStr = _formatTimestamp(timestamp);
                                final borderColor =
                                    index % 2 == 0 ? AppColors.deepBlue : AppColors.maroon;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: borderColor, width: 1.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    leading: Icon(Icons.notifications, color: borderColor),
                                    title: Text(title),
                                    subtitle: Text(message),
                                    trailing: Text(timeStr),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.maroon,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
