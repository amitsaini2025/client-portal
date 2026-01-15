class PRCalcRequest {
  final int age;
  final int english;
  final int education;
  final int overseasExp;
  final int australiaExp;
  final List<int> additionalPoints;
  final int partner;

  PRCalcRequest({
    required this.age,
    required this.english,
    required this.education,
    required this.overseasExp,
    required this.australiaExp,
    required this.additionalPoints,
    required this.partner,
  });

  Map<String, dynamic> toJson() {
    return {
      "age": age,
      "english_language_proficiency": english,
      "educational_qualifications": education,
      "skilled_employment_overseas": overseasExp,
      "skilled_employment_australia": australiaExp,
      "additional_points": additionalPoints,
      "partner_spouse_status": partner,
    };
  }
}
