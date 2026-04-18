import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/home/domain/repositories/chat_repository.dart';
import 'package:skillswap/features/home/domain/models/message_model.dart';
import 'package:skillswap/features/home/presentation/cubits/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;
  StreamSubscription<dynamic>? _messageSubscription;
  List<Message> _messages = [];

  String? _currentPeerId;

  ChatCubit({required ChatRepository chatRepository})
    : _chatRepository = chatRepository,
      super(ChatInitial());

  Future<void> loadMessages(String matchId, String peerId) async {
    _currentPeerId = peerId;
    emit(ChatLoading());

    // 1. Fetch historical messages
    final result = await _chatRepository.getMessages(matchId);

    result.fold((failure) => emit(ChatError(failure.message)), (messages) {
      _messages = messages;
      emit(ChatMessagesLoaded(List.from(_messages)));

      // Mark as read after loading historical ones
      markAsRead(matchId);

      // 2. Subscribe to real-time updates (Messages + Signaling)
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
              } else if (event is Map<String, dynamic> &&
                  event['type'] == 'webrtc_signaling') {
                // Handle signaling events
                final action = event['action'];
                if (action == 'call_request') {
                  if (event['sender_id'] != _currentPeerId) return;

                  final data = event['data'] ?? {};
                  emit(
                    ChatIncomingCall(
                      messages: List.from(_messages),
                      peerId: event['sender_id'] ?? '',
                      peerName: data['caller_name'] ?? 'Peer',
                      peerImageUrl: data['caller_image'] ?? '',
                    ),
                  );
                }
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

  Future<void> rejectCall({required String targetId}) async {
    _chatRepository.sendSignalingMessage({
      'type': 'webrtc_signaling',
      'target_uid': targetId,
      'action': 'call_rejected',
      'data': {},
    });
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
