import 'package:flutter/material.dart';

import '../../../../models/personal_information/test_score.dart';

class TestScoresWidget extends StatefulWidget {
  final List<TestScore> testScores;

  const TestScoresWidget({super.key, required this.testScores});

  @override
  State<TestScoresWidget> createState() => _TestScoresWidgetState();
}

class _TestScoresWidgetState extends State<TestScoresWidget> {
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            "Test Scores",
            icon: Icons.assignment_rounded,
            isEditing: isEditing,
            onEdit: () => setState(() => isEditing = !isEditing),
            onAdd: () {
              setState(() {
                widget.testScores.add(
                  TestScore(
                    id: DateTime.now().millisecondsSinceEpoch,
                    testType: '',
                  ),
                );
              });
            },
            showAdd: false,
          ),
          const SizedBox(height: 16),
          ...widget.testScores.map(
            (score) => Column(
              children: [
                _buildTestScoreCard(score),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildTestScoreCard(TestScore score) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap:
                  isEditing
                      ? () => setState(() => widget.testScores.remove(score))
                      : null,
              child:
                  isEditing
                      ? const Icon(Icons.remove_circle, color: Colors.red)
                      : const SizedBox(),
            ),
          ),
          const SizedBox(height: 4),
          _buildEditableRow(
            "Test Type",
            score.testType,
            (val) => score.testType = val,
          ),
          Row(
            children: [
              Expanded(
                child: _buildNumberField(
                  "Listening",
                  score.listening,
                  (val) => score.listening = val,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNumberField(
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
                  "Writing",
                  score.writing,
                  (val) => score.writing = val,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNumberField(
                  "Speaking",
                  score.speaking,
                  (val) => score.speaking = val,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildNumberField(
            "Overall Score",
            score.overallScore,
            (val) => score.overallScore = val,
          ),
          const SizedBox(height: 12),
          _buildDateRow(
            "Test Date",
            score.testDate,
            (val) => score.testDate = val,
          ),
          const SizedBox(height: 12),
          _buildEditableRow(
            "Reference No",
            score.referenceNo,
            (val) => score.referenceNo = val,
          ),
          Row(
            children: [
              const Text(
                "Relevant?",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Checkbox(
                value: score.relevantTest,
                onChanged:
                    isEditing
                        ? (val) =>
                            setState(() => score.relevantTest = val ?? false)
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
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        enabled: isEditing,
        initialValue: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label.toUpperCase(),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildNumberField(String label, int value, Function(int) onChanged) {
    TextEditingController controller = TextEditingController(
      text: value.toString(),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        enabled: isEditing,
        onChanged: (val) {
          final intVal = int.tryParse(val) ?? 0;
          onChanged(intVal);
        },
        decoration: InputDecoration(
          labelText: label.toUpperCase(),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDateRow(String label, String value, Function(String) onChanged) {
    TextEditingController controller = TextEditingController(text: value);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
                        value.isNotEmpty ? _parseDate(value) : DateTime.now(),
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
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
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
