class NotificationModel {
  final int id;
  final int senderId;
  final int clientMatterId;
  final String url;
  final String notificationType;
  final String message;
  final bool isRead;
  final String senderName;
  final DateTime createdAt; // DateTime, not String

  NotificationModel({
    required this.id,
    required this.senderId,
    required this.clientMatterId,
    required this.url,
    required this.notificationType,
    required this.message,
    required this.isRead,
    required this.senderName,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      senderId: json['sender_id'],
      clientMatterId: json['client_matter_id'],
      url: json['url'],
      notificationType: json['notification_type'],
      message: json['message'],
      isRead: json['is_read'] == 1,
      senderName: json['sender_name'],
      createdAt: DateTime.parse(json['created_at']), // ✅ parse here
    );
  }
}
