class AllowedChecklist {
  final int id;
  final String checklistName;
  final String documentType;
  final String description;
  final String type;
  final String typeName;
  final bool isMandatory;
  final String dueDate;
  final String dueTime;

  AllowedChecklist({
    required this.id,
    required this.checklistName,
    required this.documentType,
    required this.description,
    required this.type,
    required this.typeName,
    required this.isMandatory,
    required this.dueDate,
    required this.dueTime,
  });

  factory AllowedChecklist.fromJson(Map<String, dynamic> json) {
    return AllowedChecklist(
      id: json['id'],
      checklistName: json['checklist_name'] ?? '',
      documentType: json['document_type'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      typeName: json['type_name'] ?? '',
      isMandatory: json['is_mandatory'] ?? false,
      dueDate: json['due_date'] ?? '',
      dueTime: json['due_time'] ?? '',
    );
  }
}
