import 'package:flutter/material.dart';

import 'booking_widget.dart';

class BookConfirmScreen extends StatelessWidget {
  const BookConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      activeStep: 4,
      title: 'Confirm Appointment',
      child: Column(
        children: [
          const Icon(Icons.check_circle, size: 80, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'Your appointment has been booked successfully!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: 220,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              child: const Text('Finish'),
            ),
          ),
        ],
      ),
    );
  }
}
