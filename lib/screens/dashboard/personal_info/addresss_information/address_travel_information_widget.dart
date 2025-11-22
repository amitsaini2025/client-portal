import 'package:flutter/material.dart';

class AddressAndTravelInformationWidget extends StatefulWidget {
  const AddressAndTravelInformationWidget({super.key});

  @override
  State<AddressAndTravelInformationWidget> createState() =>
      _AddressAndTravelInformationWidgetState();
}

class _AddressAndTravelInformationWidgetState
    extends State<AddressAndTravelInformationWidget> {
  bool isEditingAddress = false;
  bool isEditingTravel = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------------------------------------------------
          // ADDRESS INFORMATION
          // ---------------------------------------------------------
          _buildSectionTitle(
            "Address Information",
            icon: Icons.home_rounded,
            isEditing: isEditingAddress,
            onEdit: () => setState(() => isEditingAddress = !isEditingAddress),
            onAdd: () {},
            showAdd: true,
          ),
          const SizedBox(height: 12),
          _buildInfoCard([
            _buildEditableRow("Address",
                "Kelly Road, Valley View, SA, 5093", isEditingAddress),
            _buildEditableRow("Start Date", "18/10/2023", isEditingAddress),
            _buildEditableRow("End Date", "16/05/2025", isEditingAddress),
            _buildEditableRow("Regional Code", "Regional City SA",
                isEditingAddress),
            const Divider(height: 30),
            _buildEditableRow("Address",
                "6 Lisbon Street, Glen Waverley, VIC, 3150", isEditingAddress),
            _buildEditableRow("Start Date", "", isEditingAddress),
            _buildEditableRow("End Date", "", isEditingAddress),
            _buildEditableRow(
                "Regional Code", "Metro Area VIC", isEditingAddress),
          ]),

          const SizedBox(height: 28),

          // ---------------------------------------------------------
          // TRAVEL INFORMATION
          // ---------------------------------------------------------
          _buildSectionTitle(
            "Travel Information",
            icon: Icons.flight_takeoff_rounded,
            isEditing: isEditingTravel,
            onEdit: () => setState(() => isEditingTravel = !isEditingTravel),
            onAdd: () {},
            showAdd: true,
          ),
          const SizedBox(height: 12),
          _buildInfoCard([
            _buildEditableRow(
                "Country Visited", "India", isEditingTravel),
            _buildEditableRow(
                "Arrival Date", "01/05/2024", isEditingTravel),
            _buildEditableRow(
                "Departure Date", "30/06/2024", isEditingTravel),
            _buildEditableRow("Travel Purpose", "Travel1", isEditingTravel),
          ]),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // SECTION TITLE (HEADER STYLE SAME AS BASIC PERSONAL INFO SCREEN)
  // ---------------------------------------------------------------
  Widget _buildSectionTitle(
      String title, {
        required bool isEditing,
        required VoidCallback onEdit,
        required VoidCallback onAdd,
        required IconData icon,
        bool showAdd = false,
      }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
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
        InkWell(
          onTap: onEdit,
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
          InkWell(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(Icons.add, color: Colors.blue, size: 20),
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------
  // WHITE CARD CONTAINER (SAME STYLE AS BASIC PERSONAL INFO)
  // ---------------------------------------------------------------
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

  // ---------------------------------------------------------------
  // EDITABLE ROW USING TEXTFORMFIELD
  // ---------------------------------------------------------------
  Widget _buildEditableRow(String label, String value, bool enabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        initialValue: value.isEmpty ? "-" : value,
        enabled: enabled,
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
