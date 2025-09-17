class CaseItem {
  final int id;
  final String title;
  final String caseNumber;
  final String status;
  final String stageName;
  final String createdAt;
  final String updatedAt;
  final String lastUpdated;

  CaseItem({
    required this.id,
    required this.title,
    required this.caseNumber,
    required this.status,
    required this.stageName,
    required this.createdAt,
    required this.updatedAt,
    required this.lastUpdated,
  });

  factory CaseItem.fromJson(Map<String, dynamic> json) {
    return CaseItem(
      id: json['id'],
      title: json['title'],
      caseNumber: json['case_number'],
      status: json['status'],
      stageName: json['stage_name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      lastUpdated: json['last_updated'],
    );
  }
}

class Pagination {
  final int currentPage;
  final int perPage;
  final int totalCases;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  Pagination({
    required this.currentPage,
    required this.perPage,
    required this.totalCases,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: int.parse(json['current_page'].toString()),
      perPage: int.parse(json['per_page'].toString()),
      totalCases: int.parse(json['total_cases'].toString()),
      totalPages: int.parse(json['total_pages'].toString()),
      hasNextPage: json['has_next_page'] ?? false,
      hasPrevPage: json['has_prev_page'] ?? false,
    );
  }
}

class CasesResponse {
  final List<CaseItem> cases;
  final Pagination pagination;

  CasesResponse({required this.cases, required this.pagination});

  factory CasesResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = json['data']['cases'] ?? [];
    final List<CaseItem> parsedCases =
    list.map((e) => CaseItem.fromJson(e)).toList();

    return CasesResponse(
      cases: parsedCases,
      pagination: Pagination.fromJson(json['data']['pagination']),
    );
  }
}
