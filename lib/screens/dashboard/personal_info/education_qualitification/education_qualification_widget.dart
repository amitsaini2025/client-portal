import 'package:flutter/material.dart';

class EducationalQualificationsWidget extends StatefulWidget {
  const EducationalQualificationsWidget({super.key});

  @override
  State<EducationalQualificationsWidget> createState() =>
      _EducationalQualificationsWidgetState();
}

class _EducationalQualificationsWidgetState
    extends State<EducationalQualificationsWidget> {
  bool isEditing = false;

  // Sample data for educational qualifications
  List<Map<String, String>> qualifications = [
    {
      "Level": "Masters Degree",
      "Name": "MCA",
      "Institution": "BBDNITM",
      "Campus": "Lucknow",
      "Country": "India",
      "Status": "Completed",
      "Start Date": "01/07/2006",
      "Finish Date": "30/06/2009",
      "Relevant": "Yes",
    },
    {
      "Level": "Bachelor Degree",
      "Name": "BSC",
      "Institution": "RHPG college",
      "Campus": "Kashipur",
      "Country": "India",
      "Status": "Completed",
      "Start Date": "01/07/2003",
      "Finish Date": "30/06/2006",
      "Relevant": "Yes",
    },
  ];

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
            onEdit: () {
              setState(() => isEditing = !isEditing);
            },
            onAdd: () {
              setState(() {
                qualifications.add({
                  "Level": "",
                  "Name": "",
                  "Institution": "",
                  "Campus": "",
                  "Country": "",
                  "Status": "",
                  "Start Date": "",
                  "Finish Date": "",
                  "Relevant": "No",
                });
              });
            },
          ),
          const SizedBox(height: 18),

          /// Render all qualifications as editable cards
          ...qualifications.map((qual) => Column(
            children: [
              _buildQualificationCard(qual),
              const SizedBox(height: 18),
            ],
          )),
        ],
      ),
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
        VoidCallback? onAdd,
      }) {
    return Row(
      children: [
        const Icon(
          Icons.school_rounded,
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

  /// ----------------------------
  /// QUALIFICATION CARD
  /// ----------------------------
  Widget _buildQualificationCard(Map<String, String> qualification) {
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
          _buildEditableRow("Level", qualification),
          _buildEditableRow("Name", qualification),
          _buildEditableRow("Institution", qualification),
          _buildEditableRow("Campus", qualification),
          _buildEditableRow("Country", qualification),
          _buildEditableRow("Status", qualification),
          _buildEditableRow("Start Date", qualification),
          _buildEditableRow("Finish Date", qualification),
          _buildEditableRow("Relevant", qualification),
        ],
      ),
    );
  }

  /// ----------------------------
  /// EDITABLE ROW
  /// ----------------------------
  Widget _buildEditableRow(String key, Map<String, String> qualification) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: qualification[key],
        enabled: isEditing,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        onChanged: (val) {
          setState(() {
            qualification[key] = val;
          });
        },
        decoration: InputDecoration(
          labelText: key.toUpperCase(),
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
