import 'package:flutter/material.dart';

class BasicPersonalInformationWidget extends StatefulWidget {
  const BasicPersonalInformationWidget({super.key});

  @override
  State<BasicPersonalInformationWidget> createState() => _BasicPersonalInformationWidgetState();
}

class _BasicPersonalInformationWidgetState extends State<BasicPersonalInformationWidget> {
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Basic Information', showEdit: true),
        const SizedBox(height: 12),
        _buildInfoCard([
          _buildEditableRow('Name', 'Test User'),
          _buildEditableRow('Client ID', 'VIPL2400001'),
          _buildEditableRow('Date of Birth', '22/06/1989'),
          _buildEditableRow('Age', '39 years 7 months'),
          _buildEditableRow('Gender', 'Male'),
          _buildEditableRow('Marital Status', 'Married'),
        ]),

        const SizedBox(height: 24),

        _buildSectionTitle('Phone Numbers', showEdit: true, showAdd: true),
        const SizedBox(height: 12),
        _buildInfoCard([
          _buildEditableRow('Personal', '+919888888888'),
          _buildEditableRow('Mobile', '+914444444444'),
        ]),

        const SizedBox(height: 24),

        _buildSectionTitle('Email Addresses', showEdit: true, showAdd: true),
        const SizedBox(height: 12),
        _buildInfoCard([
          _buildEditableRow('Work', 'vipulcmca123@yahoo.co.in'),
          _buildEditableRow('Personal', 'viplucmca@yahoo.co.in'),
        ]),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {bool showEdit = false, bool showAdd = false}) {
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
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13, letterSpacing: 0.2),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}