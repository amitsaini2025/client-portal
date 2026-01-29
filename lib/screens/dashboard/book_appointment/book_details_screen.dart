import 'package:flutter/material.dart';

import '../../../models/appointment/appointment_variable_list.dart';
import 'book_confirm_screen.dart';
import 'booking_widget.dart';

class BookDetailsScreen extends StatefulWidget {
  final List<ServiceTypeModel> services;
  final Map<String, dynamic> selectedOptions;

  const BookDetailsScreen({
    super.key,
    required this.services,
    required this.selectedOptions,
  });

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      activeStep: 3,
      title: 'Select Service',
      child: Column(
        children: [
          ...List.generate(widget.services.length, (index) {
            final service = widget.services[index];

            final tagText =
                service.price == 0
                    ? 'FREE'
                    : service.availableForOverseas
                    ? 'OVERSEAS'
                    : service.priceDisplay;

            final tagColor =
                service.price == 0
                    ? Colors.green
                    : service.availableForOverseas
                    ? const Color(0xFF1E3A8A)
                    : Colors.orange;

            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ServiceCard(
                tagText: tagText,
                tagColor: tagColor,
                title: service.name,
                priceText: service.priceDisplay,
                duration:
                    '${service.duration} ${service.durationUnit} • ${service.startTime} - ${service.endTime} ${service.timeFormat}',
                description: service.description,
                availability:
                    'Available: ${service.availableDays.join(', ')} • ${service.timeSlotDescription}',
                selected: selectedIndex == index,
                onTap: () => setState(() => selectedIndex = index),
              ),
            );
          }),
          const SizedBox(height: 32),
          NextButton(
            onTap: () {
              widget.selectedOptions['service_id'] =
                  widget.services[selectedIndex];
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => BookConfirmScreen(
                        selectedOptions: widget.selectedOptions,
                      ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String tagText;
  final Color tagColor;
  final String title;
  final String priceText;
  final String duration;
  final String description;
  final String availability;
  final bool selected;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.tagText,
    required this.tagColor,
    required this.title,
    required this.priceText,
    required this.duration,
    required this.description,
    required this.availability,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF1E3A8A) : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Tag(text: tagText, color: tagColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  priceText,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: tagColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(duration, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            Text(description, style: const TextStyle(height: 1.5)),
            const SizedBox(height: 12),
            Text(
              availability,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;

  const _Tag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
