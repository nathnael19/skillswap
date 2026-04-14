import 'package:equatable/equatable.dart';
import 'package:skillswap/features/home/domain/models/message_model.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatMessagesLoaded extends ChatState {
  final List<Message> messages;
  const ChatMessagesLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatIncomingCall extends ChatMessagesLoaded {
  final String peerName;
  final String peerImageUrl;
  final String peerId;

  const ChatIncomingCall({
    required List<Message> messages,
    required this.peerName,
    required this.peerImageUrl,
    required this.peerId,
  }) : super(messages);

  @override
  List<Object?> get props => [messages, peerName, peerImageUrl, peerId];
}

class ChatSendError extends ChatMessagesLoaded {
  final String message;
  const ChatSendError({
    required List<Message> messages,
    required this.message,
  }) : super(messages);

  @override
  List<Object?> get props => [messages, message];
}
