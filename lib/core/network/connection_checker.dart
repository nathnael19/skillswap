import 'package:connectivity_plus/connectivity_plus.dart';

abstract interface class ConnectionChecker {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

class ConnectionCheckerImpl implements ConnectionChecker {
  final Connectivity _connectivity;

  ConnectionCheckerImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    return _isConnectedFromResult(results);
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_isConnectedFromResult);
  }

  bool _isConnectedFromResult(List<ConnectivityResult> results) {
    // If any of the results are not 'none', we are connected
    return results.any((result) => result != ConnectivityResult.none);
  }
}
