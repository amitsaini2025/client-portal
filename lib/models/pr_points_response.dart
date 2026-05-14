
class PRPointsResponse {
  final bool success;
  final PRData data;

  PRPointsResponse({required this.success, required this.data});

  factory PRPointsResponse.fromJson(Map<String, dynamic> json) {
    return PRPointsResponse(
      success: json['success'] ?? false,
      data: PRData.fromJson(json['data'] ?? {}),
    );
  }
}

class PRData {
  final List<PointItem> age;
  final List<PointItem> englishLanguage;
  final List<PointItem> education;
  final List<PointItem> overseasExp;
  final List<PointItem> australiaExp;
  final List<AdditionalPointItem> additionalPoints;
  final List<PointItem> partnerStatus;
  final List<VisaOption> visaOptions;
  final List<String> importantNotes;

  PRData({
    required this.age,
    required this.englishLanguage,
    required this.education,
    required this.overseasExp,
    required this.australiaExp,
    required this.additionalPoints,
    required this.partnerStatus,
    required this.visaOptions,
    required this.importantNotes,
  });

  factory PRData.fromJson(Map<String, dynamic> json) {
    return PRData(
      age: _parsePointList(json['age']),
      englishLanguage:
      _parsePointList(json['english_language_proficiency']),
      education:
      _parsePointList(json['educational_qualifications']),
      overseasExp:
      _parsePointList(json['skilled_employment_overseas']),
      australiaExp:
      _parsePointList(json['skilled_employment_australia']),
      additionalPoints: (json['additional_points'] as List? ?? [])
          .map((e) => AdditionalPointItem.fromJson(e))
          .toList(),
      partnerStatus:
      _parsePointList(json['partner_spouse_status']),
      visaOptions: (json['visa_options'] as List? ?? [])
          .map((e) => VisaOption.fromJson(e))
          .toList(),
      importantNotes: (json['important_notes'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  static List<PointItem> _parsePointList(List? list) {
    return (list ?? []).map((e) => PointItem.fromJson(e)).toList();
  }
}

class PointItem {
  final String label;
  final int value;

  PointItem({required this.label, required this.value});

  factory PointItem.fromJson(Map<String, dynamic> json) {
    return PointItem(
      label: json['label'] ?? '',
      value: (json['value'] as num).toInt(),
    );
  }
}

class AdditionalPointItem extends PointItem {
  final String? description;
  final String? note;

  AdditionalPointItem({
    required super.label,
    required super.value,
    this.description,
    this.note,
  });

  factory AdditionalPointItem.fromJson(Map<String, dynamic> json) {
    return AdditionalPointItem(
      label: json['label'] ?? '',
      value: (json['value'] as num).toInt(),
      description: json['description'],
      note: json['note'],
    );
  }
}

class VisaOption {
  final String name;
  final String code;
  final int minimumPoints;
  final String description;
  final int? additionalPoints;
  final String? additionalPointsNote;

  VisaOption({
    required this.name,
    required this.code,
    required this.minimumPoints,
    required this.description,
    this.additionalPoints,
    this.additionalPointsNote,
  });

  factory VisaOption.fromJson(Map<String, dynamic> json) {
    return VisaOption(
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      minimumPoints: (json['minimum_points'] as num).toInt(),
      description: json['description'] ?? '',
      additionalPoints: json['additional_points'] != null
          ? (json['additional_points'] as num).toInt()
          : null,
      additionalPointsNote: json['additional_points_note'],
    );
  }
}
