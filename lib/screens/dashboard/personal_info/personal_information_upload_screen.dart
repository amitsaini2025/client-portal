import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:client/config/theme_config.dart';

class PersonalInformationUploadScreen extends StatefulWidget {
  const PersonalInformationUploadScreen({super.key});

  @override
  State<PersonalInformationUploadScreen> createState() =>
      _PersonalInformationUploadScreenState();
}

class _PersonalInformationUploadScreenState
    extends State<PersonalInformationUploadScreen> {
  // Controllers for text fields
  final _nameController = TextEditingController();
  final _clientIdController = TextEditingController();
  final _dobController = TextEditingController();
  final _genderController = TextEditingController();
  final _maritalStatusController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _regionController = TextEditingController();

  File? _passportFile;
  File? _visaFile;
  File? _travelFile;

  Future<void> _pickFile(Function(File) onPicked) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        onPicked(file);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting file: $e')),
      );
    }
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: ThemeConfig.goldenYellow, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeConfig.navyBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: ThemeConfig.navyBlue,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ThemeConfig.goldenYellow),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ThemeConfig.goldenYellow, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildFileUploadField({
    required String title,
    required File? file,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: ThemeConfig.goldenYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border:
              Border.all(color: ThemeConfig.goldenYellow.withOpacity(0.7)),
            ),
            child: Center(
              child: file == null
                  ? const Text(
                "Tap to upload file",
                style: TextStyle(color: Colors.white70),
              )
                  : Text(
                file.path.split('/').last,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Personal information submitted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        },
        icon: const Icon(Icons.cloud_upload_outlined),
        label: const Text("Submit Personal Information"),
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeConfig.goldenYellow,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.navyBlue,
      appBar: AppBar(
        backgroundColor: ThemeConfig.goldenYellow,
        title: const Text("Upload Personal Information",
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---------- Basic Information ----------
            _buildCard(
              title: "Basic Information",
              children: [
                _buildSectionTitle("Basic Information", Icons.info_outline),
                const SizedBox(height: 12),
                _buildTextField("Name", _nameController),
                _buildTextField("Client ID", _clientIdController),
                _buildTextField("Date of Birth", _dobController),
                _buildTextField("Gender", _genderController),
                _buildTextField("Marital Status", _maritalStatusController),
              ],
            ),

            // ---------- Phone ----------
            _buildCard(
              title: "Phone Numbers",
              children: [
                _buildSectionTitle("Phone Numbers", Icons.phone),
                const SizedBox(height: 12),
                _buildTextField("Personal Phone", _phoneController),
              ],
            ),

            // ---------- Email ----------
            _buildCard(
              title: "Email Addresses",
              children: [
                _buildSectionTitle("Email Addresses", Icons.email_outlined),
                const SizedBox(height: 12),
                _buildTextField("Personal Email", _emailController),
              ],
            ),

            // ---------- Passport Upload ----------
            _buildCard(
              title: "Passport Information",
              children: [
                _buildSectionTitle(
                    "Passport Information", Icons.airplane_ticket_outlined),
                const SizedBox(height: 12),
                _buildFileUploadField(
                  title: "Upload Passport Copy",
                  file: _passportFile,
                  onTap: () => _pickFile((f) => setState(() {
                    _passportFile = f;
                  })),
                ),
              ],
            ),

            // ---------- Visa Upload ----------
            _buildCard(
              title: "Visa Information",
              children: [
                _buildSectionTitle("Visa Information", Icons.flight),
                const SizedBox(height: 12),
                _buildFileUploadField(
                  title: "Upload Visa Document",
                  file: _visaFile,
                  onTap: () => _pickFile((f) => setState(() {
                    _visaFile = f;
                  })),
                ),
              ],
            ),

            // ---------- Address ----------
            _buildCard(
              title: "Address Information",
              children: [
                _buildSectionTitle("Address Information", Icons.home_outlined),
                const SizedBox(height: 12),
                _buildTextField("Address", _addressController),
                _buildTextField("Regional Code", _regionController),
              ],
            ),

            // ---------- Travel Upload ----------
            _buildCard(
              title: "Travel Information",
              children: [
                _buildSectionTitle("Travel Information", Icons.flight_takeoff),
                const SizedBox(height: 12),
                _buildFileUploadField(
                  title: "Upload Travel Document",
                  file: _travelFile,
                  onTap: () => _pickFile((f) => setState(() {
                    _travelFile = f;
                  })),
                ),
              ],
            ),

            const SizedBox(height: 24),
            _buildSubmitButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
