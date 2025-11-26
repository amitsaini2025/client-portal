class Address {
  final int id;
  final String searchAddress;
  final String? addressLine1;
  final String? addressLine2;
  final String suburb;
  final String state;
  final int postcode;
  final String country;
  final String? regionalCode;
  late final String? startDate;
  late final String? endDate;
  final bool isCurrent;

  Address({
    required this.id,
    required this.searchAddress,
    this.addressLine1,
    this.addressLine2,
    required this.suburb,
    required this.state,
    required this.postcode,
    required this.country,
    this.regionalCode,
    this.startDate,
    this.endDate,
    required this.isCurrent,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json["id"] ?? 0,
    searchAddress: json["search_address"]?.toString() ?? "",
    addressLine1: json["address_line_1"]?.toString(),
    addressLine2: json["address_line_2"]?.toString(),
    suburb: json["suburb"]?.toString() ?? "",
    state: json["state"]?.toString() ?? "",
    postcode: json["postcode"] ?? 0, // int
    country: json["country"]?.toString() ?? "",
    regionalCode: json["regional_code"]?.toString(),
    startDate: json["start_date"]?.toString(),
    endDate: json["end_date"]?.toString(),
    isCurrent: json["is_current"] ?? false,
  );
}
