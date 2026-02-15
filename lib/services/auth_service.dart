import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with Email and Password
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        await _saveUserLocally(user.uid);
      }

      return user;
    } catch (e) {
      print('Error logging in: $e');
      rethrow;
    }
  }

  // Student Login
  Future<Map<String, dynamic>?> loginStudent(
    String username,
    String password,
  ) async {
    try {
      // Query the students collection for the matching username
      final QuerySnapshot result = await _firestore
          .collection('students')
          .where('username', isEqualTo: username)
          .limit(1)
          .snapshots()
          .first;

      if (result.docs.isEmpty) {
        return null; // User not found
      }

      final doc = result.docs.first;
      final data = doc.data() as Map<String, dynamic>;

      // Check if password matches
      // Note: In a real app, passwords should be hashed.
      // Assuming plain text for this specific requirement as per user input.
      if (data['password'] == password) {
        // Save doc.id (which is usually the student_id based on schema)
        // AND explicitly save the 'student_id' field if available to be sure.
        await _saveUserLocally(doc.id);

        // Save specific student_id if it exists in data, otherwise use doc.id
        String studentId = data['student_id'] ?? doc.id;
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('student_id', studentId);

        return data;
      } else {
        return null; // Password mismatch
      }
    } catch (e) {
      print('Error logging in student: $e');
      rethrow;
    }
  }

  // Save User UID locally
  Future<void> _saveUserLocally(String uid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_uid', uid);
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_uid');
    await prefs.remove('school_id');
    // We can also cancel the background task if needed, but clearing school_id stops it from fetching.
  }

  // Get current user
  User? get currentUser => _auth.currentUser;
}
