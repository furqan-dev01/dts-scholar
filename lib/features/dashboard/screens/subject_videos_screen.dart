import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../theme/app_colors.dart';
import '../../../global/videos/video_data.dart';
import 'video_player_screen.dart';
import '../../../services/student_repository.dart';
import '../../../services/videos_repository.dart';

class SubjectVideosScreen extends StatefulWidget {
  final String subject;

  const SubjectVideosScreen({super.key, required this.subject});

  @override
  State<SubjectVideosScreen> createState() => _SubjectVideosScreenState();
}

class _SubjectVideosScreenState extends State<SubjectVideosScreen> {
  String? _studentId;
  bool _isLoadingId = true;

  // Old initState/_loadStudentId removed in favor of repository-powered init.

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

  Future<void> _initRepositories() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('student_id') ?? prefs.getString('user_uid');
    if (!mounted) return;
    setState(() {
      _studentId = id;
      _isLoadingId = false;
    });
    if (id != null) {
      await StudentRepository.instance.ensureListening(id);
    }
  }

  @override
  void initState() {
    super.initState();
    _initRepositories();
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
      body: ValueListenableBuilder<Map<String, dynamic>?>(
        valueListenable: StudentRepository.instance.student,
        builder: (context, studentData, _) {
          final studentClass = studentData?['class'] as String?;
          final schoolId = studentData?['school_id'] as String?;
          if (studentClass == null || schoolId == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.maroon),
            );
          }
          final notifier = VideosRepository.instance.notifier(
            schoolId,
            studentClass,
            widget.subject,
          );
          VideosRepository.instance.ensureListening(
            schoolId,
            studentClass,
            widget.subject,
          );
          return ValueListenableBuilder<List<VideoModel>>(
            valueListenable: notifier,
            builder: (context, videos, _) {
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
