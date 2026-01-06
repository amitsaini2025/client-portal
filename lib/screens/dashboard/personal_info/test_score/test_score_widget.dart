import 'package:client/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/theme_config.dart';
import '../../../../models/personal_information/test_score.dart';

class TestScoresWidget extends StatefulWidget {
  final List<TestScore> testScores;

  const TestScoresWidget({super.key, required this.testScores});

  @override
  State<TestScoresWidget> createState() => _TestScoresWidgetState();
}

class _TestScoresWidgetState extends State<TestScoresWidget> {
  bool isEditing = false;
  bool isLoading = false;

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
                "Test Scores",
                icon: Icons.assignment_rounded,
                isEditing: isEditing,
                onEdit: () async {
                  if (isEditing) {
                    await _updateTestScores();
                  }
                  setState(() => isEditing = !isEditing);
                },
                onAdd: () {
                  setState(() {
                    widget.testScores.add(TestScore(id: null, testType: ''));
                    isEditing = true;
                  });
                },
                showAdd: true,
              ),
              const SizedBox(height: 16),
              ...widget.testScores.map(
                (score) => _buildTestScoreCard(context, score),
              ),
            ],
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Future<void> _updateTestScores() async {
    setState(() => isLoading = true);

    final result = await ApiService.updateClientTestScoreDetail(
      widget.testScores.map((e) => e.toJson()).toList(),
    );

    if (result['success'] == true) {
      final updatedScores = result['data']['test_scores'] as List;
      for (int i = 0; i < updatedScores.length; i++) {
        widget.testScores[i].id = updatedScores[i]['id'];
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test scores updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Update failed')),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> _deleteTestScore(TestScore score) async {
    if (score.id == null) {
      setState(() {
        widget.testScores.remove(score);
      });
      return;
    }

    setState(() => isLoading = true);

    final res = await ApiService.deleteClientTabDetail(
      id: score.id!,
      type: "testscore",
    );

    setState(() => isLoading = false);

    if (res["success"] == true) {
      setState(() {
        widget.testScores.remove(score);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Test score deleted successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Delete failed")),
      );
    }
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title, {
    required bool isEditing,
    required VoidCallback onEdit,
    bool showAdd = false,
    VoidCallback? onAdd,
    required IconData icon,
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
          if (showAdd && onAdd != null)
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
          if (showAdd) const SizedBox(width: 8),
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
        ],
      ),
    );
  }

  Widget _buildTestScoreCard(BuildContext context, TestScore score) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? ThemeConfig.cardDark : ThemeConfig.cardLight;
    final borderColor =
        isDark ? ThemeConfig.borderDark : ThemeConfig.borderLight;

    return Container(
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
        children: [
          Align(
            alignment: Alignment.topRight,
            child:
                isEditing
                    ? IconButton(
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
                                  "Delete Test Score",
                                  style: GoogleFonts.spaceGrotesk(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                content: Text(
                                  "Are you sure you want to delete this test score?",
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
                          await _deleteTestScore(score);
                        }
                      },
                    )
                    : const SizedBox(),
          ),
          const SizedBox(height: 4),
          _buildEditableRow(
            context,
            "Test Type",
            score.testType,
            (val) => score.testType = val,
          ),
          Row(
            children: [
              Expanded(
                child: _buildNumberField(
                  context,
                  "Listening",
                  score.listening,
                  (val) => score.listening = val,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNumberField(
                  context,
                  "Reading",
                  score.reading,
                  (val) => score.reading = val,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNumberField(
                  context,
                  "Writing",
                  score.writing,
                  (val) => score.writing = val,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNumberField(
                  context,
                  "Speaking",
                  score.speaking,
                  (val) => score.speaking = val,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDoubleField(
            context,
            "Overall Score",
            score.overallScore,
            (val) => score.overallScore = val,
          ),
          _buildDateRow(
            context,
            "Test Date",
            score.testDate,
            (val) => score.testDate = val,
          ),
          _buildEditableRow(
            context,
            "Reference No",
            score.referenceNo,
            (val) => score.referenceNo = val,
          ),
          Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Text(
                      "Relevant?",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color:
                            isDark
                                ? ThemeConfig.textPrimaryDark
                                : ThemeConfig.textPrimaryLight,
                      ),
                    ),
                    Checkbox(
                      value: score.relevantTest,
                      activeColor: ThemeConfig.primaryColor,
                      checkColor: Colors.white,
                      onChanged:
                          isEditing
                              ? (val) => setState(
                                () => score.relevantTest = val ?? false,
                              )
                              : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
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
          TextFormField(
            enabled: isEditing,
            initialValue: value,
            onChanged: onChanged,
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
                      isDark ? ThemeConfig.borderDark : const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color:
                      isDark ? ThemeConfig.borderDark : const Color(0xFFE5E7EB),
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
          ),
        ],
      ),
    );
  }

  Widget _buildDoubleField(
    BuildContext context,
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController(text: value.toString());

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
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                enabled: isEditing,
                onChanged: (val) {
                  final doubleVal = double.tryParse(val) ?? 0.0;
                  onChanged(doubleVal);
                },
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField(
    BuildContext context,
    String label,
    int value,
    Function(int) onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    TextEditingController controller = TextEditingController(
      text: value.toString(),
    );
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
                keyboardType: TextInputType.number,
                enabled: isEditing,
                onChanged: (val) {
                  final intVal = int.tryParse(val) ?? 0;
                  onChanged(intVal);
                },
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
    Function(String) onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    TextEditingController controller = TextEditingController(text: value);
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
                    isEditing
                        ? () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate:
                                value.isNotEmpty
                                    ? _parseDate(value)
                                    : DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            final formatted =
                                "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                            controller.text = formatted;
                            onChanged(formatted);
                          }
                        }
                        : null,
                child: AbsorbPointer(
                  absorbing: true,
                  child: TextFormField(
                    controller: controller,
                    enabled: isEditing,
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

  DateTime _parseDate(String value) {
    try {
      final parts = value.split('/');
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (e) {
      return DateTime.now();
    }
  }
}
