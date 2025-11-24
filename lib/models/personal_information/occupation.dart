class Occupation {
  final int id;
  late final String skillAssessment;
  late final String nominatedOccupation;
  late final String occupationCode;
  late final String assessingAuthority;
  late final String? visaSubclass;
  late final String assessmentDate;
  late final String expiryDate;
  late final String referenceNo;
  late final bool relevantOccupation;

  Occupation({
    required this.id,
    required this.skillAssessment,
    required this.nominatedOccupation,
    required this.occupationCode,
    required this.assessingAuthority,
    this.visaSubclass,
    required this.assessmentDate,
    required this.expiryDate,
    required this.referenceNo,
    required this.relevantOccupation,
  });

  factory Occupation.fromJson(Map<String, dynamic> json) => Occupation(
    id: json["id"],
    skillAssessment: json["skill_assessment"],
    nominatedOccupation: json["nominated_occupation"],
    occupationCode: json["occupation_code"],
    assessingAuthority: json["assessing_authority"],
    visaSubclass: json["visa_subclass"],
    assessmentDate: json["assessment_date"],
    expiryDate: json["expiry_date"],
    referenceNo: json["reference_no"],
    relevantOccupation: json["relevant_occupation"],
  );
}
