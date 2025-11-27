import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/personal_information/basic_information.dart';
import '../../../../models/personal_information/email.dart';
import '../../../../models/personal_information/phone.dart';
import '../../../../services/api_service.dart';

class BasicPersonalInformationWidget extends StatefulWidget {
  final BasicInformation? basicInfo;
  final List<Phone>? phones;
  final List<Email>? emails;

  const BasicPersonalInformationWidget({
    super.key,
    this.basicInfo,
    this.phones,
    this.emails,
  });

  @override
  State<BasicPersonalInformationWidget> createState() =>
      _BasicPersonalInformationWidgetState();
}

class _BasicPersonalInformationWidgetState
    extends State<BasicPersonalInformationWidget> {
  bool isEditing = false;

  late TextEditingController firstNameCtrl;
  late TextEditingController lastNameCtrl;
  late TextEditingController dobCtrl;
  late TextEditingController genderCtrl;
  late TextEditingController maritalStatusCtrl;

  @override
  void initState() {
    super.initState();

    final basic = widget.basicInfo;

    String first = "";
    String last = "";
    if (basic?.fullName != null) {
      final parts = basic!.fullName!.split(" ");
      first = parts.first;
      last = parts.length > 1 ? parts.sublist(1).join(" ") : "";
    }

    firstNameCtrl = TextEditingController(text: first);
    lastNameCtrl = TextEditingController(text: last);
    genderCtrl = TextEditingController(text: basic?.gender ?? "");
    maritalStatusCtrl = TextEditingController(text: basic?.maritalStatus ?? "");
    dobCtrl = TextEditingController(text: basic?.dateOfBirth ?? "");
  }

  Future<void> _pickDOB() async {
    DateTime initial;
    try {
      final parts = dobCtrl.text.split('/');
      initial = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (_) {
      initial = DateTime.now().subtract(const Duration(days: 365 * 20));
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      dobCtrl.text = DateFormat("dd/MM/yyyy").format(picked);
    }
  }

  Future<void> _saveData() async {
    try {
      final res = await ApiService.updateClientBasicDetail(
        firstName: firstNameCtrl.text,
        lastName: lastNameCtrl.text,
        dob: dobCtrl.text,
        gender: genderCtrl.text,
        maritalStatus: maritalStatusCtrl.text,
      );

      if (res["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Updated Successfully!")),
        );

        setState(() {
          isEditing = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res["message"] ?? "Update failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final phones = widget.phones ?? [];
    final emails = widget.emails ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Basic Information', showEdit: true),
        const SizedBox(height: 12),

        _buildInfoCard([
          _buildTextField('First Name', firstNameCtrl),
          _buildTextField('Last Name', lastNameCtrl),
          _buildDOBField('Date of Birth', dobCtrl),
          _buildTextField('Gender', genderCtrl),
          _buildTextField('Marital Status', maritalStatusCtrl),
        ]),

        const SizedBox(height: 24),

        _buildSectionTitle('Phone Numbers', showEdit: true, showAdd: true),
        const SizedBox(height: 12),

        _buildInfoCard(
          phones.isEmpty
              ? [_buildStaticField('No Phone Records', '')]
              : phones.map((p) {
            final phoneCtrl = TextEditingController(
              text: "${p.countryCode ?? ''} ${p.phone ?? ''}",
            );
            return _buildTextField(
              p.type ?? 'Phone Number',
              phoneCtrl,
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        _buildSectionTitle('Email Addresses', showEdit: true, showAdd: true),
        const SizedBox(height: 12),

        _buildInfoCard(
          emails.isEmpty
              ? [_buildStaticField('No Email Records', '')]
              : emails.map((e) {
            final emailCtrl = TextEditingController(text: e.email ?? "");
            return _buildTextField(
              e.type ?? 'Email Address',
              emailCtrl,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl,
      {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        readOnly: readOnly || !isEditing, // <-- important
        enabled: !readOnly,                // <-- disable native focus for read-only
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label.toUpperCase(),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildDOBField(String label, TextEditingController ctrl) {
    return GestureDetector(
      onTap: isEditing ? _pickDOB : null,
      child: _buildTextField(
        label,
        ctrl,
        readOnly: true,
      ),
    );
  }


  Widget _buildStaticField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text("$label: $value"),
    );
  }

  Widget _buildSectionTitle(String title,
      {bool showEdit = false, bool showAdd = false}) {
    return Row(
      children: [
        Icon(
          title.contains('Phone')
              ? Icons.phone_iphone
              : title.contains('Email')
              ? Icons.email
              : Icons.person,
          color: Colors.white,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        if (showEdit)
          InkWell(
            onTap: () {
              if (isEditing) {
                _saveData();
              } else {
                setState(() => isEditing = true);
              }
            },
            child: _editButton(),
          ),
        if (showAdd) const SizedBox(width: 8),
        if (showAdd)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: _buttonDecoration(),
            child: const Icon(Icons.add, color: Colors.blue, size: 20),
          ),
      ],
    );
  }

  Widget _editButton() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: _buttonDecoration(),
      child: Icon(
        isEditing ? Icons.check : Icons.edit,
        color: Colors.blue,
        size: 20,
      ),
    );
  }

  BoxDecoration _buttonDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade300),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}
