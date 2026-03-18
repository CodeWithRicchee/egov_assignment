import 'package:equatable/equatable.dart';

// Generic dropdown option from MDMS or boundary
class DropdownOption extends Equatable {
  final String code;
  final String name;
  final bool isActive;
  final Map<String, dynamic>? extra;

  const DropdownOption({
    required this.code,
    required this.name,
    this.isActive = true,
    this.extra,
  });

  @override
  List<Object?> get props => [code];
}

// Boundary node in the hierarchy tree
class BoundaryNode extends Equatable {
  final String code;
  final String name;
  final String boundaryType;
  final List<BoundaryNode> children;

  const BoundaryNode({
    required this.code,
    required this.name,
    required this.boundaryType,
    this.children = const [],
  });

  List<DropdownOption> get asOptions => children.map((c) => DropdownOption(code: c.code, name: c.name)).toList();

  @override
  List<Object?> get props => [code, boundaryType];
}

// Form data collected across 3 steps
class EmployeeFormData extends Equatable {
  // Step 1 – Login
  final String? username;
  final String? password;

  // Step 2 – Personal
  final String? name;
  final String? mobileNumber;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? email;
  final String? correspondenceAddress;

  // Step 3 – Employment
  final String? employmentType;
  final DateTime? dateOfAppointment;
  final String? department;
  final String? designation;
  final List<DropdownOption> selectedRoles;

  // Boundary
  final BoundaryNode? selectedCountry;
  final BoundaryNode? selectedProvince;
  final BoundaryNode? selectedDistrict;

  const EmployeeFormData({
    this.username,
    this.password,
    this.name,
    this.mobileNumber,
    this.gender,
    this.dateOfBirth,
    this.email,
    this.correspondenceAddress,
    this.employmentType,
    this.dateOfAppointment,
    this.department,
    this.designation,
    this.selectedRoles = const [],
    this.selectedCountry,
    this.selectedProvince,
    this.selectedDistrict,
  });

  EmployeeFormData copyWith({
    String? username,
    String? password,
    String? name,
    String? mobileNumber,
    String? gender,
    DateTime? dateOfBirth,
    String? email,
    String? correspondenceAddress,
    String? employmentType,
    DateTime? dateOfAppointment,
    String? department,
    String? designation,
    List<DropdownOption>? selectedRoles,
    BoundaryNode? selectedCountry,
    BoundaryNode? selectedProvince,
    BoundaryNode? selectedDistrict,
    bool clearProvince = false,
    bool clearDistrict = false,
  }) =>
      EmployeeFormData(
        username: username ?? this.username,
        password: password ?? this.password,
        name: name ?? this.name,
        mobileNumber: mobileNumber ?? this.mobileNumber,
        gender: gender ?? this.gender,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        email: email ?? this.email,
        correspondenceAddress: correspondenceAddress ?? this.correspondenceAddress,
        employmentType: employmentType ?? this.employmentType,
        dateOfAppointment: dateOfAppointment ?? this.dateOfAppointment,
        department: department ?? this.department,
        designation: designation ?? this.designation,
        selectedRoles: selectedRoles ?? this.selectedRoles,
        selectedCountry: selectedCountry ?? this.selectedCountry,
        selectedProvince: clearProvince ? null : (selectedProvince ?? this.selectedProvince),
        selectedDistrict: clearDistrict ? null : (selectedDistrict ?? this.selectedDistrict),
      );

  BoundaryNode? get deepestBoundary => selectedDistrict ?? selectedProvince ?? selectedCountry;

  @override
  List<Object?> get props => [
        username,
        password,
        name,
        mobileNumber,
        gender,
        dateOfBirth,
        email,
        correspondenceAddress,
        employmentType,
        dateOfAppointment,
        department,
        designation,
        selectedRoles,
        selectedCountry,
        selectedProvince,
        selectedDistrict,
      ];
}
