import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/firestore_config.dart';
import 'cache_service.dart';

class StudentRepository {
  StudentRepository._();
  static final StudentRepository instance = StudentRepository._();

  final ValueNotifier<Map<String, dynamic>?> student = ValueNotifier(null);
  StreamSubscription<DocumentSnapshot>? _sub;
  String? _currentId;

  Future<Map<String, dynamic>?> loadCached(String id) async {
    final k = 'student_doc_$id';
    return await CacheService.instance.getJson(k);
  }

  Future<void> ensureListening(String id) async {
    if (_currentId == id && _sub != null) return;
    await _sub?.cancel();
    _currentId = id;
    _sub = FirestoreConfig.studentsCollection.doc(id).snapshots().listen(
      (snap) async {
        if (!snap.exists) {
          student.value = null;
          return;
        }
        final data = snap.data() as Map<String, dynamic>;
        student.value = data;
        await CacheService.instance.setJson('student_doc_$id', data);
        await CacheService.instance.setInt('student_doc_updated_$id', DateTime.now().millisecondsSinceEpoch);
      },
    );
  }

  Future<void> updateFields(String id, Map<String, dynamic> patch) async {
    await FirestoreConfig.studentsCollection.doc(id).update(patch);
    final current = student.value ?? {};
    final next = Map<String, dynamic>.from(current)..addAll(patch);
    student.value = next;
    await CacheService.instance.setJson('student_doc_$id', next);
    await CacheService.instance.setInt('student_doc_updated_$id', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> clear() async {
    await _sub?.cancel();
    _sub = null;
    _currentId = null;
    student.value = null;
  }
}
