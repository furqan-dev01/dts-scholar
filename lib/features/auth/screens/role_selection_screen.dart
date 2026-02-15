import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final padding = (screenWidth * 0.06).clamp(16.0, 28.0);
    final isNarrow = screenWidth < 400;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.deepBlue,
              Color(0xFF003380),
              AppColors.maroon,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: padding,
                vertical: MediaQuery.paddingOf(context).vertical + 16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 400),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: padding,
                    vertical: (screenWidth * 0.08).clamp(24.0, 36.0),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepBlue.withOpacity(0.25),
                        blurRadius: 32,
                        offset: const Offset(0, 16),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.deepBlue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Continue as',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.deepBlue,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(height: isNarrow ? 20 : 32),
                      if (isNarrow)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildRoleOption(
                              context,
                              title: 'Admin',
                              iconPath: 'assets/more/admin_icon.png',
                              role: 'admin',
                            ),
                            const SizedBox(height: 16),
                            _buildRoleOption(
                              context,
                              title: 'Student',
                              iconPath: 'assets/more/student_icon.png',
                              role: 'student',
                            ),
                          ],
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildRoleOption(
                              context,
                              title: 'Admin',
                              iconPath: 'assets/more/admin_icon.png',
                              role: 'admin',
                            ),
                            SizedBox(width: (screenWidth * 0.06).clamp(16.0, 32.0)),
                            _buildRoleOption(
                              context,
                              title: 'Student',
                              iconPath: 'assets/more/student_icon.png',
                              role: 'student',
                            ),
                          ],
                        ),
                      SizedBox(height: isNarrow ? 24 : 36),
                      Divider(height: 1, color: Colors.grey.shade200),
                      const SizedBox(height: 20),
                      Text(
                        'Powered by DevTriSoft',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        'assets/more/devtrisoft_icon.png',
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption(
    BuildContext context, {
    required String title,
    required String iconPath,
    required String role,
  }) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isNarrow = screenWidth < 400;
    final iconSize = isNarrow ? 72.0 : 88.0;
    final padding = isNarrow ? 16.0 : 24.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginScreen(userRole: role)),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: padding,
            vertical: isNarrow ? 20 : 28,
          ),
          constraints: BoxConstraints(minWidth: isNarrow ? 0 : 120),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: role == 'admin'
                  ? AppColors.maroon.withOpacity(0.2)
                  : AppColors.deepBlue.withOpacity(0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (role == 'admin' ? AppColors.maroon : AppColors.deepBlue)
                    .withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                padding: EdgeInsets.all(iconSize * 0.22),
                decoration: BoxDecoration(
                  color: (role == 'admin' ? AppColors.maroon : AppColors.deepBlue)
                      .withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(iconPath, fit: BoxFit.contain),
              ),
              SizedBox(height: isNarrow ? 12 : 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepBlue,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
