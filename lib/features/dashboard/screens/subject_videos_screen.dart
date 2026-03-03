import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../theme/app_colors.dart';
import '../../../global/videos/video_data.dart';
import 'video_player_screen.dart';

class SubjectVideosScreen extends StatefulWidget {
  final String subject;

  const SubjectVideosScreen({super.key, required this.subject});

  @override
  State<SubjectVideosScreen> createState() => _SubjectVideosScreenState();
}

class _SubjectVideosScreenState extends State<SubjectVideosScreen> {
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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.deepBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<DocumentSnapshot>(
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
                .where('subject', isEqualTo: widget.subject)
                .snapshots(),
            builder: (context, videoSnapshot) {
              if (!videoSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.maroon),
                );
              }

              final videos = videoSnapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return VideoModel(
                  title: data['title'] ?? '',
                  description: data['description'] ?? '',
                  thumbnailUrl: data['thumbnailUrl'] ?? '',
                  videoUrl: data['videoUrl'] ?? '',
                  subject: data['subject'] ?? '',
                );
              }).toList();

              if (videos.isEmpty) {
                return const Center(
                  child: Text("No videos found for this subject."),
                );
              }

              return ListView.builder(
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final video = videos[index];
                  final borderColor = index % 2 == 0 ? AppColors.deepBlue : AppColors.maroon;
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: borderColor, width: 1),
                    ),
                    child: ListTile(
                      leading: Image.network(
                        video.thumbnailUrl,
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.error),
                      ),
                      title: Text(video.title, style: const TextStyle(color: AppColors.deepBlue, fontWeight: FontWeight.bold)),
                      subtitle: Text(video.description),
                      onTap: () => _openVideoPlayer(context, video, videos),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
