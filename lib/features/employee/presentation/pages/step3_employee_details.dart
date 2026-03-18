import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/employee_entities.dart';
import '../bloc/employee_form_bloc.dart';
import '../bloc/employee_form_event.dart';
import '../bloc/employee_form_state.dart';
import '../widgets/form_widgets.dart';

class Step3EmployeeDetails extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSubmit;
  const Step3EmployeeDetails({super.key, required this.onBack, required this.onSubmit});

  @override
  State<Step3EmployeeDetails> createState() => _Step3EmployeeDetailsState();
}

class _Step3EmployeeDetailsState extends State<Step3EmployeeDetails> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final bloc = context.read<EmployeeFormBloc>();
    final state = bloc.state;

    // Load all step-3 MDMS data if missing
    final schemas = {
      'employmentType': 'egov-hrms.EmployeeType',
      'department': 'common-masters.Department',
      'designation': 'common-masters.Designation',
      'roles': 'ACCESSCONTROL-ROLES.roles',
    };
    for (final entry in schemas.entries) {
      if (state.getOptions(entry.key).isEmpty) {
        bloc.add(MdmsDataRequested(schemaCode: entry.value, fieldKey: entry.key));
      }
    }
    if (state.boundaryRoot == null && !state.boundaryLoading) {
      bloc.add(BoundaryDataRequested());
    }
  }

  void _onSubmit() {
    final state = context.read<EmployeeFormBloc>().state;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (state.formData.employmentType == null) { _snack('Select employment type'); return; }
    if (state.formData.dateOfAppointment == null) { _snack('Select date of appointment'); return; }
    if (state.formData.department == null) { _snack('Select department'); return; }
    if (state.formData.designation == null) { _snack('Select designation'); return; }
    if (state.formData.selectedRoles.isEmpty) { _snack('Select at least one role'); return; }
    if (state.formData.selectedCountry == null) { _snack('Select boundary area (at least country)'); return; }

    context.read<EmployeeFormBloc>().add(EmployeeSubmitRequested());
    widget.onSubmit();
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppTheme.error),
      );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeFormBloc, EmployeeFormState>(
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader('Employee Details', Icons.work_outline),
              const SizedBox(height: 20),

              // Employment Type
              AppDropdown(
                label: 'Employment Type',
                isRequired: true,
                value: state.formData.employmentType,
                options: state.getOptions('employmentType'),
                isLoading: state.isLoadingMdms('employmentType'),
                onChanged: (v) => context
                    .read<EmployeeFormBloc>()
                    .add(FormFieldUpdated('employmentType', v)),
              ),
              const SizedBox(height: 16),

              // Date of Appointment
              AppDatePickerField(
                label: 'Date of Appointment',
                isRequired: true,
                value: state.formData.dateOfAppointment,
                lastDate: DateTime.now(),
                firstDate: DateTime(2000),
                hint: 'Select appointment date',
                onDateSelected: (d) => context
                    .read<EmployeeFormBloc>()
                    .add(FormFieldUpdated('dateOfAppointment', d)),
              ),
              const SizedBox(height: 16),

              // Department
              AppDropdown(
                label: 'Department',
                isRequired: true,
                value: state.formData.department,
                options: state.getOptions('department'),
                isLoading: state.isLoadingMdms('department'),
                onChanged: (v) => context
                    .read<EmployeeFormBloc>()
                    .add(FormFieldUpdated('department', v)),
              ),
              const SizedBox(height: 16),

              // Designation
              AppDropdown(
                label: 'Designation',
                isRequired: true,
                value: state.formData.designation,
                options: state.getOptions('designation'),
                isLoading: state.isLoadingMdms('designation'),
                onChanged: (v) => context
                    .read<EmployeeFormBloc>()
                    .add(FormFieldUpdated('designation', v)),
              ),
              const SizedBox(height: 16),

              // Roles (multi-select)
              AppMultiSelectDropdown(
                label: 'Roles',
                isRequired: true,
                options: state.getOptions('roles'),
                selectedOptions: state.formData.selectedRoles,
                isLoading: state.isLoadingMdms('roles'),
                errorText: state.formData.selectedRoles.isEmpty ? null : null,
                onChanged: (selected) =>
                    context.read<EmployeeFormBloc>().add(RolesUpdated(selected)),
              ),
              const SizedBox(height: 24),

              // Boundary Area
              _sectionHeader('Boundary Area', Icons.location_on_outlined),
              const SizedBox(height: 12),

              if (state.boundaryLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Loading boundary data…', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              else if (state.boundaryError != null)
                _BoundaryErrorWidget(
                  error: state.boundaryError!,
                  onRetry: () =>
                      context.read<EmployeeFormBloc>().add(BoundaryDataRequested()),
                )
              else ...[
                // Country
                AppDropdown(
                  label: 'Country',
                  isRequired: true,
                  value: state.formData.selectedCountry?.code,
                  options: state.countryOptions,
                  hint: 'Select country',
                  onChanged: (v) {
                    if (v == null) return;
                    final node = state.boundaryRoot;
                    if (node != null && node.code == v) {
                      context
                          .read<EmployeeFormBloc>()
                          .add(CountrySelected(BoundaryNode(
                            code: node.code,
                            name: node.name,
                            boundaryType: node.boundaryType,
                          )));
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Province
                AppDropdown(
                  label: 'Province',
                  isRequired: false,
                  value: state.formData.selectedProvince?.code,
                  options: state.provinceOptions,
                  hint: state.formData.selectedCountry == null
                      ? 'Select country first'
                      : 'Select province',
                  onChanged: (v) {
                    if (v == null) return;
                    final opt = state.provinceOptions.firstWhere(
                      (o) => o.code == v,
                      orElse: () => DropdownOption(code: v, name: v),
                    );
                    // Find boundary node for province
                    final root = state.boundaryRoot;
                    if (root != null) {
                      for (final child in root.children) {
                        if (child.code == v) {
                          context.read<EmployeeFormBloc>().add(ProvinceSelected(child));
                          return;
                        }
                      }
                    }
                    context.read<EmployeeFormBloc>().add(ProvinceSelected(
                          BoundaryNode(code: v, name: opt.name, boundaryType: ''),
                        ));
                  },
                ),
                const SizedBox(height: 16),

                // District
                AppDropdown(
                  label: 'District',
                  isRequired: false,
                  value: state.formData.selectedDistrict?.code,
                  options: state.districtOptions,
                  hint: state.formData.selectedProvince == null
                      ? 'Select province first'
                      : 'Select district',
                  onChanged: (v) {
                    if (v == null) return;
                    final opt = state.districtOptions.firstWhere(
                      (o) => o.code == v,
                      orElse: () => DropdownOption(code: v, name: v),
                    );
                    context.read<EmployeeFormBloc>().add(DistrictSelected(
                          BoundaryNode(code: v, name: opt.name, boundaryType: ''),
                        ));
                  },
                ),
              ],

              const SizedBox(height: 32),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Back'),
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 50)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: state.submitStatus == SubmitStatus.loading ? null : _onSubmit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 50),
                        backgroundColor: AppTheme.success,
                      ),
                      child: state.submitStatus == SubmitStatus.loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline, size: 18),
                                SizedBox(width: 8),
                                Text('Submit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              ],
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

class _BoundaryErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _BoundaryErrorWidget({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: AppTheme.error, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(error, style: const TextStyle(color: AppTheme.error, fontSize: 13))),
            ],
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
