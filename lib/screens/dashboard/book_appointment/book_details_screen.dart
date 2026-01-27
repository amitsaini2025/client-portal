import 'package:flutter/material.dart';

import 'book_confirm_screen.dart';
import 'booking_widget.dart';

class BookDetailsScreen extends StatefulWidget {
  const BookDetailsScreen({super.key});

  @override
  State<BookDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<BookDetailsScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      activeStep: 3,
      title: 'Select Service',
      child: Column(
        children: [
          ServiceCard(
            tagText: 'FREE',
            tagColor: Colors.green,
            title: 'Free Consultation',
            priceText: 'FREE',
            duration: '15 minutes • 10:45 AM - 4:00 PM',
            description:
                'Perfect for initial inquiries: Quick assessment of your immigration situation, '
                'basic visa pathway guidance, and preliminary advice. '
                'Available for clients currently within Australia only. '
                'Includes initial case evaluation and next steps recommendation.',
            availability:
                'Available: Monday to Friday, 10:45 AM - 4:00 PM • 15-minute time slots',
            selected: selectedIndex == 0,
            onTap: () => setState(() => selectedIndex = 0),
          ),
          const SizedBox(height: 20),

          ServiceCard(
            tagText: '\$150',
            tagColor: Colors.orange,
            title: 'Comprehensive Migration Advice',
            priceText: '\$150',
            duration: '30 minutes • 9:00 AM - 5:00 PM',
            description:
                'In-depth professional consultation: Comprehensive case analysis, '
                'detailed migration strategy, complex visa applications, ART appeals, '
                'visa cancellations, protection visas, and personalized action plans. '
                'Suitable for overseas applicants and complex cases.',
            availability:
                'Available: Monday to Friday, 9:00 AM - 5:00 PM • 30-minute time slots • Includes video call option',
            selected: selectedIndex == 1,
            onTap: () => setState(() => selectedIndex = 1),
          ),
          const SizedBox(height: 20),

          ServiceCard(
            tagText: 'OVERSEAS',
            tagColor: const Color(0xFF1E3A8A),
            title: 'Overseas Applicant Enquiry',
            priceText: '\$150',
            duration: '30 minutes • 9:00 AM - 5:00 PM',
            description:
                'Specialized consultation for overseas applicants: For applicants currently '
                'outside Australia or inquiring on behalf of someone overseas. '
                'Includes detailed assessment and personalized migration strategy.',
            availability:
                'Available: Monday to Friday, 9:00 AM - 5:00 PM • 30-minute time slots • Includes video call option',
            selected: selectedIndex == 2,
            onTap: () => setState(() => selectedIndex = 2),
          ),

          const SizedBox(height: 32),
          NextButton(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookConfirmScreen()),
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
