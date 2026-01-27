import 'package:flutter/material.dart';

import 'book_service_screen.dart';
import 'booking_widget.dart';

class BookLocationScreen extends StatefulWidget {
  const BookLocationScreen({super.key});

  @override
  State<BookLocationScreen> createState() => _BookLocationScreenState();
}

class _BookLocationScreenState extends State<BookLocationScreen> {
  String selectedOffice = 'Melbourne';
  String selectedMeeting = 'Phone';
  String selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      activeStep: 1,
      title: 'Choose Your Preferred Location',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Select Office Location'),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _card(context, SelectionCard(
                title: 'Adelaide Office',
                subtitle: 'Unit 5, 55 Gawler Pl\nAdelaide SA 5000',
                isSelected: selectedOffice == 'Adelaide',
                onTap: () => setState(() => selectedOffice = 'Adelaide'),
              )),
              _card(context, SelectionCard(
                title: 'Melbourne Office',
                subtitle: 'Level 8/278 Collins St\nMelbourne VIC 3000',
                isSelected: selectedOffice == 'Melbourne',
                onTap: () => setState(() => selectedOffice = 'Melbourne'),
              )),
            ],
          ),

          const SizedBox(height: 32),
          const SectionTitle('Meeting Type'),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _card(context, SelectionCard(
                icon: Icons.phone,
                title: 'Phone Call',
                isSelected: selectedMeeting == 'Phone',
                onTap: () => setState(() => selectedMeeting = 'Phone'),
              )),
              _card(context, SelectionCard(
                icon: Icons.apartment,
                title: 'In Person',
                isSelected: selectedMeeting == 'InPerson',
                onTap: () => setState(() => selectedMeeting = 'InPerson'),
              )),
              _card(context, SelectionCard(
                icon: Icons.videocam,
                title: 'Video Call',
                isSelected: selectedMeeting == 'Video',
                onTap: () => setState(() => selectedMeeting = 'Video'),
              )),
            ],
          ),

          const SizedBox(height: 32),
          const SectionTitle('Preferred Language'),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _card(context, SelectionCard(
                title: 'English',
                isSelected: selectedLanguage == 'English',
                onTap: () => setState(() => selectedLanguage = 'English'),
              )),
              _card(context, SelectionCard(
                title: 'Hindi',
                isSelected: selectedLanguage == 'Hindi',
                onTap: () => setState(() => selectedLanguage = 'Hindi'),
              )),
              _card(context, SelectionCard(
                title: 'Punjabi',
                isSelected: selectedLanguage == 'Punjabi',
                onTap: () => setState(() => selectedLanguage = 'Punjabi'),
              )),
            ],
          ),

          const SizedBox(height: 40),
          NextButton(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookServiceScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, Widget child) {
    final w = MediaQuery.of(context).size.width;
    return SizedBox(width: w > 900 ? 320 : w > 600 ? 280 : w - 100, child: child);
  }
}
