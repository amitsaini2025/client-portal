import 'package:flutter/material.dart';
import '../../../../models/personal_information/occupation.dart';
import '../../../../services/api_service.dart';

class OccupationSkillsWidget extends StatefulWidget {
  final List<Occupation> occupations;

  const OccupationSkillsWidget({super.key, required this.occupations});

  @override
  State<OccupationSkillsWidget> createState() => _OccupationSkillsWidgetState();
}

class _OccupationSkillsWidgetState extends State<OccupationSkillsWidget> {
  bool isEditing = false;
  bool isLoading = false;

  Map<int, List<String>> occupationSuggestions = {};

  Future<void> _saveOccupations() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService.updateClientOccupationDetail(
        widget.occupations.map((e) => e.toJson()).toList(),
      );

      if (response["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Occupation details updated successfully")),
        );
        setState(() {
          isEditing = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["message"] ?? "Update failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _searchOccupation(String query, int index) async {
    if (query.isEmpty) {
      setState(() => occupationSuggestions[index] = []);
      return;
    }

    final response = await ApiService.searchOccupation(query);

    if (response["success"] == true && response["data"] != null) {
      List<String> titles = List<String>.from(
          response["data"].map((item) => item["occupation_title"]));
      setState(() {
        occupationSuggestions[index] = titles;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(
                "Occupation & Skills",
                icon: Icons.assessment_rounded,
                isEditing: isEditing,
                showAdd: false,
                onEdit: () {
                  if (isEditing) {
                    _saveOccupations();
                  } else {
                    setState(() => isEditing = true);
                  }
                },
                onAdd: () {
                  setState(() {
                    widget.occupations.add(
                      Occupation(
                        id: DateTime.now().millisecondsSinceEpoch,
                        skillAssessment: "",
                        nominatedOccupation: "",
                        occupationCode: "",
                        assessingAuthority: "",
                        visaSubclass: "",
                        assessmentDate: "",
                        expiryDate: "",
                        referenceNo: "",
                        relevantOccupation: false,
                      ),
                    );
                  });
                },
              ),
              const SizedBox(height: 18),
              ...widget.occupations.asMap().entries.map((entry) {
                int index = entry.key;
                Occupation occupation = entry.value;
                return Column(
                  children: [
                    _buildSkillCard(occupation, index),
                    const SizedBox(height: 18),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

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

  Widget _buildSkillCard(Occupation occupation, int index) {
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
          Wrap(
            spacing: 26,
            runSpacing: 14,
            children: [
              _buildEditableRow(
                  "Skill Assessment", occupation.skillAssessment,
                      (val) => occupation.skillAssessment = val),
              _buildDateRow(
                  "Assessment Date", occupation.assessmentDate,
                      (val) => occupation.assessmentDate = val),
              _buildSearchableRow(
                  "Nominated Occupation",
                  occupation.nominatedOccupation,
                  index,
                      (val) => occupation.nominatedOccupation = val),
              _buildEditableRow(
                  "Occupation Code", occupation.occupationCode,
                      (val) => occupation.occupationCode = val),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 26,
            runSpacing: 14,
            children: [
              _buildDateRow(
                  "Expiry Date", occupation.expiryDate,
                      (val) => occupation.expiryDate = val),
              _buildEditableRow(
                  "Reference No", occupation.referenceNo,
                      (val) => occupation.referenceNo = val),
              _buildEditableRow(
                  "Assessing Authority", occupation.assessingAuthority,
                      (val) => occupation.assessingAuthority = val),
              _buildEditableRow(
                  "Visa Subclass", occupation.visaSubclass ?? "",
                      (val) => occupation.visaSubclass = val),
              _buildCheckboxRow(
                  "Relevant", occupation.relevantOccupation,
                      (val) {
                    setState(() {
                      occupation.relevantOccupation = val;
                    });
                  }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableRow(String label, String value, Function(String) onChanged) {
    return SizedBox(
      child: TextFormField(
        initialValue: value,
        enabled: isEditing,
        onChanged: onChanged,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildSearchableRow(String label, String value, int index, Function(String) onChanged) {
    TextEditingController controller = TextEditingController(text: value);

    return SizedBox(
      child: Column(
        children: [
          TextFormField(
            controller: controller,
            enabled: isEditing,
            onChanged: (val) {
              onChanged(val);
              _searchOccupation(val, index);
            },
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              suffixIcon: isEditing && controller.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  setState(() {
                    controller.clear();
                    onChanged("");
                    occupationSuggestions[index] = [];
                  });
                },
              )
                  : null,
            ),
          ),
          if (occupationSuggestions[index] != null &&
              occupationSuggestions[index]!.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ListView(
                shrinkWrap: true,
                children: occupationSuggestions[index]!
                    .map((suggestion) => ListTile(
                  title: Text(suggestion),
                  onTap: () {
                    setState(() {
                      controller.text = suggestion;
                      onChanged(suggestion);
                      occupationSuggestions[index] = [];
                    });
                  },
                ))
                    .toList(),
              ),
            )
        ],
      ),
    );
  }


  Widget _buildDateRow(String label, String value, Function(String) onChanged) {
    TextEditingController controller = TextEditingController(text: value);
    return SizedBox(
      child: TextFormField(
        controller: controller,
        enabled: isEditing,
        readOnly: true,
        onTap: isEditing
            ? () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: value.isNotEmpty
                ? DateTime.tryParse(value) ?? DateTime.now()
                : DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            String formattedDate = "${pickedDate.day.toString().padLeft(2,'0')}/${pickedDate.month.toString().padLeft(2,'0')}/${pickedDate.year}";
            controller.text = formattedDate;
            setState(() {
              onChanged(formattedDate);
            });
          }
        }
            : null,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          suffixIcon: isEditing ? const Icon(Icons.calendar_today, size: 18) : null,
        ),
      ),
    );
  }

  Widget _buildCheckboxRow(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Checkbox(
          value: value,
          onChanged: isEditing
              ? (val) {
            setState(() {
              onChanged(val ?? false);
            });
          }
              : null,
        ),
      ],
    );
  }
}
