import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../config/theme_config.dart';

class MattersScreen extends StatefulWidget {
  const MattersScreen({super.key});

  @override
  State<MattersScreen> createState() => _MattersScreenState();
}

class _MattersScreenState extends State<MattersScreen> {
  late Future<Map<String, dynamic>> _mattersFuture;

  @override
  void initState() {
    super.initState();
    _mattersFuture = ApiService.getMatters();
  }

  /// Confirm selected matter
  void _confirmSelection() {
    if (!AuthService.isMatterSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a matter'),
          backgroundColor: Colors.redAccent.shade400,
        ),
      );
      return;
    }

    // Navigate to dashboard
    /*Navigator.pushReplacementNamed(
      context,
      '/dashboard',
      arguments: AuthService.selectedMatterId.toString(),
    );*/

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/dashboard',
          (route) => false, // removes all previous routes
      arguments: AuthService.selectedMatterId.toString(),
    );


    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Matter confirmed!'),
        backgroundColor: ThemeConfig.navyBlue,
      ),
    );

    print('Selected Matter ID: ${AuthService.selectedMatterId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Matter',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: ThemeConfig.navyBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _confirmSelection,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _mattersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData ||
              snapshot.data!['data'] == null ||
              snapshot.data!['data']['matters'].isEmpty) {
            return Center(
              child: Text(
                'No matters found.',
                style: TextStyle(color: ThemeConfig.navyBlue),
              ),
            );
          } else {
            final List matters = snapshot.data!['data']['matters'];
            final selectedMatterId = AuthService.selectedMatterId;

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: matters.length,
              itemBuilder: (context, index) {
                final matter = matters[index];
                final matterId = matter['matter_id'];
                final matterName = matter["matter_name"];
                final isSelected = selectedMatterId == matterId;

                return GestureDetector(
                  onTap: () async {
                    await AuthService.selectMatter(matterId: matterId, matterName: matterName);
                    setState(() {});
                  },
                  child: Card(
                    elevation: isSelected ? 6 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isSelected
                          ? BorderSide(
                        color: ThemeConfig.navyBlue,
                        width: 2,
                      )
                          : BorderSide.none,
                    ),
                    color: isSelected
                        ? ThemeConfig.goldenYellow.withOpacity(0.3)
                        : Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      title: Text(
                        matter['matter_name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ThemeConfig.navyBlue,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                        Icons.check_circle,
                        color: ThemeConfig.navyBlue,
                      )
                          : Icon(Icons.radio_button_unchecked,
                          color: ThemeConfig.navyBlue.withOpacity(0.6)),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
