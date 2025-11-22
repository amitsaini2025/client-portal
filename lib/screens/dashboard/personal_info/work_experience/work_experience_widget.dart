import 'package:flutter/material.dart';

class WorkExperienceWidget extends StatefulWidget {
  const WorkExperienceWidget({super.key});

  @override
  State<WorkExperienceWidget> createState() => _WorkExperienceWidgetState();
}

class _WorkExperienceWidgetState extends State<WorkExperienceWidget> {
  bool isEditing = false;

  // Sample work experience data
  List<Map<String, String>> workExperiences = [
    {
      "Job Title": "Senior Software Engineer",
      "ANZSCO Code": "123456",
      "Employer Name": "Bansal Immigration",
      "Country": "India",
      "Address": "Patiyala",
      "Job Type": "Full-time",
      "Start Date": "26/12/2024",
      "Finish Date": "26/12/2027",
      "Relevant": "Yes",
    },
    {
      "Job Title": "Software Engineer",
      "ANZSCO Code": "13579",
      "Employer Name": "Effectual Infotech",
      "Country": "India",
      "Address": "Chandigarh",
      "Job Type": "Full-time",
      "Start Date": "26/12/2017",
      "Finish Date": "31/03/2023",
      "Relevant": "Yes",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          _buildSectionTitle(
            "Work Experience",
            icon: Icons.work_rounded,
            isEditing: isEditing,
            showAdd: true,
            onEdit: () => setState(() => isEditing = !isEditing),
            onAdd: () {
              setState(() {
                workExperiences.add({
                  "Job Title": "",
                  "ANZSCO Code": "",
                  "Employer Name": "",
                  "Country": "",
                  "Address": "",
                  "Job Type": "",
                  "Start Date": "",
                  "Finish Date": "",
                  "Relevant": "No",
                });
              });
            },
          ),
          const SizedBox(height: 18),

          /// Work Experience Cards
          ...workExperiences.map((work) => Column(
            children: [
              _buildWorkCard(work),
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
        required IconData icon,
        required bool isEditing,
        required VoidCallback onEdit,
        bool showAdd = false,
        VoidCallback? onAdd,
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
  // WORK EXPERIENCE CARD
  // -------------------------------------------------------------------------
  Widget _buildWorkCard(Map<String, String> work) {
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
                _buildEditableRow("Job Title", work),
                _buildEditableRow("ANZSCO Code", work),
                _buildEditableRow("Employer Name", work),
                _buildEditableRow("Country", work),
                _buildEditableRow("Address", work),
                _buildEditableRow("Job Type", work),
                _buildEditableRow("Start Date", work),
                _buildEditableRow("Finish Date", work),
                _buildEditableRow("Relevant", work),
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
      height: 200,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // EDITABLE ROW
  // -------------------------------------------------------------------------
  Widget _buildEditableRow(String key, Map<String, String> work) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: work[key],
        enabled: isEditing,
        onChanged: (val) {
          setState(() {
            work[key] = val;
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
