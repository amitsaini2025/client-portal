import 'package:flutter/material.dart';

class ExperienceWidget extends StatefulWidget {
  const ExperienceWidget({super.key});

  @override
  State<ExperienceWidget> createState() => _ExperienceWidgetState();
}

class _ExperienceWidgetState extends State<ExperienceWidget> {
  bool isEditing = false;

  List<Map<String, dynamic>> experiences = [
    {
      "jobTitle": "Senior Software Engineer",
      "anzsco": "123456",
      "employer": "Bansal Immigration",
      "country": "India",
      "address": "Patiyala",
      "jobType": "Full-time",
      "startDate": "26/12/2024",
      "finishDate": "26/12/2027",
      "relevant": true,
    },
    {
      "jobTitle": "Software Engineer",
      "anzsco": "13579",
      "employer": "Effectual Infotech",
      "country": "India",
      "address": "Chandigarh",
      "jobType": "Full-time",
      "startDate": "26/12/2017",
      "finishDate": "31/03/2023",
      "relevant": true,
    },
  ];

  // List for dropdown items
  final List<String> jobTypes = ["Full-time", "Part-time", "Contract"];
  final List<String> countries = ["India", "Nepal", "Australia", "USA", "Canada"];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Experience', showEdit: true, showAdd: true),

        const SizedBox(height: 16),

        ...List.generate(experiences.length, (index) {
          return Column(
            children: [
              _buildExperienceCard(index),
              const SizedBox(height: 20),
            ],
          );
        }),

        const SizedBox(height: 20),
      ],
    );
  }

  // ---------------------------
  // SECTION TITLE
  // ---------------------------
  Widget _buildSectionTitle(String title, {bool showEdit = false, bool showAdd = false}) {
    return Row(
      children: [
        const Icon(Icons.work, color: Colors.white),
        const SizedBox(width: 8),

        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),

        if (showEdit)
          InkWell(
            onTap: () {
              setState(() => isEditing = !isEditing);
            },
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

        if (showAdd) const SizedBox(width: 10),

        if (showAdd)
          InkWell(
            onTap: () {
              setState(() {
                experiences.add({
                  "jobTitle": "",
                  "anzsco": "",
                  "employer": "",
                  "country": "India",
                  "address": "",
                  "jobType": "Full-time",
                  "startDate": "",
                  "finishDate": "",
                  "relevant": false,
                });
              });
            },
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

  // ---------------------------
  // EXPERIENCE CARD
  // ---------------------------
  Widget _buildExperienceCard(int index) {
    final item = experiences[index];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Remove Icon
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: isEditing
                  ? () {
                setState(() => experiences.removeAt(index));
              }
                  : null,
              child: isEditing
                  ? const Icon(Icons.remove_circle, color: Colors.red)
                  : const SizedBox(),
            ),
          ),

          _buildEditableRow("Job Title", item["jobTitle"], (val) => item["jobTitle"] = val),
          _buildEditableRow("ANZSCO Code", item["anzsco"], (val) => item["anzsco"] = val),
          _buildEditableRow("Employer Name", item["employer"], (val) => item["employer"] = val),

          _buildDropdownRow(
            label: "Country",
            value: item["country"],
            items: countries,
            onChanged: (v) => setState(() => item["country"] = v),
          ),

          _buildEditableRow("Address", item["address"], (val) => item["address"] = val),

          _buildDropdownRow(
            label: "Job Type",
            value: item["jobType"],
            items: jobTypes,
            onChanged: (v) => setState(() => item["jobType"] = v),
          ),

          _buildEditableRow("Start Date", item["startDate"], (val) => item["startDate"] = val),
          _buildEditableRow("Finish Date", item["finishDate"], (val) => item["finishDate"] = val),

          Row(
            children: [
              const Text("Relevant?", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              Checkbox(
                value: item["relevant"],
                onChanged: isEditing
                    ? (val) => setState(() => item["relevant"] = val)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------
  // TEXT FIELD ROW
  // ---------------------------
  Widget _buildEditableRow(String label, String value, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        enabled: isEditing,
        initialValue: value,
        onChanged: (v) => onChanged(v),
        decoration: InputDecoration(
          labelText: label.toUpperCase(),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ---------------------------
  // DROPDOWN ROW
  // ---------------------------
  Widget _buildDropdownRow({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label.toUpperCase(),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isDense: true,
            value: value,
            items: items.map((e) {
              return DropdownMenuItem(value: e, child: Text(e));
            }).toList(),
            onChanged: isEditing ? onChanged : null,
          ),
        ),
      ),
    );
  }
}
