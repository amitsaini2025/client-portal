import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/appointment/appointment_variable_list.dart';
import '../../../utils/app_loader.dart';
import '../../../utils/cache_helper.dart';
import 'book_details_screen.dart';
import 'booking_widget.dart';

class BookServiceScreen extends StatefulWidget {
  const BookServiceScreen({super.key});

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  List<ServiceTypeModel> services = [];
  List<SimpleServiceModel> serviceCategories = [];

  Map<String, dynamic> selectedOptions = {};

  SimpleServiceModel? selectedService;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCachedData();
  }

  Future<void> _loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();

    services = await CacheHelper.loadData(
      'locations',
      (e) => ServiceTypeModel.fromJson(e),
    );
    serviceCategories = await CacheHelper.loadData(
      'serviceCategories',
      (e) => SimpleServiceModel.fromJson(e),
    );

    final cachedSelectedOptions = prefs.getString('selectedOptions');
    if (cachedSelectedOptions != null) {
      final decoded = jsonDecode(cachedSelectedOptions);
      if (decoded is Map<String, dynamic>) {
        selectedOptions = decoded;
      }
    }

    // restore cache selection
    if (selectedOptions.containsKey("noe_id") && serviceCategories.isNotEmpty) {
      selectedService = serviceCategories.firstWhere(
        (e) => e.id == selectedOptions["noe_id"],
        orElse: () => serviceCategories.first,
      );
    }

    // ✅ FIX: ensure at least one selected
    if (selectedService == null && serviceCategories.isNotEmpty) {
      selectedService = serviceCategories.first;
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _saveSelectedOptions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("selectedOptions", jsonEncode(selectedOptions));
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      activeStep: 2,
      title: 'Select Your Service',
      child:
          isLoading
              ? const Center(child: AppLoader())
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...serviceCategories.map((service) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: SelectionCard(
                        title: service.name,
                        subtitle: service.name,
                        isSelected: selectedService?.id == service.id,
                        onTap: () {
                          setState(() {
                            selectedService = service;
                          });
                        },
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: PreviousButton(
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: NextButton(
                          onTap: () async {
                            if (selectedService != null) {
                              selectedOptions['noe_id'] = selectedService!.id;
                              selectedOptions["service_name"] =
                                  selectedService!.name;

                              await _saveSelectedOptions();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookDetailsScreen(),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
    );
  }
}
