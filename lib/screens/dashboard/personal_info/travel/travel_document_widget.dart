import 'package:client/models/personal_information/basic_information_post/visa_types/visa_type.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/personal_information/basic_information_post/country/country_model.dart';
import '../../../../models/personal_information/passport.dart';
import '../../../../models/personal_information/visa.dart';
import '../../../../services/api_service.dart';

class TravelDocumentsWidget extends StatefulWidget {
  final List<Passport> passports;
  final List<Visa> visas;
  final List<Country> countries;
  final List<VisaType> visaTypes;

  const TravelDocumentsWidget({
    super.key,
    required this.passports,
    required this.visas,
    required this.countries,
    required this.visaTypes,
  });

  @override
  State<TravelDocumentsWidget> createState() => _TravelDocumentsWidgetState();
}

class _TravelDocumentsWidgetState extends State<TravelDocumentsWidget> {
  bool isPassportEditing = false;
  bool isVisaEditing = false;

  final Map<Passport, TextEditingController> _passportNumberControllers = {};
  final Map<Passport, TextEditingController> _passportIssueControllers = {};
  final Map<Passport, TextEditingController> _passportExpiryControllers = {};

  final Map<Visa, TextEditingController> _visaDescriptionControllers = {};
  final Map<Visa, TextEditingController> _visaGrantControllers = {};
  final Map<Visa, TextEditingController> _visaExpiryControllers = {};

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

  Future<void> _savePassports() async {
    final payload = widget.passports.map((p) {
      return {
        "id": p.id == 0 ? null : p.id,
        "passport_number": p.passportNumber ?? "",
        "country": p.country ?? "",
        "issue_date": p.issueDate ?? "",
        "expiry_date": p.expiryDate ?? "",
      };
    }).toList();

    final res = await ApiService.updateClientPassportDetail(payload);

    if (res["success"] == true && res["data"] != null && res["data"]["passports"] != null) {
      final List<dynamic> updatedData = res["data"]["passports"];

      // Update local IDs and other fields from API response
      for (int i = 0; i < updatedData.length; i++) {
        final apiPassport = updatedData[i];
        final localPassport = widget.passports[i];
        localPassport.id = apiPassport["id"];
        localPassport.passportNumber = apiPassport["passport_number"];
        localPassport.country = apiPassport["country"];
        localPassport.issueDate = apiPassport["issue_date"];
        localPassport.expiryDate = apiPassport["expiry_date"];
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passports updated successfully")),
      );
      setState(() => isPassportEditing = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Passport update failed")),
      );
    }
  }

  Future<void> _saveVisas() async {
    final payload = widget.visas.map((v) {
      return {
        "id": v.id == 0 ? null : v.id,
        "visa_country": v.visaCountry ?? "",
        "visa_type": v.visaType ?? "",
        "visa_description": v.visaDescription ?? "",
        "visa_grant_date": v.visaGrantDate ?? "",
        "visa_expiry_date": v.visaExpiryDate ?? "",
      };
    }).toList();

    final res = await ApiService.updateClientVisaDetail(payload);

    if (res["success"] == true && res["data"] != null && res["data"]["visas"] != null) {
      final List<dynamic> updatedData = res["data"]["visas"];

      for (int i = 0; i < updatedData.length; i++) {
        final apiVisa = updatedData[i];
        final localVisa = widget.visas[i];

        localVisa.id = apiVisa["id"];
        localVisa.visaCountry = apiVisa["visa_country"];
        localVisa.visaType = apiVisa["visa_type"];
        localVisa.visaDescription = apiVisa["visa_description"];
        localVisa.visaGrantDate = apiVisa["visa_grant_date"];
        localVisa.visaExpiryDate = apiVisa["visa_expiry_date"];
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Visas updated successfully")),
      );
      setState(() => isVisaEditing = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Visa update failed")),
      );
    }
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
          onEdit: () {
            if (isPassportEditing) {
              _savePassports();
            } else {
              setState(() => isPassportEditing = true);
            }
          },
          onAdd: () {
            setState(() {
              final p = Passport(id: 0, passportNumber: "", country: "", issueDate: "", expiryDate: "");
              widget.passports.add(p);
              isPassportEditing = true;
            });
          },
        ),
        const SizedBox(height: 12),
        ...widget.passports.map((p) => _buildPassportCard(p)),

        const SizedBox(height: 24),

