class RecentActivity {
  final int id;
  final String type;
  final String title;
  final String description;
  final String createdAt;
  final String updatedAt;
  final String timeAgo;

  RecentActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.timeAgo,
  });

  // From JSON
  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      description: json['description'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      timeAgo: json['time_ago'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'time_ago': timeAgo,
    };
  }
}
