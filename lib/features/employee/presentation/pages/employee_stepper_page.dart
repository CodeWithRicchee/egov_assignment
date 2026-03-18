import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_router.dart';
import '../bloc/employee_form_bloc.dart';
import '../bloc/employee_form_event.dart';
import '../bloc/employee_form_state.dart';
import '../widgets/connectivity_banner.dart';
import '../widgets/step_indicator.dart';
import 'step1_login_details.dart';
import 'step2_personal_details.dart';
import 'step3_employee_details.dart';

class EmployeeStepperPage extends StatefulWidget {
  const EmployeeStepperPage({super.key});

  @override
  State<EmployeeStepperPage> createState() => _EmployeeStepperPageState();
}

class _EmployeeStepperPageState extends State<EmployeeStepperPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _stepLabels = ['Login Details', 'Personal Info', 'Employment'];

  void _goToPage(int page) {
    setState(() => _currentPage = page);
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onNext() => _goToPage(_currentPage + 1);
  void _onBack() => _goToPage(_currentPage - 1);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EmployeeFormBloc>(),
      child: BlocConsumer<EmployeeFormBloc, EmployeeFormState>(
        listenWhen: (prev, curr) =>
            prev.submitStatus != curr.submitStatus || prev.isOffline != curr.isOffline || prev.syncMessage != curr.syncMessage,
        listener: (context, state) {
          if (state.submitStatus == SubmitStatus.success) {
            context.go(AppRouter.success, extra: false);
          } else if (state.submitStatus == SubmitStatus.offlineSaved) {
            context.go(AppRouter.success, extra: true);
          } else if (state.submitStatus == SubmitStatus.failure) {
            _showErrorDialog(context, state.submitError ?? 'Submission failed');
          }
          if (state.syncMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.syncMessage!)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppTheme.background,
            appBar: AppBar(
              title: const Text(
                'New Employee Registration',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ConnectivityIndicator(isOffline: state.isOffline),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'logout', child: Text('Logout')),
                  ],
                  onSelected: (v) {
                    if (v == 'logout') _onLogout(context);
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                // Offline banner
                if (state.isOffline) const OfflineBanner(),

                // Step indicator
                StepIndicator(currentStep: _currentPage, steps: _stepLabels),

                // Pages
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _StepWrapper(
                        child: Step1LoginDetails(onNext: _onNext),
                      ),
                      _StepWrapper(
                        child: Step2PersonalDetails(onNext: _onNext, onBack: _onBack),
                      ),
                      _StepWrapper(
                        child: Step3EmployeeDetails(
                          onBack: _onBack,
                          onSubmit: () {}, // Handled by BLoC → listener
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRouter.login);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.error_outline, color: AppTheme.error),
            SizedBox(width: 8),
            Text('Submission Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<EmployeeFormBloc>().add(EmployeeSubmitRequested());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _StepWrapper extends StatelessWidget {
  final Widget child;
  const _StepWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}
