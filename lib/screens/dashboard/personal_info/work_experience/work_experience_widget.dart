import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/personal_information/basic_information_post/country/country_model.dart';
import '../../../../models/personal_information/experience.dart';
import '../../../../services/api_service.dart';

class WorkExperienceWidget extends StatefulWidget {
  final List<Experience> experiences;
  final List<Country> countries;

  const WorkExperienceWidget({
    super.key,
    required this.experiences,
    required this.countries,
  });

  @override
  State<WorkExperienceWidget> createState() => _WorkExperienceWidgetState();
}

class _WorkExperienceWidgetState extends State<WorkExperienceWidget> {
  bool isEditing = false;
  bool isLoading = false;

  Future<void> _pickDate(
      Function(String) onChanged,
      String currentValue,
      ) async {
    DateTime initial;

    try {
      if (currentValue.isNotEmpty) {
        final parts = currentValue.split('/');
        initial = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } else {
        initial = DateTime.now().subtract(const Duration(days: 365 * 5));
      }
    } catch (_) {
      initial = DateTime.now().subtract(const Duration(days: 365 * 5));
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );

    if (picked != null) {
      final formatted = DateFormat("dd/MM/yyyy").format(picked);
      setState(() {
        onChanged(formatted);
      });
    }
  }

  Future<void> _saveExperiences() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService.updateClientExperienceDetail(
        widget.experiences.map((e) => e.toJson()).toList(),
      );

      if (response["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Experiences updated successfully")),
        );
        setState(() => isEditing = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["message"] ?? "Update failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addExperience() {
    setState(() {
      widget.experiences.add(
        Experience(
          id: DateTime.now().millisecondsSinceEpoch,
          jobTitle: "",
          jobCode: "",
          country: "",
          startDate: "",
          finishDate: "",
          relevantExperience: false,
          employerName: "",
          state: "",
          jobType: "",
          fteMultiplier: 1.0,
        ),
      );
      isEditing = true;
    });
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
                "Work Experience",
                icon: Icons.work_rounded,
                isEditing: isEditing,
                showAdd: true,
                onEdit: () {
                  if (isEditing) {
                    _saveExperiences();
                  } else {
                    setState(() => isEditing = true);
                  }
                },
                onAdd: _addExperience,
              ),
              const SizedBox(height: 18),
              ...widget.experiences.map(
                    (exp) => Column(
                  children: [
                    _buildWorkCard(exp),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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

  Widget _buildWorkCard(Experience exp) {
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
          _buildEditableRow("Job Title", exp.jobTitle, (val) => exp.jobTitle = val),
          _buildEditableRow("ANZSCO Code", exp.jobCode, (val) => exp.jobCode = val),
          _buildEditableRow("Employer Name", exp.employerName, (val) => exp.employerName = val),
          _buildCountryDropdown(exp),
          _buildEditableRow("State", exp.state ?? "", (val) => exp.state = val),
          _buildEditableRow("Job Type", exp.jobType, (val) => exp.jobType = val),
          _buildDateRow("Start Date", exp.startDate, (val) => exp.startDate = val),
          const SizedBox(height: 12),
          _buildDateRow("Finish Date", exp.finishDate, (val) => exp.finishDate = val),
          _buildCheckboxRow("Relevant", exp.relevantExperience, (val) => exp.relevantExperience = val),
        ],
      ),
    );
  }

  Widget _buildCountryDropdown(Experience exp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: exp.country.isEmpty ? null : exp.country,
        isExpanded: true,
        items: widget.countries
            .map(
              (country) => DropdownMenuItem<String>(
            value: country.name,
            child: Text(country.name),
          ),
        )
            .toList(),
        onChanged: isEditing
            ? (val) {
          setState(() {
            exp.country = val ?? "";
          });
        }
            : null,
        decoration: const InputDecoration(
          labelText: "COUNTRY",
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildEditableRow(String label, String value, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: value,
        enabled: isEditing,
        onChanged: (val) => onChanged(val),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label.toUpperCase(),
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13, letterSpacing: 0.2),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildDateRow(String label, String value, Function(String) onChanged) {
    final controller = TextEditingController(text: value);

    return GestureDetector(
      onTap: isEditing
          ? () => _pickDate(onChanged, controller.text)
          : null,
      child: AbsorbPointer(
        absorbing: true,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            controller: controller,
            enabled: isEditing,
            readOnly: true,
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

  Widget _buildCheckboxRow(String label, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
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
