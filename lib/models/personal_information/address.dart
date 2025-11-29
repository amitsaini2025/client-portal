class Address {
  int? id;
  String searchAddress;
  String? addressLine1;
  String? addressLine2;
  String suburb;
  String state;
  int postcode;
  String country;
  String? regionalCode;
  String? startDate; // Format: "dd/MM/yyyy"
  String? endDate;   // Format: "dd/MM/yyyy"
  bool isCurrent;

  Address({
    this.id,
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

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] != null ? json['id'] as int : null,
      searchAddress: json['search_address'] as String,
      addressLine1: json['address_line_1'] as String?,
      addressLine2: json['address_line_2'] as String?,
      suburb: json['suburb'] as String,
      state: json['state'] as String,
      postcode: json['postcode'] is int
          ? json['postcode'] as int
          : int.tryParse(json['postcode'].toString()) ?? 0,
      country: json['country'] as String,
      regionalCode: json['regional_code'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      isCurrent: json['is_current'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'search_address': searchAddress,
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'suburb': suburb,
      'state': state,
      'postcode': postcode.toString(),
      'country': country,
      'regional_code': regionalCode,
      'start_date': startDate,
      'end_date': endDate,
      'is_current': isCurrent,
    };
  }
}
