import 'package:flutter/material.dart';

class TravelDocumentsWidget extends StatefulWidget {
  const TravelDocumentsWidget({super.key});

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

        /// ----------------------------
        /// PASSPORT SECTION
        /// ----------------------------
        _buildSectionTitle(
          "Passport Information",
          showEdit: true,
          showAdd: true,
          isEditing: isPassportEditing,
          onEdit: () {
            setState(() => isPassportEditing = !isPassportEditing);
          },
        ),

        const SizedBox(height: 12),

        _buildInfoCard([
          _buildEditableRow("Passport Number", "N9802312", isPassportEditing),
          _buildEditableRow("Country", "India", isPassportEditing),
          _buildEditableRow("Issued Place", "Sydney", isPassportEditing),
          _buildEditableRow("Issued Date", "21/10/2015", isPassportEditing),
          _buildEditableRow("Expiry Date", "20/10/2025", isPassportEditing),
        ]),

        const SizedBox(height: 24),

        /// ----------------------------
        /// VISA SECTION
        /// ----------------------------
        _buildSectionTitle(
          "Visa Information",
          showEdit: true,
          showAdd: true,
          isEditing: isVisaEditing,
          onEdit: () {
            setState(() => isVisaEditing = !isVisaEditing);
          },
        ),

        const SizedBox(height: 12),

        _buildInfoCard([
          _buildEditableRow("Visa Number", "AU12345VISA", isVisaEditing),
          _buildEditableRow("Type", "Temporary Resident Visa", isVisaEditing),
          _buildEditableRow("Issued Country", "Australia", isVisaEditing),
          _buildEditableRow("Issued Date", "12/05/2020", isVisaEditing),
          _buildEditableRow("Expiry Date", "12/05/2025", isVisaEditing),
        ]),
      ],
    );
  }

  /// ----------------------------
  /// SECTION TITLE
  /// ----------------------------
  Widget _buildSectionTitle(
      String title, {
        required bool showEdit,
        required bool showAdd,
        required bool isEditing,
        required VoidCallback onEdit,
      }) {
    return Row(
      children: [
        Icon(
          Icons.file_copy,
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

        /// ADD Button
        if (showAdd)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.add,
              color: Colors.blue,
              size: 20,
            ),
          ),

        if (showAdd) const SizedBox(width: 8),

        /// EDIT Button
        if (showEdit)
          InkWell(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isEditing ? Icons.check : Icons.edit,
                color: Colors.blue,
                size: 20,
              ),
            ),
          ),
      ],
    );
  }

  /// ----------------------------
  /// CARD
  /// ----------------------------
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

  /// ----------------------------
  /// ROW FIELD
  /// ----------------------------
  Widget _buildEditableRow(String label, String value, bool editable) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        initialValue: value,
        enabled: editable,
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
    );
  }
}
