import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../theme/app_colors.dart';
import '../../../services/loading_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ["All", "Fees", "Videos", "Announcements"];
  String? _schoolId;
  bool _isLoading = true;
  StreamSubscription? _schoolIdSubscription;

  @override
  void initState() {
    super.initState();
    _setupSchoolIdListener();
  }

  @override
  void dispose() {
    _schoolIdSubscription?.cancel();
    super.dispose();
  }

  Future<void> _setupSchoolIdListener() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Use user_uid to fetch the student document, as it corresponds to doc.id
      String? docId = prefs.getString('user_uid');

      // Fallback to student_id if user_uid is missing
      docId ??= prefs.getString('student_id');

      if (docId != null) {
        _schoolIdSubscription = FirebaseFirestore.instance
            .collection('students')
            .doc(docId)
            .snapshots()
            .listen(
              (doc) {
                if (doc.exists && doc.data() != null) {
                  final newSchoolId = doc
                      .data()!['school_id']
                      ?.toString()
                      .trim();
                  if (mounted && newSchoolId != _schoolId) {
                    setState(() {
                      _schoolId = newSchoolId;
                      _isLoading = false;
                    });
                  } else if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                } else {
                  debugPrint("Student document not found for ID: $docId");
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
              onError: (e) {
                debugPrint("Error loading school_id: $e");
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
            );
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error setting up school_id listener: $e");
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
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.only(
            top: 56,
            left: 20,
            right: 20,
            bottom: 24,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.deepBlue,
                Color(0xFF003380),
                AppColors.maroon,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepBlue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Notifications",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Stay updated",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Mark all read",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final isSelected = _selectedFilterIndex == index;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => setState(() => _selectedFilterIndex = index),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            _filters[index],
                            style: TextStyle(
                              color: isSelected ? AppColors.deepBlue : Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Notifications List
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
                      child: Text(
                        "Unable to load notifications (No School ID)",
                      ),
                    );
                  },
                )
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('notices')
                      .where('school_id', isEqualTo: _schoolId)
                      // .orderBy('created_at', descending: true) // Removed to avoid index error
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        LoadingService().hide();
                      });
                      // If error is permission-denied or failed-precondition, it might still need index
                      // But removing orderBy usually fixes the index error for single where clause
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

                    // Get docs and sort them in memory
                    final List<QueryDocumentSnapshot> notices = List.from(
                      snapshot.data?.docs ?? [],
                    );

                    // Sort by created_at descending
                    notices.sort((a, b) {
                      final t1 =
                          (a.data() as Map<String, dynamic>)['created_at']
                              as Timestamp?;
                      final t2 =
                          (b.data() as Map<String, dynamic>)['created_at']
                              as Timestamp?;
                      if (t1 == null) return 1;
                      if (t2 == null) return -1;
                      return t2.compareTo(t1); // Descending
                    });

                    if (notices.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppColors.deepBlue.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.notifications_none_rounded,
                                  size: 56,
                                  color: AppColors.deepBlue.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "No notifications yet",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.deepBlue,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "When your school sends updates,\nthey’ll show up here.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      itemCount: notices.length,
                      itemBuilder: (context, index) {
                        final notice =
                            notices[index].data() as Map<String, dynamic>;
                        final title = notice['title'] ?? 'No Title';
                        final message = notice['message'] ?? '';
                        final timestamp = notice['created_at'] as Timestamp?;
                        final timeStr = _formatTimestamp(timestamp);

                        IconData icon = Icons.campaign_rounded;
                        Color iconColor = AppColors.deepBlue;
                        Color iconBgColor = AppColors.deepBlue.withOpacity(0.1);

                        if (title.toString().toLowerCase().contains('fee')) {
                          icon = Icons.receipt_long_rounded;
                          iconColor = AppColors.maroon;
                          iconBgColor = AppColors.maroon.withOpacity(0.12);
                        } else if (title.toString().toLowerCase().contains('video')) {
                          icon = Icons.play_circle_rounded;
                          iconColor = const Color(0xFF2563EB);
                          iconBgColor = const Color(0xFF2563EB).withOpacity(0.12);
                        } else if (title.toString().toLowerCase().contains('exam') ||
                            title.toString().toLowerCase().contains('holiday')) {
                          icon = Icons.celebration_rounded;
                          iconColor = const Color(0xFFEA580C);
                          iconBgColor = const Color(0xFFEA580C).withOpacity(0.12);
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.deepBlue.withOpacity(0.06),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: iconBgColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(icon, color: iconColor, size: 26),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            title,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.deepBlue,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            timeStr,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (message.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Text(
                                        message,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                          height: 1.45,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
