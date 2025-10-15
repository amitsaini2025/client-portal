import 'dart:convert';

class WorkflowMessagesResponse {
  bool success;
  Data data;

  WorkflowMessagesResponse({required this.success, required this.data});

  factory WorkflowMessagesResponse.fromJson(Map<String, dynamic> json) => WorkflowMessagesResponse(
    success: json["success"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data.toJson(),
  };
}

class Data {
  List<Message> messages;
  Pagination pagination;
  Filters filters;

  Data({required this.messages, required this.pagination, required this.filters});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    messages: List<Message>.from(json["messages"].map((x) => Message.fromJson(x))),
    pagination: Pagination.fromJson(json["pagination"]),
    filters: Filters.fromJson(json["filters"]),
  );

  Map<String, dynamic> toJson() => {
    "messages": List<dynamic>.from(messages.map((x) => x.toJson())),
    "pagination": pagination.toJson(),
    "filters": filters.toJson(),
  };
}

class Message {
  int id;
  String message;
  String sender;
  int senderId;
  bool isSender;
  bool isRecipient;
  List<int> recipientIds;
  Map<String, String> recipients;
  int recipientCount;
  String sentAt;
  bool? isRead;
  String? readAt;
  int clientMatterId;
  String createdAt;
  String updatedAt;

  Message({
    required this.id,
    required this.message,
    required this.sender,
    required this.senderId,
    required this.isSender,
    required this.isRecipient,
    required this.recipientIds,
    required this.recipients,
    required this.recipientCount,
    required this.sentAt,
    this.isRead,
    this.readAt,
    required this.clientMatterId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json["id"],
    message: json["message"],
    sender: json["sender"],
    senderId: json["sender_id"],
    isSender: json["is_sender"],
    isRecipient: json["is_recipient"],
    recipientIds: List<int>.from(json["recipient_ids"].map((x) => x)),
    recipients: Map<String, String>.from(json["recipients"]),
    recipientCount: json["recipient_count"],
    sentAt: json["sent_at"],
    isRead: json["is_read"],
    readAt: json["read_at"],
    clientMatterId: json["client_matter_id"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "message": message,
    "sender": sender,
    "sender_id": senderId,
    "is_sender": isSender,
    "is_recipient": isRecipient,
    "recipient_ids": List<dynamic>.from(recipientIds.map((x) => x)),
    "recipients": Map.from(recipients),
    "recipient_count": recipientCount,
    "sent_at": sentAt,
    "is_read": isRead,
    "read_at": readAt,
    "client_matter_id": clientMatterId,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class Pagination {
  String currentPage;
  String perPage;
  int total;
  int lastPage;

  Pagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["current_page"],
    perPage: json["per_page"],
    total: json["total"],
    lastPage: json["last_page"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "per_page": perPage,
    "total": total,
    "last_page": lastPage,
  };
}

class Filters {
  String clientMatterId;

  Filters({required this.clientMatterId});

  factory Filters.fromJson(Map<String, dynamic> json) => Filters(
    clientMatterId: json["client_matter_id"],
  );

  Map<String, dynamic> toJson() => {
    "client_matter_id": clientMatterId,
  };
}
