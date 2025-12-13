class Experience {
  int? id;
  String jobTitle;
  String jobCode;
  String country;
  String startDate;
  String finishDate;
  bool relevantExperience;
  String employerName;
  String? state;
  String jobType;
  double fteMultiplier;

  Experience({
    required this.id,
    required this.jobTitle,
    required this.jobCode,
    required this.country,
    required this.startDate,
    required this.finishDate,
    required this.relevantExperience,
    required this.employerName,
    this.state,
    required this.jobType,
    required this.fteMultiplier,
  });

  factory Experience.fromJson(Map<String, dynamic> json) => Experience(
    id: json["id"] ?? 0,
    jobTitle: json["job_title"]?.toString() ?? "",
    jobCode: json["job_code"]?.toString() ?? "",
    country: json["country"]?.toString() ?? "",
    startDate: json["start_date"]?.toString() ?? "",
    finishDate: json["finish_date"]?.toString() ?? "",
    relevantExperience: json["relevant_experience"] ?? false,
    employerName: json["employer_name"]?.toString() ?? "",
    state: json["state"]?.toString(),
    jobType: json["job_type"]?.toString() ?? "",
    fteMultiplier: (json["fte_multiplier"] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "job_title": jobTitle,
    "job_code": jobCode,
    "country": country,
    "start_date": startDate,
    "finish_date": finishDate,
    "relevant_experience": relevantExperience,
    "employer_name": employerName,
    "state": state,
    "job_type": jobType,
    "fte_multiplier": fteMultiplier,
  };
}
