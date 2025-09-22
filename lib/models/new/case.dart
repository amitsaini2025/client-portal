class Case {
  final int id;
  final String title;
  final String? caseNumber;
  final String status;
  final String? stageName;
  final int? progressPercentage;
  final String? progressDisplay;
  final bool? isFileClosed;
  final Agent? migrationAgent;
  final Agent? personResponsible;
  final Agent? personAssisting;
  final String? createdAt;
  final String? updatedAt;
  final String? lastUpdated;

  Case({
    required this.id,
    required this.title,
    this.caseNumber,
    required this.status,
    this.stageName,
    this.progressPercentage,
    this.progressDisplay,
    this.isFileClosed,
    this.migrationAgent,
    this.personResponsible,
    this.personAssisting,
    this.createdAt,
    this.updatedAt,
    this.lastUpdated,
  });

  /// Dynamic agents map for easier UI iteration
  Map<String, Agent> get agentsMap {
    final map = <String, Agent>{};
    if (migrationAgent != null) map['Migration Agent'] = migrationAgent!;
    if (personResponsible != null) map['Responsible'] = personResponsible!;
    if (personAssisting != null) map['Assisting'] = personAssisting!;
    return map;
  }

  factory Case.fromJson(Map<String, dynamic> json) {
    final agents = json['agents'] ?? {};
    return Case(
      id: json['id'],
      title: json['title'] ?? 'Untitled',
      caseNumber: json['case_number'],
      status: json['status'] ?? '',
      stageName: json['stage_name'],
      progressPercentage: json['progress_percentage'],
      progressDisplay: json['progress_display'],
      isFileClosed: json['is_file_closed'],
      migrationAgent: agents['migration_agent'] != null
          ? Agent.fromJson(agents['migration_agent'])
          : null,
      personResponsible: agents['person_responsible'] != null
          ? Agent.fromJson(agents['person_responsible'])
          : null,
      personAssisting: agents['person_assisting'] != null
          ? Agent.fromJson(agents['person_assisting'])
          : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      lastUpdated: json['last_updated'],
    );
  }
}

class Agent {
  final int id;
  final String name;

  Agent({required this.id, required this.name});

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id'],
      name: json['name'],
    );
  }
}
