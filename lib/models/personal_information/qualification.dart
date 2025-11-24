class Qualification {
  final int id;
  late final String level;
  late final String name;
  late final String collegeName;
  late final String campus;
  late final String country;
  late final String? state;
  late final String startDate;
  late final String finishDate;
  late final bool relevantQualification;
  late final bool specialistEducation;
  late final bool stemQualification;
  late final bool regionalStudy;

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
    relevantQualification: json["relevant_qualification"],
    specialistEducation: json["specialist_education"],
    stemQualification: json["stem_qualification"],
    regionalStudy: json["regional_study"],
  );
}
