import 'package:flutter/material.dart';

import '../../../models/appointment/appointment_variable_list.dart';
import 'book_details_screen.dart';
import 'booking_widget.dart';

class BookServiceScreen extends StatefulWidget {
  final List<ServiceTypeModel> services;
  final List<SimpleServiceModel> serviceCategories;
  final Map<String, dynamic> selectedOptions;

  const BookServiceScreen({
    super.key,
    required this.services,
    required this.serviceCategories,
    required this.selectedOptions,
  });

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  SimpleServiceModel? selectedService;

  @override
  void initState() {
    super.initState();
    if (widget.serviceCategories.isNotEmpty) {
      selectedService = widget.serviceCategories.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      activeStep: 2,
      title: 'Select Your Service',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...widget.serviceCategories.map((service) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: SelectionCard(
                title: service.name,
                subtitle: service.name,
                isSelected: selectedService?.id == service.id,
                onTap: () => setState(() => selectedService = service),
              ),
            );
          }).toList(),
          const SizedBox(height: 30),
          NextButton(
            onTap: () {
              if (selectedService != null) {
                widget.selectedOptions['noe_id'] = selectedService?.id;
                widget.selectedOptions["service_name"] = selectedService?.name;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => BookDetailsScreen(
                          services: widget.services,
                          selectedOptions: widget.selectedOptions,
                        ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
