import 'package:client/screens/dashboard/personal_info/addresss_information/address_travel_information_widget.dart';
import 'package:client/screens/dashboard/personal_info/basic/basic_personal_information_widget.dart';
import 'package:client/screens/dashboard/personal_info/education_qualitification/education_qualification_widget.dart';
import 'package:client/screens/dashboard/personal_info/experience/experience_widget.dart';
import 'package:client/screens/dashboard/personal_info/occupation_skills/occupation_skills_widget.dart';
import 'package:client/screens/dashboard/personal_info/travel/travel_document_widget.dart';
import 'package:client/screens/dashboard/personal_info/work_experience/work_experience_widget.dart';
import 'package:flutter/material.dart';
import 'package:client/config/theme_config.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState
    extends State<PersonalInformationScreen> {

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            BasicPersonalInformationWidget(),
            const SizedBox(height: 20),
            TravelDocumentsWidget(),
            const SizedBox(height: 20),
            AddressAndTravelInformationWidget(),
            const SizedBox(height: 20),
            EducationalQualificationsWidget(),
            const SizedBox(height: 20),
            WorkExperienceWidget(),
            const SizedBox(height: 20),
            OccupationSkillsWidget(),
            const SizedBox(height: 20),
            ExperienceWidget(),
            const SizedBox(height: 20),
            /*const SizedBox(height: 24),
            _buildSubmitButton(),
            const SizedBox(height: 20),*/
          ],
        ),
      ),
    );
  }
}
