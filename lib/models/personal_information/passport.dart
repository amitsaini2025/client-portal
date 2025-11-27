class Passport {
  int? id;
  String? passportNumber;
  String? country;
  String? issueDate;
  String? expiryDate;

  Passport({
    this.id,
    this.passportNumber,
    this.country,
    this.issueDate,
    this.expiryDate,
  });

  factory Passport.fromJson(Map<String, dynamic> json) => Passport(
    id: json["id"],                                           // may be null
    passportNumber: json["passport_number"] ?? "",            // safe default
    country: json["country"] ?? "",
    issueDate: json["issue_date"],                            // allow null
    expiryDate: json["expiry_date"],
  );
}
