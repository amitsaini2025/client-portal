class DashboardSummary {
  final int activeCases;
  final int totalDocuments;
  final int totalAppointments;

  DashboardSummary({
    required this.activeCases,
    required this.totalDocuments,
    required this.totalAppointments,
  });

  // From JSON
  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      activeCases: json['active_cases'] ?? 0,
      totalDocuments: json['total_documents'] ?? 0,
      totalAppointments: json['total_appointments'] ?? 0,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'active_cases': activeCases,
      'total_documents': totalDocuments,
      'total_appointments': totalAppointments,
    };
  }
}
