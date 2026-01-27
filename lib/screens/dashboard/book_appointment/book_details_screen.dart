import 'package:flutter/material.dart';

import 'book_confirm_screen.dart';
import 'booking_widget.dart';

class BookDetailsScreen extends StatefulWidget {
  const BookDetailsScreen({super.key});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      activeStep: 3,
      title: 'Enter Your Details',
      child: Column(
        children: [
          _input('Full Name', nameCtrl),
          _input('Email', emailCtrl),
          _input('Phone', phoneCtrl),
          const SizedBox(height: 30),
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

  Widget _input(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
