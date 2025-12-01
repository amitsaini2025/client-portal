class TestScore {
  int? id;
  String testType;
  int listening;
  int reading;
  int writing;
  int speaking;
  int overallScore;
  String testDate;
  String referenceNo;
  bool relevantTest;

  TestScore({
    this.id,
    this.testType = '',
    this.listening = 0,
    this.reading = 0,
    this.writing = 0,
    this.speaking = 0,
    this.overallScore = 0,
    this.testDate = '',
    this.referenceNo = '',
    this.relevantTest = false,
  });

  factory TestScore.fromJson(Map<String, dynamic> json) => TestScore(
    id: json['id'],
    testType: json['test_type'] ?? '',
    listening: json['listening'] ?? 0,
    reading: json['reading'] ?? 0,
    writing: json['writing'] ?? 0,
    speaking: json['speaking'] ?? 0,
    overallScore: json['overall_score'] ?? 0,
    testDate: json['test_date'] ?? '',
    referenceNo: json['reference_no'] ?? '',
    relevantTest: json['relevant_test'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'test_type': testType,
    'listening': listening,
    'reading': reading,
    'writing': writing,
    'speaking': speaking,
    'overall_score': overallScore,
    'test_date': testDate,
    'reference_no': referenceNo,
    'relevant_test': relevantTest,
  };
}