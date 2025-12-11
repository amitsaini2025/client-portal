class Phone {
  int id;
  String phone;
  String type;
  bool isPrimary;
  String countryCode;
  String? extension;

  Phone({
    required this.id,
    required this.phone,
    required this.type,
    required this.isPrimary,
    required this.countryCode,
    this.extension,
  });

  // Factory constructor to create Phone from JSON
  factory Phone.fromJson(Map<String, dynamic> json) {
    return Phone(
      id: json["id"] ?? 0,
      phone: json["phone"] ?? "",
      type: json["type"] ?? "",
      isPrimary: json["is_primary"] ?? false,
      countryCode: json["country_code"] ?? "",
      extension: json["extension"], // nullable field
    );
  }

  // Convert Phone object to JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "phone": phone,
      "type": type,
      "is_primary": isPrimary,
      "country_code": countryCode,
      "extension": extension,
    };
  }
}
