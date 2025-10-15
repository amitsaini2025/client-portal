class SendMessageResponse {
  bool success;
  String message;
  Data? data;

  SendMessageResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) =>
      SendMessageResponse(
        success: json["success"],
        message: json["message"],
        data: json["data"] != null ? Data.fromJson(json["data"]) : null,
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  int? messageId;
  Message? message;
  String? sentAt;
  int? recipientCount;

  Data({this.messageId, this.message, this.sentAt, this.recipientCount});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    messageId: json["message_id"],
    message: json["message"] != null ? Message.fromJson(json["message"]) : null,
    sentAt: json["sent_at"],
    recipientCount: json["recipient_count"],
  );

  Map<String, dynamic> toJson() => {
    "message_id": messageId,
    "message": message?.toJson(),
    "sent_at": sentAt,
    "recipient_count": recipientCount,
  };
}

class Message {
  int id;
  String message;
  String sender;
  int senderId;
  List<int> recipientIds;
  String sentAt;
  int clientMatterId;
  int recipientCount;

  Message({
    required this.id,
    required this.message,
    required this.sender,
    required this.senderId,
    required this.recipientIds,
    required this.sentAt,
    required this.clientMatterId,
    required this.recipientCount,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json["id"] is int ? json["id"] : int.parse(json["id"].toString()),
    message: json["message"],
    sender: json["sender"],
    senderId: json["sender_id"] is int
        ? json["sender_id"]
        : int.parse(json["sender_id"].toString()),
    recipientIds: List<int>.from(
        json["recipient_ids"].map((x) => x is int ? x : int.parse(x.toString()))),
    sentAt: json["sent_at"],
    clientMatterId: json["client_matter_id"] is int
        ? json["client_matter_id"]
        : int.parse(json["client_matter_id"].toString()),
    recipientCount: json["recipient_count"] is int
        ? json["recipient_count"]
        : int.parse(json["recipient_count"].toString()),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "message": message,
    "sender": sender,
    "sender_id": senderId,
    "recipient_ids": recipientIds,
    "sent_at": sentAt,
    "client_matter_id": clientMatterId,
    "recipient_count": recipientCount,
  };
}
