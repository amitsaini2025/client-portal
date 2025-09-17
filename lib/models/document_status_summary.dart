class DocumentStatusSummary {
  final int approved;
  final int pending;
  final int rejected;

  DocumentStatusSummary({
    required this.approved,
    required this.pending,
    required this.rejected,
  });

  factory DocumentStatusSummary.fromJson(Map<String, dynamic> json) {
    return DocumentStatusSummary(
      approved: json['approved'] ?? 0,
      pending: json['pending'] ?? 0,
      rejected: json['rejected'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'approved': approved,
      'pending': pending,
      'rejected': rejected,
    };
  }
}
