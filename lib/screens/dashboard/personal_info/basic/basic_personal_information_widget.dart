import 'package:flutter/material.dart';

import '../../../../models/personal_information/basic_information.dart';
import '../../../../models/personal_information/email.dart';
import '../../../../models/personal_information/phone.dart';

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

  @override
  Widget build(BuildContext context) {
    final basic = widget.basicInfo;
    final phones = widget.phones ?? [];
    final emails = widget.emails ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ---------------- BASIC INFO ----------------
        _buildSectionTitle('Basic Information', showEdit: true),
        const SizedBox(height: 12),

        _buildInfoCard([
          _buildEditableRow('Name', basic?.fullName ?? '-'),
          _buildEditableRow('Client ID', basic?.clientId ?? '-'),
          _buildEditableRow('Date of Birth', basic?.dateOfBirth ?? '-'),
          _buildEditableRow('Age', basic?.age ?? '-'),
          _buildEditableRow('Gender', basic?.gender ?? '-'),
          _buildEditableRow('Marital Status', basic?.maritalStatus ?? '-'),
        ]),

        const SizedBox(height: 24),

        /// ---------------- PHONE NUMBERS ----------------
        _buildSectionTitle('Phone Numbers', showEdit: true, showAdd: true),
        const SizedBox(height: 12),

        _buildInfoCard(
          phones.isEmpty
              ? [_buildEditableRow('No Phone Records', '')]
              : phones
              .map((p) => _buildEditableRow(
            p.type ?? 'Phone',
            "${p.countryCode ?? ''} ${p.phone ?? ''}",
          ))
              .toList(),
        ),

        const SizedBox(height: 24),

        /// ---------------- EMAILS ----------------
        _buildSectionTitle('Email Addresses', showEdit: true, showAdd: true),
        const SizedBox(height: 12),

        _buildInfoCard(
          emails.isEmpty
              ? [_buildEditableRow('No Email Records', '')]
              : emails
              .map((e) => _buildEditableRow(
            e.type ?? 'Email',
            e.email ?? '',
          ))
              .toList(),
        ),
      ],
    );
  }

  // ------------------------------------------------------
  // SECTION TITLE WITH EDIT & ADD BUTTONS
  // ------------------------------------------------------
  Widget _buildSectionTitle(
      String title, {
        bool showEdit = false,
        bool showAdd = false,
      }) {
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
              setState(() {
                isEditing = !isEditing;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(
                isEditing ? Icons.check : Icons.edit,
                color: Colors.blue,
                size: 20,
              ),
            ),
          ),

        if (showAdd) const SizedBox(width: 8),
        if (showAdd)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Icon(Icons.add, color: Colors.blue, size: 20),
          ),
      ],
    );
  }

  // ------------------------------------------------------
  // WHITE CARD CONTAINER
  // ------------------------------------------------------
  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // ------------------------------------------------------
  // EDITABLE TEXT FIELD ROW
  // ------------------------------------------------------
  Widget _buildEditableRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        initialValue: value,
        enabled: isEditing,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label.toUpperCase(),
          labelStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
            letterSpacing: 0.2,
          ),
          border: const OutlineInputBorder(),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}
