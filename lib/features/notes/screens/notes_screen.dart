import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../theme/app_colors.dart';
import 'subject_notes_screen.dart';
import 'subject_chapters_screen.dart';
 
class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});
 
  @override
  State<NotesScreen> createState() => _NotesScreenState();
}
 
class _NotesScreenState extends State<NotesScreen> {
  String? _schoolId;
  String? _studentId;
  String? _className;
  bool _loading = true;
 
  @override
  void initState() {
    super.initState();
    _loadContext();
  }
 
  Future<void> _loadContext() async {
    final prefs = await SharedPreferences.getInstance();
    final schoolId = prefs.getString('school_id');
    final studentId = prefs.getString('student_id') ?? prefs.getString('user_uid');
    String? className;
    if (studentId != null) {
      final doc = await FirebaseFirestore.instance.collection('students').doc(studentId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        className = data['class']?.toString();
      }
    }
    if (mounted) {
      setState(() {
        _schoolId = schoolId;
        _studentId = studentId;
        _className = className;
        _loading = false;
      });
    }
  }
 
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final Map<String, String> subjectImages = {
      'English': 'assets/more/english.png',
      'Social Studies': 'assets/more/social.png',
      'Urdu': 'assets/more/urdu.png',
      'Math': 'assets/more/maths.png',
      'General Science': 'assets/more/science.png',
      'Islamiyat': 'assets/more/islamiyat.png',
      'General Knowledge': 'assets/more/general_knowledge.png',
      'Pakistan Studies': 'assets/more/pakistan_studies.png',
      'Geography': 'assets/more/geo.png',
      'History': 'assets/more/history.png',
      'Arabic': 'assets/more/arabic.png',
    };
    final List<String> subjects = [
      'English',
      'Social Studies',
      'Urdu',
      'Math',
      'General Science',
      'Islamiyat',
      'General Knowledge',
      'Pakistan Studies',
      'Geography',
      'History',
      'Arabic',
    ];
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(child: CircularProgressIndicator(color: AppColors.maroon)),
      );
    }
    if (_schoolId == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(child: Text('No school context found')),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.deepBlue, Color(0xFF003380), AppColors.maroon],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
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
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.description_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Notes',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _className != null ? 'Class $_className' : 'All Classes',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    child: const Icon(Icons.description_rounded, color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: GridView.builder(
                  shrinkWrap: false,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    final borderColor = index % 2 == 0 ? AppColors.deepBlue : AppColors.maroon;
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubjectChaptersScreen(subject: subject),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: borderColor, width: 1),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (subjectImages.containsKey(subject))
                              Image.asset(
                                subjectImages[subject]!,
                                height: 80,
                                width: 80,
                              )
                            else
                              const Icon(
                                Icons.subject,
                                size: 80,
                                color: AppColors.deepBlue,
                              ),
                            Text(
                              subject,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
