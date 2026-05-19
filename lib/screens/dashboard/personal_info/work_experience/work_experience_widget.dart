import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/theme_config.dart';
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

      if (response["success"] == true &&
          response["data"] != null &&
          response["data"]["experiences"] != null) {
        final List<dynamic> updatedData = response["data"]["experiences"];

        // Update local experience objects from API response
        for (int i = 0; i < updatedData.length; i++) {
          final apiExp = updatedData[i];
          final localExp = widget.experiences[i];

          localExp.id = apiExp["id"];
          localExp.jobTitle = apiExp["job_title"];
          localExp.jobCode = apiExp["job_code"];
          localExp.employerName = apiExp["employer_name"];
          localExp.country = apiExp["country"];
          localExp.state = apiExp["state"];
          localExp.jobType = apiExp["job_type"];
          localExp.startDate = apiExp["start_date"];
          localExp.finishDate = apiExp["finish_date"];
          localExp.relevantExperience = apiExp["relevant_experience"];
          localExp.fteMultiplier = apiExp["fte_multiplier"];
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Experiences updated successfully!")),
        );
        setState(() => isEditing = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["message"] ?? "Experience update failed"),
          ),
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
          id: null,
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

  Future<void> _deleteExperience(Experience exp) async {
    // If not yet saved on server
    if (exp.id == null || exp.id == 0) {
      setState(() {
        widget.experiences.remove(exp);
      });
      return;
    }

    final res = await ApiService.deleteClientTabDetail(
      id: exp.id!,
      type: "experience",
    );

    if (res["success"] == true) {
      setState(() {
        widget.experiences.remove(exp);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Experience deleted successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Delete failed")),
      );
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
                context,
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
                (exp) => _buildWorkCard(context, exp),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title, {
    required IconData icon,
    required bool isEditing,
    required VoidCallback onEdit,
    bool showAdd = false,
    VoidCallback? onAdd,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? ThemeConfig.textPrimaryDark : ThemeConfig.textPrimaryLight;
    final cardColor = isDark ? ThemeConfig.cardDark : ThemeConfig.cardLight;
    final borderColor = isDark ? ThemeConfig.borderDark : ThemeConfig.borderLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
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
              color: ThemeConfig.primaryColor.withValues(alpha:0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ThemeConfig.primaryColor.withValues(alpha:0.2),
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
          if (showAdd && onAdd != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ThemeConfig.successColor.withValues(alpha:0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: ThemeConfig.successColor.withValues(alpha:0.25),
                      width: 1,
                    ),
                  ),
                  child: Icon(Icons.add_rounded,
                      color: ThemeConfig.successColor, size: 20),
                ),
              ),
            ),
          if (showAdd) const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isEditing
                      ? ThemeConfig.successColor.withValues(alpha:0.12)
                      : ThemeConfig.primaryColor.withValues(alpha:0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isEditing
                        ? ThemeConfig.successColor.withValues(alpha:0.25)
                        : ThemeConfig.primaryColor.withValues(alpha:0.25),
                    width: 1,
                  ),
                ),
                child: Icon(
                  isEditing ? Icons.check_rounded : Icons.edit_rounded,
                  color: isEditing ? ThemeConfig.successColor : ThemeConfig.primaryColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkCard(BuildContext context, Experience exp) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? ThemeConfig.cardDark : ThemeConfig.cardLight;
    final borderColor = isDark ? ThemeConfig.borderDark : ThemeConfig.borderLight;

    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildEditableRow(
                  context,
                  "Job Title",
                  exp.jobTitle,
                  (val) => exp.jobTitle = val,
                ),
              ),
              if (isEditing)
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, color: ThemeConfig.errorColor),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder:
                          (_) => AlertDialog(
                            title: Text(
                              "Delete Experience",
                              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
                            ),
                            content: Text(
                              "Are you sure you want to delete this work experience?",
                              style: GoogleFonts.inter(),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text("Cancel", style: GoogleFonts.inter()),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: ThemeConfig.errorColor,
                                ),
                                child: Text("Delete", style: GoogleFonts.inter()),
                              ),
                            ],
                          ),
                    );

                    if (confirm == true) {
                      await _deleteExperience(exp);
                    }
                  },
                ),
            ],
          ),
          _buildEditableRow(
            context,
            "ANZSCO Code",
            exp.jobCode,
            (val) => exp.jobCode = val,
          ),
          _buildEditableRow(
            context,
            "Employer Name",
            exp.employerName,
            (val) => exp.employerName = val,
          ),
          _buildCountryDropdown(context, exp),
          _buildEditableRow(context, "State", exp.state ?? "", (val) => exp.state = val),
          _buildEditableRow(
            context,
            "Job Type",
            exp.jobType,
            (val) => exp.jobType = val,
          ),
          _buildDateRow(
            context,
            "Start Date",
            exp.startDate,
            (val) => exp.startDate = val,
          ),
          _buildDateRow(
            context,
            "Finish Date",
            exp.finishDate,
            (val) => exp.finishDate = val,
          ),
          _buildCheckboxRow(
            context,
            "Relevant",
            exp.relevantExperience,
            (val) => exp.relevantExperience = val,
          ),
        ],
      ),
    );
  }

  Widget _buildCountryDropdown(BuildContext context, Experience exp) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Country",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? ThemeConfig.textPrimaryDark : ThemeConfig.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: DropdownButtonFormField<String>(
                initialValue: exp.country.isEmpty ? null : exp.country,
                isExpanded: true,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: isDark ? ThemeConfig.textPrimaryDark : ThemeConfig.textPrimaryLight,
                ),
                items: widget.countries
                    .map(
                      (country) => DropdownMenuItem<String>(
                        value: country.name,
                        child: Text(country.name, style: GoogleFonts.inter(fontSize: 14)),
                      ),
                    )
                    .toList(),
                onChanged:
                    isEditing
                        ? (val) {
                          setState(() {
                            exp.country = val ?? "";
                          });
                        }
                        : null,
                decoration: InputDecoration(
                  hintText: "Choose Country",
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark ? ThemeConfig.textSecondaryDark : ThemeConfig.textSecondaryLight,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? ThemeConfig.borderDark : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? ThemeConfig.borderDark : const Color(0xFFE5E7EB),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  suffixIcon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isDark ? ThemeConfig.textSecondaryDark : ThemeConfig.textSecondaryLight,
                  ),
                ),
                icon: const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableRow(
    BuildContext context,
    String label,
    String value,
    Function(String) onChanged,
  ) {
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
                color: isDark ? ThemeConfig.textPrimaryDark : ThemeConfig.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextFormField(
                initialValue: value,
                enabled: isEditing,
                onChanged: (val) => onChanged(val),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: isDark ? ThemeConfig.textPrimaryDark : ThemeConfig.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  hintText: label,
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark ? ThemeConfig.textSecondaryDark : ThemeConfig.textSecondaryLight,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? ThemeConfig.borderDark : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? ThemeConfig.borderDark : const Color(0xFFE5E7EB),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRow(BuildContext context, String label, String value, Function(String) onChanged) {
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
                color: isDark ? ThemeConfig.textPrimaryDark : ThemeConfig.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: isEditing ? () => _pickDate(onChanged, controller.text) : null,
                child: AbsorbPointer(
                  absorbing: true,
                  child: TextFormField(
                    controller: controller,
                    enabled: isEditing,
                    readOnly: true,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: isDark ? ThemeConfig.textPrimaryDark : ThemeConfig.textPrimaryLight,
                    ),
                    decoration: InputDecoration(
                      hintText: label,
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: isDark ? ThemeConfig.textSecondaryDark : ThemeConfig.textSecondaryLight,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? ThemeConfig.borderDark : const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? ThemeConfig.borderDark : const Color(0xFFE5E7EB),
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      suffixIcon: Icon(
                        Icons.calendar_today_rounded,
                        size: 20,
                        color: isDark ? ThemeConfig.textSecondaryDark : ThemeConfig.textSecondaryLight,
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

  Widget _buildCheckboxRow(BuildContext context, String label, bool value, Function(bool) onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? ThemeConfig.textPrimaryDark : ThemeConfig.textPrimaryLight;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
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
                isEditing
                    ? (val) {
                      setState(() {
                        onChanged(val ?? false);
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
