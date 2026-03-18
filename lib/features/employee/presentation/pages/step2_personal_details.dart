import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/employee_form_bloc.dart';
import '../bloc/employee_form_event.dart';
import '../bloc/employee_form_state.dart';
import '../widgets/form_widgets.dart';

class Step2PersonalDetails extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const Step2PersonalDetails({super.key, required this.onNext, required this.onBack});

  @override
  State<Step2PersonalDetails> createState() => _Step2PersonalDetailsState();
}

class _Step2PersonalDetailsState extends State<Step2PersonalDetails> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  Timer? _mobileDebounce;

  static final _mobileRegex = RegExp(r'^[0-9]{10}$');
  static final _emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  @override
  void initState() {
    super.initState();
    final formData = context.read<EmployeeFormBloc>().state.formData;
    _nameCtrl.text = formData.name ?? '';
    _mobileCtrl.text = formData.mobileNumber ?? '';
    _emailCtrl.text = formData.email ?? '';
    _addressCtrl.text = formData.correspondenceAddress ?? '';

    // Load gender MDMS if not yet loaded
    final bloc = context.read<EmployeeFormBloc>();
    if (bloc.state.getOptions('gender').isEmpty) {
      bloc.add(const MdmsDataRequested(
        schemaCode: 'common-masters.GenderType',
        fieldKey: 'gender',
      ));
    }
  }

  @override
  void dispose() {
    _mobileDebounce?.cancel();
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _onMobileChanged(String value) {
    context.read<EmployeeFormBloc>().add(FormFieldUpdated('mobileNumber', value));
    _mobileDebounce?.cancel();
    if (_mobileRegex.hasMatch(value)) {
      _mobileDebounce = Timer(const Duration(milliseconds: 600), () {
        context.read<EmployeeFormBloc>().add(MobileValidationRequested(value));
      });
    }
  }

  void _onNext() {
    final bloc = context.read<EmployeeFormBloc>();
    final state = bloc.state;

    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (state.formData.gender == null) {
      _showSnack('Please select a gender');
      return;
    }

    if (state.formData.dateOfBirth == null) {
      _showSnack('Please select date of birth');
      return;
    }

    if (state.mobileValidation == ValidationStatus.invalid) {
      _showSnack('Mobile number is already registered');
      return;
    }

    if (state.mobileValidation == ValidationStatus.checking) {
      _showSnack('Please wait while we validate the mobile number');
      return;
    }

    bloc.add(NextStepRequested({}));
    widget.onNext();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeFormBloc, EmployeeFormState>(
      builder: (context, state) {
        final maxDob = DateTime(
          DateTime.now().year - 18,
          DateTime.now().month,
          DateTime.now().day,
        );

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader('Personal Details', Icons.badge_outlined),
              const SizedBox(height: 20),

              // Name
              AppTextField(
                label: 'Name',
                controller: _nameCtrl,
                isRequired: true,
                prefixIcon: const Icon(Icons.person, size: 20),
                hint: 'Enter full name',
                onChanged: (v) =>
                    context.read<EmployeeFormBloc>().add(FormFieldUpdated('name', v)),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              // Mobile
              AppTextField(
                label: 'Mobile Number',
                controller: _mobileCtrl,
                isRequired: true,
                prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                hint: '10-digit mobile number',
                keyboardType: TextInputType.number,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: _onMobileChanged,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Mobile number is required';
                  if (!_mobileRegex.hasMatch(v)) return 'Must be exactly 10 digits';
                  return null;
                },
              ),
              AsyncValidationIndicator(
                isChecking: state.mobileValidation == ValidationStatus.checking,
                isValid: state.mobileValidation == ValidationStatus.valid,
                errorText: state.mobileError,
              ),
              const SizedBox(height: 16),

              // Gender
              AppDropdown(
                label: 'Gender',
                isRequired: true,
                value: state.formData.gender,
                options: state.getOptions('gender'),
                isLoading: state.isLoadingMdms('gender'),
                onChanged: (v) =>
                    context.read<EmployeeFormBloc>().add(FormFieldUpdated('gender', v)),
                errorText: (state.formData.gender == null &&
                        !state.isLoadingMdms('gender') &&
                        state.getOptions('gender').isNotEmpty)
                    ? null
                    : null,
              ),
              const SizedBox(height: 16),

              // Date of Birth
              AppDatePickerField(
                label: 'Date of Birth',
                isRequired: true,
                value: state.formData.dateOfBirth,
                lastDate: maxDob,
                firstDate: DateTime(1940),
                hint: 'Select date of birth',
                onDateSelected: (d) =>
                    context.read<EmployeeFormBloc>().add(FormFieldUpdated('dateOfBirth', d)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 14),
                child: Text(
                  'Employee must be at least 18 years old',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ),
              const SizedBox(height: 16),

              // Email (optional)
              AppTextField(
                label: 'Email',
                controller: _emailCtrl,
                isRequired: false,
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                hint: 'Enter email address (optional)',
                keyboardType: TextInputType.emailAddress,
                onChanged: (v) =>
                    context.read<EmployeeFormBloc>().add(FormFieldUpdated('email', v)),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  if (!_emailRegex.hasMatch(v.trim())) return 'Enter a valid email address';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Address (optional)
              AppTextField(
                label: 'Correspondence Address',
                controller: _addressCtrl,
                isRequired: false,
                hint: 'Enter address (optional)',
                maxLines: 3,
                onChanged: (v) => context
                    .read<EmployeeFormBloc>()
                    .add(FormFieldUpdated('correspondenceAddress', v)),
              ),
              const SizedBox(height: 32),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Back'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 50),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _onNext,
                      icon: const Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      label: const Icon(Icons.arrow_forward_rounded, size: 18),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 50),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title, IconData icon) => Row(
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
          Text(title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.primary)),
        ],
      );
}
