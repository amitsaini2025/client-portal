import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme_config.dart';
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

  final List<String> qualificationLevels = [
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

  List<Map<String, dynamic>> convertQualificationsToJson() {
    return widget.qualifications.map((q) {
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

  void _addQualification() {
    setState(() {
      widget.qualifications.add(
        Qualification(
          id: null,
          level: "",
          name: "",
          collegeName: "",
          campus: "",
          country: "",
          state: null,
          startDate: "",
          finishDate: "",
          relevantQualification: false,
          specialistEducation: false,
          stemQualification: false,
          regionalStudy: false,
        ),
      );
      isEditing = true;
    });
  }

  Future<void> _saveQualifications() async {
    try {
      final payload = convertQualificationsToJson();
      final response = await ApiService.updateClientQualificationDetail(
        payload,
      );
      if (response['success'] == true &&
          response['data'] != null &&
          response['data']['qualifications'] != null) {
        final List<dynamic> updatedList = response['data']['qualifications'];
        for (int i = 0; i < updatedList.length; i++) {
          if (i >= widget.qualifications.length) break;

          final api = updatedList[i];
          final local = widget.qualifications[i];

          local.id = api['id'];
          local.level = api['level'] ?? "";
          local.name = api['name'] ?? "";
          local.collegeName = api['college_name'] ?? "";
          local.campus = api['campus'] ?? "";
          local.country = api['country'] ?? "";
          local.state = api['state'] ?? "";
          local.startDate = api['start_date'] ?? "";
          local.finishDate = api['finish_date'] ?? "";
          local.relevantQualification = api['relevant_qualification'] ?? false;
          local.specialistEducation = api['specialist_education'] ?? false;
          local.stemQualification = api['stem_qualification'] ?? false;
          local.regionalStudy = api['regional_study'] ?? false;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Qualifications updated successfully')),
        );

        setState(() => isEditing = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Failed to update qualifications',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating qualifications: $e')),
      );
    }
  }

  Future<String?> _pickDate(String current) async {
    DateTime initial;
    try {
      final parts = current.split('/');
      initial = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (_) {
      initial = DateTime.now();
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      return DateFormat("dd/MM/yyyy").format(picked);
    }
    return null;
  }

  Future<void> _deleteQualification(Qualification q) async {
    // If not yet saved to API
    if (q.id == null || q.id == 0) {
      setState(() {
        widget.qualifications.remove(q);
      });
      return;
    }

    final res = await ApiService.deleteClientTabDetail(
      id: q.id!,
      type: "qualification",
    );

    if (res["success"] == true) {
      setState(() {
        widget.qualifications.remove(q);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Qualification deleted successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Delete failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            context,
            "Educational Qualifications",
            icon: Icons.school_rounded,
            isEditing: isEditing,
            onEdit: () {
              if (isEditing) {
                _saveQualifications();
              } else {
                setState(() => isEditing = true);
              }
            },
            onAdd: _addQualification,
            showAdd: true,
          ),
          const SizedBox(height: 16),
          ...widget.qualifications.map(
            (qual) => _buildInfoCard(context, [
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      context,
                      label: "Level",
                      value: qual.level,
                      items: qualificationLevels,
                      enabled: isEditing,
                      onChanged:
                          (val) => setState(() => qual.level = val ?? ""),
                    ),
                  ),
                  if (isEditing)
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: ThemeConfig.errorColor,
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: Text(
                                  "Delete Qualification",
                                  style: GoogleFonts.spaceGrotesk(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                content: Text(
                                  "Are you sure you want to delete this qualification?",
                                  style: GoogleFonts.inter(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: Text(
                                      "Cancel",
                                      style: GoogleFonts.inter(),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: ThemeConfig.errorColor,
                                    ),
                                    child: Text(
                                      "Delete",
                                      style: GoogleFonts.inter(),
                                    ),
                                  ),
                                ],
                              ),
                        );

                        if (confirm == true) {
                          await _deleteQualification(qual);
                        }
                      },
                    ),
                ],
              ),

              _buildEditableRow(
                context,
                "Name",
                qual.name,
                isEditing,
                (val) => qual.name = val,
              ),
              _buildEditableRow(
                context,
                "Institution",
                qual.collegeName,
                isEditing,
                (val) => qual.collegeName = val,
              ),
              _buildEditableRow(
                context,
                "Campus",
                qual.campus,
                isEditing,
                (val) => qual.campus = val,
              ),
              _buildDropdown(
                context,
                label: "Country",
                value: qual.country,
                items: widget.countries.map((c) => c.name).toList(),
                enabled: isEditing,
                onChanged: (val) => setState(() => qual.country = val ?? ""),
              ),
              _buildEditableRow(
                context,
                "State",
                qual.state ?? "",
                isEditing,
                (val) => qual.state = val,
              ),
              _buildDateRow(
                context,
                "Start Date",
                qual.startDate,
                isEditing,
                (val) => qual.startDate = val!,
              ),
              _buildDateRow(
                context,
                "Finish Date",
                qual.finishDate,
                isEditing,
                (val) => qual.finishDate = val!,
              ),
              _buildCheckbox(
                "Relevant",
                qual.relevantQualification,
                isEditing,
                (val) => qual.relevantQualification = val,
              ),
              _buildCheckbox(
                "Specialist Education",
                qual.specialistEducation,
                isEditing,
                (val) => qual.specialistEducation = val,
              ),
              _buildCheckbox(
                "STEM Qualification",
                qual.stemQualification,
                isEditing,
                (val) => qual.stemQualification = val,
              ),
              _buildCheckbox(
                "Regional Study",
                qual.regionalStudy,
                isEditing,
                (val) => qual.regionalStudy = val,
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title, {
    required IconData icon,
    required bool isEditing,
    required VoidCallback onEdit,
    required VoidCallback onAdd,
    bool showAdd = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? ThemeConfig.textPrimaryDark : ThemeConfig.textPrimaryLight;
    final cardColor = isDark ? ThemeConfig.cardDark : ThemeConfig.cardLight;
    final borderColor =
        isDark ? ThemeConfig.borderDark : ThemeConfig.borderLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ThemeConfig.primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ThemeConfig.primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(icon, color: ThemeConfig.primaryColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      isEditing
                          ? ThemeConfig.successColor.withOpacity(0.12)
                          : ThemeConfig.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        isEditing
                            ? ThemeConfig.successColor.withOpacity(0.25)
                            : ThemeConfig.primaryColor.withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: Icon(
                  isEditing ? Icons.check_rounded : Icons.edit_rounded,
                  color:
                      isEditing
                          ? ThemeConfig.successColor
                          : ThemeConfig.primaryColor,
                  size: 20,
                ),
              ),
            ),
          ),
          if (showAdd) const SizedBox(width: 8),
          if (showAdd)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ThemeConfig.successColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: ThemeConfig.successColor.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: ThemeConfig.successColor,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? ThemeConfig.cardDark : ThemeConfig.cardLight;
    final borderColor =
        isDark ? ThemeConfig.borderDark : ThemeConfig.borderLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildEditableRow(
    BuildContext context,
    String label,
    String value,
    bool enabled,
    ValueChanged<String> onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController(text: value);
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                    isDark
                        ? ThemeConfig.textPrimaryDark
                        : ThemeConfig.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextFormField(
                controller: controller,
                enabled: enabled,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color:
                      isDark
                          ? ThemeConfig.textPrimaryDark
                          : ThemeConfig.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  hintText: label,
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color:
                        isDark
                            ? ThemeConfig.textSecondaryDark
                            : ThemeConfig.textSecondaryLight,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color:
                          isDark
                              ? ThemeConfig.borderDark
                              : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color:
                          isDark
                              ? ThemeConfig.borderDark
                              : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: ThemeConfig.primaryColor,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: isDark ? ThemeConfig.cardDark : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context, {
    required String label,
    required String value,
    required List<String> items,
    required bool enabled,
    required ValueChanged<String?> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                    isDark
                        ? ThemeConfig.textPrimaryDark
                        : ThemeConfig.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child:
                  enabled
                      ? DropdownButtonFormField<String>(
                        value: value.isEmpty ? null : value,
                        isExpanded: true,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color:
                              isDark
                                  ? ThemeConfig.textPrimaryDark
                                  : ThemeConfig.textPrimaryLight,
                        ),
                        onChanged: onChanged,
                        items:
                            items
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(
                                      e,
                                      style: GoogleFonts.inter(fontSize: 14),
                                    ),
                                  ),
                                )
                                .toList(),
                        decoration: InputDecoration(
                          hintText: 'Choose $label',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color:
                                isDark
                                    ? ThemeConfig.textSecondaryDark
                                    : ThemeConfig.textSecondaryLight,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color:
                                  isDark
                                      ? ThemeConfig.borderDark
                                      : const Color(0xFFE5E7EB),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color:
                                  isDark
                                      ? ThemeConfig.borderDark
                                      : const Color(0xFFE5E7EB),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: ThemeConfig.primaryColor,
                              width: 1.5,
                            ),
                          ),
                          filled: true,
                          fillColor:
                              isDark ? ThemeConfig.cardDark : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color:
                                isDark
                                    ? ThemeConfig.textSecondaryDark
                                    : ThemeConfig.textSecondaryLight,
                          ),
                        ),
                        icon: const SizedBox.shrink(),
                      )
                      : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? ThemeConfig.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isDark
                                    ? ThemeConfig.borderDark
                                    : const Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          value,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color:
                                isDark
                                    ? ThemeConfig.textPrimaryDark
                                    : ThemeConfig.textPrimaryLight,
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRow(
    BuildContext context,
    String label,
    String value,
    bool enabled,
    ValueChanged<String?> onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController(text: value);
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                    isDark
                        ? ThemeConfig.textPrimaryDark
                        : ThemeConfig.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap:
                    !enabled
                        ? null
                        : () async {
                          final picked = await _pickDate(controller.text);
                          if (picked != null) {
                            controller.text = picked;
                            onChanged(picked);
                            setState(() {});
                          }
                        },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: controller,
                    enabled: enabled,
                    readOnly: true,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color:
                          isDark
                              ? ThemeConfig.textPrimaryDark
                              : ThemeConfig.textPrimaryLight,
                    ),
                    decoration: InputDecoration(
                      hintText: label,
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color:
                            isDark
                                ? ThemeConfig.textSecondaryDark
                                : ThemeConfig.textSecondaryLight,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              isDark
                                  ? ThemeConfig.borderDark
                                  : const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              isDark
                                  ? ThemeConfig.borderDark
                                  : const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: ThemeConfig.primaryColor,
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: isDark ? ThemeConfig.cardDark : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      suffixIcon: Icon(
                        Icons.calendar_today_rounded,
                        size: 20,
                        color:
                            isDark
                                ? ThemeConfig.textSecondaryDark
                                : ThemeConfig.textSecondaryLight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(
    String label,
    bool? value,
    bool enabled,
    ValueChanged<bool> onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? ThemeConfig.textPrimaryDark : ThemeConfig.textPrimaryLight;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
          Checkbox(
            value: value,
            activeColor: ThemeConfig.primaryColor,
            checkColor: Colors.white,
            onChanged:
                enabled
                    ? (v) {
                      setState(() {
                        onChanged(v ?? false);
                      });
                    }
                    : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
