import 'package:flutter/material.dart';

import '../../../config/theme_config.dart';

class BookAppointmentLocationScreen extends StatefulWidget {
  const BookAppointmentLocationScreen({super.key});

  @override
  State<BookAppointmentLocationScreen> createState() =>
      _BookAppointmentLocationScreenState();
}

class _BookAppointmentLocationScreenState
    extends State<BookAppointmentLocationScreen> {
  String selectedOffice = 'Melbourne';
  String selectedMeeting = 'Phone';
  String selectedLanguage = 'Hindi';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Location',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: ThemeConfig.goldenYellow,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1100),
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StepHeader(),
                  const SizedBox(height: 32),

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
                          onTap:
                              () => setState(() => selectedOffice = 'Adelaide'),
                        ),
                      ),
                      _cardWidth(
                        context,
                        SelectionCard(
                          title: 'Melbourne Office',
                          subtitle:
                              'Level 8/278 Collins St\nMelbourne VIC 3000',
                          isSelected: selectedOffice == 'Melbourne',
                          onTap:
                              () =>
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
                          accentColor: Colors.orange,
                          isSelected: selectedMeeting == 'Phone',
                          onTap:
                              () => setState(() => selectedMeeting = 'Phone'),
                        ),
                      ),
                      _cardWidth(
                        context,
                        SelectionCard(
                          icon: Icons.apartment,
                          title: 'In Person',
                          subtitle: 'Visit our office',
                          isSelected: selectedMeeting == 'InPerson',
                          onTap:
                              () =>
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
                          subtitleColor: Colors.orange,
                          isSelected: selectedMeeting == 'Video',
                          onTap:
                              () => setState(() => selectedMeeting = 'Video'),
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
                          onTap:
                              () =>
                                  setState(() => selectedLanguage = 'English'),
                        ),
                      ),
                      _cardWidth(
                        context,
                        SelectionCard(
                          title: 'Hindi',
                          accentColor: Colors.green,
                          isSelected: selectedLanguage == 'Hindi',
                          onTap:
                              () => setState(() => selectedLanguage = 'Hindi'),
                        ),
                      ),
                      _cardWidth(
                        context,
                        SelectionCard(
                          title: 'Punjabi',
                          isSelected: selectedLanguage == 'Punjabi',
                          onTap:
                              () =>
                                  setState(() => selectedLanguage = 'Punjabi'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                  Center(
                    child: SizedBox(
                      width: 220,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          'Next Step',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Responsive card width
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

class StepHeader extends StatelessWidget {
  const StepHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 12,
      children: const [
        StepItem(number: '1', label: 'Location', active: true),
        StepItem(number: '2', label: 'Service'),
        StepItem(number: '3', label: 'Details'),
        StepItem(number: '4', label: 'Confirm'),
      ],
    );
  }
}

class StepItem extends StatelessWidget {
  final String number;
  final String label;
  final bool active;

  const StepItem({
    super.key,
    required this.number,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: active ? const Color(0xFF1E3A8A) : Colors.grey[300],
          child: Text(
            number,
            style: TextStyle(
              color: active ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: active ? const Color(0xFF1E3A8A) : Colors.grey,
          ),
        ),
      ],
    );
  }
}

class SelectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool isSelected;
  final Color accentColor;
  final Color? subtitleColor;
  final VoidCallback onTap;

  const SelectionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.isSelected,
    required this.onTap,
    this.accentColor = const Color(0xFF1E3A8A),
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accentColor : Colors.grey.shade300,
            width: 2,
          ),
          color: isSelected ? accentColor.withOpacity(0.05) : Colors.white,
        ),
        child: Column(
          children: [
            if (icon != null) Icon(icon, size: 32, color: accentColor),
            if (icon != null) const SizedBox(height: 12),

            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            if (subtitle != null) const SizedBox(height: 8),

            if (subtitle != null)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: subtitleColor ?? Colors.grey[600],
                  ),
                ),
              ),

            if (isSelected) ...[
              const SizedBox(height: 12),
              CircleAvatar(
                radius: 12,
                backgroundColor: accentColor,
                child: const Icon(Icons.check, size: 14, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
