// GENERATED CODE - Manually written DI config
// In a real build, run: flutter pub run build_runner build

import 'package:get_it/get_it.dart';
import '../network/network_client.dart';
import '../network/connectivity_service.dart';
import '../utils/local_storage_service.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/employee/data/datasources/employee_remote_datasource.dart';
import '../../features/employee/data/repositories/employee_repository_impl.dart';
import '../../features/employee/domain/repositories/employee_repository.dart';
import '../../features/employee/domain/usecases/employee_usecases.dart';
import '../../features/employee/presentation/bloc/employee_form_bloc.dart';
import '../../sdui/parser/sdui_service.dart';

extension GetItInjectableX on GetIt {
  Future<GetIt> init() async {
    // Core — singletons
    final localStorage = LocalStorageService();
    await localStorage.init();
    registerSingleton<LocalStorageService>(localStorage);

    registerSingleton<NetworkClient>(NetworkClient());

    final connectivityService = ConnectivityService();
    connectivityService.init();
    registerSingleton<ConnectivityService>(connectivityService);

    registerSingleton<SduiService>(SduiService());

    // Auth datasource & repo
    registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(get<NetworkClient>()),
    );
    registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        get<AuthRemoteDataSource>(),
        get<LocalStorageService>(),
        get<ConnectivityService>(),
      ),
    );
    registerLazySingleton<LoginUseCase>(() => LoginUseCase(get<AuthRepository>()));
    registerFactory<AuthBloc>(() => AuthBloc(get<LoginUseCase>()));

    // Employee datasource & repo
    registerLazySingleton<EmployeeRemoteDataSource>(
      () => EmployeeRemoteDataSourceImpl(
        get<NetworkClient>(),
        get<LocalStorageService>(),
      ),
    );
    registerLazySingleton<EmployeeRepository>(
      () => EmployeeRepositoryImpl(
        get<EmployeeRemoteDataSource>(),
        get<LocalStorageService>(),
        get<ConnectivityService>(),
      ),
    );

    // Employee usecases
    registerLazySingleton(() => GetMdmsOptionsUseCase(get<EmployeeRepository>()));
    registerLazySingleton(() => GetBoundaryHierarchyUseCase(get<EmployeeRepository>()));
    registerLazySingleton(() => CheckUsernameExistsUseCase(get<EmployeeRepository>()));
    registerLazySingleton(() => CheckMobileExistsUseCase(get<EmployeeRepository>()));
    registerLazySingleton(() => CreateEmployeeUseCase(get<EmployeeRepository>()));
    registerLazySingleton(() => SyncPendingEmployeesUseCase(get<EmployeeRepository>()));

    // Employee BLoC (factory — new instance per page)
    registerFactory<EmployeeFormBloc>(
      () => EmployeeFormBloc(
        get<GetMdmsOptionsUseCase>(),
        get<GetBoundaryHierarchyUseCase>(),
        get<CheckUsernameExistsUseCase>(),
        get<CheckMobileExistsUseCase>(),
        get<CreateEmployeeUseCase>(),
        get<SyncPendingEmployeesUseCase>(),
        get<ConnectivityService>(),
      ),
    );

    return this;
  }
}
