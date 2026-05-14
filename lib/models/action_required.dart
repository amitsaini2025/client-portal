class ActionRequiredModel {
  final int id;
  final String type;
  final int clientId;
  final int clientMatterId;
  final int? checklistId;
  final int senderId;
  final int receiverId;
  final int moduleId;
  final String url;
  final String notificationType;
  final String message;
  final int senderStatus;
  final int receiverStatus;
  final int seen;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String senderName;

  bool isRead;

  ActionRequiredModel({
    required this.id,
    required this.type,
    required this.clientId,
    required this.clientMatterId,
    this.checklistId,
    required this.senderId,
    required this.receiverId,
    required this.moduleId,
    required this.url,
    required this.notificationType,
    required this.message,
    required this.senderStatus,
    required this.receiverStatus,
    required this.seen,
    required this.createdAt,
    required this.updatedAt,
    required this.senderName,
  }) : isRead = seen == 1;

  factory ActionRequiredModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      try {
        final formatted = value.toString().replaceFirst(' ', 'T');
        return DateTime.parse(formatted);
      } catch (e) {
        return DateTime.now();
      }
    }

    return ActionRequiredModel(
      id: parseInt(json['id']),
      type: json['type']?.toString() ?? '',
      clientId: parseInt(json['client_id']),
      clientMatterId: parseInt(json['client_matter_id']),
      checklistId: json['checklist_id'] != null
          ? parseInt(json['checklist_id'])
          : null,
      senderId: parseInt(json['sender_id']),
      receiverId: parseInt(json['receiver_id']),
      moduleId: parseInt(json['module_id']),
      url: json['url']?.toString() ?? '',
      notificationType: json['notification_type']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      senderStatus: parseInt(json['sender_status']),
      receiverStatus: parseInt(json['receiver_status']),
      seen: parseInt(json['seen']),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      senderName: json['sender_name']?.toString() ?? 'Unknown',
    );
  }
}