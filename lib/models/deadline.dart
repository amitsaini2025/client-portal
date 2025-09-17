class Deadline {
  final int id;
  final String title;
  final String dueDate;
  final String dueDatetime;
  final String status;
  final double daysUntil;
  final String priority;
  final String type;

  Deadline({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.dueDatetime,
    required this.status,
    required this.daysUntil,
    required this.priority,
    required this.type,
  });

  factory Deadline.fromJson(Map<String, dynamic> json) {
    return Deadline(
      id: json['id'],
      title: json['title'] ?? '',
      dueDate: json['due_date'] ?? '',
      dueDatetime: json['due_datetime'] ?? '',
      status: json['status'] ?? '',
      daysUntil: (json['days_until'] != null) ? (json['days_until'] as num).toDouble() : 0.0,
      priority: json['priority'] ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'due_date': dueDate,
    'due_datetime': dueDatetime,
    'status': status,
    'days_until': daysUntil,
    'priority': priority,
    'type': type,
  };
}
