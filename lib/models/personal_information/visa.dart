class Visa {
  final int id;
  final String visaCountry;
  final String visaType;
  final String visaDescription;
  late final String visaExpiryDate;
  late final String visaGrantDate;

  Visa({
    required this.id,
    required this.visaCountry,
    required this.visaType,
    required this.visaDescription,
    required this.visaExpiryDate,
    required this.visaGrantDate,
  });

  factory Visa.fromJson(Map<String, dynamic> json) => Visa(
    id: json["id"],
    visaCountry: json["visa_country"],
    visaType: json["visa_type"],
    visaDescription: json["visa_description"],
    visaExpiryDate: json["visa_expiry_date"],
    visaGrantDate: json["visa_grant_date"],
  );
}
