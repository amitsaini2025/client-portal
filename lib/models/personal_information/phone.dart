class Phone {
  final int id;
  final String phone;
  final String type;
  final bool isPrimary;
  final String countryCode;
  final String? extension;

  Phone({
    required this.id,
    required this.phone,
    required this.type,
    required this.isPrimary,
    required this.countryCode,
    this.extension,
  });

  factory Phone.fromJson(Map<String, dynamic> json) => Phone(
    id: json["id"],
    phone: json["phone"],
    type: json["type"],
    isPrimary: json["is_primary"],
    countryCode: json["country_code"],
    extension: json["extension"],
  );
}