        _buildSectionTitle(
          "Visa Information",
          showEdit: true,
          showAdd: true,
          isEditing: isVisaEditing,
          onEdit: () {
            if (isVisaEditing) {
              _saveVisas();
            } else {
              setState(() => isVisaEditing = true);
            }
          },
          onAdd: () {
            setState(() {
              final v = Visa(
                id: 0,
                visaCountry: "",
                visaType: "",
                visaDescription: "",
                visaGrantDate: "",
                visaExpiryDate: "",
              );
              widget.visas.add(v);
              isVisaEditing = true;
            });
          },
        ),
        const SizedBox(height: 12),
        ...widget.visas.map((v) => _buildVisaCard(v)),
      ],
    );
  }

  Widget _buildSectionTitle(String title,
      {required bool showEdit,
        required bool showAdd,
        required bool isEditing,
        required VoidCallback onEdit,
        required VoidCallback onAdd}) {
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
          InkWell(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.blue),
            ),
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

  Widget _buildPassportCard(Passport p) {
    final numberController = _passportNumberControllers.putIfAbsent(p, () => TextEditingController(text: p.passportNumber));
    final issueController = _passportIssueControllers.putIfAbsent(p, () => TextEditingController(text: p.issueDate));
    final expiryController = _passportExpiryControllers.putIfAbsent(p, () => TextEditingController(text: p.expiryDate));

    return _buildInfoCard([
      _buildEditableRow("Passport Number", numberController, (val) => p.passportNumber = val, isPassportEditing),
      _buildCountryDropdown(
        label: "Country",
        selected: p.country,
        editable: isPassportEditing,
        onChanged: (val) => setState(() => p.country = val ?? ""),
      ),
      _buildDateRow("Issued Date", issueController, (val) => p.issueDate = val ?? "", isPassportEditing),
      _buildDateRow("Expiry Date", expiryController, (val) => p.expiryDate = val ?? "", isPassportEditing),
    ]);
  }

  Widget _buildVisaCard(Visa v) {
    final descriptionController = _visaDescriptionControllers.putIfAbsent(v, () => TextEditingController(text: v.visaDescription));
    final grantController = _visaGrantControllers.putIfAbsent(v, () => TextEditingController(text: v.visaGrantDate));
    final expiryController = _visaExpiryControllers.putIfAbsent(v, () => TextEditingController(text: v.visaExpiryDate));

    return _buildInfoCard([
      _buildCountryDropdown(
        label: "Visa Country",
        selected: v.visaCountry,
        editable: isVisaEditing,
        onChanged: (val) => setState(() => v.visaCountry = val ?? ""),
      ),
      _buildVisaTypeDropdown(
        label: "Visa Type",
        selectedId: int.tryParse(v.visaType),
        editable: isVisaEditing,
        onChanged: (id) => setState(() => v.visaType = id?.toString() ?? ""),
      ),
      _buildEditableRow("Description", descriptionController, (val) => v.visaDescription = val, isVisaEditing),
      _buildDateRow("Grant Date", grantController, (val) => v.visaGrantDate = val ?? "", isVisaEditing),
      _buildDateRow("Expiry Date", expiryController, (val) => v.visaExpiryDate = val ?? "", isVisaEditing),
    ]);
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildEditableRow(String label, TextEditingController controller, ValueChanged<String> onChanged, bool editable) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        enabled: editable,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label.toUpperCase(),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDateRow(String label, TextEditingController controller, ValueChanged<String?> onChanged, bool editable) {
    return GestureDetector(
      onTap: editable
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
        absorbing: true,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: TextFormField(
            controller: controller,
            readOnly: true,
            enabled: editable,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            decoration: InputDecoration(
              labelText: label.toUpperCase(),
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
      ),
    );
  }

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
            value: selected?.isEmpty ?? true ? null : selected,
            isExpanded: true,
            onChanged: onChanged,
            items: widget.countries
                .map((c) => DropdownMenuItem(value: c.name, child: Text(c.name)))
                .toList(),
          ),
        )
            : Text(selected ?? "", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildVisaTypeDropdown({
    required String label,
    required int? selectedId,
    required bool editable,
    required ValueChanged<int?> onChanged,
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
          child: DropdownButton<int>(
            value: widget.visaTypes.any((v) => v.id == selectedId) ? selectedId : null,
            isExpanded: true,
            onChanged: onChanged,
            items: widget.visaTypes
                .map((v) => DropdownMenuItem<int>(value: v.id, child: Text(v.title)))
                .toList(),
          ),
        )
            : Text(
          selectedId != null
              ? (widget.visaTypes
              .firstWhere((vt) => vt.id == selectedId, orElse: () => VisaType(id: 0, title: "", nickName: ''))
              .title)
              : "",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
