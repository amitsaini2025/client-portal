import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/personal_information/experience.dart';

class WorkExperienceWidget extends StatefulWidget {
  final List<Experience> experiences;

  const WorkExperienceWidget({super.key, required this.experiences});

  @override
  State<WorkExperienceWidget> createState() => _WorkExperienceWidgetState();
}

class _WorkExperienceWidgetState extends State<WorkExperienceWidget> {
  bool isEditing = false;

  Future<void> _pickDate(Function(String) onChanged, String currentValue) async {
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            "Work Experience",
            icon: Icons.work_rounded,
            isEditing: isEditing,
            showAdd: true,
            onEdit: () => setState(() => isEditing = !isEditing),
            onAdd: () {
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
              });
            },
          ),
          const SizedBox(height: 18),
          ...widget.experiences.map((exp) => Column(
            children: [
              _buildWorkCard(exp),
              const SizedBox(height: 18),
            ],
          )),
        ],
      ),
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
          _buildEditableRow("Country", exp.country, (val) => exp.country = val),
          _buildEditableRow("State", exp.state ?? "", (val) => exp.state = val),
          _buildEditableRow("Job Type", exp.jobType, (val) => exp.jobType = val),

          /// -----------------------------
          /// DATE PICKER FOR START & FINISH
          /// -----------------------------
          _buildDateRow("Start Date", exp.startDate, (val) => exp.startDate = val),

          SizedBox(
            height: 12,
          ),
          
          _buildDateRow("Finish Date", exp.finishDate, (val) => exp.finishDate = val),

          _buildCheckboxRow("Relevant", exp.relevantExperience, (val) => exp.relevantExperience = val),
        ],
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

  Widget _buildDateRow(String label, String value, Function(String) onChanged) {
    final controller = TextEditingController(text: value);

    return GestureDetector(
      onTap: isEditing
          ? () async {
        DateTime initial;
        try {
          if (controller.text.isNotEmpty) {
            final parts = controller.text.split('/');
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
            controller.text = formatted;
            onChanged(formatted);
          });
        }
      }
          : null,
      child: AbsorbPointer(
        absorbing: true,
        child: TextFormField(
          controller: controller,
          enabled: isEditing,
          decoration: InputDecoration(
            labelText: label.toUpperCase(),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
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
