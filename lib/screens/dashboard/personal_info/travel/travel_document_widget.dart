import 'package:flutter/material.dart';

import '../../../../models/personal_information/passport.dart';
import '../../../../models/personal_information/visa.dart';

class TravelDocumentsWidget extends StatefulWidget {
  final List<Passport> passports;
  final List<Visa> visas;

  const TravelDocumentsWidget({
    super.key,
    required this.passports,
    required this.visas,
  });

  @override
  State<TravelDocumentsWidget> createState() => _TravelDocumentsWidgetState();
}

class _TravelDocumentsWidgetState extends State<TravelDocumentsWidget> {
  bool isPassportEditing = false;
  bool isVisaEditing = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          "Passport Information",
          showEdit: true,
          showAdd: true,
          isEditing: isPassportEditing,
          onEdit: () => setState(() => isPassportEditing = !isPassportEditing),
        ),
        const SizedBox(height: 12),

        ...widget.passports.map(
              (p) => _buildInfoCard([
            _buildEditableRow("Passport Number", p.passportNumber, isPassportEditing),
            _buildEditableRow("Country", p.country, isPassportEditing),
            _buildEditableRow("Issued Date", p.issueDate, isPassportEditing),
            _buildEditableRow("Expiry Date", p.expiryDate, isPassportEditing),
          ]),
        ),

        const SizedBox(height: 24),

        _buildSectionTitle(
          "Visa Information",
          showEdit: true,
          showAdd: true,
          isEditing: isVisaEditing,
          onEdit: () => setState(() => isVisaEditing = !isVisaEditing),
        ),
        const SizedBox(height: 12),

        ...widget.visas.map(
              (v) => _buildInfoCard([
            _buildEditableRow("Visa Country", v.visaCountry, isVisaEditing),
            _buildEditableRow("Visa Type", v.visaType, isVisaEditing),
            _buildEditableRow("Description", v.visaDescription, isVisaEditing),
            _buildEditableRow("Grant Date", v.visaGrantDate, isVisaEditing),
            _buildEditableRow("Expiry Date", v.visaExpiryDate, isVisaEditing),
          ]),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
      String title, {
        required bool showEdit,
        required bool showAdd,
        required bool isEditing,
        required VoidCallback onEdit,
      }) {
    return Row(
      children: [
        const Icon(Icons.file_copy, color: Colors.white),
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

        if (showAdd)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, color: Colors.blue),
          ),
        const SizedBox(width: 8),

        InkWell(
          onTap: onEdit,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isEditing ? Icons.check : Icons.edit,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 14),
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

  Widget _buildEditableRow(String label, String? value, bool editable) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        initialValue: value ?? "",
        enabled: editable,
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
}
