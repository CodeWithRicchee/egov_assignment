import 'package:get_it/get_it.dart';
import 'injection_container.config.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async => sl.init();
