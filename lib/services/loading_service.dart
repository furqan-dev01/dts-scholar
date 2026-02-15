import 'package:flutter/material.dart';

class LoadingService {
  // Singleton pattern
  static final LoadingService _instance = LoadingService._internal();
  factory LoadingService() => _instance;
  LoadingService._internal();

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  void show() {
    isLoading.value = true;
  }

  void hide() {
    isLoading.value = false;
  }
}
