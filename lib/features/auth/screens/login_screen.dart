import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../theme/app_colors.dart';
import 'loading_screen.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../../services/auth_service.dart';
import '../../../services/loading_service.dart';

class LoginScreen extends StatefulWidget {
  final String userRole;
  const LoginScreen({super.key, this.userRole = 'student'});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final savedPassword = prefs.getString('saved_password');
    final rememberMe = prefs.getBool('remember_me') ?? false;

    if (rememberMe && savedEmail != null && savedPassword != null) {
      if (mounted) {
        setState(() {
          _emailController.text = savedEmail;
          _passwordController.text = savedPassword;
          _rememberMe = true;
        });

        // Auto login if we have credentials
        _handleLogin();
      }
    }
  }

  void _handleLogin() async {
    final input = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (input.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both username/email and password'),
          backgroundColor: AppColors.maroon,
        ),
      );
      return;
    }

    LoadingService().show();

    try {
      if (widget.userRole == 'student') {
        // Student Login
        final studentData = await _authService.loginStudent(input, password);

        if (!mounted) return;

        if (studentData != null) {
          if (_rememberMe) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('saved_email', input);
            await prefs.setString('saved_password', password);
            await prefs.setBool('remember_me', true);
            await prefs.setString('user_role', 'student');
          } else {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('saved_email');
            await prefs.remove('saved_password');
            await prefs.setBool('remember_me', false);
            await prefs.remove('user_role');
          }

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid username or password'),
              backgroundColor: AppColors.maroon,
            ),
          );
        }
      } else {
        // Admin Login
        await _authService.signInWithEmailAndPassword(input, password);

        if (!mounted) return;

        if (_rememberMe) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('saved_email', input);
          await prefs.setString('saved_password', password);
          await prefs.setBool('remember_me', true);
          await prefs.setString('user_role', 'admin');
        } else {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('saved_email');
          await prefs.remove('saved_password');
          await prefs.setBool('remember_me', false);
          await prefs.remove('user_role');
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid email or password'),
          backgroundColor: AppColors.maroon,
        ),
      );
    } finally {
      LoadingService().hide();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.userRole == 'admin';
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.deepBlue, Color(0xFF003380), AppColors.maroon],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                (MediaQuery.sizeOf(context).width * 0.06).clamp(16.0, 24.0),
                16,
                (MediaQuery.sizeOf(context).width * 0.06).clamp(16.0, 24.0),
                MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/more/devtrisoft_icon.png',
                      width: 88,
                      height: 88,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'SCHOLARSHIP SCHOOL',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isAdmin ? 'Admin / Teacher' : 'Student',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.95),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    constraints: BoxConstraints(maxWidth: 400),
                    padding: EdgeInsets.only(
                      top: 16,
                      left: (MediaQuery.sizeOf(context).width * 0.06).clamp(
                        16.0,
                        24.0,
                      ),
                      right: (MediaQuery.sizeOf(context).width * 0.06).clamp(
                        16.0,
                        24.0,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.deepBlue.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          style: const TextStyle(
                            color: AppColors.deepBlue,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                isAdmin
                                    ? Icons.email_rounded
                                    : Icons.badge_rounded,
                                color: AppColors.maroon.withOpacity(0.7),
                                size: 22,
                              ),
                            ),
                            labelText: isAdmin ? 'Email' : 'Username',
                            labelStyle: TextStyle(
                              color: AppColors.maroon.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                            filled: true,
                            fillColor: AppColors.lightGrey.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(
                            color: AppColors.deepBlue,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                Icons.lock_rounded,
                                color: AppColors.maroon.withOpacity(0.7),
                                size: 22,
                              ),
                            ),
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: AppColors.maroon.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                            filled: true,
                            fillColor: AppColors.lightGrey.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                                activeColor: AppColors.maroon,
                                checkColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                side: BorderSide(
                                  color: AppColors.maroon.withOpacity(0.6),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Remember me',
                              style: TextStyle(
                                color: AppColors.deepBlue.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 12,
                        ), // Added minimal padding between Remember me and Sign in button

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _handleLogin,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      AppColors.maroon,
                                      AppColors.deepBlue,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.maroon.withOpacity(0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Sign in',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12), // Added minimal padding
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
