import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/core/network/connection_checker.dart';

enum ConnectivityStatus { connected, disconnected }

class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  final ConnectionChecker _connectionChecker;
  StreamSubscription? _subscription;

  ConnectivityCubit(this._connectionChecker) : super(ConnectivityStatus.connected) {
    _init();
  }

  void _init() async {
    // Check initial state
    final isConnected = await _connectionChecker.isConnected;
    emit(isConnected ? ConnectivityStatus.connected : ConnectivityStatus.disconnected);

    // Listen to changes
    _subscription = _connectionChecker.onConnectivityChanged.listen((isConnected) {
      emit(isConnected ? ConnectivityStatus.connected : ConnectivityStatus.disconnected);
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
