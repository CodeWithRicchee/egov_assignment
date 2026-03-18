import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../domain/entities/employee_entities.dart';
import '../../domain/usecases/employee_usecases.dart';
import 'employee_form_event.dart';
import 'employee_form_state.dart';

@injectable
class EmployeeFormBloc extends Bloc<EmployeeFormEvent, EmployeeFormState> {
  final GetMdmsOptionsUseCase _getMdmsOptions;
  final GetBoundaryHierarchyUseCase _getBoundary;
  final CheckUsernameExistsUseCase _checkUsername;
  final CheckMobileExistsUseCase _checkMobile;
  final CreateEmployeeUseCase _createEmployee;
  final SyncPendingEmployeesUseCase _syncPending;
  final ConnectivityService _connectivity;

  StreamSubscription<bool>? _connectivitySub;

  static const _mdmsSchemas = {
    'gender': 'common-masters.GenderType',
    'employmentType': 'egov-hrms.EmployeeType',
    'department': 'common-masters.Department',
    'designation': 'common-masters.Designation',
    'roles': 'ACCESSCONTROL-ROLES.roles',
  };

  EmployeeFormBloc(
    this._getMdmsOptions,
    this._getBoundary,
    this._checkUsername,
    this._checkMobile,
    this._createEmployee,
    this._syncPending,
    this._connectivity,
  ) : super(EmployeeFormState(isOffline: !_connectivity.isOnline)) {
    on<MdmsDataRequested>(_onMdmsRequested);
    on<BoundaryDataRequested>(_onBoundaryRequested);
    on<UsernameValidationRequested>(_onUsernameValidation);
    on<MobileValidationRequested>(_onMobileValidation);
    on<FormFieldUpdated>(_onFieldUpdated);
    on<CountrySelected>(_onCountrySelected);
    on<ProvinceSelected>(_onProvinceSelected);
    on<DistrictSelected>(_onDistrictSelected);
    on<RolesUpdated>(_onRolesUpdated);
    on<NextStepRequested>(_onNextStep);
    on<PreviousStepRequested>(_onPreviousStep);
    on<EmployeeSubmitRequested>(_onSubmit);
    on<SyncPendingRequested>(_onSync);
    on<_ConnectivityChanged>(_onConnectivityChanged);

    _connectivitySub = _connectivity.onConnectivityChanged.listen((isOnline) {
      add(_ConnectivityChanged(isOnline));
    });
  }

  // ── MDMS ─────────────────────────────────────────────────────────────────
  Future<void> _onMdmsRequested(MdmsDataRequested event, Emitter<EmployeeFormState> emit) async {
    final loading = Map<String, bool>.from(state.mdmsLoading)..[event.fieldKey] = true;
    emit(state.copyWith(mdmsLoading: loading));

    final result = await _getMdmsOptions(event.schemaCode);
    final newLoading = Map<String, bool>.from(state.mdmsLoading)..[event.fieldKey] = false;

    result.fold(
      (failure) {
        final errors = Map<String, String?>.from(state.mdmsErrors)..[event.fieldKey] = failure.message;
        emit(state.copyWith(mdmsLoading: newLoading, mdmsErrors: errors));
      },
      (options) {
        final data = Map<String, List<DropdownOption>>.from(state.mdmsData)..[event.fieldKey] = options;
        emit(state.copyWith(mdmsLoading: newLoading, mdmsData: data));
      },
    );
  }

  // ── Boundary ──────────────────────────────────────────────────────────────
  Future<void> _onBoundaryRequested(BoundaryDataRequested event, Emitter<EmployeeFormState> emit) async {
    emit(state.copyWith(boundaryLoading: true, boundaryError: null));
    final result = await _getBoundary();
    result.fold(
      (failure) => emit(state.copyWith(boundaryLoading: false, boundaryError: failure.message)),
      (node) => emit(state.copyWith(boundaryLoading: false, boundaryRoot: node)),
    );
  }

  // ── Async Validations ─────────────────────────────────────────────────────
  Future<void> _onUsernameValidation(UsernameValidationRequested event, Emitter<EmployeeFormState> emit) async {
    if (event.username.isEmpty) return;
    emit(state.copyWith(usernameValidation: ValidationStatus.checking, clearUsernameError: true));
    final result = await _checkUsername(event.username);
    result.fold(
      (f) => emit(state.copyWith(usernameValidation: ValidationStatus.idle)),
      (exists) => emit(state.copyWith(
        usernameValidation: exists ? ValidationStatus.invalid : ValidationStatus.valid,
        usernameError: exists ? 'This username is already taken' : null,
        clearUsernameError: !exists,
      )),
    );
  }

  Future<void> _onMobileValidation(MobileValidationRequested event, Emitter<EmployeeFormState> emit) async {
    if (event.mobile.length != 10) return;
    emit(state.copyWith(mobileValidation: ValidationStatus.checking, clearMobileError: true));
    final result = await _checkMobile(event.mobile);
    result.fold(
      (f) => emit(state.copyWith(mobileValidation: ValidationStatus.idle)),
      (exists) => emit(state.copyWith(
        mobileValidation: exists ? ValidationStatus.invalid : ValidationStatus.valid,
        mobileError: exists ? 'This mobile number is already registered' : null,
        clearMobileError: !exists,
      )),
    );
  }

