class Task {
  final int id;
  final String title;
  final String dueDate;
  final String dueDatetime;
  final String status;
  final double daysUntil;
  final String priority;
  final String type;
  final bool isOverdue;
  final String createdAt;
  final String updatedAt;
  final String lastUpdated;

  Task({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.dueDatetime,
    required this.status,
    required this.daysUntil,
    required this.priority,
    required this.type,
    required this.isOverdue,
    required this.createdAt,
    required this.updatedAt,
    required this.lastUpdated,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      dueDate: json['due_date'],
      dueDatetime: json['due_datetime'],
      status: json['status'],
      daysUntil: (json['days_until'] as num).toDouble(),
      priority: json['priority'],
      type: json['type'],
      isOverdue: json['is_overdue'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      lastUpdated: json['last_updated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'due_date': dueDate,
      'due_datetime': dueDatetime,
      'status': status,
      'days_until': daysUntil,
      'priority': priority,
      'type': type,
      'is_overdue': isOverdue,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'last_updated': lastUpdated,
    };
  }
}
