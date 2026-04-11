import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/home/domain/repositories/chat_repository.dart';
import 'package:skillswap/features/home/domain/models/message_model.dart';
import 'package:skillswap/features/home/presentation/cubits/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;
  StreamSubscription<Message>? _messageSubscription;
  List<Message> _messages = [];

  ChatCubit({required ChatRepository chatRepository})
      : _chatRepository = chatRepository,
        super(ChatInitial());

  Future<void> loadMessages(String matchId) async {
    emit(ChatLoading());
    
    // 1. Fetch historical messages
    final result = await _chatRepository.getMessages(matchId);
    
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (messages) {
        _messages = messages;
        emit(ChatMessagesLoaded(List.from(_messages)));
        
        // 2. Subscribe to real-time updates
        _messageSubscription?.cancel();
        _messageSubscription = _chatRepository.getMessagesStream(matchId).listen(
          (newMessage) {
            // Check if message is already in list (sent by me via REST)
            if (!_messages.any((m) => m.id == newMessage.id)) {
              _messages.add(newMessage);
              emit(ChatMessagesLoaded(List.from(_messages)));
            }
          },
          onError: (e) {
            emit(ChatError('WebSocket connection lost: $e'));
          },
        );
      },
    );
  }

  Future<void> sendMessage(String matchId, String content) async {
    if (content.trim().isEmpty) return;

    final result = await _chatRepository.sendMessage(
      matchId: matchId,
      content: content,
    );

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (sentMessage) {
        // We don't NEED to add it here because the WS broadcast might handle it,
        // but adding it immediately makes the UI feel punchy.
        // The listen() logic above prevents duplicates.
        if (!_messages.contains(sentMessage)) {
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
