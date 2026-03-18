class Qualification {
  int? id;
  String level;
  String name;
  String collegeName;
  String campus;
  String country;
  String? state;
  String startDate;
  String finishDate;
  bool? relevantQualification;
  bool? specialistEducation;
  bool? stemQualification;
  bool? regionalStudy;

  Qualification({
    required this.id,
    required this.level,
    required this.name,
    required this.collegeName,
    required this.campus,
    required this.country,
    this.state,
    required this.startDate,
    required this.finishDate,
    required this.relevantQualification,
    required this.specialistEducation,
    required this.stemQualification,
    required this.regionalStudy,
  });

  factory Qualification.fromJson(Map<String, dynamic> json) => Qualification(
    id: json["id"],
    level: json["level"],
    name: json["name"],
    collegeName: json["college_name"],
    campus: json["campus"],
    country: json["country"],
    state: json["state"],
    startDate: json["start_date"],
    finishDate: json["finish_date"],
    relevantQualification: json["relevant_qualification"] ?? false,
    specialistEducation: json["specialist_education"] ?? false,
    stemQualification: json["stem_qualification"] ?? false,
    regionalStudy: json["regional_study"] ?? false,
  );
}
