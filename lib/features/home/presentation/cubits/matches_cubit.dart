import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/home/domain/models/message_model.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/features/home/presentation/cubits/matches_state.dart';
import 'package:skillswap/features/home/domain/repositories/home_repository.dart';
import 'package:skillswap/core/services/presence_service.dart';

export 'matches_state.dart';

class MatchesCubit extends Cubit<MatchesState> {
  final HomeRepository _homeRepository;
  StreamSubscription<Message>? _messageSubscription;
  final Map<String, StreamSubscription<bool>> _presenceSubscriptions = {};

  MatchesCubit(this._homeRepository) : super(MatchesInitial());

  Future<void> fetchMatches() async {
    emit(MatchesLoading());
    final result = await _homeRepository.getMatches();

    result.fold((failure) => emit(MatchesError(failure.message)), (matches) {
      emit(MatchesLoaded(List.from(matches)));

      _watchPresences(matches);

      // Subscribe to real-time updates for all matches
      _messageSubscription?.cancel();
      _messageSubscription = _homeRepository.getGlobalMessageStream().listen(
        (Message message) {
          _onNewMessageReceived(message);
        },
        onError: (e) {},
      );
    });
  }

  void _watchPresences(List<Conversation> matches) {
    for (var sub in _presenceSubscriptions.values) {
      sub.cancel();
    }
    _presenceSubscriptions.clear();

    for (var match in matches) {
      final uid = match.user.id;
      _presenceSubscriptions[uid] = PresenceService.instance.watchPresence(uid).listen((isOnline) {
        if (state is MatchesLoaded) {
          final currentState = state as MatchesLoaded;
          final currentStatuses = Map<String, bool>.from(currentState.onlineStatuses);
          currentStatuses[uid] = isOnline;
          emit(MatchesLoaded(currentState.matches, onlineStatuses: currentStatuses));
        }
      });
    }
  }

  void _onNewMessageReceived(Message message) {
    if (state is MatchesLoaded) {
      final currentMatches = List<Conversation>.from(
        (state as MatchesLoaded).matches,
      );
      final index = currentMatches.indexWhere(
        (c) => c.matchId == message.matchId,
      );

      if (index != -1) {
        final conversation = currentMatches[index];
        // Create updated conversation object
        final updatedConversation = Conversation(
          user: conversation.user,
          matchId: conversation.matchId,
          lastMessage: message.content,
          lastMessageTime: message.timestamp.toIso8601String(),
          // Always unread if someone else sent it
          // In a real app, we'd check if the user is currently looking at this chat
          hasUnread: true,
        );

        // Remove and insert at top for "Telegram" behavior
        currentMatches.removeAt(index);
        currentMatches.insert(0, updatedConversation);

        final currentState = state as MatchesLoaded;
        emit(MatchesLoaded(currentMatches, onlineStatuses: currentState.onlineStatuses));
      }
    }
  }

  @override
  Future<void> close() {
    for (var sub in _presenceSubscriptions.values) {
      sub.cancel();
    }
    _messageSubscription?.cancel();
    return super.close();
  }
}
