class WorkFlowMessageDetailsResponse {
  bool success;
  Data data;

  WorkFlowMessageDetailsResponse({
    required this.success,
    required this.data,
  });

  factory WorkFlowMessageDetailsResponse.fromJson(
      Map<String, dynamic> json) {
    return WorkFlowMessageDetailsResponse(
      success: json['success'] ?? false,
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
  String senderShortname;
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
  List<Attachment> attachments;

  Data({
    required this.id,
    required this.message,
    required this.sender,
    required this.senderShortname,
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
    required this.attachments,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    var recipientsList = json['recipients'] as List? ?? [];
    List<Recipient> recipients =
    recipientsList.map((e) => Recipient.fromJson(e)).toList();

    var attachmentsList = json['attachments'] as List? ?? [];
    List<Attachment> attachments =
    attachmentsList.map((e) => Attachment.fromJson(e)).toList();

    return Data(
      id: json['id'],
      message: json['message'] ?? '',
      sender: json['sender'] ?? '',
      senderShortname: json['sender_shortname'] ?? '',
      senderId: json['sender_id'],
      isSender: json['is_sender'] ?? false,
      isRecipient: json['is_recipient'] ?? false,
      recipients: recipients,
      recipientCount: json['recipient_count'] ?? 0,
      sentAt: json['sent_at'] ?? '',
      isRead: json['is_read'],
      readAt: json['read_at'],
      clientMatterId: json['client_matter_id'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      attachments: attachments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'sender': sender,
      'sender_shortname': senderShortname,
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
      'attachments': attachments.map((e) => e.toJson()).toList(),
    };
  }
}

class Recipient {
  int recipientId;
  String recipientName;
  String recipientShortname;
  bool isRead;
  String? readAt;

  Recipient({
    required this.recipientId,
    required this.recipientName,
    required this.recipientShortname,
    required this.isRead,
    this.readAt,
  });

  factory Recipient.fromJson(Map<String, dynamic> json) {
    return Recipient(
      recipientId: json['recipient_id'],
      recipientName: json['recipient_name'] ?? '',
      recipientShortname: json['recipient_shortname'] ?? '',
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipient_id': recipientId,
      'recipient_name': recipientName,
      'recipient_shortname': recipientShortname,
      'is_read': isRead,
      'read_at': readAt,
    };
  }
}

class Attachment {
  int id;
  String type;
  String filename;
  String url;
  int size;

  Attachment({
    required this.id,
    required this.type,
    required this.filename,
    required this.url,
    required this.size,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'],
      type: json['type'] ?? '',
      filename: json['filename'] ?? '',
      url: json['url'] ?? '',
      size: json['size'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'filename': filename,
      'url': url,
      'size': size,
    };
  }
}