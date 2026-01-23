class PostcodeSearchItem {
  final String suburb;
  final String postcode;
  final String state;

  PostcodeSearchItem({
    required this.suburb,
    required this.postcode,
    required this.state,
  });

  factory PostcodeSearchItem.fromJson(Map<String, dynamic> json) {
    return PostcodeSearchItem(
      suburb: json['suburb'],
      postcode: json['postcode'],
      state: json['state'],
    );
  }
}
