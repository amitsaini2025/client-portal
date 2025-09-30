class WorkflowChecklist {
  final int id;
  final String checklistName;
  final String documentType;
  final String? description;
  final String? type;
  final String? typeName;
  final bool isMandatory;
  final String? dueDate;
  final String? dueTime;
  final String? createdAt;
  final String? updatedAt;

  WorkflowChecklist({
    required this.id,
    required this.checklistName,
    required this.documentType,
    this.description,
    this.type,
    this.typeName,
    this.isMandatory = false,
    this.dueDate,
    this.dueTime,
    this.createdAt,
    this.updatedAt,
  });

  factory WorkflowChecklist.fromJson(Map<String, dynamic> json) {
    return WorkflowChecklist(
      id: _parseInt(json['id']) ?? 0,
      checklistName: json['checklist_name'] ?? json['document_type'] ?? '',
      documentType: json['document_type'] ?? '',
      description: json['description'],
      type: json['type'],
      typeName: json['type_name'],
      isMandatory: json['is_mandatory'] ?? false,
      dueDate: json['due_date'],
      dueTime: json['due_time'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checklist_name': checklistName,
      'document_type': documentType,
      'description': description,
      'type': type,
      'type_name': typeName,
      'is_mandatory': isMandatory,
      'due_date': dueDate,
      'due_time': dueTime,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get hasDueDate => dueDate != null && dueDate!.isNotEmpty;

  DateTime? get dueDateParsed {
    if (!hasDueDate) return null;
    try {
      return DateTime.parse(dueDate!);
    } catch (e) {
      return null;
    }
  }

  bool get isOverdue {
    final date = dueDateParsed;
    if (date == null) return false;
    return date.isBefore(DateTime.now());
  }

  String get priorityLabel {
    if (isMandatory) return 'Required';
    return 'Optional';
  }

  @override
  String toString() {
    return 'WorkflowChecklist(id: $id, name: $checklistName, mandatory: $isMandatory)';
  }
}

class ApplicationInfo {
  final int applicationId;
  final int clientMatterId;
  final int clientId;
  final String currentStage;
  final int status;

  ApplicationInfo({
    required this.applicationId,
    required this.clientMatterId,
    required this.clientId,
    required this.currentStage,
    required this.status,
  });

  factory ApplicationInfo.fromJson(Map<String, dynamic> json) {
    return ApplicationInfo(
      applicationId: _parseInt(json['application_id']) ?? 0,
      clientMatterId: _parseInt(json['client_matter_id']) ?? 0,
      clientId: _parseInt(json['client_id']) ?? 0,
      currentStage: json['current_stage'] ?? '',
      status: _parseInt(json['status']) ?? 0,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'application_id': applicationId,
      'client_matter_id': clientMatterId,
      'client_id': clientId,
      'current_stage': currentStage,
      'status': status,
    };
  }
}

class WorkflowChecklistResponse {
  final ApplicationInfo applicationInfo;
  final List<WorkflowChecklist> allowedChecklists;
  final int totalAllowedChecklists;
  final int mandatoryChecklists;
  final int clientMatterId;

  WorkflowChecklistResponse({
    required this.applicationInfo,
    required this.allowedChecklists,
    required this.totalAllowedChecklists,
    required this.mandatoryChecklists,
    required this.clientMatterId,
  });

  factory WorkflowChecklistResponse.fromJson(Map<String, dynamic> json) {
    var checklistsList = <WorkflowChecklist>[];
    if (json['allowed_checklists'] != null) {
      checklistsList = (json['allowed_checklists'] as List)
          .map((checklist) => WorkflowChecklist.fromJson(checklist))
          .toList();
    }

    return WorkflowChecklistResponse(
      applicationInfo: ApplicationInfo.fromJson(json['application_info']),
      allowedChecklists: checklistsList,
      totalAllowedChecklists: _parseInt(json['total_allowed_checklists']) ?? 0,
      mandatoryChecklists: _parseInt(json['mandatory_checklists']) ?? 0,
      clientMatterId: _parseInt(json['client_matter_id']) ?? 0,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  List<WorkflowChecklist> get mandatoryChecklistsOnly =>
      allowedChecklists.where((c) => c.isMandatory).toList();

  List<WorkflowChecklist> get optionalChecklists =>
      allowedChecklists.where((c) => !c.isMandatory).toList();

  List<WorkflowChecklist> get overdueChecklists =>
      allowedChecklists.where((c) => c.isOverdue).toList();
}
