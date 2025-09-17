class UpcomingDeadlineSummary {
  final int dueThisWeekCount;
  final int appointmentsCount;
  final int overdueCount;

  UpcomingDeadlineSummary({
    required this.dueThisWeekCount,
    required this.appointmentsCount,
    required this.overdueCount,
  });

  factory UpcomingDeadlineSummary.fromJson(Map<String, dynamic> json) {
    return UpcomingDeadlineSummary(
      dueThisWeekCount: json['due_this_week_count'] ?? 0,
      appointmentsCount: json['appointments_count'] ?? 0,
      overdueCount: json['overdue_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'due_this_week_count': dueThisWeekCount,
      'appointments_count': appointmentsCount,
      'overdue_count': overdueCount,
    };
  }
}
