class WorkFlowMessageDetailsResponse {
  bool success;
  Data data;

  WorkFlowMessageDetailsResponse({required this.success, required this.data});

  factory WorkFlowMessageDetailsResponse.fromJson(Map<String, dynamic> json) {
    return WorkFlowMessageDetailsResponse(
      success: json['success'],
      data: Data.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class Data {
  int id;
  String message;
  String sender;
  int senderId;
  bool isSender;
  bool isRecipient;
  List<Recipient> recipients;
  int recipientCount;
  String sentAt;
  bool? isRead;
  String? readAt;
  int clientMatterId;
  String createdAt;
  String updatedAt;

  Data({
    required this.id,
    required this.message,
    required this.sender,
    required this.senderId,
    required this.isSender,
    required this.isRecipient,
    required this.recipients,
    required this.recipientCount,
    required this.sentAt,
    this.isRead,
    this.readAt,
    required this.clientMatterId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    var recipientsList = json['recipients'] as List;
    List<Recipient> recipients =
    recipientsList.map((i) => Recipient.fromJson(i)).toList();

    return Data(
      id: json['id'],
      message: json['message'],
      sender: json['sender'],
      senderId: json['sender_id'],
      isSender: json['is_sender'],
      isRecipient: json['is_recipient'],
      recipients: recipients,
      recipientCount: json['recipient_count'],
      sentAt: json['sent_at'],
      isRead: json['is_read'],
      readAt: json['read_at'],
      clientMatterId: json['client_matter_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'sender': sender,
      'sender_id': senderId,
      'is_sender': isSender,
      'is_recipient': isRecipient,
      'recipients': recipients.map((e) => e.toJson()).toList(),
      'recipient_count': recipientCount,
      'sent_at': sentAt,
      'is_read': isRead,
      'read_at': readAt,
      'client_matter_id': clientMatterId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class Recipient {
  int recipientId;
  String recipientName;
  bool isRead;
  String? readAt;

  Recipient({
    required this.recipientId,
    required this.recipientName,
    required this.isRead,
    this.readAt,
  });

  factory Recipient.fromJson(Map<String, dynamic> json) {
    return Recipient(
      recipientId: json['recipient_id'],
      recipientName: json['recipient_name'],
      isRead: json['is_read'],
      readAt: json['read_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipient_id': recipientId,
      'recipient_name': recipientName,
      'is_read': isRead,
      'read_at': readAt,
    };
  }
}
