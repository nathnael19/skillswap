import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/home/domain/models/message_model.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/features/home/presentation/cubits/matches_state.dart';
import 'package:skillswap/features/home/domain/repositories/home_repository.dart';

export 'matches_state.dart';

class MatchesCubit extends Cubit<MatchesState> {
  final HomeRepository _homeRepository;
  StreamSubscription<Message>? _messageSubscription;

  MatchesCubit(this._homeRepository) : super(MatchesInitial());

  Future<void> fetchMatches() async {
    emit(MatchesLoading());
    final result = await _homeRepository.getMatches();

    result.fold((failure) => emit(MatchesError(failure.message)), (matches) {
      emit(MatchesLoaded(List.from(matches)));

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

        emit(MatchesLoaded(currentMatches));
      }
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
