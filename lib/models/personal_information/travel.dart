class Travel {
  int id;
  String countryVisited;
  String arrivalDate;
  String departureDate;
  String purpose;

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

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "country_visited": countryVisited,
      "arrival_date": arrivalDate,
      "departure_date": departureDate,
      "purpose": purpose,
    };
  }
}
