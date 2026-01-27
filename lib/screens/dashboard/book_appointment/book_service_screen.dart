import 'package:flutter/material.dart';

import 'book_details_screen.dart';
import 'booking_widget.dart';

class BookServiceScreen extends StatefulWidget {
  const BookServiceScreen({super.key});

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  int selected = 0;

  final services = [
    'Permanent Residency Appointment',
    'Temporary Residency Appointment',
    'JRP/Skill Assessment',
    'Tourist Visa',
    'Education / Student Visa',
    'Complex Matters',
    'Visa Cancellation / Refusals',
  ];

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      activeStep: 2,
      title: 'Select Your Service',
      child: Column(
        children: [
          ...List.generate(services.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: SelectionCard(
                title: services[i],
                isSelected: selected == i,
                onTap: () => setState(() => selected = i),
              ),
            );
          }),
          const SizedBox(height: 30),
          NextButton(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookDetailsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
