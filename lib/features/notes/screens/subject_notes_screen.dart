import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
 
class SubjectNotesScreen extends StatefulWidget {
  final String subject;
  final int? chapterNumber;
  const SubjectNotesScreen({super.key, required this.subject, this.chapterNumber});
 
  @override
  State<SubjectNotesScreen> createState() => _SubjectNotesScreenState();
}
 
class _SubjectNotesScreenState extends State<SubjectNotesScreen> {
  String? _schoolId;
  bool _loading = true;
 
  @override
  void initState() {
    super.initState();
    _loadContext();
  }
 
  Future<void> _loadContext() async {
    final prefs = await SharedPreferences.getInstance();
    final schoolId = prefs.getString('school_id');
    if (mounted) {
      setState(() {
        _schoolId = schoolId;
        _loading = false;
      });
    }
  }
 
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(child: CircularProgressIndicator(color: AppColors.maroon)),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: AppColors.deepBlue,
        elevation: 0,
        title: Text(widget.subject, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notes')
            .where('school_id', isEqualTo: _schoolId)
            .where('subject', isEqualTo: widget.subject)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.maroon));
          }
          var docs = snapshot.data!.docs;
          if (widget.chapterNumber != null) {
            final int target = widget.chapterNumber!;
            docs = docs.where((d) {
              final data = d.data() as Map<String, dynamic>;
              final ch = data['chapter'];
              if (ch == null) return false;
              final str = ch.toString();
              final match = RegExp(r'\d+').firstMatch(str);
              if (match == null) return false;
              final numStr = match.group(0)!;
              final parsed = int.tryParse(numStr);
              return parsed == target;
            }).toList();
          }
          if (docs.isEmpty) {
            return const Center(child: Text('No notes for this subject'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final title = (data['title'] ?? '').toString();
              final description = (data['description'] ?? '').toString();
              final chapter = (data['chapter'] ?? '').toString();
              final className = (data['class'] ?? data['className'] ?? data['classsName'] ?? '').toString();
              final rawUrl = (data['noteUrl'] ?? data['noreUrl'] ?? '').toString();
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _openUrl(rawUrl),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.deepBlue.withOpacity(0.15),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.deepBlue.withOpacity(0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.isNotEmpty ? title : 'Untitled',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.deepBlue,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (description.isNotEmpty)
                            Text(description, style: TextStyle(color: Colors.grey.shade700)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.menu_book_rounded, size: 16, color: AppColors.maroon),
                              const SizedBox(width: 6),
                              Text(chapter.isNotEmpty ? chapter : 'Chapter', style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 16),
                              const Icon(Icons.school_rounded, size: 16, color: AppColors.deepBlue),
                              const SizedBox(width: 6),
                              Text(className.isNotEmpty ? className : 'Class', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
 
  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    final normalized = url.startsWith('http') ? url : 'https://$url';
    final uri = Uri.tryParse(normalized);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
