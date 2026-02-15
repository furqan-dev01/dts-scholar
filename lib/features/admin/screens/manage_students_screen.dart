import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../config/firestore_config.dart';
import '../../../theme/app_colors.dart';
import '../../../services/loading_service.dart';
import 'edit_student_screen.dart';
import 'student_fee_screen.dart';
import 'student_details_screen.dart';
import 'add_student_screen.dart';

class ManageStudentsScreen extends StatefulWidget {
  final String schoolId;

  const ManageStudentsScreen({super.key, required this.schoolId});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedClass = 'All';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
              colors: [AppColors.deepBlue, Color(0xFF003380), AppColors.maroon],
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
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manage Students',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Add, edit & view students',
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
                child: const Icon(
                  Icons.people_rounded,
                  color: Colors.white,
                  size: 24,
                ),
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
                          hintText: 'Search by name or username…',
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
                            borderSide: BorderSide(
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
                      onTap: _openAddStudent,
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
                          Icons.person_add_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepBlue.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedClass,
                          items: [
                            const DropdownMenuItem(
                              value: 'All',
                              child: Text('Class: All'),
                            ),
                            ..._classOptions.map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text('Class: $c'),
                              ),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedClass = v ?? 'All'),
                          icon: const Icon(
                            Icons.expand_more,
                            color: AppColors.deepBlue,
                          ),
                          style: const TextStyle(
                            color: AppColors.deepBlue,
                            fontWeight: FontWeight.w600,
                          ),
                          isExpanded: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirestoreConfig.studentsCollection
                .where('school_id', isEqualTo: widget.schoolId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  LoadingService().hide();
                });
                return Center(child: Text('Error: ${snapshot.error}'));
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

              final docs = snapshot.data?.docs ?? [];
              final allStudents = docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return {
                  'id': doc.id,
                  'name': data['student_name']?.toString() ?? '',
                  'username': data['username']?.toString() ?? '',
                  'password': data['password']?.toString() ?? '',
                  'class': data['class']?.toString() ?? '',
                };
              }).toList();

              // Apply filters
              final query = _searchController.text.toLowerCase().trim();
              final filteredStudents = allStudents.where((s) {
                final matchesQuery =
                    query.isEmpty ||
                    s['name']!.toLowerCase().contains(query) ||
                    s['username']!.toLowerCase().contains(query);
                final matchesClass =
                    _selectedClass == 'All' || s['class'] == _selectedClass;
                return matchesQuery && matchesClass;
              }).toList();

              if (filteredStudents.isEmpty) {
                return const Center(child: Text('No students found'));
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: filteredStudents.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final s = filteredStudents[index];
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  StudentDetailsScreen(student: s),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.deepBlue.withOpacity(
                                        0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.person_rounded,
                                      color: AppColors.deepBlue,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s['name']!,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.deepBlue,
                                          ),
                                        ),
                                        Text(
                                          '@${s['username']}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[500],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.maroon.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      s['class']!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.maroon,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Divider(height: 1),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _QuickActionButton(
                                    icon: Icons.account_balance_wallet_rounded,
                                    label: 'Fees',
                                    color: Colors.green,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              StudentFeeScreen(
                                                studentId: s['id'] ?? '',
                                                studentName: s['name'] ?? '',
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                  _QuickActionButton(
                                    icon: Icons.edit_note_rounded,
                                    label: 'Edit',
                                    color: Colors.blue,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditStudentScreen(
                                            student: s,
                                            onSave: (updatedStudent) async {
                                              try {
                                                await FirestoreConfig
                                                    .studentsCollection
                                                    .doc(s['id'])
                                                    .update({
                                                      'student_name':
                                                          updatedStudent['name'],
                                                      'username':
                                                          updatedStudent['username'],
                                                      'password':
                                                          updatedStudent['password'],
                                                      'class':
                                                          updatedStudent['class'],
                                                    });
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Student updated successfully',
                                                      ),
                                                      backgroundColor:
                                                          AppColors.deepBlue,
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Error updating student: $e',
                                                      ),
                                                      backgroundColor:
                                                          AppColors.maroon,
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  _QuickActionButton(
                                    icon: Icons.delete_sweep_rounded,
                                    label: 'Delete',
                                    color: Colors.red,
                                    onTap: () {
                                      _showDeleteDialog(context, s);
                                    },
                                  ),
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
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, Map<String, String> student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.maroon.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: const Icon(
                Icons.delete_sweep_rounded,
                color: AppColors.maroon,
                size: 48,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'Delete Student?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Are you sure you want to delete ${student['name']}? This action cannot be undone and will delete all related records.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              Navigator.pop(context);
                              LoadingService().show();
                              await FirestoreConfig.studentsCollection
                                  .doc(student['id'])
                                  .delete();
                              await FirestoreConfig.feesCollection
                                  .doc(student['id'])
                                  .delete();
                              LoadingService().hide();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Student deleted successfully',
                                    ),
                                    backgroundColor: AppColors.maroon,
                                  ),
                                );
                              }
                            } catch (e) {
                              LoadingService().hide();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error deleting student: $e'),
                                    backgroundColor: AppColors.maroon,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.maroon,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('Delete'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddStudent() {
    final nameController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    String classVal = '10th';
    bool obscurePassword = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 20,
              bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add Student',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepBlue,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Full name',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.maroon, width: 1),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.maroon, width: 1),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                StatefulBuilder(
                  builder: (context, setInner) {
                    return TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.maroon,
                            width: 1,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setInner(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: StatefulBuilder(
                            builder: (context, setInner) =>
                                DropdownButton<String>(
                                  value: classVal,
                                  items: _classOptions
                                      .map(
                                        (c) => DropdownMenuItem(
                                          value: c,
                                          child: Text('Class: $c'),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) =>
                                      setInner(() => classVal = v ?? '10th'),
                                  icon: const Icon(
                                    Icons.expand_more,
                                    color: AppColors.deepBlue,
                                  ),
                                  isExpanded: true,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.maroon,
                          side: const BorderSide(color: AppColors.maroon),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final username = usernameController.text.trim();
                          final password = passwordController.text.trim();

                          if (name.isEmpty ||
                              username.isEmpty ||
                              password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill all fields'),
                                backgroundColor: AppColors.maroon,
                              ),
                            );
                            return;
                          }

                          try {
                            // Use passed schoolId
                            final String schoolId = widget.schoolId;

                            if (schoolId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Error: User not logged in'),
                                  backgroundColor: AppColors.maroon,
                                ),
                              );
                              return;
                            }

                            // Save to Firestore with explicit document ID
                            final newStudentRef = FirestoreConfig
                                .studentsCollection
                                .doc();

                            await newStudentRef.set({
                              'student_id':
                                  newStudentRef.id, // Save doc ID as uid
                              'student_name': name,
                              'username': username,
                              'password': password,
                              'class': classVal,
                              'school_id': widget.schoolId,
                              'created_at': FieldValue.serverTimestamp(),
                            });

                            // Create corresponding fee record
                            final initialMonthData = {
                              'total_fee': 0,
                              'payable': 0,
                              'status': 'Pending',
                            };

                            await FirestoreConfig.feesCollection
                                .doc(newStudentRef.id)
                                .set({
                                  'school_id': widget.schoolId,
                                  'Jan': initialMonthData,
                                  'Feb': initialMonthData,
                                  'Mar': initialMonthData,
                                  'Apr': initialMonthData,
                                  'May': initialMonthData,
                                  'Jun': initialMonthData,
                                  'Jul': initialMonthData,
                                  'Aug': initialMonthData,
                                  'Sep': initialMonthData,
                                  'Oct': initialMonthData,
                                  'Nov': initialMonthData,
                                  'Dec': initialMonthData,
                                  'created_at': DateTime.now()
                                      .toIso8601String(),
                                });

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Student added successfully'),
                                  backgroundColor: AppColors.deepBlue,
                                ),
                              );
                              Navigator.of(context).pop();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error saving student: $e'),
                                  backgroundColor: AppColors.maroon,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.deepBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
