

class SendMessageResponse {
  final bool success;
  final String message;
  final Data data;

  SendMessageResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) {
    return SendMessageResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: Data.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data.toJson()};
  }
}

class Data {
  final int messageId;
  final MessageDetail message;
  final DateTime sentAt;
  final int recipientCount;

  Data({
    required this.messageId,
    required this.message,
    required this.sentAt,
    required this.recipientCount,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      messageId: int.tryParse(json['message_id'].toString()) ?? 0,
      message: MessageDetail.fromJson(json['message'] ?? {}),
      sentAt: DateTime.parse(
        json['sent_at'] ?? DateTime.now().toIso8601String(),
      ),
      recipientCount: int.tryParse(json['recipient_count'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'message': message.toJson(),
      'sent_at': sentAt.toIso8601String(),
      'recipient_count': recipientCount,
    };
  }
}

class MessageDetail {
  final int id;
  final String message;
  final String sender;
  final int senderId;
  final String senderShortname;
  bool isSender;
  bool isRecipient;
  final List<Recipient> recipientIds;
  final DateTime sentAt;
  final int clientMatterId;
  final int recipientCount;
  bool? isRead;
  String? readAt;

  MessageDetail({
    required this.id,
    required this.message,
    required this.sender,
    required this.senderId,
    required this.senderShortname,
    required this.isSender,
    required this.isRecipient,
    required this.recipientIds,
    required this.sentAt,
    required this.clientMatterId,
    required this.recipientCount,
    this.isRead,
    this.readAt,
  });

  factory MessageDetail.fromJson(Map<String, dynamic> json) {
    return MessageDetail(
      id: int.tryParse(json['id'].toString()) ?? 0,
      message: json['message'] ?? '',
      sender: json['sender'] ?? '',
      senderId: int.tryParse(json['sender_id'].toString()) ?? 0,
      senderShortname: json['sender_shortname'] ?? '',
      isSender: json['is_sender'] as bool? ?? false,
      isRecipient: json['is_recipient'] as bool? ?? false,
      recipientIds:
      (json['recipient_ids'] as List<dynamic>?)
          ?.map((e) => Recipient.fromJson(e))
          .toList() ??
          [],
      sentAt: DateTime.parse(
        json['sent_at'] ?? DateTime.now().toIso8601String(),
      ),
      clientMatterId: int.tryParse(json['client_matter_id'].toString()) ?? 0,
      recipientCount: int.tryParse(json['recipient_count'].toString()) ?? 0,
      isRead: json['is_read'] as bool?, // handle null properly
      readAt: json['read_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'sender': sender,
      'sender_id': senderId,
      'sender_shortname': senderShortname,
      'is_sender': isSender,
      'is_recipient': isRecipient,
      'recipient_ids': recipientIds.map((e) => e.toJson()).toList(),
      'sent_at': sentAt.toIso8601String(),
      'client_matter_id': clientMatterId,
      'recipient_count': recipientCount,
      'is_read': isRead,
      'read_at': readAt,
    };
  }
}

class Recipient {
  final int recipientId;
  final String recipient;
  final String recipientShortname;

  Recipient({
    required this.recipientId,
    required this.recipient,
    required this.recipientShortname,
  });

  factory Recipient.fromJson(Map<String, dynamic> json) {
    return Recipient(
      recipientId: int.tryParse(json['recipient_id'].toString()) ?? 0,
      recipient: json['recipient'] ?? '',
      recipientShortname: json['recipient_shortname'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipient_id': recipientId,
      'recipient': recipient,
      'recipient_shortname': recipientShortname,
    };
  }
}
