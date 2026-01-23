class PostcodeResult {
  final String postcode;
  final String area;
  final String state;
  final String regionalStatus;
  final String category;
  final bool isRegional;

  PostcodeResult({
    required this.postcode,
    required this.area,
    required this.state,
    required this.regionalStatus,
    required this.category,
    required this.isRegional,
  });

  factory PostcodeResult.fromJson(Map<String, dynamic> json) {
    return PostcodeResult(
      postcode: json['postcode'],
      area: json['area'],
      state: json['state'],
      regionalStatus: json['regional_status'],
      category: json['category'],
      isRegional: json['is_regional'],
    );
  }
}
