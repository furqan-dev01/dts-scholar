import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreConfig {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection References
  static CollectionReference get usersCollection =>
      _firestore.collection('users');
  static CollectionReference get schoolsCollection =>
      _firestore.collection('schools');
  static CollectionReference get studentsCollection =>
      _firestore.collection('students');
  static CollectionReference get noticesCollection =>
      _firestore.collection('notices');
  static CollectionReference get videosCollection =>
      _firestore.collection('videos');
  static CollectionReference get feesCollection =>
      _firestore.collection('fees');

  // Helper method to get user document by ID
  static DocumentReference getUserDoc(String uid) {
    return usersCollection.doc(uid);
  }

  // Helper method to get school document by ID
  static DocumentReference getSchoolDoc(String uid) {
    return schoolsCollection.doc(uid);
  }

  // Helper method to get student document by ID
  static DocumentReference getStudentDoc(String studentId) {
    return studentsCollection.doc(studentId);
  }
}
