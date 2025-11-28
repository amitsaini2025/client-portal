class Email {
  final int? id;
  final String email;
  final String type;
  final bool? isPrimary;

  Email({
    this.id,
    required this.email,
    required this.type,
    this.isPrimary,
  });

  factory Email.fromJson(Map<String, dynamic> json) => Email(
    id: json["id"],
    email: json["email"],
    type: json["type"],
    isPrimary: json["is_primary"],
  );
}
