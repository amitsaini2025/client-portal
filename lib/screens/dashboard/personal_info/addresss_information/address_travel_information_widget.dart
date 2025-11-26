import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/personal_information/address.dart';
import '../../../../models/personal_information/travel.dart';

class AddressAndTravelInformationWidget extends StatefulWidget {
  final List<Address> addresses;
  final List<Travel> travels;

  const AddressAndTravelInformationWidget({
    super.key,
    required this.addresses,
    required this.travels,
  });

  @override
  State<AddressAndTravelInformationWidget> createState() =>
      _AddressAndTravelInformationWidgetState();
}

class _AddressAndTravelInformationWidgetState
    extends State<AddressAndTravelInformationWidget> {
  bool isEditingAddress = false;
  bool isEditingTravel = false;

  // ---------------------------------------------------------------
  // DATE PICKER
  // ---------------------------------------------------------------
  Future<String?> _pickDate(String current) async {
    DateTime initial;
    try {
      final parts = current.split('/');
      initial = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (_) {
      initial = DateTime.now();
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      return DateFormat("dd/MM/yyyy").format(picked);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ---------------------------------------------------------
          /// ADDRESS INFORMATION
          /// ---------------------------------------------------------
          _buildSectionTitle(
            "Address Information",
            icon: Icons.home_rounded,
            isEditing: isEditingAddress,
            onEdit: () => setState(() => isEditingAddress = !isEditingAddress),
            onAdd: () {},
            showAdd: true,
          ),
          const SizedBox(height: 12),

          ...widget.addresses.map(
                (address) => _buildInfoCard([
              _buildEditableRow("Search Address", address.searchAddress, isEditingAddress),
              _buildEditableRow("Address Line 1", address.addressLine1 ?? "-", isEditingAddress),
              _buildEditableRow("Address Line 2", address.addressLine2 ?? "-", isEditingAddress),
              _buildEditableRow("Suburb", address.suburb, isEditingAddress),
              _buildEditableRow("State", address.state, isEditingAddress),
              _buildEditableRow("Postcode", address.postcode.toString(), isEditingAddress),
              _buildEditableRow("Country", address.country, isEditingAddress),
              _buildEditableRow("Regional Code", address.regionalCode ?? "-", isEditingAddress),

              /// ---------- DATE PICKERS ----------
              _buildDateRow("Start Date", address.startDate ?? "-", isEditingAddress,
                      (val) => address.startDate = val),
              _buildDateRow("End Date", address.endDate ?? "-", isEditingAddress,
                      (val) => address.endDate = val),

              _buildEditableRow("Is Current", address.isCurrent ? "Yes" : "No", isEditingAddress),
            ]),
          ),

          const SizedBox(height: 28),

          /// ---------------------------------------------------------
          /// TRAVEL INFORMATION
          /// ---------------------------------------------------------
          _buildSectionTitle(
            "Travel Information",
            icon: Icons.flight_takeoff_rounded,
            isEditing: isEditingTravel,
            onEdit: () => setState(() => isEditingTravel = !isEditingTravel),
            onAdd: () {},
            showAdd: true,
          ),
          const SizedBox(height: 12),

          ...widget.travels.map(
                (travel) => _buildInfoCard([
              _buildEditableRow("Country Visited", travel.countryVisited, isEditingTravel),

              /// ---------- DATE PICKERS ----------
              _buildDateRow("Arrival Date", travel.arrivalDate, isEditingTravel,
                      (val) => travel.arrivalDate = val!),
              _buildDateRow("Departure Date", travel.departureDate, isEditingTravel,
                      (val) => travel.departureDate = val!),

              _buildEditableRow("Travel Purpose", travel.purpose, isEditingTravel),
            ]),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // SECTION TITLE
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
  // INFO CARD
  // ---------------------------------------------------------------
  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
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

  // ---------------------------------------------------------------
  // NORMAL EDITABLE ROW
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // DATE PICKER ROW
  // ---------------------------------------------------------------
  Widget _buildDateRow(
      String label,
      String value,
      bool enabled,
      ValueChanged<String?> onChanged,
      ) {
    final controller = TextEditingController(text: value);

    return GestureDetector(
      onTap: enabled
          ? () async {
        final newDate = await _pickDate(controller.text);
        if (newDate != null) {
          controller.text = newDate;
          onChanged(newDate);
          setState(() {});
        }
      }
          : null,
      child: AbsorbPointer(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            readOnly: true,
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
        ),
      ),
    );
  }
}
