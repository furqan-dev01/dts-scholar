import 'package:flutter/material.dart';
import '../../auth/screens/login_screen.dart';
import '../../../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFade;
  late Animation<Offset> _topArrowSlide;
  late Animation<Offset> _bottomArrowSlide;
  late Animation<Offset> _leftArrowSlide;
  late Animation<Offset> _rightArrowSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    _topArrowSlide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _bottomArrowSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.8, curve: Curves.elasticOut),
      ),
    );

    _leftArrowSlide = Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.9, curve: Curves.elasticOut),
      ),
    );

    _rightArrowSlide = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Top Arrow
          Align(
            alignment: Alignment.topCenter,
            child: SlideTransition(
              position: _topArrowSlide,
              child: _buildArrow(AppColors.deepBlue, quarterTurns: 2),
            ),
          ),
          // Bottom Arrow
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _bottomArrowSlide,
              child: _buildArrow(AppColors.maroon, quarterTurns: 0),
            ),
          ),
          // Left Arrow
          Align(
            alignment: Alignment.centerLeft,
            child: SlideTransition(
              position: _leftArrowSlide,
              child: _buildArrow(AppColors.deepBlue, quarterTurns: 1),
            ),
          ),
          // Right Arrow
          Align(
            alignment: Alignment.centerRight,
            child: SlideTransition(
              position: _rightArrowSlide,
              child: _buildArrow(AppColors.maroon, quarterTurns: 3),
            ),
          ),
          // Center Content (Logo + Text)
          Center(
            child: FadeTransition(
              opacity: _logoFade,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/more/logo.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                     'Welcome\nTo\nScholarship School',
                     textAlign: TextAlign.center,
                     style: TextStyle(
                       fontSize: 26,
                       fontWeight: FontWeight.bold,
                       color: AppColors.deepBlue,
                     ),
                   ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: const Text(
                      'Supporting Academic Excellence and Future Leaders',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.maroon,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/more/devtrisoft_icon.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'product by DevTriSoft',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.deepBlue.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildArrow(Color color, {required int quarterTurns}) {
    return RotatedBox(
      quarterTurns: quarterTurns,
      child: ClipPath(
        clipper: ArrowClipper(),
        child: Container(
          width: 150,
          height: 120,
          color: color,
        ),
      ),
    );
  }
}

class ArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double radius = 30.0;
    
    // Create a rounded triangle pointing up
    path.moveTo(size.width / 2, 0); // Tip
    path.lineTo(size.width, size.height); // Bottom right
    path.lineTo(0, size.height); // Bottom left
    path.close();
    
    // To make it rounded and look like the image (which has very soft corners)
    // we use a more sophisticated path.
    path = Path();
    path.moveTo(size.width / 2, 0);
    path.quadraticBezierTo(size.width / 2 + 10, 5, size.width - 20, size.height - 10);
    path.quadraticBezierTo(size.width, size.height, size.width - 40, size.height);
    path.lineTo(40, size.height);
    path.quadraticBezierTo(0, size.height, 20, size.height - 10);
    path.quadraticBezierTo(size.width / 2 - 10, 5, size.width / 2, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

