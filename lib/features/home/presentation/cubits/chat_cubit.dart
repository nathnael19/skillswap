import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/home/domain/repositories/chat_repository.dart';
import 'package:skillswap/features/home/domain/models/message_model.dart';
import 'package:skillswap/features/home/presentation/cubits/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;
  StreamSubscription<dynamic>? _messageSubscription;
  List<Message> _messages = [];

  ChatCubit({required ChatRepository chatRepository})
    : _chatRepository = chatRepository,
      super(ChatInitial());

  Future<void> loadMessages(String matchId) async {
    emit(ChatLoading());

    // 1. Fetch historical messages
    final result = await _chatRepository.getMessages(matchId);

    result.fold((failure) => emit(ChatError(failure.message)), (messages) {
      _messages = messages;
      emit(ChatMessagesLoaded(List.from(_messages)));

      // Mark as read after loading historical ones
      markAsRead(matchId);

      // 2. Subscribe to real-time message updates
      _messageSubscription?.cancel();
      _messageSubscription = _chatRepository
          .getMessagesStream(matchId)
          .listen(
            (event) {
              if (event is Message) {
                // Standard message and status update handling
                final index = _messages.indexWhere((m) => m.id == event.id);
                if (index != -1) {
                  // Update existing message (e.g. read status changed)
                  _messages[index] = event;
                } else {
                  // Add new message
                  _messages.add(event);
                  // Mark as read immediately if we are viewing this chat
                  markAsRead(matchId);
                }
                emit(ChatMessagesLoaded(List.from(_messages)));
              }
            },
            onError: (e) {
              if (state is! ChatMessagesLoaded) {
                emit(ChatError('Could not connect to chat: $e'));
              }
            },
          );
    });
  }

  Future<void> markAsRead(String matchId) async {
    await _chatRepository.markMessagesAsRead(matchId);
  }

  Future<void> sendMessage(String matchId, String content) async {
    if (content.trim().isEmpty) return;

    final result = await _chatRepository.sendMessage(
      matchId: matchId,
      content: content,
    );

    result.fold(
      (failure) => emit(
        ChatSendError(messages: List.from(_messages), message: failure.message),
      ),
      (sentMessage) {
        if (!_messages.any((m) => m.id == sentMessage.id)) {
          _messages.add(sentMessage);
          emit(ChatMessagesLoaded(List.from(_messages)));
        }
      },
    );
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
