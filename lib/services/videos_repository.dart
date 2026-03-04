import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/firestore_config.dart';
import 'cache_service.dart';
import '../global/videos/video_data.dart';

class VideosRepository {
  VideosRepository._();
  static final VideosRepository instance = VideosRepository._();

  final Map<String, ValueNotifier<List<VideoModel>>> _lists = {};
  final Map<String, StreamSubscription<QuerySnapshot>> _subs = {};

  String _key(String schoolId, String clazz, String subject) =>
      'videos_${schoolId}_${clazz}_${subject}';

  ValueNotifier<List<VideoModel>> notifier(String schoolId, String clazz, String subject) {
    final k = _key(schoolId, clazz, subject);
    return _lists.putIfAbsent(k, () => ValueNotifier<List<VideoModel>>([]));
  }

  Future<List<VideoModel>> loadCached(String schoolId, String clazz, String subject) async {
    final k = _key(schoolId, clazz, subject);
    final list = await CacheService.instance.getJsonList(k);
    if (list == null) return [];
    return list.map((e) => VideoModel(
      title: e['title'] ?? '',
      description: e['description'] ?? '',
      thumbnailUrl: e['thumbnailUrl'] ?? '',
      videoUrl: e['videoUrl'] ?? '',
      subject: e['subject'] ?? '',
    )).toList();
  }

  Future<void> ensureListening(String schoolId, String clazz, String subject) async {
    final k = _key(schoolId, clazz, subject);
    if (_subs.containsKey(k)) return;
    final sub = FirestoreConfig.videosCollection
        .where('school_id', isEqualTo: schoolId)
        .where('class', isEqualTo: clazz)
        .where('subject', isEqualTo: subject)
        .snapshots()
        .listen((snapshot) async {
      final items = snapshot.docs.map((doc) {
        final d = doc.data() as Map<String, dynamic>;
        return VideoModel(
          title: d['title'] ?? '',
          description: d['description'] ?? '',
          thumbnailUrl: d['thumbnailUrl'] ?? '',
          videoUrl: d['videoUrl'] ?? '',
          subject: d['subject'] ?? '',
        );
      }).toList();
      final n = notifier(schoolId, clazz, subject);
      n.value = items;
      await CacheService.instance.setJsonList(
        k,
        items.map((e) => {
          'title': e.title,
          'description': e.description,
          'thumbnailUrl': e.thumbnailUrl,
          'videoUrl': e.videoUrl,
          'subject': e.subject,
        }).toList(),
      );
      await CacheService.instance.setInt('${k}_updated', DateTime.now().millisecondsSinceEpoch);
    });
    _subs[k] = sub;
  }

  Future<String> addVideo(String schoolId, String clazz, String subject, Map<String, dynamic> data) async {
    final payload = Map<String, dynamic>.from(data)
      ..addAll({'school_id': schoolId, 'class': clazz, 'subject': subject});
    final doc = await FirestoreConfig.videosCollection.add(payload);
    final n = notifier(schoolId, clazz, subject);
    final list = List<VideoModel>.from(n.value);
    list.add(VideoModel(
      title: payload['title'] ?? '',
      description: payload['description'] ?? '',
      thumbnailUrl: payload['thumbnailUrl'] ?? '',
      videoUrl: payload['videoUrl'] ?? '',
      subject: subject,
    ));
    n.value = list;
    await CacheService.instance.setJsonList(
      _key(schoolId, clazz, subject),
      list.map((e) => {
        'title': e.title,
        'description': e.description,
        'thumbnailUrl': e.thumbnailUrl,
        'videoUrl': e.videoUrl,
        'subject': e.subject,
      }).toList(),
    );
    return doc.id;
  }

  Future<void> updateVideo(String docId, Map<String, dynamic> patch) async {
    await FirestoreConfig.videosCollection.doc(docId).update(patch);
  }

  Future<void> deleteVideo(String docId) async {
    await FirestoreConfig.videosCollection.doc(docId).delete();
  }

  Future<void> clear(String schoolId, String clazz, String subject) async {
    final k = _key(schoolId, clazz, subject);
    await _subs[k]?.cancel();
    _subs.remove(k);
    _lists[k]?.value = [];
    _lists.remove(k);
  }
}
