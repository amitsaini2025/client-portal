import 'package:flutter/material.dart';

import '../../../config/theme_config.dart';
import '../../../widgets/webview/universal_webview.dart';

class HealthInsuranceScreen extends StatefulWidget {
  const HealthInsuranceScreen({super.key});

  @override
  State<HealthInsuranceScreen> createState() => _HealthInsuranceScreenState();
}

class _HealthInsuranceScreenState extends State<HealthInsuranceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> urls = [
    'https://www.bansalimmigration.com.au/student-visa-health-insurance',
    'https://www.bansalimmigration.com.au/tourist-visa-health-insurance',
    'https://www.bansalimmigration.com.au/temporary-graduate-health-insurance',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: urls.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeConfig.goldenYellow,
        title: const Text(
          "Health Insurance",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Student Visa Health Insurance(OSHC)"),
            Tab(text: "Tourist Visa Health Insurance(OVHC)"),
            Tab(text: "Temporary Graduate Health Insurance(OVHC)"),
          ],
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.white,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: TabBarView(
          controller: _tabController,
          children: List.generate(
            urls.length,
                (index) => UniversalWebView(
              url: urls[index],
              viewId: 'iframe-$index',
            ),
          ),
        ),
      ),
    );
  }
}
