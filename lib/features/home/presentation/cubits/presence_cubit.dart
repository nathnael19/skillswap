import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:skillswap/core/services/presence_service.dart';

class PresenceState extends Equatable {
  final bool isOnline;
  final bool isTyping;

  const PresenceState({this.isOnline = false, this.isTyping = false});

  PresenceState copyWith({bool? isOnline, bool? isTyping}) {
    return PresenceState(
      isOnline: isOnline ?? this.isOnline,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  @override
  List<Object?> get props => [isOnline, isTyping];
}

class PresenceCubit extends Cubit<PresenceState> {
  StreamSubscription<bool>? _onlineSub;
  StreamSubscription<bool>? _typingSub;

  PresenceCubit() : super(const PresenceState());

  void watchPeer(String peerId, String matchId) {
    _onlineSub?.cancel();
    _typingSub?.cancel();

    _onlineSub = PresenceService.instance.watchPresence(peerId).listen((online) {
      emit(state.copyWith(isOnline: online));
    });

    _typingSub = PresenceService.instance.watchTyping(matchId, peerId).listen((typing) {
      emit(state.copyWith(isTyping: typing));
    });
  }

  void setTyping(String matchId, bool isTyping) {
    PresenceService.instance.setTyping(matchId, isTyping);
  }

  @override
  Future<void> close() {
    _onlineSub?.cancel();
    _typingSub?.cancel();
    return super.close();
  }
}
