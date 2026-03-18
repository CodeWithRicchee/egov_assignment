import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/employee_form_bloc.dart';
import '../bloc/employee_form_event.dart';
import '../bloc/employee_form_state.dart';
import '../widgets/form_widgets.dart';

class Step1LoginDetails extends StatefulWidget {
  final VoidCallback onNext;
  const Step1LoginDetails({super.key, required this.onNext});

  @override
  State<Step1LoginDetails> createState() => _Step1LoginDetailsState();
}

class _Step1LoginDetailsState extends State<Step1LoginDetails> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  Timer? _debounce;

  static final _passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@]{8,}$');

  @override
  void initState() {
    super.initState();
    final formData = context.read<EmployeeFormBloc>().state.formData;
    _usernameCtrl.text = formData.username ?? '';
    _passwordCtrl.text = formData.password ?? '';
    _confirmCtrl.text = formData.password ?? '';
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    context.read<EmployeeFormBloc>().add(FormFieldUpdated('username', value));
    _debounce?.cancel();
    if (value.length >= 3) {
      _debounce = Timer(const Duration(milliseconds: 600), () {
        context.read<EmployeeFormBloc>().add(UsernameValidationRequested(value));
      });
    }
  }

  void _onNext() {
    final bloc = context.read<EmployeeFormBloc>();
    final state = bloc.state;

    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (state.usernameValidation == ValidationStatus.invalid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Username is already taken. Please choose another.'),
        backgroundColor: AppTheme.error,
      ));
      return;
    }

    if (state.usernameValidation == ValidationStatus.checking) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please wait while we validate the username.'),
        backgroundColor: AppTheme.warning,
      ));
      return;
    }

    bloc.add(NextStepRequested({}));
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeFormBloc, EmployeeFormState>(
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(title: 'Login Details', icon: Icons.person_outline),
              const SizedBox(height: 20),

              // Username
              AppTextField(
                label: 'Username',
                controller: _usernameCtrl,
                isRequired: true,
                prefixIcon: const Icon(Icons.person_outline, size: 20),
                hint: 'Enter unique username',
                onChanged: _onUsernameChanged,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Username is required';
                  if (v.trim().length < 3) return 'Minimum 3 characters';
                  return null;
                },
              ),
              AsyncValidationIndicator(
                isChecking: state.usernameValidation == ValidationStatus.checking,
                isValid: state.usernameValidation == ValidationStatus.valid,
                errorText: state.usernameError,
              ),
              const SizedBox(height: 16),

              // Password
              AppPasswordField(
                label: 'Password',
                controller: _passwordCtrl,
                isRequired: true,
                hint: 'Min 8 chars, uppercase, lowercase, number',
                onChanged: (v) => context.read<EmployeeFormBloc>().add(FormFieldUpdated('password', v)),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required';
                  if (!_passwordRegex.hasMatch(v)) {
                    return 'Min 8 chars with uppercase, lowercase, number.\nOnly @ special character allowed.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirm Password
              AppPasswordField(
                label: 'Confirm Password',
                controller: _confirmCtrl,
                isRequired: true,
                hint: 'Re-enter password',
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Confirm password is required';
                  if (v != _passwordCtrl.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Password hint
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Password requirements:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text('• At least 8 characters', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    Text('• 1 uppercase letter (A-Z)', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    Text('• 1 lowercase letter (a-z)', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    Text('• 1 number (0-9)', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    Text('• Only @ allowed as special character', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _onNext,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }
}
