import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../../../models/personal_information/address.dart';
import '../../../../models/personal_information/travel.dart';
import '../../../../models/personal_information/basic_information_post/country/country_model.dart';
import '../../../../services/api_service.dart';

class AddressAndTravelInformationWidget extends StatefulWidget {
  final List<Address> addresses;
  final List<Travel> travels;
  final List<Country> countries;

  const AddressAndTravelInformationWidget({
    super.key,
    required this.addresses,
    required this.travels,
    required this.countries,
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

  // ---------------------------------------------------------------
  // SAVE ADDRESSES API CALL
  // ---------------------------------------------------------------
  Future<void> _saveAddresses() async {
    try {
      final addressesPayload =
      widget.addresses.map((a) => a.toJson()).toList();
      final response =
      await ApiService.updateClientAddressDetail(addressesPayload);
      if (response['success'] == true || response['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Addresses updated successfully')),
        );
        setState(() => isEditingAddress = false); // exit edit mode
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  response['message'] ?? 'Failed to update addresses')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // ---------------------------------------------------------------
  // SAVE TRAVELS API CALL (optional)
  // ---------------------------------------------------------------
  Future<void> _saveTravels() async {
    try {
      /*final travelsPayload = widget.travels.map((t) => t.toJson()).toList();
      final response = await ApiService.updateClientTravelDetail(travelsPayload);
      if (response['success'] == true || response['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Travels updated successfully')),
        );
        setState(() => isEditingTravel = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  response['message'] ?? 'Failed to update travels')),
        );
      }*/
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ADDRESS INFORMATION
          _buildSectionTitle(
            "Address Information",
            icon: Icons.home_rounded,
            isEditing: isEditingAddress,
            onEdit: () {
              if (isEditingAddress) {
                _saveAddresses();
              } else {
                setState(() => isEditingAddress = !isEditingAddress);
              }
            },
            onAdd: () {},
            showAdd: true,
          ),
          const SizedBox(height: 12),

          ...widget.addresses.map(
                (address) => _buildInfoCard([
              _buildEditableRow(
                  "Search Address", address.searchAddress, isEditingAddress,
                      (val) => address.searchAddress = val),
              _buildEditableRow(
                  "Address Line 1", address.addressLine1 ?? "-", isEditingAddress,
                      (val) => address.addressLine1 = val),
              _buildEditableRow(
                  "Address Line 2", address.addressLine2 ?? "-", isEditingAddress,
                      (val) => address.addressLine2 = val),
              _buildEditableRow("Suburb", address.suburb, isEditingAddress,
                      (val) => address.suburb = val),
              _buildEditableRow("State", address.state, isEditingAddress,
                      (val) => address.state = val),
              _buildEditableRow(
                  "Postcode", address.postcode.toString(), isEditingAddress,
                      (val) => address.postcode = int.tryParse(val) ?? address.postcode),
              _buildCountryDropdown(
                label: "Country",
                editable: isEditingAddress,
                selected: address.country,
                onChanged: (val) => setState(() => address.country = val ?? ""),
              ),
              _buildEditableRow("Regional Code", address.regionalCode ?? "-", isEditingAddress,
                      (val) => address.regionalCode = val),
              _buildDateRow(
                "Start Date",
                address.startDate ?? "-",
                isEditingAddress,
                    (val) => address.startDate = val,
              ),
              _buildDateRow(
                "End Date",
                address.endDate ?? "-",
                isEditingAddress,
                    (val) => address.endDate = val,
              ),
              _buildEditableRow("Is Current", address.isCurrent ? "Yes" : "No", isEditingAddress,
                      (val) => address.isCurrent = val.toLowerCase() == "yes"),
            ]),
          ),

          if (isEditingAddress)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ElevatedButton.icon(
                onPressed: _saveAddresses,
                icon: const Icon(Icons.save),
                label: const Text("Save Addresses"),
              ),
            ),

          const SizedBox(height: 28),

          /// TRAVEL INFORMATION
          _buildSectionTitle(
            "Travel Information",
            icon: Icons.flight_takeoff_rounded,
            isEditing: isEditingTravel,
            onEdit: () {
              if (isEditingTravel) {
                _saveTravels();
              } else {
                setState(() => isEditingTravel = !isEditingTravel);
              }
            },
            onAdd: () {},
            showAdd: true,
          ),
          const SizedBox(height: 12),

          ...widget.travels.map(
                (travel) => _buildInfoCard([
              _buildCountryDropdown(
                label: "Country Visited",
                editable: isEditingTravel,
                selected: travel.countryVisited,
                onChanged: (val) => setState(() => travel.countryVisited = val ?? ""),
              ),
              _buildDateRow(
                "Arrival Date",
                travel.arrivalDate,
                isEditingTravel,
                    (val) => travel.arrivalDate = val!,
              ),
              _buildDateRow(
                "Departure Date",
                travel.departureDate,
                isEditingTravel,
                    (val) => travel.departureDate = val!,
              ),
              _buildEditableRow("Travel Purpose", travel.purpose, isEditingTravel,
                      (val) => travel.purpose = val),
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
  Widget _buildEditableRow(
      String label, String value, bool enabled, ValueChanged<String> onChanged) {
    final controller = TextEditingController(text: value);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
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
        onChanged: onChanged,
      ),
    );
  }

  // ---------------------------------------------------------------
  // COUNTRY DROPDOWN
  // ---------------------------------------------------------------
  Widget _buildCountryDropdown({
    required String label,
    required String? selected,
    required bool editable,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label.toUpperCase(),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        child: editable
            ? DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selected!.isEmpty ? null : selected,
            isExpanded: true,
            onChanged: onChanged,
            items: widget.countries
                .map((c) => DropdownMenuItem(
              value: c.name,
              child: Text(c.name),
            ))
                .toList(),
          ),
        )
            : Text(
          selected ?? "",
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // DATE PICKER ROW
  // ---------------------------------------------------------------
  Widget _buildDateRow(
      String label, String value, bool enabled, ValueChanged<String?> onChanged) {
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
