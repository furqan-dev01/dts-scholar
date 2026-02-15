import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../config/firestore_config.dart';
import '../../../theme/app_colors.dart';

class ManageVideosScreen extends StatefulWidget {
  const ManageVideosScreen({super.key});

  @override
  State<ManageVideosScreen> createState() => _ManageVideosScreenState();
}

class _ManageVideosScreenState extends State<ManageVideosScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Form Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();
  final TextEditingController _thumbnailUrlController = TextEditingController();

  String _selectedClass = 'Playgroup';
  String _selectedSubject = 'English';

  final List<String> _classOptions = [
    'Playgroup',
    'Nursery',
    'Prep',
    '1st',
    '2nd',
    '3rd',
    '4th',
    '5th',
    '6th',
    '7th',
    '8th',
    '9th',
    '10th',
    '11th',
    '12th',
  ];

  final List<String> _subjectOptions = [
    'English',
    'Math',
    'Science',
    'General Knowledge',
    'History',
    'Geography',
    'Islamiyat',
    'Urdu',
    'Nazara',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    _thumbnailUrlController.dispose();
    super.dispose();
  }

  void _showAddVideoSheet({DocumentSnapshot? videoDoc}) {
    // If editing, pre-fill controllers
    if (videoDoc != null) {
      final data = videoDoc.data() as Map<String, dynamic>;
      _titleController.text = data['title'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _videoUrlController.text = data['videoUrl'] ?? '';
      _thumbnailUrlController.text = data['thumbnailUrl'] ?? '';

      if (data['subject'] != null &&
          _subjectOptions.contains(data['subject'])) {
        _selectedSubject = data['subject'];
      } else {
        _selectedSubject = _subjectOptions.first;
      }

      if (data['class'] != null && _classOptions.contains(data['class'])) {
        _selectedClass = data['class'];
      } else {
        _selectedClass = _classOptions.first;
      }
    } else {
      // Clear controllers
      _titleController.clear();
      _descriptionController.clear();
      _videoUrlController.clear();
      _thumbnailUrlController.clear();
      _selectedSubject = _subjectOptions.first;
      _selectedClass = _classOptions.first;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      videoDoc == null ? 'Add New Video' : 'Edit Video',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepBlue,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Title'),
                      _buildTextField(_titleController, 'Enter video title'),
                      const SizedBox(height: 16),

                      _buildLabel('Description'),
                      _buildTextField(
                        _descriptionController,
                        'Enter description',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.15),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedClass,
                                  isExpanded: true,
                                  items: _classOptions.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text('Class: $value'),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    if (newValue != null) {
                                      setState(() => _selectedClass = newValue);
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.expand_more,
                                    color: AppColors.deepBlue,
                                  ),
                                  style: const TextStyle(
                                    color: AppColors.deepBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.15),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedSubject,
                                  isExpanded: true,
                                  items: _subjectOptions.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text('Subject: $value'),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    if (newValue != null) {
                                      setState(
                                        () => _selectedSubject = newValue,
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.expand_more,
                                    color: AppColors.deepBlue,
                                  ),
                                  style: const TextStyle(
                                    color: AppColors.deepBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Video URL'),
                      _buildTextField(
                        _videoUrlController,
                        'https://youtu.be/...',
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Thumbnail URL'),
                      _buildTextField(
                        _thumbnailUrlController,
                        'assets/video_images/ABC.png or https://...',
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () =>
                              _saveVideo(context, docId: videoDoc?.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.maroon,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            videoDoc == null ? 'Save Video' : 'Update Video',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.deepBlue,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.maroon),
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }

  Future<void> _saveVideo(BuildContext context, {String? docId}) async {
    if (_titleController.text.isEmpty || _videoUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in required fields (Title, Video URL)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not logged in')));
      return;
    }

    try {
      final data = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'videoUrl': _videoUrlController.text.trim(),
        'thumbnailUrl': _thumbnailUrlController.text.trim(),
        'subject': _selectedSubject,
        'class': _selectedClass,
        'school_id': user.uid,
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (docId != null) {
        await FirestoreConfig.videosCollection.doc(docId).update(data);
      } else {
        data['created_at'] = FieldValue.serverTimestamp();
        await FirestoreConfig.videosCollection.add(data);
      }

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              docId != null
                  ? 'Video updated successfully!'
                  : 'Video added successfully!',
            ),
            backgroundColor: AppColors.deepBlue,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteVideo(String docId) async {
    try {
      await FirestoreConfig.videosCollection.doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video deleted successfully'),
            backgroundColor: AppColors.maroon,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting video: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 56,
              left: 20,
              right: 20,
              bottom: 28,
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
                      child: const Icon(
                        Icons.video_library_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manage Videos',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Upload & organize lessons',
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
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  child: const Icon(Icons.play_circle_rounded, color: Colors.white, size: 24),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.deepBlue.withOpacity(0.06),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search videos...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: AppColors.deepBlue.withOpacity(0.6),
                              size: 22,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AppColors.maroon,
                                width: 2,
                              ),
                            ),
                          ),
                          style: const TextStyle(
                            color: AppColors.deepBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _showAddVideoSheet,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.maroon, Color(0xFFA52A2A)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.maroon.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.15),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedClass,
                            isExpanded: true,
                            items: _classOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text('Class: $value'),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              if (newValue != null) {
                                setState(() => _selectedClass = newValue);
                              }
                            },
                            icon: const Icon(
                              Icons.expand_more,
                              color: AppColors.deepBlue,
                            ),
                            style: const TextStyle(
                              color: AppColors.deepBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.15),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSubject,
                            isExpanded: true,
                            items: _subjectOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text('Subject: $value'),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              if (newValue != null) {
                                setState(() => _selectedSubject = newValue);
                              }
                            },
                            icon: const Icon(
                              Icons.expand_more,
                              color: AppColors.deepBlue,
                            ),
                            style: const TextStyle(
                              color: AppColors.deepBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirestoreConfig.videosCollection
                  .where('school_id', isEqualTo: user?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                // Client-side filtering
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title = data['title']?.toString().toLowerCase() ?? '';
                  final subject =
                      data['subject']?.toString().toLowerCase() ?? '';
                  final query = _searchController.text.toLowerCase();

                  return title.contains(query) || subject.contains(query);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(child: Text('No videos found'));
                }

                // Group by Class -> Subject -> Videos
                final Map<String, Map<String, List<DocumentSnapshot>>>
                groupedVideos = {};

                for (var doc in filteredDocs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final className = data['class'] as String? ?? 'Uncategorized';
                  final subjectName = data['subject'] as String? ?? 'Other';

                  if (!groupedVideos.containsKey(className)) {
                    groupedVideos[className] = {};
                  }
                  if (!groupedVideos[className]!.containsKey(subjectName)) {
                    groupedVideos[className]![subjectName] = [];
                  }
                  groupedVideos[className]![subjectName]!.add(doc);
                }

                // Sort classes
                final sortedClasses = groupedVideos.keys.toList()
                  ..sort((a, b) {
                    int indexA = _classOptions.indexOf(a);
                    int indexB = _classOptions.indexOf(b);
                    if (indexA == -1) indexA = 999;
                    if (indexB == -1) indexB = 999;
                    return indexA.compareTo(indexB);
                  });

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: sortedClasses.length,
                  itemBuilder: (context, index) {
                    final className = sortedClasses[index];
                    final subjectsMap = groupedVideos[className]!;
                    final sortedSubjects = subjectsMap.keys.toList()..sort();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Class Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          color: Colors.grey[200],
                          child: Text(
                            className,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepBlue,
                            ),
                          ),
                        ),

                        // Subjects
                        ...sortedSubjects.map((subject) {
                          final videos = subjectsMap[subject]!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  16,
                                  20,
                                  8,
                                ),
                                child: Text(
                                  subject,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.maroon,
                                  ),
                                ),
                              ),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: videos.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, vIndex) {
                                  return _buildVideoCard(videos[vIndex]);
                                },
                              ),
                              const SizedBox(height: 8),
                            ],
                          );
                        }),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepBlue.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Implement video playback or details view
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Thumbnail
                    Container(
                      width: 80,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            data['thumbnailUrl'] != null &&
                                data['thumbnailUrl'].toString().isNotEmpty
                            ? Image.network(
                                data['thumbnailUrl'],
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.video_library,
                                      color: Colors.grey,
                                    ),
                              )
                            : const Icon(
                                Icons.video_library,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['title'] ?? 'No Title',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepBlue,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${data['subject']} • ${data['class']}',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _QuickActionButton(
                      icon: Icons.edit_outlined,
                      label: 'Edit',
                      color: Colors.blue,
                      onTap: () => _showAddVideoSheet(videoDoc: doc),
                    ),
                    _QuickActionButton(
                      icon: Icons.delete_outline,
                      label: 'Delete',
                      color: Colors.red,
                      onTap: () => _deleteVideo(doc.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for quick action buttons
  Widget _QuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
