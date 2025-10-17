class WorkflowMessagesResponse {
  final bool success;
  final Data data;

  WorkflowMessagesResponse({
    required this.success,
    required this.data,
  });

  factory WorkflowMessagesResponse.fromJson(Map<String, dynamic> json) {
    return WorkflowMessagesResponse(
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
  final List<Message> messages;
  final Pagination pagination;
  final Filters filters;

  Data({
    required this.messages,
    required this.pagination,
    required this.filters,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      messages: (json['messages'] as List)
          .map((e) => Message.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json['pagination']),
      filters: Filters.fromJson(json['filters']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messages': messages.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
      'filters': filters.toJson(),
    };
  }
}

class Message {
  final int id;
  final String message;
  final String sender;
  final int senderId;
  final String senderShortname;
  final bool isSender;
  final bool isRecipient;
  final List<Recipient> recipientIds;
  final int recipientCount;
  final String sentAt;
  final bool? isRead;
  final String? readAt;
  final int clientMatterId;
  final String createdAt;
  final String updatedAt;

  Message({
    required this.id,
    required this.message,
    required this.sender,
    required this.senderId,
    required this.senderShortname,
    required this.isSender,
    required this.isRecipient,
    required this.recipientIds,
    required this.recipientCount,
    required this.sentAt,
    this.isRead,
    this.readAt,
    required this.clientMatterId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      message: json['message'],
      sender: json['sender'],
      senderId: json['sender_id'],
      senderShortname: json['sender_shortname'],
      isSender: json['is_sender'],
      isRecipient: json['is_recipient'],
      recipientIds: (json['recipient_ids'] as List)
          .map((e) => Recipient.fromJson(e))
          .toList(),
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
      'sender_shortname': senderShortname,
      'is_sender': isSender,
      'is_recipient': isRecipient,
      'recipient_ids': recipientIds.map((e) => e.toJson()).toList(),
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
      recipientId: json['recipient_id'],
      recipient: json['recipient'],
      recipientShortname: json['recipient_shortname'],
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

class Pagination {
  final String currentPage;
  final String perPage;
  final int total;
  final int lastPage;

  Pagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'],
      perPage: json['per_page'],
      total: json['total'],
      lastPage: json['last_page'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'per_page': perPage,
      'total': total,
      'last_page': lastPage,
    };
  }
}

class Filters {
  final String clientMatterId;

  Filters({required this.clientMatterId});

  factory Filters.fromJson(Map<String, dynamic> json) {
    return Filters(
      clientMatterId: json['client_matter_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client_matter_id': clientMatterId,
    };
  }
}
