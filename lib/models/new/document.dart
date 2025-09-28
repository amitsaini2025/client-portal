class DocumentsResponse {
  bool success;
  Data data;

  DocumentsResponse({required this.success, required this.data});

  factory DocumentsResponse.fromJson(Map<String, dynamic> json) {
    return DocumentsResponse(
      success: json['success'],
      data: Data.fromJson(json['data']),
    );
  }
}

class Data {
  List<Document> documents;
  Summary summary;
  int overallProgress;
  Pagination pagination;
  Filters filters;

  Data({
    required this.documents,
    required this.summary,
    required this.overallProgress,
    required this.pagination,
    required this.filters,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      documents: (json['documents'] as List)
          .map((e) => Document.fromJson(e))
          .toList(),
      summary: Summary.fromJson(json['summary']),
      overallProgress: json['overall_progress'] ?? 0,
      pagination: Pagination.fromJson(json['pagination']),
      filters: Filters.fromJson(json['filters']),
    );
  }
}

class Document {
  int id;
  String name;
  String fileName;
  String fileType;
  String docType;
  String status;
  String originalStatus;
  String fileSize;
  String uploadedAt;
  String updatedAt;
  double uploadedDaysAgo;
  String lastUpdated;
  String fileUrl;
  String fileKey;

  Document({
    required this.id,
    required this.name,
    required this.fileName,
    required this.fileType,
    required this.docType,
    required this.status,
    required this.originalStatus,
    required this.fileSize,
    required this.uploadedAt,
    required this.updatedAt,
    required this.uploadedDaysAgo,
    required this.lastUpdated,
    required this.fileUrl,
    required this.fileKey,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      name: json['name'] ?? '',
      fileName: json['file_name'] ?? '',
      fileType: json['file_type'] ?? '',
      docType: json['doc_type'] ?? '',
      status: json['status'] ?? '',
      originalStatus: json['original_status'] ?? '',
      fileSize: json['file_size'] ?? '0',
      uploadedAt: json['uploaded_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      uploadedDaysAgo: (json['uploaded_days_ago'] ?? 0).toDouble(),
      lastUpdated: json['last_updated'] ?? '',
      fileUrl: json['file_url'] ?? '',
      fileKey: json['file_key'] ?? '',
    );
  }
}

class Summary {
  int approved;
  int pending;
  int rejected;
  int total;

  Summary({
    required this.approved,
    required this.pending,
    required this.rejected,
    required this.total,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      approved: json['approved'] ?? 0,
      pending: json['pending'] ?? 0,
      rejected: json['rejected'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class Pagination {
  int currentPage;
  int perPage;
  int totalDocuments;
  int totalPages;
  bool hasNextPage;
  bool hasPrevPage;

  Pagination({
    required this.currentPage,
    required this.perPage,
    required this.totalDocuments,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: int.tryParse(json['current_page'].toString()) ?? 1,
      perPage: int.tryParse(json['per_page'].toString()) ?? 10,
      totalDocuments: json['total_documents'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
      hasNextPage: json['has_next_page'] ?? false,
      hasPrevPage: json['has_prev_page'] ?? false,
    );
  }
}

class Filters {
  String? search;
  String? status;
  String? docType;
  String selMatterId;

  Filters({
    this.search,
    this.status,
    this.docType,
    required this.selMatterId,
  });

  factory Filters.fromJson(Map<String, dynamic> json) {
    return Filters(
      search: json['search']?.toString(),
      status: json['status']?.toString(),
      docType: json['doc_type']?.toString(),
      selMatterId: json['sel_matter_id']?.toString() ?? '',
    );
  }
}
