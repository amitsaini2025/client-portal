class PRCalcResultResponse {
  final bool success;
  final PRPointsData? data;

  PRCalcResultResponse({required this.success, this.data});

  factory PRCalcResultResponse.fromJson(Map<String, dynamic> json) {
    return PRCalcResultResponse(
      success: json['success'] ?? false,
      data: (json['data'] is Map<String, dynamic>)
          ? PRPointsData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
    };
  }
}

class PRPointsData {
  final int totalPoints;
  final int basePoints;
  final int additionalPoints;
  final PointsBreakdown pointsBreakdown;
  final List<PRCalcResultVisaOption> visaOptions;
  final String message;
  final List<String> importantNotes;

  PRPointsData({
    required this.totalPoints,
    required this.basePoints,
    required this.additionalPoints,
    required this.pointsBreakdown,
    required this.visaOptions,
    required this.message,
    required this.importantNotes,
  });

  factory PRPointsData.fromJson(Map<String, dynamic> json) {
    return PRPointsData(
      totalPoints: json['total_points'] ?? 0,
      basePoints: json['base_points'] ?? 0,
      additionalPoints: json['additional_points'] ?? 0,
      pointsBreakdown: (json['points_breakdown'] is Map<String, dynamic>)
          ? PointsBreakdown.fromJson(json['points_breakdown'])
          : PointsBreakdown.empty(),
      visaOptions: (json['visa_options'] as List<dynamic>?)
          ?.map((e) => PRCalcResultVisaOption.fromJson(e))
          .toList() ??
          [],
      message: json['message'] ?? '',
      importantNotes: (json['important_notes'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_points': totalPoints,
      'base_points': basePoints,
      'additional_points': additionalPoints,
      'points_breakdown': pointsBreakdown.toJson(),
      'visa_options': visaOptions.map((e) => e.toJson()).toList(),
      'message': message,
      'important_notes': importantNotes,
    };
  }
}

class PointsBreakdown {
  final PRCalcResultPointItem age;
  final PRCalcResultPointItem englishLanguageProficiency;
  final PRCalcResultPointItem educationalQualifications;
  final PRCalcResultPointItem skilledEmploymentOverseas;
  final PRCalcResultPointItem skilledEmploymentAustralia;
  final PRCalcResultPointItem partnerSpouseStatus;
  final AdditionalPoints additionalPoints;

  PointsBreakdown({
    required this.age,
    required this.englishLanguageProficiency,
    required this.educationalQualifications,
    required this.skilledEmploymentOverseas,
    required this.skilledEmploymentAustralia,
    required this.partnerSpouseStatus,
    required this.additionalPoints,
  });

  factory PointsBreakdown.fromJson(Map<String, dynamic> json) {
    return PointsBreakdown(
      age: (json['age'] is Map<String, dynamic>)
          ? PRCalcResultPointItem.fromJson(json['age'])
          : PRCalcResultPointItem.empty(),
      englishLanguageProficiency: (json['english_language_proficiency'] is Map<String, dynamic>)
          ? PRCalcResultPointItem.fromJson(json['english_language_proficiency'])
          : PRCalcResultPointItem.empty(),
      educationalQualifications: (json['educational_qualifications'] is Map<String, dynamic>)
          ? PRCalcResultPointItem.fromJson(json['educational_qualifications'])
          : PRCalcResultPointItem.empty(),
      skilledEmploymentOverseas: (json['skilled_employment_overseas'] is Map<String, dynamic>)
          ? PRCalcResultPointItem.fromJson(json['skilled_employment_overseas'])
          : PRCalcResultPointItem.empty(),
      skilledEmploymentAustralia: (json['skilled_employment_australia'] is Map<String, dynamic>)
          ? PRCalcResultPointItem.fromJson(json['skilled_employment_australia'])
          : PRCalcResultPointItem.empty(),
      partnerSpouseStatus: (json['partner_spouse_status'] is Map<String, dynamic>)
          ? PRCalcResultPointItem.fromJson(json['partner_spouse_status'])
          : PRCalcResultPointItem.empty(),
      additionalPoints: (json['additional_points'] is Map<String, dynamic>)
          ? AdditionalPoints.fromJson(json['additional_points'])
          : AdditionalPoints.empty(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'age': age.toJson(),
      'english_language_proficiency': englishLanguageProficiency.toJson(),
      'educational_qualifications': educationalQualifications.toJson(),
      'skilled_employment_overseas': skilledEmploymentOverseas.toJson(),
      'skilled_employment_australia': skilledEmploymentAustralia.toJson(),
      'partner_spouse_status': partnerSpouseStatus.toJson(),
      'additional_points': additionalPoints.toJson(),
    };
  }

  factory PointsBreakdown.empty() => PointsBreakdown(
    age: PRCalcResultPointItem.empty(),
    englishLanguageProficiency: PRCalcResultPointItem.empty(),
    educationalQualifications: PRCalcResultPointItem.empty(),
    skilledEmploymentOverseas: PRCalcResultPointItem.empty(),
    skilledEmploymentAustralia: PRCalcResultPointItem.empty(),
    partnerSpouseStatus: PRCalcResultPointItem.empty(),
    additionalPoints: AdditionalPoints.empty(),
  );
}

class PRCalcResultPointItem {
  final String label;
  final int points;

  PRCalcResultPointItem({required this.label, required this.points});

  factory PRCalcResultPointItem.fromJson(Map<String, dynamic> json) {
    return PRCalcResultPointItem(
      label: json['label'] ?? '',
      points: json['points'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'label': label, 'points': points};

  factory PRCalcResultPointItem.empty() => PRCalcResultPointItem(label: '', points: 0);
}

class AdditionalPoints {
  final String label;
  final int points;
  final List<int> details;

  AdditionalPoints({required this.label, required this.points, required this.details});

  factory AdditionalPoints.fromJson(Map<String, dynamic> json) {
    return AdditionalPoints(
      label: json['label'] ?? '',
      points: json['points'] ?? 0,
      details: (json['details'] as List<dynamic>?)
          ?.map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {'label': label, 'points': points, 'details': details};

  factory AdditionalPoints.empty() => AdditionalPoints(label: '', points: 0, details: []);
}

class PRCalcResultVisaOption {
  final String name;
  final String code;
  final int minimumPoints;
  final String description;
  final int? additionalPoints;
  final String? additionalPointsNote;
  final bool eligible;
  final int? pointsWithNomination;
  final bool? eligibleWithNomination;

  PRCalcResultVisaOption({
    required this.name,
    required this.code,
    required this.minimumPoints,
    required this.description,
    this.additionalPoints,
    this.additionalPointsNote,
    required this.eligible,
    this.pointsWithNomination,
    this.eligibleWithNomination,
  });

  factory PRCalcResultVisaOption.fromJson(Map<String, dynamic> json) {
    return PRCalcResultVisaOption(
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      minimumPoints: json['minimum_points'] ?? 0,
      description: json['description'] ?? '',
      additionalPoints: json['additional_points'],
      additionalPointsNote: json['additional_points_note'],
      eligible: json['eligible'] ?? false,
      pointsWithNomination: json['points_with_nomination'],
      eligibleWithNomination: json['eligible_with_nomination'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'code': code,
    'minimum_points': minimumPoints,
    'description': description,
    'additional_points': additionalPoints,
    'additional_points_note': additionalPointsNote,
    'eligible': eligible,
    'points_with_nomination': pointsWithNomination,
    'eligible_with_nomination': eligibleWithNomination,
  };
}
