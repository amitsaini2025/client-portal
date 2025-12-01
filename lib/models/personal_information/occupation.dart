class Occupation {
  int? id;
  String skillAssessment;
  String nominatedOccupation;
  String occupationCode;
  String assessingAuthority;
  String? visaSubclass;
  String assessmentDate;
  String expiryDate;
  String referenceNo;
  bool relevantOccupation;

  Occupation({
    this.id,
    this.skillAssessment = '',
    this.nominatedOccupation = '',
    this.occupationCode = '',
    this.assessingAuthority = '',
    this.visaSubclass,
    this.assessmentDate = '',
    this.expiryDate = '',
    this.referenceNo = '',
    this.relevantOccupation = false,
  });

  factory Occupation.fromJson(Map<String, dynamic> json) => Occupation(
    id: json["id"],
    skillAssessment: json["skill_assessment"] ?? '',
    nominatedOccupation: json["nominated_occupation"] ?? '',
    occupationCode: json["occupation_code"] ?? '',
    assessingAuthority: json["assessing_authority"] ?? '',
    visaSubclass: json["visa_subclass"],
    assessmentDate: json["assessment_date"] ?? '',
    expiryDate: json["expiry_date"] ?? '',
    referenceNo: json["reference_no"] ?? '',
    relevantOccupation: json["relevant_occupation"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "skill_assessment": skillAssessment,
    "nominated_occupation": nominatedOccupation,
    "occupation_code": occupationCode,
    "assessing_authority": assessingAuthority,
    "visa_subclass": visaSubclass,
    "assessment_date": assessmentDate,
    "expiry_date": expiryDate,
    "reference_no": referenceNo,
    "relevant_occupation": relevantOccupation,
  };

}
