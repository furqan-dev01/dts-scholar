import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../theme/app_colors.dart';
import 'loading_screen.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../../services/auth_service.dart';
import '../../../services/loading_service.dart';
import '../../../widgets/wave_clipper.dart';

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
    final screenSize = MediaQuery.sizeOf(context);
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Responsive measurements
    final headerHeight = (screenHeight * 0.35).clamp(200.0, 350.0);
    final logoSize = (screenWidth * 0.4).clamp(100.0, 200.0);
    final horizontalPadding = (screenWidth * 0.08).clamp(16.0, 40.0);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    height: headerHeight,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.deepBlue, AppColors.maroon],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 50,
                  left: 20,
                  right: 20,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Welcome to Digital Scholarship School',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 4.0,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/more/devtrisoft_icon.png',
                              width: 16,
                              height: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'product by DevTriSoft',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                0, // Reduced padding as logo will be here
                horizontalPadding,
                MediaQuery.viewInsetsOf(context).bottom + 20,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/more/logo.png',
                      width: logoSize * 0.8,
                      height: logoSize * 0.8,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepBlue,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 450), // Slightly wider for tablets
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepBlue.withOpacity(0.1),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _emailController,
                            keyboardType: isAdmin
                                ? TextInputType.emailAddress
                                : TextInputType.text,
                            textInputAction: TextInputAction.next,
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
                              hintText: 'username@scholarship.com',
                              labelStyle: TextStyle(
                                color: AppColors.maroon.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                              hintStyle: TextStyle(
                                color: AppColors.deepBlue.withOpacity(0.3),
                                fontWeight: FontWeight.w400,
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
                          const SizedBox(height: 18),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleLogin(),
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
                              hintText: '......',
                              labelStyle: TextStyle(
                                color: AppColors.maroon.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                              hintStyle: TextStyle(
                                color: AppColors.deepBlue.withOpacity(0.3),
                                fontWeight: FontWeight.w400,
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
                          const SizedBox(height: 20),
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
                                  checkColor: AppColors.white,
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
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
} 
