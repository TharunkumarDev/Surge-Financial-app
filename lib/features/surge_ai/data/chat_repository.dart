import 'package:isar/isar.dart';
import '../domain/chat_message.dart';

/// Chat persistence and caching repository
class ChatRepository {
  final Isar isar;
  
  ChatRepository({required this.isar});
  
  /// Save a message to local storage
  Future<void> saveMessage(ChatMessage message) async {
    await isar.writeTxn(() async {
      await isar.chatMessages.put(message);
    });
  }
  
  /// Get recent messages (default: last 20)
  Future<List<ChatMessage>> getRecentMessages({int limit = 20}) async {
    return await isar.chatMessages
        .where()
        .sortByTimestampDesc()
        .limit(limit)
        .findAll();
  }
  
  /// Watch messages for real-time updates
  Stream<List<ChatMessage>> watchMessages({int limit = 20}) {
    return isar.chatMessages
        .where()
        .sortByTimestampDesc()
        .limit(limit)
        .watch(fireImmediately: true);
  }
  
  /// Clear all chat history
  Future<void> clearHistory() async {
    await isar.writeTxn(() async {
      await isar.chatMessages.clear();
    });
  }
  
  /// Get message count
  Future<int> getMessageCount() async {
    return await isar.chatMessages.count();
  }
  
  /// Update message status (e.g., sending -> sent)
  Future<void> updateMessageStatus(int messageId, MessageStatus status) async {
    await isar.writeTxn(() async {
      final message = await isar.chatMessages.get(messageId);
      if (message != null) {
        message.status = status;
        await isar.chatMessages.put(message);
      }
    });
  }
}
