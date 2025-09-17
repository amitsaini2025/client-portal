class CaseSummary {
  final int activeCases;
  final int completedCases;
  final int totalCases;

  CaseSummary({
    required this.activeCases,
    required this.completedCases,
    required this.totalCases,
  });

  factory CaseSummary.fromJson(Map<String, dynamic> json) {
    return CaseSummary(
      activeCases: json['active_cases'] ?? 0,
      completedCases: json['completed_cases'] ?? 0,
      totalCases: json['total_cases'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active_cases': activeCases,
      'completed_cases': completedCases,
      'total_cases': totalCases,
    };
  }
}
