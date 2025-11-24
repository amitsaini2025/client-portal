class Travel {
  final int id;
  final String countryVisited;
  final String arrivalDate;
  final String departureDate;
  final String purpose;

  Travel({
    required this.id,
    required this.countryVisited,
    required this.arrivalDate,
    required this.departureDate,
    required this.purpose,
  });

  factory Travel.fromJson(Map<String, dynamic> json) => Travel(
    id: json["id"],
    countryVisited: json["country_visited"],
    arrivalDate: json["arrival_date"],
    departureDate: json["departure_date"],
    purpose: json["purpose"],
  );
}
