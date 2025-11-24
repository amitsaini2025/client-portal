class Passport {
  final int id;
  final String passportNumber;
  final String country;
  final String issueDate;
  final String expiryDate;

  Passport({
    required this.id,
    required this.passportNumber,
    required this.country,
    required this.issueDate,
    required this.expiryDate,
  });

  factory Passport.fromJson(Map<String, dynamic> json) => Passport(
    id: json["id"],
    passportNumber: json["passport_number"],
    country: json["country"],
    issueDate: json["issue_date"],
    expiryDate: json["expiry_date"],
  );
}
