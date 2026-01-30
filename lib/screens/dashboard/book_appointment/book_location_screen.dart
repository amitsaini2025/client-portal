import 'package:client/screens/dashboard/appointment_list/appointment_list.dart';
import 'package:client/services/api_service.dart';
import 'package:flutter/material.dart';

import '../../../models/appointment/appointment_variable_list.dart';
import 'book_service_screen.dart';
import 'booking_widget.dart';

class BookLocationScreen extends StatefulWidget {
  const BookLocationScreen({super.key});

  @override
  State<BookLocationScreen> createState() => _BookLocationScreenState();
}

class _BookLocationScreenState extends State<BookLocationScreen> {
  bool isLoading = true;

  List<LocationModel> locations = [];
  List<MeetingTypeModel> meetingTypes = [];
  List<LanguageModel> languages = [];
  List<ServiceTypeModel> services = [];
  List<SimpleServiceModel> serviceCategories = [];

  LocationModel? selectedLocation;
  MeetingTypeModel? selectedMeeting;
  LanguageModel? selectedLanguage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final response = await ApiService.getAppointmentVariableLists();
      final data = response['data'];

      setState(() {
        locations =
            (data['location'] as List)
                .map((e) => LocationModel.fromJson(e))
                .toList();

        meetingTypes =
            (data['meeting_type'] as List)
                .map((e) => MeetingTypeModel.fromJson(e))
                .toList();

        languages =
            (data['preferred_language'] as List)
                .map((e) => LanguageModel.fromJson(e))
                .toList();

        services =
            (data['service_type'] as List)
                .map((e) => ServiceTypeModel.fromJson(e))
                .toList();

        serviceCategories =
            (data['select_your_service'] as List)
                .map((e) => SimpleServiceModel.fromJson(e))
                .toList();

        selectedLocation = locations.first;
        selectedMeeting = meetingTypes.first;
        selectedLanguage = languages.first;

        isLoading = false;
      });
    } catch (e) {
      debugPrint("API Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      title: 'Choose Your Preferred Location',
      activeStep: 1,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AppointmentListScreen()),
            );
          },
          child: const Text(
            'See All',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ],
      child:
          isLoading
              ? SizedBox(
                height: MediaQuery.of(context).size.height / 2,
                child: const Center(child: CircularProgressIndicator()),
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Office Location',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children:
                        locations
                            .map(
                              (location) => _cardWidth(
                                context,
                                SelectionCard(
                                  title: location.name,
                                  subtitle: location.fullAddress,
                                  isSelected:
                                      selectedLocation?.id == location.id,
                                  onTap:
                                      () => setState(
                                        () => selectedLocation = location,
                                      ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Meeting Type',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children:
                        meetingTypes
                            .map(
                              (meeting) => _cardWidth(
                                context,
                                SelectionCard(
                                  icon: _iconFromString(meeting.icon),
                                  title: meeting.name,
                                  subtitle: meeting.description,
                                  isSelected: selectedMeeting?.id == meeting.id,
                                  onTap:
                                      () => setState(
                                        () => selectedMeeting = meeting,
                                      ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Preferred Language',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children:
                        languages
                            .map(
                              (lang) => _cardWidth(
                                context,
                                SelectionCard(
                                  title: "${lang.flag} ${lang.name}",
                                  isSelected: selectedLanguage?.id == lang.id,
                                  onTap:
                                      () => setState(
                                        () => selectedLanguage = lang,
                                      ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 40),
                  NextButton(
                    onTap: () {
                      Map<String, dynamic> selectedOptions = {
                        'inperson_address': selectedLocation?.id.toString(),
                        'appointment_details': selectedMeeting?.id.toString(),
                        'preferred_language': selectedLanguage?.id.toString(),
                      };

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => BookServiceScreen(
                                services: services,
                                serviceCategories: serviceCategories,
                                selectedOptions: selectedOptions,
                              ),
                        ),
                      );
                    },
                  ),
                ],
              ),
    );
  }

  IconData _iconFromString(String icon) {
    switch (icon) {
      case 'phone':
        return Icons.phone;
      case 'building':
        return Icons.apartment;
      case 'video':
        return Icons.videocam;
      default:
        return Icons.help;
    }
  }

  Widget _cardWidth(BuildContext context, Widget child) {
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      width:
          width > 900
              ? 320
              : width > 600
              ? 280
              : width - 100,
      child: child,
    );
  }
}
