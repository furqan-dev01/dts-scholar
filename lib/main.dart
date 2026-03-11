import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/splash/screens/splash_screen.dart';
import 'widgets/global_loader_ui.dart';
import 'services/local_notification_service.dart';
import 'services/background_service.dart';
import 'features/homework/screens/homework_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize Local Notifications
  await LocalNotificationService.instance.init();

  // Initialize Background Service
  await BackgroundService.initialize();

  // Enable offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scholarship School',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF002366)),
        useMaterial3: true,
        // fontFamily: 'SchoolFont', // Uncomment when fonts are added
      ),
      builder: (context, child) {
        return GlobalLoaderUI(child: child ?? const SizedBox.shrink());
      },
      routes: {
        '/homework': (context) => const HomeworkScreen(),
      },
      home: const SplashScreen(),
    );
  }
}
