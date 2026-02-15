import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../theme/app_colors.dart';
import '../../../global/videos/video_data.dart';
import 'video_player_screen.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  String? _studentId;
  bool _isLoadingId = true;

  @override
  void initState() {
    super.initState();
    _loadStudentId();
  }

  Future<void> _loadStudentId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? studentId =
        prefs.getString('student_id') ?? prefs.getString('user_uid');
    if (mounted) {
      setState(() {
        _studentId = studentId;
        _isLoadingId = false;
      });
    }
  }

  void _openVideoPlayer(
    BuildContext context,
    VideoModel video,
    List<VideoModel> relatedVideos,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          videoUrl: video.videoUrl,
          title: video.title,
          description: video.description,
          relatedVideos: relatedVideos,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingId) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.maroon),
      );
    }

    if (_studentId == null) {
      return const Center(child: Text("Student information not found"));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('students')
          .doc(_studentId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.maroon),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final studentClass = data?['class'] as String?;
        final schoolId = data?['school_id'] as String?;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('videos')
              .where('school_id', isEqualTo: schoolId)
              .where('class', isEqualTo: studentClass)
              .snapshots(),
          builder: (context, videoSnapshot) {
            // Get videos based on student class
            final allVideos = videoSnapshot.hasData
                ? videoSnapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return VideoModel(
                      title: data['title'] ?? '',
                      description: data['description'] ?? '',
                      thumbnailUrl: data['thumbnailUrl'] ?? '',
                      videoUrl: data['videoUrl'] ?? '',
                      subject: data['subject'] ?? '',
                    );
                  }).toList()
                : <VideoModel>[];

            // Group videos by subject
            final Map<String, List<VideoModel>> groupedVideos = {};
            for (var video in allVideos) {
              if (!groupedVideos.containsKey(video.subject)) {
                groupedVideos[video.subject] = [];
              }
              groupedVideos[video.subject]!.add(video);
            }

            return Column(
              children: [
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
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.play_circle_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Videos",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              if (studentClass != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  "For $studentClass",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search videos...",
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: Colors.white.withOpacity(0.8),
                              size: 22,
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: allVideos.isEmpty
                      ? Center(
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
                                    Icons.video_library_rounded,
                                    size: 56,
                                    color: AppColors.deepBlue.withOpacity(0.5),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  "No videos for $studentClass yet",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.deepBlue,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "New lessons will appear here soon.",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(top: 20, bottom: 40),
                          children: groupedVideos.entries.map((entry) {
                            return Column(
                              children: [
                                _VideoSection(
                                  subject: entry.key,
                                  videos: entry.value,
                                  onVideoTap: (video) => _openVideoPlayer(
                                    context,
                                    video,
                                    allVideos,
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            );
                          }).toList(),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _VideoSection extends StatelessWidget {
  final String subject;
  final List<VideoModel> videos;
  final Function(VideoModel) onVideoTap;

  const _VideoSection({
    required this.subject,
    required this.videos,
    required this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.maroon.withOpacity(0.15),
                      AppColors.deepBlue.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.subject_rounded,
                  color: AppColors.maroon,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                subject,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.deepBlue,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: videos.length,
          separatorBuilder: (context, index) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            return _VideoCard(
              video: videos[index],
              onTap: () => onVideoTap(videos[index]),
            );
          },
        ),
      ],
    );
  }
}

class _VideoCard extends StatelessWidget {
  final VideoModel video;
  final VoidCallback onTap;

  const _VideoCard({required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepBlue.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 88,
                  height: 88,
                  color: Colors.grey.shade200,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: video.thumbnailUrl.startsWith('http')
                            ? NetworkImage(video.thumbnailUrl)
                            : AssetImage(video.thumbnailUrl) as ImageProvider,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.video_file_rounded,
                          size: 36,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.4),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.maroon.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: AppColors.maroon,
                            size: 26,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.maroon.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        video.subject,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.maroon,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepBlue,
                        height: 1.3,
                      ),
                    ),
                    if (video.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        video.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.deepBlue.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
