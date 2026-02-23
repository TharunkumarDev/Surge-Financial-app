import 'package:isar/isar.dart';

part 'chat_message.g.dart';

@collection
class ChatMessage {
  Id id = Isar.autoIncrement;
  
  late String content;
  late bool isUser;
  late DateTime timestamp;
  
  @Enumerated(EnumType.name)
  late MessageStatus status;
  
  @Enumerated(EnumType.name)
  late MessageType type;
  
  // Optional: For AI responses with structured data
  String? dataJson;
  
  // Bill attachments: expense IDs that have bill images
  List<int> attachedExpenseIds = [];
  
  // Whether the attached expenses have bill images (for display logic)
  bool hasBillImages = false;
  
  ChatMessage();
  
  ChatMessage.create({
    required this.content,
    required this.isUser,
    this.dataJson,
    this.attachedExpenseIds = const [],
    this.type = MessageType.text,
  }) : timestamp = DateTime.now(),
       status = MessageStatus.sent;
  
  ChatMessage.user(String message)
      : content = message,
        isUser = true,
        timestamp = DateTime.now(),
        status = MessageStatus.sending,
        type = MessageType.text,
        attachedExpenseIds = [];
  
  ChatMessage.ai(String response, {String? data, List<int>? expenseIds, bool hasBills = false})
      : content = response,
        isUser = false,
        dataJson = data,
        timestamp = DateTime.now(),
        status = MessageStatus.sent,
        type = expenseIds != null && expenseIds.isNotEmpty ? MessageType.billSearch : MessageType.text,
        attachedExpenseIds = expenseIds ?? [],
        hasBillImages = hasBills;
}

enum MessageStatus {
  sending,
  sent,
  error,
}

enum MessageType {
  text,
  billSearch,
}
