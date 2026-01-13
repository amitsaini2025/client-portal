import 'package:flutter/material.dart';

import '../../../config/theme_config.dart';

class StudentFundCalculatorScreen extends StatelessWidget {
  const StudentFundCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Fund Calculator',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: ThemeConfig.goldenYellow,
        foregroundColor: Colors.white,
      ),
      body: const SizedBox.shrink(), // empty screen
    );
  }
}
