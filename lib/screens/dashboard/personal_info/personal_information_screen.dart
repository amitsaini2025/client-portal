import 'package:client/models/personal_information/basic_information_post/country/country_model.dart';
import 'package:client/screens/dashboard/personal_info/test_score/test_score_widget.dart';
import 'package:flutter/material.dart';
import 'package:client/config/theme_config.dart';
import 'package:client/services/api_service.dart';

import 'package:client/screens/dashboard/personal_info/basic/basic_personal_information_widget.dart';
import 'package:client/screens/dashboard/personal_info/travel/travel_document_widget.dart';
import 'package:client/screens/dashboard/personal_info/addresss_information/address_travel_information_widget.dart';
import 'package:client/screens/dashboard/personal_info/education_qualitification/education_qualification_widget.dart';
import 'package:client/screens/dashboard/personal_info/work_experience/work_experience_widget.dart';
import 'package:client/screens/dashboard/personal_info/occupation_skills/occupation_skills_widget.dart';

import '../../../models/personal_information/basic_information_post/visa_types/visa_type.dart';
import '../../../models/personal_information/client_personal_detail_response.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState
    extends State<PersonalInformationScreen> {
  ClientPersonalDetail? personalDetail;
  List<Country> countries = [];
  List<VisaType> visaTypes = []; // 🔥 Added for visa types

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPersonalDetails();
    _loadCountries();
    _loadVisaTypes(); // 🔥 Fetch visa types
  }

  /// Load personal details
  Future<void> _loadPersonalDetails() async {
    try {
      final response = await ApiService.getClientPersonalDetail(tab: "all");

      if (response["success"] == true) {
        final parsed = ClientPersonalDetailResponse.fromJson(response);
        setState(() {
          personalDetail = parsed.data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response["message"] ?? "Something went wrong";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  /// Load countries
  Future<void> _loadCountries() async {
    final response = await ApiService.getCountries();
    if (response["success"] == true) {
      final parsed = CountryResponse.fromJson(response);
      setState(() {
        countries = parsed.data;
      });
    } else {
      setState(() {
        errorMessage = response["message"] ?? "Something went wrong";
        isLoading = false;
      });
    }
  }

  /// Load visa types
  Future<void> _loadVisaTypes() async {
    try {
      final response = await ApiService.getVisaTypes();

      if (response["success"] == true) {
        final parsed = VisaTypeResponse.fromJson(response);
        setState(() {
          visaTypes = parsed.data;
        });
      } else {
        setState(() {
          errorMessage = response["message"] ?? "Failed to load visa types";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.navyBlue,
      appBar: AppBar(
        backgroundColor: ThemeConfig.goldenYellow,
        title: const Text("Personal Information",
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.white),
      )
          : errorMessage != null
          ? Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.white),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BasicPersonalInformationWidget(
              basicInfo: personalDetail!.basicInformation,
              phones: personalDetail!.phones,
              emails: personalDetail!.emails,
            ),
            const SizedBox(height: 20),
            TravelDocumentsWidget(
              passports: personalDetail!.passports,
              visas: personalDetail!.visas,
              countries: countries,
              visaTypes: visaTypes,
            ),
            const SizedBox(height: 20),
            AddressAndTravelInformationWidget(
              addresses: personalDetail!.addresses,
              travels: personalDetail!.travels,
              countries: countries,
            ),
            const SizedBox(height: 20),
            EducationalQualificationsWidget(
              qualifications: personalDetail!.qualifications,
              countries: countries,
            ),
            const SizedBox(height: 20),
            WorkExperienceWidget(
              experiences: personalDetail!.experiences,
              countries: countries,
            ),
            const SizedBox(height: 20),
            OccupationSkillsWidget(
              occupations: personalDetail!.occupations,
            ),
            const SizedBox(height: 20),
            TestScoresWidget(
              testScores: personalDetail!.testScores,
            ),
            const SizedBox(height: 20)
            /*ExperienceWidget(
              experiences: personalDetail!.experiences,
              countries: countries,
            ),
            const SizedBox(height: 20),*/
          ],
        ),
      ),
    );
  }
}
