import 'package:fpdart/fpdart.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/home/domain/models/message_model.dart';

abstract interface class ChatRepository {
  Future<Either<Failure, List<Message>>> getMessages(String matchId);
  Stream<dynamic> getMessagesStream(String matchId);
  Future<Either<Failure, Message>> sendMessage({
    required String matchId,
    required String content,
  });
  void sendSignalingMessage(Map<String, dynamic> payload);
}
