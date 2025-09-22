
/// =====================
/// MODELS / POJOS
/// =====================
class DocumentsResponse {
  final bool success;
  final DocumentsData data;

  DocumentsResponse({
    required this.success,
    required this.data,
  });

  factory DocumentsResponse.fromJson(Map<String, dynamic> json) {
    return DocumentsResponse(
      success: json['success'],
      data: DocumentsData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class DocumentsData {
  final List<Document> documents;
  final Summary summary;
  final int overallProgress;
  final Pagination pagination;
  final Filters filters;

  DocumentsData({
    required this.documents,
    required this.summary,
    required this.overallProgress,
    required this.pagination,
    required this.filters,
  });

  factory DocumentsData.fromJson(Map<String, dynamic> json) {
    return DocumentsData(
      documents: (json['documents'] as List)
          .map((e) => Document.fromJson(e))
          .toList(),
      summary: Summary.fromJson(json['summary']),
      overallProgress: json['overall_progress'],
      pagination: Pagination.fromJson(json['pagination']),
      filters: Filters.fromJson(json['filters']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documents': documents.map((e) => e.toJson()).toList(),
      'summary': summary.toJson(),
      'overall_progress': overallProgress,
      'pagination': pagination.toJson(),
      'filters': filters.toJson(),
    };
  }
}

class Document {
  final int id;
  final String name;
  final String fileName;
  final String fileType;
  final String docType;
  final String status;
  final String originalStatus;
  final String fileSize;
  final String uploadedAt;
  final String updatedAt;
  final double uploadedDaysAgo;
  final String lastUpdated;
  final String fileUrl;
  final String fileKey;

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
      name: json['name'],
      fileName: json['file_name'],
      fileType: json['file_type'],
      docType: json['doc_type'],
      status: json['status'],
      originalStatus: json['original_status'],
      fileSize: json['file_size'],
      uploadedAt: json['uploaded_at'],
      updatedAt: json['updated_at'],
      uploadedDaysAgo: (json['uploaded_days_ago'] as num).toDouble(),
      lastUpdated: json['last_updated'],
      fileUrl: json['file_url'],
      fileKey: json['file_key'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'file_name': fileName,
      'file_type': fileType,
      'doc_type': docType,
      'status': status,
      'original_status': originalStatus,
      'file_size': fileSize,
      'uploaded_at': uploadedAt,
      'updated_at': updatedAt,
      'uploaded_days_ago': uploadedDaysAgo,
      'last_updated': lastUpdated,
      'file_url': fileUrl,
      'file_key': fileKey,
    };
  }
}

class Summary {
  final int approved;
  final int pending;
  final int rejected;
  final int total;

  Summary({
    required this.approved,
    required this.pending,
    required this.rejected,
    required this.total,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      approved: json['approved'],
      pending: json['pending'],
      rejected: json['rejected'],
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'approved': approved,
      'pending': pending,
      'rejected': rejected,
      'total': total,
    };
  }
}

class Pagination {
  final int currentPage;
  final int perPage;
  final int totalDocuments;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

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
      currentPage: int.parse(json['current_page']),
      perPage: int.parse(json['per_page']),
      totalDocuments: json['total_documents'],
      totalPages: json['total_pages'],
      hasNextPage: json['has_next_page'],
      hasPrevPage: json['has_prev_page'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'per_page': perPage,
      'total_documents': totalDocuments,
      'total_pages': totalPages,
      'has_next_page': hasNextPage,
      'has_prev_page': hasPrevPage,
    };
  }
}

class Filters {
  final String? search;
  final String? status;
  final String? docType;
  final String selMatterId;

  Filters({
    this.search,
    this.status,
    this.docType,
    required this.selMatterId,
  });

  factory Filters.fromJson(Map<String, dynamic> json) {
    return Filters(
      search: json['search'],
      status: json['status'],
      docType: json['doc_type'],
      selMatterId: json['sel_matter_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'search': search,
      'status': status,
      'doc_type': docType,
      'sel_matter_id': selMatterId,
    };
  }
}