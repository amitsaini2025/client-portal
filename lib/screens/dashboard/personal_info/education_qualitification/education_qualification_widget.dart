import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/personal_information/basic_information_post/country/country_model.dart';
import '../../../../models/personal_information/qualification.dart';
import '../../../../services/api_service.dart';

class EducationalQualificationsWidget extends StatefulWidget {
  final List<Qualification> qualifications;
  final List<Country> countries;

  const EducationalQualificationsWidget({
    super.key,
    required this.qualifications,
    required this.countries,
  });

  @override
  State<EducationalQualificationsWidget> createState() =>
      _EducationalQualificationsWidgetState();
}

class _EducationalQualificationsWidgetState
    extends State<EducationalQualificationsWidget> {
  bool isEditing = false;

  final List<String> qualificationLevels = [
    "Certificate I",
    "Certificate II",
    "Certificate III",
    "Certificate IV",
    "Diploma",
    "Advanced Diploma",
    "Bachelor Degree",
    "Bachelor Honours Degree",
    "Graduate Certificate",
    "Graduate Diploma",
    "Masters Degree",
    "Doctoral Degree",
    "Other",
  ];

  List<Map<String, dynamic>> convertQualificationsToJson() {
    return widget.qualifications.map((q) {
      return {
        "id": q.id,
        "level": q.level,
        "name": q.name,
        "college_name": q.collegeName,
        "campus": q.campus,
        "country": q.country,
        "state": q.state,
        "start_date": q.startDate,
        "finish_date": q.finishDate,
        "relevant_qualification": q.relevantQualification,
        "specialist_education": q.specialistEducation,
        "stem_qualification": q.stemQualification,
        "regional_study": q.regionalStudy,
      };
    }).toList();
  }

  void _addQualification() {
    setState(() {
      widget.qualifications.add(Qualification(
        id: null,
        level: "",
        name: "",
        collegeName: "",
        campus: "",
        country: "",
        state: null,
        startDate: "",
        finishDate: "",
        relevantQualification: false,
        specialistEducation: false,
        stemQualification: false,
        regionalStudy: false,
      ));
      isEditing = true;
    });
  }

  Future<void> _saveQualifications() async {
    try {
      final payload = convertQualificationsToJson();
      final response = await ApiService.updateClientQualificationDetail(payload);
      if (response['success'] == true &&
          response['data'] != null &&
          response['data']['qualifications'] != null) {
        final List<dynamic> updatedList = response['data']['qualifications'];
        for (int i = 0; i < updatedList.length; i++) {
          if (i >= widget.qualifications.length) break;

          final api = updatedList[i];
          final local = widget.qualifications[i];

          local.id = api['id'];
          local.level = api['level'] ?? "";
          local.name = api['name'] ?? "";
          local.collegeName = api['college_name'] ?? "";
          local.campus = api['campus'] ?? "";
          local.country = api['country'] ?? "";
          local.state = api['state'] ?? "";
          local.startDate = api['start_date'] ?? "";
          local.finishDate = api['finish_date'] ?? "";
          local.relevantQualification = api['relevant_qualification'] ?? false;
          local.specialistEducation = api['specialist_education'] ?? false;
          local.stemQualification = api['stem_qualification'] ?? false;
          local.regionalStudy = api['regional_study'] ?? false;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Qualifications updated successfully')),
        );

        setState(() => isEditing = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to update qualifications'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating qualifications: $e')),
      );
    }
  }


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
          _buildSectionTitle(
            "Educational Qualifications",
            icon: Icons.school_rounded,
            isEditing: isEditing,
            onEdit: () {
              if (isEditing) {
                _saveQualifications();
              } else {
                setState(() => isEditing = true);
              }
            },
            onAdd: _addQualification,
            showAdd: true,
          ),
          const SizedBox(height: 12),
          ...widget.qualifications.map(
                (qual) => _buildInfoCard([
              _buildDropdown(
                label: "Level",
                value: qual.level,
                items: qualificationLevels,
                enabled: isEditing,
                onChanged: (val) => setState(() => qual.level = val ?? ""),
              ),
              _buildEditableRow("Name", qual.name, isEditing,
                      (val) => qual.name = val),
              _buildEditableRow("Institution", qual.collegeName, isEditing,
                      (val) => qual.collegeName = val),
              _buildEditableRow("Campus", qual.campus, isEditing,
                      (val) => qual.campus = val),
              _buildDropdown(
                label: "Country",
                value: qual.country,
                items: widget.countries.map((c) => c.name).toList(),
                enabled: isEditing,
                onChanged: (val) => setState(() => qual.country = val ?? ""),
              ),
              _buildEditableRow(
                  "State", qual.state ?? "", isEditing, (val) => qual.state = val),
              _buildDateRow("Start Date", qual.startDate, isEditing,
                      (val) => qual.startDate = val!),
              _buildDateRow("Finish Date", qual.finishDate, isEditing,
                      (val) => qual.finishDate = val!),
              _buildCheckbox(
                  "Relevant", qual.relevantQualification, isEditing,
                      (val) => qual.relevantQualification = val),
              _buildCheckbox(
                  "Specialist Education", qual.specialistEducation, isEditing,
                      (val) => qual.specialistEducation = val),
              _buildCheckbox(
                  "STEM Qualification", qual.stemQualification, isEditing,
                      (val) => qual.stemQualification = val),
              _buildCheckbox(
                  "Regional Study", qual.regionalStudy, isEditing,
                      (val) => qual.regionalStudy = val),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      String title, {
        required IconData icon,
        required bool isEditing,
        required VoidCallback onEdit,
        required VoidCallback onAdd,
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

  Widget _buildEditableRow(
      String label, String value, bool enabled, ValueChanged<String> onChanged) {
    final controller = TextEditingController(text: value);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label.toUpperCase(),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required bool enabled,
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
        child: enabled
            ? DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value.isEmpty ? null : value,
            isExpanded: true,
            onChanged: onChanged,
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
          ),
        )
            : Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDateRow(
      String label, String value, bool enabled, ValueChanged<String?> onChanged) {
    final controller = TextEditingController(text: value);
    return GestureDetector(
      onTap: !enabled
          ? null
          : () async {
        final picked = await _pickDate(controller.text);
        if (picked != null) {
          controller.text = picked;
          onChanged(picked);
          setState(() {});
        }
      },
      child: AbsorbPointer(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            readOnly: true,
            decoration: InputDecoration(
              labelText: label.toUpperCase(),
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(
      String label, bool value, bool enabled, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Checkbox(
          value: value,
          onChanged: enabled
              ? (v) {
            setState(() {
              onChanged(v ?? false);
            });
          }
              : null,
        ),
      ],
    );
  }
}
