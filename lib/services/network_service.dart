import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  final _connectivity = Connectivity();
  StreamController<bool> _controller = StreamController<bool>.broadcast();

  NetworkService() {
    _connectivity.onConnectivityChanged.listen((status) {
      _controller.add(status != ConnectivityResult.none);
    });
  }

  Stream<bool> get onConnectivityChanged => _controller.stream;

  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void dispose() {
    _controller.close();
  }
}
