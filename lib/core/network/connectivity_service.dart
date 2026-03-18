import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

@singleton
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _subscription;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  bool _isOnline = true;

  bool get isOnline => _isOnline;
  Stream<bool> get onConnectivityChanged => _controller.stream;

  @PostConstruct()
  void init() {
    _connectivity.checkConnectivity().then((result) {
      _updateStatus(result);
    });
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(ConnectivityResult result) {
    _isOnline = result != ConnectivityResult.none;
    _controller.add(_isOnline);
  }

  @disposeMethod
  void dispose() {
    _subscription.cancel();
    _controller.close();
  }
}
