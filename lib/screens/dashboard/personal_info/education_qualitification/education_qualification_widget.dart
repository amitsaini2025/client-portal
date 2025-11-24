import 'package:flutter/material.dart';
import '../../../../models/personal_information/qualification.dart';

class EducationalQualificationsWidget extends StatefulWidget {
  final List<Qualification> qualifications;

  const EducationalQualificationsWidget({
    super.key,
    required this.qualifications,
  });

  @override
  State<EducationalQualificationsWidget> createState() =>
      _EducationalQualificationsWidgetState();
}

class _EducationalQualificationsWidgetState
    extends State<EducationalQualificationsWidget> {
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            "Educational Qualifications",
            showEdit: true,
            showAdd: true,
            isEditing: isEditing,
            onEdit: () => setState(() => isEditing = !isEditing),
            onAdd: () {
              setState(() {
                widget.qualifications.add(
                  Qualification(
                    id: DateTime.now().millisecondsSinceEpoch,
                    level: "",
                    name: "",
                    collegeName: "",
                    campus: "",
                    country: "",
                    state: "",
                    startDate: "",
                    finishDate: "",
                    relevantQualification: false,
                    specialistEducation: false,
                    stemQualification: false,
                    regionalStudy: false,
                  ),
                );
              });
            },
          ),
          const SizedBox(height: 18),

          ...widget.qualifications.map(
                (qual) => Column(
              children: [
                _buildQualificationCard(qual),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      String title, {
        required bool showEdit,
        required bool showAdd,
        required bool isEditing,
        required VoidCallback onEdit,
        VoidCallback? onAdd,
      }) {
    return Row(
      children: [
        const Icon(Icons.school_rounded, color: Colors.white),
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
        if (showAdd && onAdd != null)
          InkWell(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.blue, size: 20),
            ),
          ),
        if (showAdd) const SizedBox(width: 8),
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

  Widget _buildQualificationCard(Qualification qual) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEditableRow("Level", qual.level, (val) => qual.level = val),
          _buildEditableRow("Name", qual.name, (val) => qual.name = val),
          _buildEditableRow(
              "Institution", qual.collegeName, (val) => qual.collegeName = val),
          _buildEditableRow("Campus", qual.campus, (val) => qual.campus = val),
          _buildEditableRow("Country", qual.country, (val) => qual.country = val),
          _buildEditableRow("State", qual.state ?? "", (val) => qual.state = val),
          _buildEditableRow("Start Date", qual.startDate, (val) => qual.startDate = val),
          _buildEditableRow("Finish Date", qual.finishDate, (val) => qual.finishDate = val),
          _buildCheckboxRow(
              "Relevant", qual.relevantQualification, (val) => qual.relevantQualification = val),
          _buildCheckboxRow(
              "Specialist Education", qual.specialistEducation, (val) => qual.specialistEducation = val),
          _buildCheckboxRow(
              "STEM Qualification", qual.stemQualification, (val) => qual.stemQualification = val),
          _buildCheckboxRow(
              "Regional Study", qual.regionalStudy, (val) => qual.regionalStudy = val),
        ],
      ),
    );
  }

  Widget _buildEditableRow(
      String label, String value, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: value,
        enabled: isEditing,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        onChanged: (val) => onChanged(val),
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

  Widget _buildCheckboxRow(String label, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
        Checkbox(
          value: value,
          onChanged: isEditing ? (val) => onChanged(val ?? false) : null,
        ),
      ],
    );
  }
}
