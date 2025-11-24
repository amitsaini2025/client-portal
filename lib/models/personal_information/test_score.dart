class TestScore {
  final int id;
  final String testType;
  final double listening;
  final double reading;
  final double writing;
  final double speaking;
  final double overallScore;
  final String testDate;
  final String referenceNo;
  final bool relevantTest;

  TestScore({
    required this.id,
    required this.testType,
    required this.listening,
    required this.reading,
    required this.writing,
    required this.speaking,
    required this.overallScore,
    required this.testDate,
    required this.referenceNo,
    required this.relevantTest,
  });

  factory TestScore.fromJson(Map<String, dynamic> json) => TestScore(
    id: json["id"],
    testType: json["test_type"],
    listening: (json["listening"] ?? 0).toDouble(),
    reading: (json["reading"] ?? 0).toDouble(),
    writing: (json["writing"] ?? 0).toDouble(),
    speaking: (json["speaking"] ?? 0).toDouble(),
    overallScore: (json["overall_score"] ?? 0).toDouble(),
    testDate: json["test_date"],
    referenceNo: json["reference_no"],
    relevantTest: json["relevant_test"],
  );
}
