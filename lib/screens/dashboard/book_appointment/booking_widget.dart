import 'package:flutter/material.dart';

class ScaffoldWrapper extends StatelessWidget {
  final int activeStep;
  final String title;
  final Widget child;

  const ScaffoldWrapper({
    super.key,
    required this.activeStep,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(title: const Text('Book Appointment')),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StepHeader(activeStep: activeStep),
                const SizedBox(height: 30),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StepHeader extends StatelessWidget {
  final int activeStep;

  const StepHeader({super.key, required this.activeStep});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      children: [
        _step(1, 'Location'),
        _step(2, 'Service'),
        _step(3, 'Details'),
        _step(4, 'Confirm'),
      ],
    );
  }

  Widget _step(int n, String label) {
    final active = n == activeStep;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: active ? const Color(0xFF1E3A8A) : Colors.grey[300],
          child: Text(
            '$n',
            style: TextStyle(color: active ? Colors.white : Colors.black),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
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
  final VoidCallback onTap;

  const SelectionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            if (icon != null) Icon(icon, size: 30),
            Text(title, textAlign: TextAlign.center),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Icon(Icons.check_circle, color: Colors.blue),
              ),
          ],
        ),
      ),
    );
  }
}

class NextButton extends StatelessWidget {
  final VoidCallback onTap;

  const NextButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 220,
        height: 48,
        child: ElevatedButton(onPressed: onTap, child: const Text('Next Step')),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;

  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
