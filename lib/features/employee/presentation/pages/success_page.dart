import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_router.dart';

class SuccessPage extends StatelessWidget {
  final bool isOffline;
  const SuccessPage({super.key, required this.isOffline});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: isOffline
                        ? AppTheme.warning.withOpacity(0.12)
                        : AppTheme.success.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isOffline ? Icons.cloud_off_rounded : Icons.check_circle_rounded,
                    color: isOffline ? AppTheme.warning : AppTheme.success,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  isOffline ? 'Saved Offline' : 'Employee Created!',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isOffline
                      ? 'Data saved offline. It will be submitted automatically when you are back online.'
                      : 'The employee has been successfully registered in the system.',
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                if (isOffline)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.warning, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your data is securely stored on this device and will sync automatically when internet is available.',
                            style: TextStyle(
                                fontSize: 13, color: AppTheme.warning, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go(AppRouter.employeeCreate),
                    icon: const Icon(Icons.person_add_outlined),
                    label: const Text(
                      'Add Another Employee',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
