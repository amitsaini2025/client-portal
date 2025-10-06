class WorkflowMessagesResponse {
  final bool success;
  final MessagesData data;

  WorkflowMessagesResponse({
    required this.success,
    required this.data,
  });

  factory WorkflowMessagesResponse.fromJson(Map<String, dynamic> json) {
    return WorkflowMessagesResponse(
      success: json['success'] ?? false,
      data: MessagesData.fromJson(json['data'] ?? {}),
    );
  }
}

class MessagesData {
  final List<Message> messages;
  final Pagination pagination;
  final Filters filters;

  MessagesData({
    required this.messages,
    required this.pagination,
    required this.filters,
  });

  factory MessagesData.fromJson(Map<String, dynamic> json) {
    return MessagesData(
      messages: (json['messages'] as List<dynamic>?)
          ?.map((m) => Message.fromJson(m))
          .toList() ??
          [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
      filters: Filters.fromJson(json['filters'] ?? {}),
    );
  }
}

class Message {
  final int id;
  final String subject;
  final String message;
  final String sender;
  final String recipient;
  final int senderId;
  final int recipientId;
  final bool isSender;
  final bool isRecipient;
  final String sentAt;
  final String? readAt;
  final int isRead;
  final String messageType;
  final int clientMatterId;
  final int clientMatterStageId;
  final List<dynamic> attachments;
  final Metadata metadata;
  final String createdAt;
  final String updatedAt;

  Message({
    required this.id,
    required this.subject,
    required this.message,
    required this.sender,
    required this.recipient,
    required this.senderId,
    required this.recipientId,
    required this.isSender,
    required this.isRecipient,
    required this.sentAt,
    required this.readAt,
    required this.isRead,
    required this.messageType,
    required this.clientMatterId,
    required this.clientMatterStageId,
    required this.attachments,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      subject: json['subject'] ?? '',
      message: json['message'] ?? '',
      sender: json['sender'] ?? '',
      recipient: json['recipient'] ?? '',
      senderId: json['sender_id'] ?? 0,
      recipientId: json['recipient_id'] ?? 0,
      isSender: json['is_sender'] ?? false,
      isRecipient: json['is_recipient'] ?? false,
      sentAt: json['sent_at'] ?? '',
      readAt: json['read_at'],
      isRead: json['is_read'] ?? 0,
      messageType: json['message_type'] ?? '',
      clientMatterId: json['client_matter_id'] ?? 0,
      clientMatterStageId: json['client_matter_stage_id'] ?? 0,
      attachments: json['attachments'] ?? [],
      metadata: Metadata.fromJson(json['metadata'] ?? {}),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class Metadata {
  final String? senderEmail;
  final String? recipientEmail;
  final String? sentFrom;

  Metadata({
    this.senderEmail,
    this.recipientEmail,
    this.sentFrom,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      senderEmail: json['sender_email'],
      recipientEmail: json['recipient_email'],
      sentFrom: json['sent_from'],
    );
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
      currentPage: json['current_page']?.toString() ?? '1',
      perPage: json['per_page']?.toString() ?? '20',
      total: json['total'] ?? 0,
      lastPage: json['last_page'] ?? 1,
    );
  }
}

class Filters {
  final String type;
  final String messageType;
  final String clientMatterId;
  final String clientMatterStageId;

  Filters({
    required this.type,
    required this.messageType,
    required this.clientMatterId,
    required this.clientMatterStageId,
  });

  factory Filters.fromJson(Map<String, dynamic> json) {
    return Filters(
      type: json['type'] ?? 'all',
      messageType: json['message_type'] ?? 'all',
      clientMatterId: json['client_matter_id'] ?? '',
      clientMatterStageId: json['client_matter_stage_id'] ?? '',
    );
  }
}
