import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/employee/presentation/pages/employee_stepper_page.dart';
import '../../features/employee/presentation/pages/success_page.dart';
import 'local_storage_service.dart';
import '../di/injection_container.dart';

class AppRouter {
  AppRouter._();

  static const String login = '/login';
  static const String employeeCreate = '/employee/create';
  static const String success = '/success';

  static final GoRouter router = GoRouter(
    initialLocation: _initialRoute(),
    routes: [
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: employeeCreate,
        name: 'employee_create',
        builder: (context, state) => const EmployeeStepperPage(),
      ),
      GoRoute(
        path: success,
        name: 'success',
        builder: (context, state) {
          final isOffline = state.extra as bool? ?? false;
          return SuccessPage(isOffline: isOffline);
        },
      ),
    ],
    redirect: (context, state) {
      final token = sl<LocalStorageService>().getAuthToken();
      final isLoggedIn = token != null && token.isNotEmpty;
      final isOnLoginPage = state.matchedLocation == login;

      if (!isLoggedIn && !isOnLoginPage) return login;
      if (isLoggedIn && isOnLoginPage) return employeeCreate;
      return null;
    },
  );

  static String _initialRoute() {
    final token = sl<LocalStorageService>().getAuthToken();
    return (token != null && token.isNotEmpty) ? employeeCreate : login;
  }
}
