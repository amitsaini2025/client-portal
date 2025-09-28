import 'package:client/config/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:client/services/api_service.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _profileData;


  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.getClientProfile();

      if (result['success'] == true) {
        setState(() {
          _profileData = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? "Failed to load profile";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
          (Route<dynamic> route) => false,
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final data = _profileData!;
    return Container(
      decoration: BoxDecoration(
        color: ThemeConfig.navyBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ThemeConfig.goldenYellow.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: ThemeConfig.goldenYellow.withOpacity(0.2),
              child: Text(
                data["first_name"] != null && data["first_name"].isNotEmpty
                    ? data["first_name"][0]
                    : "?",
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),

            // Full name
            Text(
              "${data["first_name"] ?? ""} ${data["last_name"] ?? ""}",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 4),

            // Email
            Text(
              data["email"] ?? "",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 20),

            // Info list
            Column(
              children: [
                _infoTile(Icons.phone, "Phone", data["phone"] ?? "-"),
                _infoTile(Icons.home, "Address", data["address"] ?? "-"),
                _infoTile(Icons.location_city, "City", data["city"] ?? "-"),
                _infoTile(Icons.flag, "Country", data["country"] ?? "-"),
                _infoTile(Icons.badge, "Client ID", data["client_id"] ?? "-"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: ThemeConfig.goldenYellow),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
      ),
      subtitle: Text(value, style: const TextStyle(color: Colors.white70)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.navyBlue,
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: ThemeConfig.goldenYellow,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _isLoading
                ? const CircularProgressIndicator(color: ThemeConfig.goldenYellow)
                : _errorMessage != null
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _fetchProfile,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConfig.goldenYellow,
                    foregroundColor: Colors.white,
                  ),
                )
              ],
            )
                : SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileCard(context),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      _handleLogout(context);
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
}
