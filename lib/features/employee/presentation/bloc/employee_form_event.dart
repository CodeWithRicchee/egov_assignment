import 'package:equatable/equatable.dart';
import '../../domain/entities/employee_entities.dart';

abstract class EmployeeFormEvent extends Equatable {
  const EmployeeFormEvent();
  @override
  List<Object?> get props => [];
}

// Navigation
class StepChanged extends EmployeeFormEvent {
  final int step;
  const StepChanged(this.step);
  @override
  List<Object?> get props => [step];
}

class NextStepRequested extends EmployeeFormEvent {
  final Map<String, dynamic> stepData;
  const NextStepRequested(this.stepData);
}

class PreviousStepRequested extends EmployeeFormEvent {}

// Step 1 – Login
class UsernameChanged extends EmployeeFormEvent {
  final String value;
  const UsernameChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class UsernameValidationRequested extends EmployeeFormEvent {
  final String username;
  const UsernameValidationRequested(this.username);
}

// Step 2 – Personal
class MobileValidationRequested extends EmployeeFormEvent {
  final String mobile;
  const MobileValidationRequested(this.mobile);
}

class FormFieldUpdated extends EmployeeFormEvent {
  final String fieldKey;
  final dynamic value;
  const FormFieldUpdated(this.fieldKey, this.value);
  @override
  List<Object?> get props => [fieldKey, value];
}

// Step 3 – Employment & Boundary
class CountrySelected extends EmployeeFormEvent {
  final BoundaryNode country;
  const CountrySelected(this.country);
}

class ProvinceSelected extends EmployeeFormEvent {
  final BoundaryNode province;
  const ProvinceSelected(this.province);
}

class DistrictSelected extends EmployeeFormEvent {
  final BoundaryNode district;
  const DistrictSelected(this.district);
}

class RolesUpdated extends EmployeeFormEvent {
  final List<DropdownOption> roles;
  const RolesUpdated(this.roles);
}

// MDMS / Boundary Loading
class MdmsDataRequested extends EmployeeFormEvent {
  final String schemaCode;
  final String fieldKey;
  const MdmsDataRequested({required this.schemaCode, required this.fieldKey});
  @override
  List<Object?> get props => [schemaCode, fieldKey];
}

class BoundaryDataRequested extends EmployeeFormEvent {}

// Submit
class EmployeeSubmitRequested extends EmployeeFormEvent {}

// Sync
class SyncPendingRequested extends EmployeeFormEvent {}
