import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/home/domain/repositories/chat_repository.dart';
import 'package:skillswap/features/home/domain/models/message_model.dart';
import 'package:skillswap/features/home/presentation/cubits/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;
  StreamSubscription<dynamic>? _messageSubscription;
  List<Message> _messages = [];

  String? _currentMatchId;
  String? _currentPeerId;

  ChatCubit({required ChatRepository chatRepository})
      : _chatRepository = chatRepository,
        super(ChatInitial());

  Future<void> loadMessages(String matchId, String peerId) async {
    _currentMatchId = matchId;
    _currentPeerId = peerId;
    emit(ChatLoading());
    
    // 1. Fetch historical messages
    final result = await _chatRepository.getMessages(matchId);
    
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (messages) {
        _messages = messages;
        emit(ChatMessagesLoaded(List.from(_messages)));
        
        // 2. Subscribe to real-time updates (Messages + Signaling)
        _messageSubscription?.cancel();
        _messageSubscription = _chatRepository.getMessagesStream(matchId).listen(
          (event) {
            if (event is Message) {
              // Standard message handling
              if (!_messages.any((m) => m.id == event.id)) {
                _messages.add(event);
                emit(ChatMessagesLoaded(List.from(_messages)));
              }
            } else if (event is Map<String, dynamic> && event['type'] == 'webrtc_signaling') {
              // Handle signaling events, specifically call_request
              final action = event['action'];
              if (action == 'call_request') {
                // Only show invitations from the person we are CURRENTLY chatting with
                if (event['sender_id'] != _currentPeerId) return;

                final data = event['data'] ?? {};
                emit(ChatIncomingCall(
                  messages: List.from(_messages),
                  peerId: event['sender_id'] ?? '', // sender_id is now added by backend relay
                  peerName: data['caller_name'] ?? 'Peer',
                  peerImageUrl: data['caller_image'] ?? '',
                ));
              }
            }
          },
          onError: (e) {
            // Only show error if we never loaded messages.
            // A WS blip should not wipe the chat history.
            if (state is! ChatMessagesLoaded) {
              emit(ChatError('Could not connect to chat: $e'));
            }
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
      (failure) => emit(ChatSendError(
        messages: List.from(_messages),
        message: failure.message,
      )),
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

  Future<void> rejectCall({required String targetId}) async {
    _chatRepository.sendSignalingMessage({
      'type': 'webrtc_signaling',
      'target_uid': targetId,
      'action': 'call_rejected',
      'data': {},
    });
    // Restore state to normal messages
    emit(ChatMessagesLoaded(List.from(_messages)));
  }

  void sendSignalingMessage(Map<String, dynamic> payload) {
    _chatRepository.sendSignalingMessage(payload);
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
