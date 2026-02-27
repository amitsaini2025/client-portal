class VisaModel {
  final String id;
  final String label;
  final String subclass;
  final String? stream;

  VisaModel({
    required this.id,
    required this.label,
    required this.subclass,
    this.stream,
  });

  factory VisaModel.fromJson(Map<String, dynamic> json) {
    return VisaModel(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      subclass: json['subclass'] ?? '',
      stream: json['stream'],
    );
  }
}