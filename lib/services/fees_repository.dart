import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/firestore_config.dart';
import 'cache_service.dart';

class FeesRepository {
  FeesRepository._();
  static final FeesRepository instance = FeesRepository._();

  final ValueNotifier<Map<String, dynamic>?> data = ValueNotifier(null);
  StreamSubscription<DocumentSnapshot>? _sub;
  String? _currentId;

  Future<Map<String, dynamic>?> loadCached(String id) async {
    final k = 'fees_doc_$id';
    return await CacheService.instance.getJson(k);
  }

  Future<void> ensureListening(String id) async {
    if (_currentId == id && _sub != null) return;
    await _sub?.cancel();
    _currentId = id;
    _sub = FirestoreConfig.feesCollection.doc(id).snapshots().listen(
      (snap) async {
        if (!snap.exists) {
          data.value = null;
          return;
        }
        final d = snap.data() as Map<String, dynamic>;
        data.value = d;
        await CacheService.instance.setJson('fees_doc_$id', d);
        await CacheService.instance.setInt('fees_doc_updated_$id', DateTime.now().millisecondsSinceEpoch);
      },
    );
  }

  Future<void> updateFields(String id, Map<String, dynamic> patch) async {
    await FirestoreConfig.feesCollection.doc(id).set(patch, SetOptions(merge: true));
    final current = data.value ?? {};
    final next = Map<String, dynamic>.from(current)..addAll(patch);
    data.value = next;
    await CacheService.instance.setJson('fees_doc_$id', next);
    await CacheService.instance.setInt('fees_doc_updated_$id', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> clear() async {
    await _sub?.cancel();
    _sub = null;
    _currentId = null;
    data.value = null;
  }
}
