import 'package:flutter/material.dart';

import '../../../../models/personal_information/basic_information_post/country/country_model.dart';
import '../../../../models/personal_information/experience.dart';

class ExperienceWidget extends StatefulWidget {
  final List<Experience> experiences;
  final List<Country> countries;

  const ExperienceWidget({
    super.key,
    required this.experiences,
    required this.countries,
  });

  @override
  State<ExperienceWidget> createState() => _ExperienceWidgetState();
}

class _ExperienceWidgetState extends State<ExperienceWidget> {
  bool isEditing = false;

  final List<String> jobTypes = ["Full-time", "Part-time", "Contract"];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Experience', showEdit: true, showAdd: true),
        const SizedBox(height: 16),
        ...List.generate(widget.experiences.length, (index) {
          return Column(
            children: [
              _buildExperienceCard(widget.experiences[index]),
              const SizedBox(height: 20),
            ],
          );
        }),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSectionTitle(
      String title, {
        bool showEdit = false,
        bool showAdd = false,
      }) {
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
            onTap: () => setState(() => isEditing = !isEditing),
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
                widget.experiences.add(
                  Experience(
                    id: DateTime.now().millisecondsSinceEpoch,
                    jobTitle: "",
                    jobCode: "",
                    employerName: "",
                    country: "India",
                    state: null,
                    jobType: "Full-time",
                    startDate: "",
                    finishDate: "",
                    relevantExperience: false,
                    fteMultiplier: 0,
                  ),
                );
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

  Widget _buildExperienceCard(Experience exp) {
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
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap:
              isEditing
                  ? () => setState(() => widget.experiences.remove(exp))
                  : null,
              child:
              isEditing
                  ? const Icon(Icons.remove_circle, color: Colors.red)
                  : const SizedBox(),
            ),
          ),

          _buildEditableRow(
            "Job Title",
            exp.jobTitle,
                (val) => exp.jobTitle = val,
          ),
          _buildEditableRow(
            "ANZSCO Code",
            exp.jobCode,
                (val) => exp.jobCode = val,
          ),
          _buildEditableRow(
            "Employer Name",
            exp.employerName,
                (val) => exp.employerName = val,
          ),

          _buildDropdownRow(
            label: "Country",
            value: exp.country,
            items: widget.countries.map((c) => c.name).toList(),
            onChanged: (v) => setState(() => exp.country = v ?? exp.country),
          ),

          _buildEditableRow(
            "Address",
            exp.state ?? "",
                (val) => exp.state = val,
          ),

          _buildDropdownRow(
            label: "Job Type",
            value: exp.jobType,
            items: jobTypes,
            onChanged: (v) => setState(() => exp.jobType = v ?? exp.jobType),
          ),

          _buildDateRow(
            "Start Date",
            exp.startDate,
                (val) => exp.startDate = val,
          ),

          const SizedBox(height: 12),

          _buildDateRow(
            "Finish Date",
            exp.finishDate,
                (val) => exp.finishDate = val,
          ),

          Row(
            children: [
              const Text(
                "Relevant?",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              Checkbox(
                value: exp.relevantExperience,
                onChanged:
                isEditing
                    ? (val) => setState(
                      () => exp.relevantExperience = val ?? false,
                )
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableRow(
      String label,
      String value,
      Function(String) onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        enabled: isEditing,
        initialValue: value,
        onChanged: (v) => onChanged(v),
        decoration: InputDecoration(
          labelText: label.toUpperCase(),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isDense: true,
                  isExpanded: true,

                  value: value,
                  items: items
                      .map(
                        (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                      .toList(),
                  onChanged: isEditing ? onChanged : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRow(String label, String value, Function(String) onChanged) {
    TextEditingController controller = TextEditingController(text: value);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        enabled: isEditing,
        readOnly: true,
        onTap:
        isEditing
            ? () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate:
            value.isNotEmpty
                ? DateTime.tryParse(value) ?? DateTime.now()
                : DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            String formattedDate =
                "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
            controller.text = formattedDate;
            onChanged(formattedDate);
          }
        }
            : null,
        decoration: InputDecoration(
          labelText: label.toUpperCase(),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          suffixIcon:
          isEditing ? const Icon(Icons.calendar_today, size: 18) : null,
        ),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}
