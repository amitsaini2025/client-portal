import 'package:flutter/material.dart';
import '../../../config/theme_config.dart';
import '../../../utils/responsive_utils.dart';

class ScaffoldWrapper extends StatelessWidget {
  final int activeStep;
  final String title;
  final Widget child;
  final List<Widget>? actions;

  const ScaffoldWrapper({
    super.key,
    required this.activeStep,
    required this.title,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text(
          'Book Appointment',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: ThemeConfig.goldenYellow,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: actions,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppResponsive.maxContentWidth,
              ),
              child: Container(
                margin: AppResponsive.pagePadding(context),
                padding: AppResponsive.pagePadding(context),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
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
    return Row(
      children: [
        Expanded(child: _step(context, 1, 'Location')),
        Expanded(child: _step(context, 2, 'Service')),
        Expanded(child: _step(context, 3, 'Details')),
        Expanded(child: _step(context, 4, 'Confirm')),
      ],
    );
  }

  Widget _step(BuildContext context, int n, String label) {
    final active = n == activeStep;
    return GestureDetector(
      onTap: () {
        /*switch (n) {
          case 1:
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const BookLocationScreen()));
            break;
          case 2:
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const BookServiceScreen()));
            break;
          case 3:
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const BookDetailsScreen()));
            break;
          case 4:
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const BookConfirmScreen()));
            break;
        }*/
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor:
            active ? const Color(0xFF1E3A8A) : Colors.grey[300],
            child: Text(
              '$n',
              style:
              TextStyle(color: active ? Colors.white : Colors.black),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: active ? const Color(0xFF1E3A8A) : Colors.grey,
            ),
          ),
        ],
      ),
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 30),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.blue,
                size: 26,
              ),
          ],
        ),
      ),
    );
  }
}

class PreviousButton extends StatelessWidget {
  final VoidCallback onTap;

  const PreviousButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: const Color(0xFF2C3E8F),
            width: 2,
          ),
        ),
        child: const Text(
          "Previous",
          style: TextStyle(
            color: Color(0xFF2C3E8F),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
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
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1F3C88),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Text('Next Step'),
        ),
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
      child:
      Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}