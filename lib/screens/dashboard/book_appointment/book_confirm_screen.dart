import 'package:flutter/material.dart';
import 'booking_widget.dart';

class BookConfirmScreen extends StatelessWidget {
  const BookConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      activeStep: 4,
      title: 'Confirm Appointment',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Your Details & Appointment Time'),
            const SizedBox(height: 20),

            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                return isMobile
                    ? Column(
                  children: const [
                    AppTextField(label: 'Full Name'),
                    SizedBox(height: 16),
                    AppTextField(label: 'Email Address'),
                  ],
                )
                    : Row(
                  children: const [
                    Expanded(child: AppTextField(label: 'Full Name')),
                    SizedBox(width: 16),
                    Expanded(child: AppTextField(label: 'Email Address')),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            const PhoneField(),

            const SizedBox(height: 20),

            const AppTextField(
              label: 'Details of Enquiry',
              maxLines: 4,
              hint: 'Please provide detailed information about your enquiry...',
            ),

            const SizedBox(height: 32),

            const SectionTitle('Select Date & Time'),
            const SizedBox(height: 12),

            const TimezoneBanner(),

            const SizedBox(height: 20),

            const CalendarSection(),

            const SizedBox(height: 40),

            /// ✅ Buttons never overflow
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(140, 48),
                  ),
                  child: const Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(180, 48),
                  ),
                  child: const Text('Review & Confirm'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final int maxLines;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFFFF1F1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}


class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E3A8A),
      ),
    );
  }
}

class PhoneField extends StatelessWidget {
  const PhoneField({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Phone Number', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Center(child: Text('🇦🇺 +61')),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: '400 000 000',
                  filled: true,
                  fillColor: const Color(0xFFFFF1F1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.redAccent),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TimezoneBanner extends StatelessWidget {
  const TimezoneBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF6D83F2), Color(0xFF7B4AA1)],
        ),
      ),
      child: const Text(
        '⏱  All times shown in Melbourne Time (AEST)',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class CalendarSection extends StatelessWidget {
  const CalendarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: const [
                Text(
                  'January 2026',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 16),
                Icon(Icons.calendar_month, size: 80, color: Colors.grey),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 160,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Select a date',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

