import 'package:flutter/material.dart';
import 'booking_widget.dart';
import 'book_service_screen.dart';

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
      title: 'Location',
      activeStep: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Your Preferred Location',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          const Text(
            'Select Office Location',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _cardWidth(
                context,
                SelectionCard(
                  title: 'Adelaide Office',
                  subtitle: 'Unit 5, 55 Gawler Pl\nAdelaide SA 5000',
                  isSelected: selectedOffice == 'Adelaide',
                  onTap: () =>
                      setState(() => selectedOffice = 'Adelaide'),
                ),
              ),
              _cardWidth(
                context,
                SelectionCard(
                  title: 'Melbourne Office',
                  subtitle:
                  'Level 8/278 Collins St\nMelbourne VIC 3000',
                  isSelected: selectedOffice == 'Melbourne',
                  onTap: () =>
                      setState(() => selectedOffice = 'Melbourne'),
                ),
              ),
            ],
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
            children: [
              _cardWidth(
                context,
                SelectionCard(
                  icon: Icons.phone,
                  title: 'Phone Call',
                  subtitle: 'Speak directly with our experts',
                  isSelected: selectedMeeting == 'Phone',
                  onTap: () =>
                      setState(() => selectedMeeting = 'Phone'),
                ),
              ),
              _cardWidth(
                context,
                SelectionCard(
                  icon: Icons.apartment,
                  title: 'In Person',
                  subtitle: 'Visit our office',
                  isSelected: selectedMeeting == 'InPerson',
                  onTap: () =>
                      setState(() => selectedMeeting = 'InPerson'),
                ),
              ),
              _cardWidth(
                context,
                SelectionCard(
                  icon: Icons.videocam,
                  title: 'Video Call ★',
                  subtitle:
                  'Online consultation\nAvailable for paid appointments only',
                  isSelected: selectedMeeting == 'Video',
                  onTap: () =>
                      setState(() => selectedMeeting = 'Video'),
                ),
              ),
            ],
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
            children: [
              _cardWidth(
                context,
                SelectionCard(
                  title: 'English',
                  isSelected: selectedLanguage == 'English',
                  onTap: () =>
                      setState(() => selectedLanguage = 'English'),
                ),
              ),
              _cardWidth(
                context,
                SelectionCard(
                  title: 'Hindi',
                  isSelected: selectedLanguage == 'Hindi',
                  onTap: () =>
                      setState(() => selectedLanguage = 'Hindi'),
                ),
              ),
              _cardWidth(
                context,
                SelectionCard(
                  title: 'Punjabi',
                  isSelected: selectedLanguage == 'Punjabi',
                  onTap: () =>
                      setState(() => selectedLanguage = 'Punjabi'),
                ),
              ),
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

  Widget _cardWidth(BuildContext context, Widget child) {
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width > 900
          ? 320
          : width > 600
          ? 280
          : width - 100,
      child: child,
    );
  }
}
