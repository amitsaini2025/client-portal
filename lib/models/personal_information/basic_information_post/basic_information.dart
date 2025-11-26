class BasicInformation {
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? clientId;
  final String? dateOfBirth;
  final String? age;
  final String? gender;
  final String? maritalStatus;

  BasicInformation({
    this.firstName,
    this.lastName,
    this.fullName,
    this.clientId,
    this.dateOfBirth,
    this.age,
    this.gender,
    this.maritalStatus,
  });

  factory BasicInformation.fromJson(Map<String, dynamic> json) {
    return BasicInformation(
      firstName: json["first_name"],
      lastName: json["last_name"],
      fullName: json["full_name"],
      clientId: json["client_id"],
      dateOfBirth: json["dob"], // comes as YYYY-MM-DD
      age: json["age"],
      gender: json["gender"],
      maritalStatus: json["marital_status"],
    );
  }
}
