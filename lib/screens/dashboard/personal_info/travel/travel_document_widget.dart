import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/personal_information/basic_information_post/country/country_model.dart';
import '../../../../models/personal_information/passport.dart';
import '../../../../models/personal_information/visa.dart';

class TravelDocumentsWidget extends StatefulWidget {
  final List<Passport> passports;
  final List<Visa> visas;
  final List<Country> countries;

  const TravelDocumentsWidget({
    super.key,
    required this.passports,
    required this.visas,
    required this.countries,
  });

  @override
  State<TravelDocumentsWidget> createState() => _TravelDocumentsWidgetState();
}

class _TravelDocumentsWidgetState extends State<TravelDocumentsWidget> {
  bool isPassportEditing = false;
  bool isVisaEditing = false;

  // --------------------- DATE PICKER ----------------------
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

            // COUNTRY DROPDOWN
            _buildCountryDropdown(
              label: "Country",
              selected: p.country!.isEmpty ? null : p.country,
              editable: isPassportEditing,
              onChanged: (value) {
                setState(() => p.country = value ?? "");
              },
            ),

            _buildDateRow("Issued Date", p.issueDate, isPassportEditing, (newVal) {
              setState(() => p.issueDate = newVal!);
            }),
            _buildDateRow("Expiry Date", p.expiryDate, isPassportEditing, (newVal) {
              setState(() => p.expiryDate = newVal!);
            }),
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
            // 🔥 REPLACED TEXT FIELD WITH COUNTRY DROPDOWN
            _buildCountryDropdown(
              label: "Visa Country",
              selected: v.visaCountry.isEmpty ? null : v.visaCountry,
              editable: isVisaEditing,
              onChanged: (value) {
                setState(() => v.visaCountry = value ?? "");
              },
            ),

            _buildEditableRow("Visa Type", v.visaType, isVisaEditing),
            _buildEditableRow("Description", v.visaDescription, isVisaEditing),

            _buildDateRow("Grant Date", v.visaGrantDate, isVisaEditing, (newVal) {
              setState(() => v.visaGrantDate = newVal!);
            }),
            _buildDateRow("Expiry Date", v.visaExpiryDate, isVisaEditing, (newVal) {
              setState(() => v.visaExpiryDate = newVal!);
            }),
          ]),
        ),
      ],
    );
  }

  // --------------------- SECTION TITLE ----------------------
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

  // --------------------- CARD WRAPPER ----------------------
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

  // --------------------- NORMAL TEXT FIELD ----------------------
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

  // --------------------- COUNTRY DROPDOWN ----------------------
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
            value: selected,
            isExpanded: true,
            onChanged: onChanged,
            items: widget.countries.map((c) {
              return DropdownMenuItem(
                value: c.name,
                child: Text(c.name),
              );
            }).toList(),
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

  // --------------------- DATE PICKER ROW ----------------------
  Widget _buildDateRow(
      String label,
      String? value,
      bool editable,
      ValueChanged<String?> onChanged,
      ) {
    final controller = TextEditingController(text: value ?? "");

    return GestureDetector(
      onTap: editable
          ? () async {
        final newDate = await _pickDate(controller.text);
        if (newDate != null) {
          controller.text = newDate;
          onChanged(newDate);
        }
      }
          : null,
      child: AbsorbPointer(
        absorbing: true,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: TextFormField(
            controller: controller,
            readOnly: true,
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
        ),
      ),
    );
  }
}
