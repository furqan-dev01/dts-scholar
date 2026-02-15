import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/screens/role_selection_screen.dart';
import '../../auth/screens/login_screen.dart';
import '../../../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Wait for 3 seconds for splash effect
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? false;
    final savedRole = prefs.getString('user_role');

    if (mounted) {
      if (rememberMe && savedRole != null) {
        // If remember me is checked, go to LoginScreen which will handle auto-login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginScreen(userRole: savedRole),
          ),
        );
      } else {
        // Otherwise go to role selection
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppColors.primaryGradient),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Main School Logo
            Image.asset(
              'assets/more/logo.png',
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),
            const Spacer(),
            // DevTriSoft Logo
            const Text(
              'Powered by',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Image.asset(
              'assets/more/devtrisoft_icon.png',
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
