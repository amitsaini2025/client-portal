import 'package:client/config/theme_config.dart';
import 'package:client/models/personal_information/basic_information_post/country/country_model.dart';
import 'package:client/screens/dashboard/personal_info/addresss_information/address_travel_information_widget.dart';
import 'package:client/screens/dashboard/personal_info/basic/basic_personal_information_widget.dart';
import 'package:client/screens/dashboard/personal_info/education_qualitification/education_qualification_widget.dart';
import 'package:client/screens/dashboard/personal_info/occupation_skills/occupation_skills_widget.dart';
import 'package:client/screens/dashboard/personal_info/test_score/test_score_widget.dart';
import 'package:client/screens/dashboard/personal_info/travel/travel_document_widget.dart';
import 'package:client/screens/dashboard/personal_info/work_experience/work_experience_widget.dart';
import 'package:client/services/api_service.dart';
import 'package:client/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

import '../../../models/personal_information/basic_information_post/visa_types/visa_type.dart';
import '../../../models/personal_information/client_personal_detail_response.dart';
import '../../../utils/app_loader.dart';

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
  List<VisaType> visaTypes = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
      personalDetail = null;
      countries = [];
      visaTypes = [];
    });

    ClientPersonalDetail? loadedDetail;
    List<Country> loadedCountries = [];
    List<VisaType> loadedVisaTypes = [];
    String? loadedError;

    Future<void> fetchDetail() async {
      try {
        final response = await ApiService.getClientPersonalDetail(tab: "all")
            .timeout(const Duration(seconds: 30));
        if (response["success"] == true) {
          loadedDetail = ClientPersonalDetailResponse.fromJson(response).data;
        } else {
          loadedError = response["message"]?.toString() ??
              "Failed to load personal details";
        }
      } catch (e) {
        loadedError = "Failed to load personal details: $e";
      }
    }

    Future<void> fetchCountries() async {
      try {
        final response = await ApiService.getCountries()
            .timeout(const Duration(seconds: 30));
        if (response["success"] == true) {
          loadedCountries = CountryResponse.fromJson(response).data;
        }
      } catch (_) {
      }
    }

    Future<void> fetchVisaTypes() async {
      try {
        final response = await ApiService.getVisaTypes()
            .timeout(const Duration(seconds: 30));
        if (response["success"] == true) {
          loadedVisaTypes = VisaTypeResponse.fromJson(response).data;
        }
      } catch (_) {
      }
    }

    await Future.wait([
      fetchDetail(),
      fetchCountries(),
      fetchVisaTypes(),
    ]);

    if (!mounted) return;
    setState(() {
      personalDetail = loadedDetail;
      countries = loadedCountries;
      visaTypes = loadedVisaTypes;
      errorMessage = loadedError;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewportHeight = MediaQuery.of(context).size.height -
        kToolbarHeight -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: ThemeConfig.white,
      appBar: AppBar(
        backgroundColor: ThemeConfig.goldenYellow,
        title: const Text(
          "Personal Information",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppResponsive.maxContentWidth,
              ),
              child: isLoading
                  ? SizedBox(
                height: viewportHeight,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppLoader(),
                      SizedBox(height: 16),
                      Text(
                        'Loading personal information...',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : errorMessage != null
                  ? SizedBox(
                height: viewportHeight,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: ThemeConfig.errorColor,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage!,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadAll,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeConfig.goldenYellow,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  : Padding(
                padding: AppResponsive.pagePadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BasicPersonalInformationWidget(
                      basicInfo: personalDetail!.basicInformation,
                      phones: personalDetail!.phones,
                      emails: personalDetail!.emails,
                    ),
                    const SizedBox(height: 24),
                    TravelDocumentsWidget(
                      passports: personalDetail!.passports,
                      visas: personalDetail!.visas,
                      countries: countries,
                      visaTypes: visaTypes,
                    ),
                    const SizedBox(height: 24),
                    AddressAndTravelInformationWidget(
                      addresses: personalDetail!.addresses,
                      travels: personalDetail!.travels,
                      countries: countries,
                    ),
                    const SizedBox(height: 24),
                    EducationalQualificationsWidget(
                      qualifications: personalDetail!.qualifications,
                      countries: countries,
                    ),
                    const SizedBox(height: 24),
                    WorkExperienceWidget(
                      experiences: personalDetail!.experiences,
                      countries: countries,
                    ),
                    const SizedBox(height: 24),
                    OccupationSkillsWidget(
                      occupations: personalDetail!.occupations,
                    ),
                    const SizedBox(height: 24),
                    TestScoresWidget(
                      testScores: personalDetail!.testScores,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}