  // ── Field Updates ─────────────────────────────────────────────────────────
  void _onFieldUpdated(FormFieldUpdated event, Emitter<EmployeeFormState> emit) {
    final data = state.formData;
    EmployeeFormData updated;
    switch (event.fieldKey) {
      case 'username':
        updated = data.copyWith(username: event.value as String);
      case 'password':
        updated = data.copyWith(password: event.value as String);
      case 'name':
        updated = data.copyWith(name: event.value as String);
      case 'mobileNumber':
        updated = data.copyWith(mobileNumber: event.value as String);
      case 'gender':
        updated = data.copyWith(gender: event.value as String);
      case 'dateOfBirth':
        updated = data.copyWith(dateOfBirth: event.value as DateTime);
      case 'email':
        updated = data.copyWith(email: event.value as String);
      case 'correspondenceAddress':
        updated = data.copyWith(correspondenceAddress: event.value as String);
      case 'employmentType':
        updated = data.copyWith(employmentType: event.value as String);
      case 'dateOfAppointment':
        updated = data.copyWith(dateOfAppointment: event.value as DateTime);
      case 'department':
        updated = data.copyWith(department: event.value as String);
      case 'designation':
        updated = data.copyWith(designation: event.value as String);
      default:
        updated = data;
    }
    emit(state.copyWith(formData: updated));
  }

  // ── Boundary Selection ────────────────────────────────────────────────────
  void _onCountrySelected(CountrySelected event, Emitter<EmployeeFormState> emit) {
    emit(state.copyWith(
      formData: state.formData.copyWith(
        selectedCountry: event.country,
        clearProvince: true,
        clearDistrict: true,
      ),
    ));
  }

  void _onProvinceSelected(ProvinceSelected event, Emitter<EmployeeFormState> emit) {
    emit(state.copyWith(
      formData: state.formData.copyWith(
        selectedProvince: event.province,
        clearDistrict: true,
      ),
    ));
  }

  void _onDistrictSelected(DistrictSelected event, Emitter<EmployeeFormState> emit) {
    emit(state.copyWith(
      formData: state.formData.copyWith(selectedDistrict: event.district),
    ));
  }

  void _onRolesUpdated(RolesUpdated event, Emitter<EmployeeFormState> emit) {
    emit(state.copyWith(formData: state.formData.copyWith(selectedRoles: event.roles)));
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  void _onNextStep(NextStepRequested event, Emitter<EmployeeFormState> emit) {
    final next = (state.currentStep + 1).clamp(0, 2);
    emit(state.copyWith(currentStep: next, submitStatus: SubmitStatus.idle, clearSubmitError: true));

    // Pre-fetch MDMS for step being navigated to
    if (next == 1 && !state.mdmsData.containsKey('gender')) {
      add(const MdmsDataRequested(schemaCode: 'common-masters.GenderType', fieldKey: 'gender'));
    }
    if (next == 2) {
      for (final entry in _mdmsSchemas.entries) {
        if (entry.key != 'gender' && !state.mdmsData.containsKey(entry.key)) {
          add(MdmsDataRequested(schemaCode: entry.value, fieldKey: entry.key));
        }
      }
      if (state.boundaryRoot == null) add(BoundaryDataRequested());
    }
  }

  void _onPreviousStep(PreviousStepRequested event, Emitter<EmployeeFormState> emit) {
    final prev = (state.currentStep - 1).clamp(0, 2);
    emit(state.copyWith(currentStep: prev, submitStatus: SubmitStatus.idle, clearSubmitError: true));
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _onSubmit(EmployeeSubmitRequested event, Emitter<EmployeeFormState> emit) async {
    emit(state.copyWith(submitStatus: SubmitStatus.loading, clearSubmitError: true));
    final result = await _createEmployee(state.formData);
    result.fold(
      (failure) {
        if (failure.message == '__offline__') {
          emit(state.copyWith(submitStatus: SubmitStatus.offlineSaved));
        } else {
          emit(state.copyWith(submitStatus: SubmitStatus.failure, submitError: failure.message));
        }
      },
      (_) => emit(state.copyWith(submitStatus: SubmitStatus.success)),
    );
  }

  // ── Sync ──────────────────────────────────────────────────────────────────
  Future<void> _onSync(SyncPendingRequested event, Emitter<EmployeeFormState> emit) async {
    final result = await _syncPending();
    result.fold(
      (failure) => emit(state.copyWith(submitError: failure.message, syncMessage: null)),
      (count) {
        if (count > 0) {
          emit(state.copyWith(syncMessage: '$count offline record(s) posted successfully.'));
        } else {
          emit(state.copyWith(syncMessage: null));
        }
      },
    );
  }

  // ── Connectivity ──────────────────────────────────────────────────────────
  void _onConnectivityChanged(_ConnectivityChanged event, Emitter<EmployeeFormState> emit) {
    emit(state.copyWith(isOffline: !event.isOnline));
    if (event.isOnline) {
      add(SyncPendingRequested());
    }
  }

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    return super.close();
  }
}

// Internal event
class _ConnectivityChanged extends EmployeeFormEvent {
  final bool isOnline;
  const _ConnectivityChanged(this.isOnline);
}
