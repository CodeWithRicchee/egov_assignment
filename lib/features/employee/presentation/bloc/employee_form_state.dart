import 'package:equatable/equatable.dart';
import '../../domain/entities/employee_entities.dart';

enum SubmitStatus { idle, loading, success, offlineSaved, failure }

enum ValidationStatus { idle, checking, valid, invalid }

class EmployeeFormState extends Equatable {
  final int currentStep;
  final EmployeeFormData formData;
  final SubmitStatus submitStatus;
  final String? submitError;
  final bool isOffline;

  // MDMS data maps: fieldKey -> list of options
  final Map<String, List<DropdownOption>> mdmsData;
  final Map<String, bool> mdmsLoading;
  final Map<String, String?> mdmsErrors;

  // Boundary tree
  final BoundaryNode? boundaryRoot;
  final bool boundaryLoading;
  final String? boundaryError;
  final String? syncMessage;

  // Async validation
  final ValidationStatus usernameValidation;
  final String? usernameError;
  final ValidationStatus mobileValidation;
  final String? mobileError;

  const EmployeeFormState({
    this.currentStep = 0,
    this.formData = const EmployeeFormData(),
    this.submitStatus = SubmitStatus.idle,
    this.submitError,
    this.isOffline = false,
    this.mdmsData = const {},
    this.mdmsLoading = const {},
    this.mdmsErrors = const {},
    this.boundaryRoot,
    this.boundaryLoading = false,
    this.boundaryError,
    this.syncMessage,
    this.usernameValidation = ValidationStatus.idle,
    this.usernameError,
    this.mobileValidation = ValidationStatus.idle,
    this.mobileError,
  });

  EmployeeFormState copyWith({
    int? currentStep,
    EmployeeFormData? formData,
    SubmitStatus? submitStatus,
    String? submitError,
    bool clearSubmitError = false,
    bool? isOffline,
    Map<String, List<DropdownOption>>? mdmsData,
    Map<String, bool>? mdmsLoading,
    Map<String, String?>? mdmsErrors,
    BoundaryNode? boundaryRoot,
    bool? boundaryLoading,
    String? boundaryError,
    String? syncMessage,
    ValidationStatus? usernameValidation,
    String? usernameError,
    bool clearUsernameError = false,
    ValidationStatus? mobileValidation,
    String? mobileError,
    bool clearMobileError = false,
  }) {
    return EmployeeFormState(
      currentStep: currentStep ?? this.currentStep,
      formData: formData ?? this.formData,
      submitStatus: submitStatus ?? this.submitStatus,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      isOffline: isOffline ?? this.isOffline,
      mdmsData: mdmsData ?? this.mdmsData,
      mdmsLoading: mdmsLoading ?? this.mdmsLoading,
      mdmsErrors: mdmsErrors ?? this.mdmsErrors,
      boundaryRoot: boundaryRoot ?? this.boundaryRoot,
      boundaryLoading: boundaryLoading ?? this.boundaryLoading,
      boundaryError: boundaryError ?? this.boundaryError,
      syncMessage: syncMessage,
      usernameValidation: usernameValidation ?? this.usernameValidation,
      usernameError: clearUsernameError ? null : (usernameError ?? this.usernameError),
      mobileValidation: mobileValidation ?? this.mobileValidation,
      mobileError: clearMobileError ? null : (mobileError ?? this.mobileError),
    );
  }

  List<DropdownOption> getOptions(String fieldKey) => mdmsData[fieldKey] ?? [];
  bool isLoadingMdms(String fieldKey) => mdmsLoading[fieldKey] ?? false;

  // Boundary helpers
  List<DropdownOption> get countryOptions {
    if (boundaryRoot == null) return [];
    return [DropdownOption(code: boundaryRoot!.code, name: boundaryRoot!.name)];
  }

  List<DropdownOption> get provinceOptions {
    final country = formData.selectedCountry;
    if (country == null || boundaryRoot == null) return [];
    if (boundaryRoot!.code == country.code) {
      return boundaryRoot!.asOptions;
    }
    return [];
  }

  List<DropdownOption> get districtOptions {
    final province = formData.selectedProvince;
    if (province == null || boundaryRoot == null) return [];
    BoundaryNode? provinceNode = _findNode(boundaryRoot!, province.code);
    return provinceNode?.asOptions ?? [];
  }

  BoundaryNode? _findNode(BoundaryNode node, String code) {
    if (node.code == code) return node;
    for (final child in node.children) {
      final found = _findNode(child, code);
      if (found != null) return found;
    }
    return null;
  }

  @override
  List<Object?> get props => [
        currentStep,
        formData,
        submitStatus,
        submitError,
        isOffline,
        mdmsData,
        mdmsLoading,
        boundaryRoot,
        boundaryLoading,
        syncMessage,
        usernameValidation,
        usernameError,
        mobileValidation,
        mobileError,
      ];
}
