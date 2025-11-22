import 'package:flutter/material.dart';

class OccupationSkillsWidget extends StatefulWidget {
  const OccupationSkillsWidget({super.key});

  @override
  State<OccupationSkillsWidget> createState() => _OccupationSkillsWidgetState();
}

class _OccupationSkillsWidgetState extends State<OccupationSkillsWidget> {
  bool isEditing = false;

  // Sample skills data
  List<Map<String, String>> skills = [
    {
      "Skill Assessment": "Engineers Australia",
      "Assessment Date": "12/08/2022",
      "Nominated Occupation": "Mechanical Engineering Technician",
      "Occupation Code": "233914",
      "Expiry Date": "12/08/2025",
      "Reference No": "HS8A92K",
      "Assessing Authority": "EA",
      "Visa Subclass": "189",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          _buildSectionTitle(
            "Occupation & Skills",
            icon: Icons.assessment_rounded,
            isEditing: isEditing,
            showAdd: true,
            onEdit: () => setState(() => isEditing = !isEditing),
            onAdd: () {
              setState(() {
                skills.add({
                  "Skill Assessment": "",
                  "Assessment Date": "",
                  "Nominated Occupation": "",
                  "Occupation Code": "",
                  "Expiry Date": "",
                  "Reference No": "",
                  "Assessing Authority": "",
                  "Visa Subclass": "",
                });
              });
            },
          ),

          const SizedBox(height: 18),

          /// Render all skill cards
          ...skills.map((skill) => Column(
            children: [
              _buildSkillCard(skill),
              const SizedBox(height: 18),
            ],
          )),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // SECTION HEADER
  // -------------------------------------------------------------------------
  Widget _buildSectionTitle(
      String title, {
        required bool isEditing,
        required VoidCallback onEdit,
        bool showAdd = false,
        VoidCallback? onAdd,
        required IconData icon,
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

  // -------------------------------------------------------------------------
  // SKILL CARD
  // -------------------------------------------------------------------------
  Widget _buildSkillCard(Map<String, String> skill) {
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /*_leftBlueBar(),
          const SizedBox(width: 14),*/
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 26,
                  runSpacing: 14,
                  children: [
                    _buildEditableRow("Skill Assessment", skill),
                    _buildEditableRow("Assessment Date", skill),
                    _buildEditableRow("Nominated Occupation", skill),
                    _buildEditableRow("Occupation Code", skill),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 26,
                  runSpacing: 14,
                  children: [
                    _buildEditableRow("Expiry Date", skill),
                    _buildEditableRow("Reference No", skill),
                    _buildEditableRow("Assessing Authority", skill),
                    _buildEditableRow("Visa Subclass", skill),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // LEFT BLUE BAR
  // -------------------------------------------------------------------------
  Widget _leftBlueBar() {
    return Container(
      width: 4,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // EDITABLE ROW
  // -------------------------------------------------------------------------
  Widget _buildEditableRow(String key, Map<String, String> skill) {
    return SizedBox(
      child: TextFormField(
        initialValue: skill[key],
        enabled: isEditing,
        onChanged: (val) {
          setState(() {
            skill[key] = val;
          });
        },
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: key.toUpperCase(),
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
