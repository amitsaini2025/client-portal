class RecentActivityResponse {
  bool success;
  Data data;

  RecentActivityResponse({required this.success, required this.data});

  factory RecentActivityResponse.fromJson(Map<String, dynamic> json) {
    return RecentActivityResponse(
      success: json['success'],
      data: Data.fromJson(json['data']),
    );
  }
}

class Data {
  List<Activity> activities;

  Data({required this.activities});

  factory Data.fromJson(Map<String, dynamic> json) {
    var activitiesJson = json['activities'] as List<dynamic>;
    return Data(
      activities: activitiesJson.map((e) => Activity.fromJson(e)).toList(),
    );
  }
}

class Activity {
  int id;
  String type;
  String title;
  String description;
  String createdAt;
  String updatedAt;
  String timeAgo;
  String? taskGroup;

  Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.timeAgo,
    this.taskGroup,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      type: json['type'] ?? "",
      title: json['title'] ?? "",
      description: json['description'] ?? "",
      createdAt: json['created_at'] ?? "",
      updatedAt: json['updated_at'] ?? "",
      timeAgo: json['time_ago'] ?? "",
      taskGroup: json['task_group'], // can be null
    );
  }
}