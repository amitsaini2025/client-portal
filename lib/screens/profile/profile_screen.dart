import 'package:client/config/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:client/services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/app_loader.dart';
import '../../utils/responsive_utils.dart';

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
    await AuthService.logout(true);
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  Future<void> _openEditProfile() async {
    final result = await Navigator.of(context).pushNamed('/profile/edit');
    if (!mounted) return;
    if (result == true) {
      _fetchProfile();
    }
  }

  Future<void> _openPersonalInformation() async {
    await Navigator.of(context).pushNamed('/personal-information');
  }

  Widget _buildProfileCard(BuildContext context) {
    final data = _profileData!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: ThemeConfig.goldenYellow.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    ThemeConfig.goldenYellow,
                    ThemeConfig.goldenYellow.withOpacity(0.6),
                  ],
                ),
              ),
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Colors.white,
                child: Text(
                  data["first_name"] != null && data["first_name"].isNotEmpty
                      ? data["first_name"][0].toUpperCase()
                      : "?",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: ThemeConfig.navyBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              "${data["first_name"] ?? ""} ${data["last_name"] ?? ""}",
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                fontWeight: FontWeight.bold,
                color: ThemeConfig.navyBlue,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              data["email"] ?? "",
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.black12, thickness: 1),
            const SizedBox(height: 10),
            _infoTile(Icons.phone, "Phone", data["phone"] ?? "-"),
            _infoTile(Icons.home, "Address", data["address"] ?? "-"),
            _infoTile(Icons.location_city, "City", data["city"] ?? "-"),
            _infoTile(Icons.flag, "Country", data["country"] ?? "-"),
            _infoTile(Icons.badge, "Client ID", data["client_id"] ?? "-"),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: ThemeConfig.goldenYellow.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: ThemeConfig.goldenYellow, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "My Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        backgroundColor: ThemeConfig.goldenYellow,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: 'Edit Profile',
            onPressed: _isLoading ? null : () => _openEditProfile(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
                maxWidth: AppResponsive.maxFormWidth),
            child: Padding(
              padding: AppResponsive.pagePadding(context),
              child: _isLoading
                  ? const AppLoader()
                  : _errorMessage != null
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.redAccent, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                        color: Colors.redAccent, fontSize: 16),
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
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              )
                  : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileCard(context),
                    const SizedBox(height: 30),

                    _elegantButton(
                      label: "Personal Information",
                      icon: Icons.person_outline,
                      onTap: _openPersonalInformation,
                      color: ThemeConfig.navyBlue,
                    ),

                    _elegantButton(
                      label: "Edit Information",
                      icon: Icons.edit,
                      onTap:
                      _isLoading ? null : _openEditProfile,
                      color: ThemeConfig.goldenYellow,
                    ),

                    _elegantButton(
                      label: "Logout",
                      icon: Icons.logout,
                      onTap: () => _handleLogout(context),
                      color: Colors.redAccent,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _elegantButton({
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}