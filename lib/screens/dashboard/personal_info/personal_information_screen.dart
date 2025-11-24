import 'package:flutter/material.dart';
import 'package:client/config/theme_config.dart';
import 'package:client/services/api_service.dart';

import 'package:client/screens/dashboard/personal_info/basic/basic_personal_information_widget.dart';
import 'package:client/screens/dashboard/personal_info/travel/travel_document_widget.dart';
import 'package:client/screens/dashboard/personal_info/addresss_information/address_travel_information_widget.dart';
import 'package:client/screens/dashboard/personal_info/education_qualitification/education_qualification_widget.dart';
import 'package:client/screens/dashboard/personal_info/work_experience/work_experience_widget.dart';
import 'package:client/screens/dashboard/personal_info/occupation_skills/occupation_skills_widget.dart';
import 'package:client/screens/dashboard/personal_info/experience/experience_widget.dart';

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
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPersonalDetails();
  }

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
            ),
            const SizedBox(height: 20),
            AddressAndTravelInformationWidget(
              addresses: personalDetail!.addresses,
              travels: personalDetail!.travels,
            ),
            const SizedBox(height: 20),
            EducationalQualificationsWidget(
              qualifications: personalDetail!.qualifications,
            ),
            const SizedBox(height: 20),
            WorkExperienceWidget(
              experiences: personalDetail!.experiences,
            ),
            const SizedBox(height: 20),
            OccupationSkillsWidget(
              occupations: personalDetail!.occupations,
            ),
            const SizedBox(height: 20),
            ExperienceWidget(
              experiences: personalDetail!.experiences,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
