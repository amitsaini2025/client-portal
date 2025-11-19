class ChecklistItem {
  final int id;
  final String name;

  ChecklistItem({required this.id, required this.name});

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class WorkflowStage {
  final int id;
  final String name;
  final String stageName;
  final bool isActive;
  final bool isCurrentStage;
  final String? createdAt;
  final String? updatedAt;
  final int allowedChecklistCount;
  final List<ChecklistItem> allowedChecklist;

  WorkflowStage({
    required this.id,
    required this.name,
    required this.stageName,
    this.isActive = false,
    this.isCurrentStage = false,
    this.createdAt,
    this.updatedAt,
    this.allowedChecklistCount = 0,
    this.allowedChecklist = const [],
  });

  factory WorkflowStage.fromJson(Map<String, dynamic> json) {
    var checklist = <ChecklistItem>[];
    if (json['allowed_checklist'] != null) {
      checklist = (json['allowed_checklist'] as List)
          .map((item) => ChecklistItem.fromJson(item))
          .toList();
    }

    return WorkflowStage(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] ?? '',
      stageName: json['stage_name'] ?? json['name'] ?? '',
      isActive: json['is_active'] ?? false,
      isCurrentStage: json['is_current_stage'] ?? false,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      allowedChecklistCount: json['allowed_checklist_count'] ?? 0,
      allowedChecklist: checklist,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stage_name': stageName,
      'is_active': isActive,
      'is_current_stage': isCurrentStage,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'allowed_checklist_count': allowedChecklistCount,
      'allowed_checklist': allowedChecklist.map((e) => e.toJson()).toList(),
    };
  }

  String get statusText {
    if (isCurrentStage || isActive) return 'Current';
    return 'Upcoming';
  }

  @override
  String toString() {
    return 'WorkflowStage(id: $id, name: $name, isActive: $isActive)';
  }
}


class ActiveStageInfo {
  final int id;
  final String name;
  final String stageName;
  final String? clientMatterNo;
  final int? matterStatus;
  final String? stageUpdatedAt;
  final bool isActive;

  ActiveStageInfo({
    required this.id,
    required this.name,
    required this.stageName,
    this.clientMatterNo,
    this.matterStatus,
    this.stageUpdatedAt,
    this.isActive = true,
  });

  factory ActiveStageInfo.fromJson(Map<String, dynamic> json) {
    return ActiveStageInfo(
      id: _parseInt(json['id']) ?? 0,
      name: json['name'] ?? '',
      stageName: json['stage_name'] ?? json['name'] ?? '',
      clientMatterNo: json['client_matter_no'],
      matterStatus: _parseInt(json['matter_status']),
      stageUpdatedAt: json['stage_updated_at'],
      isActive: json['is_active'] ?? true,
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
      'name': name,
      'stage_name': stageName,
      'client_matter_no': clientMatterNo,
      'matter_status': matterStatus,
      'stage_updated_at': stageUpdatedAt,
      'is_active': isActive,
    };
  }
}

class WorkflowStagesResponse {
  final List<WorkflowStage> workflowStages;
  final int totalStages;
  final ActiveStageInfo? activeStage;
  final bool hasActiveStage;
  final int clientId;
  final int? clientMatterId;

  WorkflowStagesResponse({
    required this.workflowStages,
    required this.totalStages,
    this.activeStage,
    required this.hasActiveStage,
    required this.clientId,
    this.clientMatterId,
  });

  factory WorkflowStagesResponse.fromJson(Map<String, dynamic> json) {
    var stagesList = <WorkflowStage>[];
    if (json['workflow_stages'] != null) {
      stagesList = (json['workflow_stages'] as List)
          .map((stage) => WorkflowStage.fromJson(stage))
          .toList();
    }

    ActiveStageInfo? activeStageInfo;
    if (json['active_stage'] != null) {
      activeStageInfo = ActiveStageInfo.fromJson(json['active_stage']);
    }

    return WorkflowStagesResponse(
      workflowStages: stagesList,
      totalStages: _parseInt(json['total_stages']) ?? 0,
      activeStage: activeStageInfo,
      hasActiveStage: json['has_active_stage'] ?? false,
      clientId: _parseInt(json['client_id']) ?? 0,
      clientMatterId: _parseInt(json['client_matter_id']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  int get currentStageIndex {
    if (!hasActiveStage || activeStage == null) return -1;
    return workflowStages.indexWhere((stage) => stage.id == activeStage!.id);
  }

  int get progressPercentage {
    if (totalStages == 0 || currentStageIndex < 0) return 0;
    return ((currentStageIndex / totalStages) * 100).round();
  }

  int get completedStages {
    if (currentStageIndex < 0) return 0;
    return currentStageIndex;
  }

  int get remainingStages {
    if (currentStageIndex < 0) return totalStages;
    return totalStages - currentStageIndex - 1;
  }
}
