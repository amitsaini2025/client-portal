class WorkflowChecklist {
  final int id;
  final String checklistName;
  final String documentType;
  final String? description;
  final String? type;
  final int? typeId;
  final String? typeName;
  final bool isMandatory;
  final String? dueDate;
  final String? dueTime;
  final bool isUpload;
  final String? fileName;
  final String? fileUrl;
  final int? docStatusId;
  final String? docStatusText;
  final String? docRejectionReason;
  final String? createdAt;
  final String? updatedAt;

  WorkflowChecklist({
    required this.id,
    required this.checklistName,
    required this.documentType,
    this.description,
    this.type,
    this.typeId,
    this.typeName,
    this.isMandatory = false,
    this.dueDate,
    this.dueTime,
    this.isUpload = false,
    this.fileName,
    this.fileUrl,
    this.docStatusId,
    this.docStatusText,
    this.docRejectionReason,
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
      typeId: _parseInt(json['type_id']),
      typeName: json['type_name'],
      isMandatory: json['is_mandatory'] ?? false,
      dueDate: json['due_date'],
      dueTime: json['due_time'],
      isUpload: json['is_upload'] ?? false,
      fileName: json['file_name'],
      fileUrl: json['file_url'],
      docStatusId: _parseInt(json['doc_status_id']),
      docStatusText: json['doc_status_text'],
      docRejectionReason: json['doc_rejection_reason'],
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'checklist_name': checklistName,
    'document_type': documentType,
    'description': description,
    'type': type,
    'type_id': typeId,
    'type_name': typeName,
    'is_mandatory': isMandatory,
    'due_date': dueDate,
    'due_time': dueTime,
    'is_upload': isUpload,
    'file_name': fileName,
    'file_url': fileUrl,
    'doc_status_id': docStatusId,
    'doc_status_text': docStatusText,
    'doc_rejection_reason': docRejectionReason,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  bool get hasDueDate => dueDate != null && dueDate!.isNotEmpty;

  DateTime? get dueDateParsed {
    if (!hasDueDate) return null;
    try {
      return DateTime.parse(dueDate!);
    } catch (_) {
      return null;
    }
  }

  bool get isOverdue {
    final date = dueDateParsed;
    if (date == null) return false;
    return date.isBefore(DateTime.now());
  }

  String get priorityLabel => isMandatory ? 'Required' : 'Optional';

  @override
  String toString() =>
      'WorkflowChecklist(id: $id, name: $checklistName, mandatory: $isMandatory, upload: $isUpload, docStatusId: $docStatusId)';
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

  Map<String, dynamic> toJson() => {
    'application_id': applicationId,
    'client_matter_id': clientMatterId,
    'client_id': clientId,
    'current_stage': currentStage,
    'status': status,
  };
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
    final data = json['data'] ?? {};

    var checklistsList = <WorkflowChecklist>[];
    if (data['allowed_checklists'] != null) {
      checklistsList = (data['allowed_checklists'] as List)
          .map((c) => WorkflowChecklist.fromJson(c))
          .toList();
    }

    return WorkflowChecklistResponse(
      applicationInfo:
      ApplicationInfo.fromJson(data['matter_info'] ?? {}),
      allowedChecklists: checklistsList,
      totalAllowedChecklists:
      _parseInt(data['total_allowed_checklists']) ?? 0,
      mandatoryChecklists: _parseInt(data['mandatory_checklists']) ?? 0,
      clientMatterId: _parseInt(data['client_matter_id']) ?? 0,
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