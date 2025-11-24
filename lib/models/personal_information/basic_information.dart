class BasicInformation {
  final String? firstName;
  final String? lastName;
  final String? name;
  final String? fullName;
  final String? clientId;
  final int? internalClientId;
  final String? dateOfBirth;
  final String? age;
  final String? gender;
  final String? maritalStatus;

  BasicInformation({
    this.firstName,
    this.lastName,
    this.name,
    this.fullName,
    this.clientId,
    this.internalClientId,
    this.dateOfBirth,
    this.age,
    this.gender,
    this.maritalStatus,
  });

  factory BasicInformation.fromJson(Map<String, dynamic> json) => BasicInformation(
    firstName: json["first_name"]?.toString(),
    lastName: json["last_name"]?.toString(),
    name: json["name"]?.toString(),
    fullName: json["full_name"]?.toString(),
    clientId: json["client_id"]?.toString(),
    internalClientId: json["internal_client_id"] is int
        ? json["internal_client_id"]
        : int.tryParse(json["internal_client_id"]?.toString() ?? ''),
    dateOfBirth: json["date_of_birth"]?.toString(),
    age: json["age"]?.toString(),
    gender: json["gender"]?.toString(),
    maritalStatus: json["marital_status"]?.toString(),
  );
}
