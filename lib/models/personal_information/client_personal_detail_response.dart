import 'dart:convert';

import 'package:client/models/personal_information/passport.dart';
import 'package:client/models/personal_information/phone.dart';
import 'package:client/models/personal_information/qualification.dart';
import 'package:client/models/personal_information/test_score.dart';
import 'package:client/models/personal_information/travel.dart';
import 'package:client/models/personal_information/visa.dart';

import 'address.dart';
import 'basic_information.dart';
import 'email.dart';
import 'experience.dart';
import 'occupation.dart';

ClientPersonalDetailResponse clientPersonalDetailResponseFromJson(String str) =>
    ClientPersonalDetailResponse.fromJson(json.decode(str));

class ClientPersonalDetailResponse {
  final bool success;
  final String message;
  final ClientPersonalDetail data;

  ClientPersonalDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ClientPersonalDetailResponse.fromJson(Map<String, dynamic> json) =>
      ClientPersonalDetailResponse(
        success: json["success"] ?? false,
        message: json["message"] ?? '',
        data: ClientPersonalDetail.fromJson(json["data"] ?? {}),
      );
}

class ClientPersonalDetail {
  final BasicInformation? basicInformation;
  final List<Phone> phones;
  final List<Email> emails;
  final List<Passport> passports;
  final List<Visa> visas;
  final List<Address> addresses;
  final List<Travel> travels;
  final List<Qualification> qualifications;
  final List<Experience> experiences;
  final List<Occupation> occupations;
  final List<TestScore> testScores;

  ClientPersonalDetail({
    this.basicInformation,
    required this.phones,
    required this.emails,
    required this.passports,
    required this.visas,
    required this.addresses,
    required this.travels,
    required this.qualifications,
    required this.experiences,
    required this.occupations,
    required this.testScores,
  });

  factory ClientPersonalDetail.fromJson(Map<String, dynamic> json) =>
      ClientPersonalDetail(
        basicInformation: json["basic_information"] != null
            ? BasicInformation.fromJson(json["basic_information"])
            : null,
        phones: (json["phones"] as List<dynamic>? ?? [])
            .map((e) => Phone.fromJson(e))
            .toList(),
        emails: (json["emails"] as List<dynamic>? ?? [])
            .map((e) => Email.fromJson(e))
            .toList(),
        passports: (json["passports"] as List<dynamic>? ?? [])
            .map((e) => Passport.fromJson(e))
            .toList(),
        visas: (json["visas"] as List<dynamic>? ?? [])
            .map((e) => Visa.fromJson(e))
            .toList(),
        addresses: (json["addresses"] as List<dynamic>? ?? [])
            .map((e) => Address.fromJson(e))
            .toList(),
        travels: (json["travels"] as List<dynamic>? ?? [])
            .map((e) => Travel.fromJson(e))
            .toList(),
        qualifications: (json["qualifications"] as List<dynamic>? ?? [])
            .map((e) => Qualification.fromJson(e))
            .toList(),
        experiences: (json["experiences"] as List<dynamic>? ?? [])
            .map((e) => Experience.fromJson(e))
            .toList(),
        occupations: (json["occupations"] as List<dynamic>? ?? [])
            .map((e) => Occupation.fromJson(e))
            .toList(),
        testScores: (json["test_scores"] as List<dynamic>? ?? [])
            .map((e) => TestScore.fromJson(e))
            .toList(),
      );
}
