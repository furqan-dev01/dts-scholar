import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../theme/app_colors.dart';
import '../../../services/loading_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/local_notification_service.dart';
import '../../../services/notice_service.dart';
import '../../../services/background_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../../global/videos/video_data.dart';
import 'videos_screen.dart';
import 'video_player_screen.dart';
import 'invoice_screen.dart';
import '../../notes/screens/notes_screen.dart';
import 'notification_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  void switchToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardContent(onTabSwitch: switchToTab),
      const VideosScreen(),
      const InvoiceScreen(),
      const NotesScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.deepBlue.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.maroon,
            unselectedItemColor: Colors.grey.shade500,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.2,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded, size: 24),
                activeIcon: Icon(Icons.dashboard_rounded, size: 26),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.play_circle_outline_rounded, size: 24),
                activeIcon: Icon(Icons.play_circle_rounded, size: 26),
                label: 'Videos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_rounded, size: 24),
                activeIcon: Icon(Icons.receipt_long_rounded, size: 26),
                label: 'Invoice',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.description_outlined, size: 24),
                activeIcon: Icon(Icons.description_rounded, size: 26),
                label: 'Notes',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardContent extends StatefulWidget {
  final Function(int) onTabSwitch;

  const DashboardContent({super.key, required this.onTabSwitch});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  String _studentName = 'Student';
  String _className = '...';
  String? _studentId;
  String? _schoolId;
  bool _isLoading = true;
  // ignore: unused_field
  StreamSubscription? _studentSubscription;
  final GlobalKey _profileIconKey = GlobalKey();
  OverlayEntry? _profileMenuEntry;

  @override
  void initState() {
    super.initState();
    _setupStudentListener();
    _requestNotificationPermissions();
  }

  Future<void> _requestNotificationPermissions() async {
    await LocalNotificationService.instance.requestPermissions();
    await BackgroundService.registerPeriodicTask();
  }

  @override
  void dispose() {
    _studentSubscription?.cancel();
    super.dispose();
  }

  Future<void> _setupStudentListener() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? studentId = prefs.getString('student_id');

      // Fallback to user_uid if student_id is not found
      if (studentId == null) {
        studentId = prefs.getString('user_uid');
      }

      if (studentId != null) {
        if (mounted) {
          setState(() {
            _studentId = studentId;
          });
        }

        _studentSubscription = FirebaseFirestore.instance
            .collection('students')
            .doc(studentId)
            .snapshots()
            .listen(
              (doc) async {
                if (doc.exists && mounted) {
                  final data = doc.data() as Map<String, dynamic>;
                  setState(() {
                    _studentName = data['student_name'] ?? 'Student';
                    _className = data['class'] ?? 'Class';
                    _schoolId = data['school_id'];
                    _isLoading = false;
                  });

                  if (_schoolId != null) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('school_id', _schoolId!);
                    NoticeService.instance.loadNoticesIfNeeded(_schoolId!);
                  }
                } else {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
              onError: (e) {
                print('Error loading student data: $e');
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
      print('Error setting up student listener: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        LoadingService().show();
      });
      return const SizedBox.shrink();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        LoadingService().hide();
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
                _buildHeader(),

                Transform.translate(
                  offset: const Offset(0, -8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildWelcomeCard(),
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FeeStatusCard(studentId: _studentId),
                ),

                const SizedBox(height: 28),

                _buildSectionHeader(
                  title: 'Recent Videos',
                  subtitle: 'Keep learning',
                  onSeeAll: () => widget.onTabSwitch(1),
                ),
                const SizedBox(height: 14),
                _buildVideoList(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    try {
      LoadingService().show();
      await AuthService().signOut();

      // Also clear local preferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        LoadingService().hide();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      LoadingService().hide();
      print("Logout error: $e");
    }
  }

  void _showProfileMenu(BuildContext context) {
    if (_profileMenuEntry != null) return;
    final iconContext = _profileIconKey.currentContext;
    if (iconContext == null) return;
    final box = iconContext.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;
    final menuWidth = 180.0;
    final menuTop = offset.dy + size.height + 8;
    final menuLeft = offset.dx + size.width - menuWidth;

    _profileMenuEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _hideProfileMenu,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              left: menuLeft,
              top: menuTop,
              child: Material(
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      width: menuWidth,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0x11000000),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              _hideProfileMenu();
                              _handleLogout();
                            },
                            child: Container(
                              height: 48,
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.logout_rounded,
                                      color: Colors.red, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Logout',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_profileMenuEntry!);
  }

  void _hideProfileMenu() {
    _profileMenuEntry?.remove();
    _profileMenuEntry = null;
  }
  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppColors.deepBlue.withOpacity(0.02)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepBlue.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.maroon.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.maroon,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.deepBlue, AppColors.maroon],
            ).createShader(bounds),
            child: const Text(
              "Ready to learn today?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your classes and videos are waiting for you.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required VoidCallback onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.deepBlue.withOpacity(0.15),
                      AppColors.maroon.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.play_circle_rounded,
                  color: AppColors.maroon,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.deepBlue,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onSeeAll,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.maroon,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: AppColors.maroon,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Overscroll filler for the top
        Positioned(
          top: -1000,
          left: 0,
          right: 0,
          height: 1000,
          child: Container(
            color: AppColors.deepBlue,
          ),
        ),
        Container(
          padding:
              const EdgeInsets.only(top: 56, left: 20, right: 20, bottom: 32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.deepBlue, Color(0xFF003380), AppColors.maroon],
              stops: [0.0, 0.5, 1.0],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepBlue.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: 56,
                right: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hi, $_studentName",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.school_rounded,
                              size: 16,
                              color: Colors.white.withOpacity(0.85),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _className,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Image.asset(
                              'assets/more/devtrisoft_icon.png',
                              width: 14,
                              height: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'product by DevTriSoft',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (context) => const NotificationDialog(),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ValueListenableBuilder<List<QueryDocumentSnapshot>>(
                            valueListenable: NoticeService.instance.noticesNotifier,
                            builder: (context, notices, _) {
                              final count = notices.length;
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.notifications_rounded,
                                      color: AppColors.deepBlue,
                                      size: 28,
                                    ),
                                  ),
                                  if (count > 0)
                                    Positioned(
                                      right: -2,
                                      top: -2,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.maroon,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.white, width: 1),
                                        ),
                                        child: Text(
                                          count > 99 ? '99+' : '$count',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        key: _profileIconKey,
                        onTap: () => _showProfileMenu(context),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person_rounded,
                              color: AppColors.maroon,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required String value,
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return PopupMenuItem<String>(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuDivider() {
    return const PopupMenuItem<String>(
      enabled: false,
      height: 1,
      padding: EdgeInsets.zero,
      child: Divider(
        height: 1,
        thickness: 1,
        indent: 60,
        endIndent: 0,
        color: Color(0xFFEEEEEE),
      ),
    );
  }

  Widget _buildVideoList() {
    if (_schoolId == null) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.maroon),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('videos')
          .where('school_id', isEqualTo: _schoolId)
          .where('class', isEqualTo: _className)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 180,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.maroon),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.deepBlue.withOpacity(0.06),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.video_library_rounded,
                      size: 48,
                      color: AppColors.deepBlue.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No recent videos yet",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "New content will appear here",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          );
        }

        // Sort by created_at descending client-side
        final sortedDocs = List<QueryDocumentSnapshot>.from(docs);
        sortedDocs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTime = aData['created_at'] as Timestamp?;
          final bTime = bData['created_at'] as Timestamp?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime); // Descending
        });

        final recentVideos = sortedDocs.take(5).map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return VideoModel(
            title: data['title'] ?? '',
            description: data['description'] ?? '',
            thumbnailUrl: data['thumbnailUrl'] ?? '',
            videoUrl: data['videoUrl'] ?? '',
            subject: data['subject'] ?? '',
          );
        }).toList();

        return SizedBox(
          height: 220,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: recentVideos.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final video = recentVideos[index];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerScreen(
                          videoUrl: video.videoUrl,
                          title: video.title,
                          description: video.description,
                          relatedVideos: recentVideos,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 172,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.deepBlue.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.white,
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    image: DecorationImage(
                                      image:
                                          video.thumbnailUrl.startsWith('http')
                                          ? NetworkImage(video.thumbnailUrl)
                                          : AssetImage(video.thumbnailUrl)
                                                as ImageProvider,
                                      fit: BoxFit.cover,
                                      onError: (_, __) {},
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.5),
                                      ],
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.95),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.maroon.withOpacity(
                                            0.3,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.play_arrow_rounded,
                                      color: AppColors.maroon,
                                      size: 32,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 10,
                                  top: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.maroon,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      video.subject,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  video.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: AppColors.deepBlue,
                                    height: 1.25,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class FeeStatusCard extends StatefulWidget {
  final String? studentId;
  const FeeStatusCard({super.key, this.studentId});

  @override
  State<FeeStatusCard> createState() => _FeeStatusCardState();
}

class _FeeStatusCardState extends State<FeeStatusCard> {
  @override
  Widget build(BuildContext context) {
    if (widget.studentId == null) {
      return const SizedBox(
        height: 150,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('fees')
          .doc(widget.studentId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.data!.exists) {
          return _buildCard(
            amount: '0.00',
            payable: '0.00',
            status: 'No Record',
            month: 'No Record',
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        // Fee processing logic
        final monthsOrder = {
          'Jan': 1,
          'Feb': 2,
          'Mar': 3,
          'Apr': 4,
          'May': 5,
          'Jun': 6,
          'Jul': 7,
          'Aug': 8,
          'Sep': 9,
          'Oct': 10,
          'Nov': 11,
          'Dec': 12,
        };

        final now = DateTime.now();
        const monthNames = [
          "Jan",
          "Feb",
          "Mar",
          "Apr",
          "May",
          "Jun",
          "Jul",
          "Aug",
          "Sep",
          "Oct",
          "Nov",
          "Dec",
        ];
        final currentMonthName = monthNames[now.month - 1];

        Map<String, dynamic>? targetInvoice;
        String targetMonthKey = '';

        List<Map<String, dynamic>> allInvoices = [];
        data.forEach((key, value) {
          if (value is Map && monthsOrder.containsKey(key)) {
            final inv = Map<String, dynamic>.from(value as Map);
            inv['monthKey'] = key;
            inv['sortIndex'] = monthsOrder[key];
            allInvoices.add(inv);
          }
        });

        allInvoices.sort(
          (a, b) => (a['sortIndex'] as int).compareTo(b['sortIndex'] as int),
        );

        if (allInvoices.isNotEmpty) {
          // 1. Try current month
          final currentMonthInvoice = allInvoices.firstWhere(
            (inv) => inv['monthKey'] == currentMonthName,
            orElse: () => {},
          );

          if (currentMonthInvoice.isNotEmpty) {
            targetInvoice = currentMonthInvoice;
            targetMonthKey = currentMonthName;
          } else {
            // 2. Try first pending
            final firstPending = allInvoices.firstWhere(
              (inv) => (inv['status']?.toString() ?? 'Pending') != 'Paid',
              orElse: () => {},
            );

            if (firstPending.isNotEmpty) {
              targetInvoice = firstPending;
              targetMonthKey = firstPending['monthKey'];
            } else {
              // 3. Last available
              targetInvoice = allInvoices.last;
              targetMonthKey = allInvoices.last['monthKey'];
            }
          }
        }

        String amount = '0.00';
        String payable = '0.00';
        String status = 'Pending';
        String month = 'No Record';

        if (targetInvoice != null) {
          final totalFee =
              double.tryParse(targetInvoice['total_fee'].toString()) ?? 0.0;
          final payableVal =
              double.tryParse(targetInvoice['payable'].toString()) ?? 0.0;
          status = targetInvoice['status']?.toString() ?? 'Pending';
          amount = totalFee.toStringAsFixed(2);
          payable = payableVal.toStringAsFixed(2);
          month = targetMonthKey;
        }

        return _buildCard(
          amount: amount,
          payable: payable,
          status: status,
          month: month,
        );
      },
    );
  }

  Widget _buildCard({
    required String amount,
    required String payable,
    required String status,
    required String month,
  }) {
    final totalAmount = double.tryParse(amount) ?? 0.0;
    final payableAmount = double.tryParse(payable) ?? 0.0;

    bool isPaid = false;
    bool isPartial = false;

    if (totalAmount > 0 && (totalAmount - payableAmount).abs() < 0.01) {
      isPaid = true;
    } else if (payableAmount > 0 && payableAmount < totalAmount) {
      isPartial = true;
    }

    final Color statusColor = isPaid
        ? const Color(0xFF22C55E)
        : (isPartial ? const Color(0xFFF59E0B) : AppColors.maroon);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepBlue.withOpacity(0.06),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.white,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    statusColor.withOpacity(0.12),
                    statusColor.withOpacity(0.05),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.calendar_month_rounded,
                          size: 20,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Fee Month",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            month,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.deepBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Payable Amount",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [AppColors.deepBlue, Color(0xFF003380)],
                          ).createShader(bounds),
                          child: Text(
                            "RS $payable",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.deepBlue.withOpacity(0.1),
                          AppColors.maroon.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.deepBlue,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            if (!isPaid && status != 'No Record')
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showPaymentContactDialog(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [AppColors.maroon, Color(0xFFA52A2A)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.maroon.withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Pay Now",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPaymentContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepBlue.withOpacity(0.12),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.maroon.withOpacity(0.15),
                      AppColors.deepBlue.withOpacity(0.08),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  size: 52,
                  color: AppColors.maroon,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Contact Office",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.deepBlue,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Please contact the school office to complete your fee payment securely.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.maroon, Color(0xFFA52A2A)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.maroon.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "Okay, Got it",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
