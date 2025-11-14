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
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? 'Untitled Task',
      dueDate: json['due_date']?.toString() ?? 'No due date',
      dueDatetime: json['due_datetime']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      daysUntil: (json['days_until'] != null)
          ? (json['days_until'] as num).toDouble()
          : 0.0,
      priority: json['priority']?.toString() ?? 'low',
      type: json['type']?.toString() ?? '',
      isOverdue: json['is_overdue'] ?? false,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      lastUpdated: json['last_updated']?.toString() ?? '',
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
