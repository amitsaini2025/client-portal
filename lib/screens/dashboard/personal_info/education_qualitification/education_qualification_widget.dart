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

  List<Map<String, dynamic>> convertQualificationsToJson(
      List<Qualification> list,
      ) {
    return list.map((q) {
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

  List<String> qualificationLevels = [
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            "Educational Qualifications",
            showEdit: true,
            showAdd: false,
            isEditing: isEditing,
            onEdit: () async {
              if (isEditing) {
                final json = convertQualificationsToJson(widget.qualifications);
                final response =
                await ApiService.updateClientQualificationDetail(json);

                if (response['success'] == true || response['status'] == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Qualifications updated successfully'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        response['message'] ??
                            'Failed to update qualifications',
                      ),
                    ),
                  );
                }
                setState(() => isEditing = false);
              } else {
                setState(() => isEditing = true);
              }
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
          _buildLevelDropdown(qual),

          _buildEditableRow("Name", qual.name, (val) => qual.name = val),
          _buildEditableRow(
            "Institution",
            qual.collegeName,
                (val) => qual.collegeName = val,
          ),
          _buildEditableRow("Campus", qual.campus, (val) => qual.campus = val),

          _buildCountryDropdown(qual),

          _buildEditableRow(
            "State",
            qual.state ?? "",
                (val) => qual.state = val,
          ),

          _buildDateRow(
            "Start Date",
            qual.startDate,
                (val) => qual.startDate = val,
          ),

          const SizedBox(height: 12),

          _buildDateRow(
            "Finish Date",
            qual.finishDate,
                (val) => qual.finishDate = val,
          ),

          _buildCheckboxRow(
            "Relevant",
            qual.relevantQualification,
                (val) {
              setState(() {
                qual.relevantQualification = val;
              });
            },
          ),
          _buildCheckboxRow(
            "Specialist Education",
            qual.specialistEducation,
                (val) {
              setState(() {
                qual.specialistEducation = val;
              });
            },
          ),
          _buildCheckboxRow(
            "STEM Qualification",
            qual.stemQualification,
                (val) {
              setState(() {
                qual.stemQualification = val;
              });
            },
          ),
          _buildCheckboxRow(
            "Regional Study",
            qual.regionalStudy,
                (val) {
              setState(() {
                qual.regionalStudy = val;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLevelDropdown(Qualification qual) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: qual.level.isEmpty ? null : qual.level,
        isExpanded: true,
        items: qualificationLevels
            .map(
              (level) => DropdownMenuItem(
            value: level,
            child: Text(level),
          ),
        )
            .toList(),
        onChanged: isEditing
            ? (val) {
          setState(() {
            qual.level = val ?? "";
          });
        }
            : null,
        decoration: const InputDecoration(
          labelText: "LEVEL",
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildCountryDropdown(Qualification qual) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: qual.country.isEmpty ? null : qual.country,
        isExpanded: true,
        items: widget.countries
            .map((country) => DropdownMenuItem<String>(
          value: country.name,
          child: Text(country.name),
        ))
            .toList(),
        onChanged: isEditing
            ? (val) {
          setState(() {
            qual.country = val ?? "";
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

  Widget _buildEditableRow(
      String label,
      String value,
      Function(String) onChanged,
      ) {
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildDateRow(String label, String value, Function(String) onChanged) {
    final controller = TextEditingController(text: value);

    return GestureDetector(
      onTap:
      isEditing
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
            initial = DateTime.now().subtract(
              const Duration(days: 365 * 5),
            );
          }
        } catch (_) {
          initial = DateTime.now().subtract(
            const Duration(days: 365 * 5),
          );
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
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
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
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
