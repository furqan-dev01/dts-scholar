import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'subject_notes_screen.dart';

class SubjectChaptersScreen extends StatelessWidget {
  final String subject;
  const SubjectChaptersScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final chapters = List<int>.generate(12, (i) => i + 1);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: AppColors.deepBlue,
        elevation: 0,
        title: Text('$subject Chapters', style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final ch = chapters[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubjectNotesScreen(
                    subject: subject,
                    chapterNumber: ch,
                  ),
                ),
              );
            },
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.deepBlue),
              ),
              child: Center(
                child: Text(
                  'Chapter $ch',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepBlue,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
