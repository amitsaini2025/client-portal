class Occupation {
  final String anzscoCode;
  final String title;
  final int skillLevel;
  final String assessingAuthority;
  final int validityYears;
  final List<String> occupationLists;
  final String alternateTitles;
  final String additionalInfo;

  Occupation({
    required this.anzscoCode,
    required this.title,
    required this.skillLevel,
    required this.assessingAuthority,
    required this.validityYears,
    required this.occupationLists,
    required this.alternateTitles,
    required this.additionalInfo
  });

  factory Occupation.fromJson(Map<String, dynamic> json) {
    return Occupation(
      anzscoCode: json['anzsco_code'],
      title: json['occupation_title'],
      skillLevel: json['skill_level'],
      assessingAuthority: json['assessing_authority'],
      validityYears: json['assessment_validity_years'],
      occupationLists: List<String>.from(json['occupation_lists']),
      alternateTitles: json['alternate_titles'] ?? '',
      additionalInfo: json['additional_info']
    );
  }
}
