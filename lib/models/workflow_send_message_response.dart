class SendMessageResponse {
  final bool success;
  final String message;
  final Data? data;

  SendMessageResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) {
    return SendMessageResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class Data {
  final int messageId;
  final Message? message;
  final String? sentAt;

  Data({
    required this.messageId,
    this.message,
    this.sentAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      messageId: json['message_id'] ?? 0,
      message: json['message'] != null ? Message.fromJson(json['message']) : null,
      sentAt: json['sent_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'message': message?.toJson(),
      'sent_at': sentAt,
    };
  }
}

class Message {
  final int id;
  final String message;
  final String sender;
  final int senderId;
  final int? recipientId;
  final String sentAt;
  final bool isRead;

  Message({
    required this.id,
    required this.message,
    required this.sender,
    required this.senderId,
    this.recipientId,
    required this.sentAt,
    required this.isRead,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      message: json['message'] ?? '',
      sender: json['sender'] ?? '',
      senderId: json['sender_id'] ?? 0,
      recipientId: json['recipient_id'],
      sentAt: json['sent_at'] ?? '',
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'sender': sender,
      'sender_id': senderId,
      'recipient_id': recipientId,
      'sent_at': sentAt,
      'is_read': isRead,
    };
  }
}
