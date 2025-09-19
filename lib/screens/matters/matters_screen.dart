import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

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
        const SnackBar(
          content: Text('Please select a matter'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Navigate to dashboard
    Navigator.pushReplacementNamed(context, '/dashboard');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Matter confirmed!'),
        backgroundColor: Colors.green,
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
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueAccent,
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
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData ||
              snapshot.data!['data'] == null ||
              snapshot.data!['data']['matters'].isEmpty) {
            return const Center(child: Text('No matters found.'));
          } else {
            final List matters = snapshot.data!['data']['matters'];
            final selectedMatterId = AuthService.selectedMatterId;

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: matters.length,
              itemBuilder: (context, index) {
                final matter = matters[index];
                final matterId = matter['matter_id'];
                final isSelected = selectedMatterId == matterId;

                return GestureDetector(
                  onTap: () async {
                    await AuthService.selectMatter(matterId);
                    setState(() {}); // refresh UI
                  },
                  child: Card(
                    elevation: isSelected ? 6 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isSelected
                          ? const BorderSide(
                        color: Colors.blueAccent,
                        width: 2,
                      )
                          : BorderSide.none,
                    ),
                    color: isSelected ? Colors.blue.shade50 : Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      leading: CircleAvatar(
                        backgroundColor:
                        isSelected ? Colors.blueAccent : Colors.grey.shade300,
                        foregroundColor: isSelected ? Colors.white : Colors.black,
                        child: Text(
                          matterId.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        matter['matter_name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                        Icons.check_circle,
                        color: Colors.blueAccent,
                      )
                          : const Icon(Icons.radio_button_unchecked),
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
