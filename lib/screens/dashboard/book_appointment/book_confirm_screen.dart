import 'package:client/screens/dashboard/book_appointment/book_confirm_appointment_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import 'booking_widget.dart';

class BookConfirmScreen extends StatefulWidget {
  final Map<String, dynamic> selectedOptions;

  const BookConfirmScreen({super.key, required this.selectedOptions});

  @override
  State<BookConfirmScreen> createState() => _BookConfirmScreenState();
}

class _BookConfirmScreenState extends State<BookConfirmScreen> {
  bool isLoading = true;
  bool isSubmitting = false;
  String? error;

  Set<DateTime> disabledDates = {};
  List<int> disabledWeekdays = [];

  DateTime? selectedDay;
  String? selectedTime;

  // Controllers
  late TextEditingController enquiryController;
  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  // Determine if we are adding a new appointment or updating an existing one
  bool get isAdd => widget.selectedOptions['is_add'] ?? true;

  @override
  void initState() {
    super.initState();

    enquiryController = TextEditingController(
      text: widget.selectedOptions['description'] ?? '',
    );
    fullNameController = TextEditingController(
      text: widget.selectedOptions['full_name'] ?? '',
    );
    emailController = TextEditingController(
      text: widget.selectedOptions['email'] ?? '',
    );
    phoneController = TextEditingController(
      text: widget.selectedOptions['phone'] ?? '',
    );

    // Pre-select existing date and time if available
    if (!isAdd) {
      final appointDate = widget.selectedOptions['appoint_date'];
      if (appointDate != null) {
        selectedDay = DateTime.tryParse(appointDate);
      }
      selectedTime = widget.selectedOptions['appoint_time'];
    }

    loadCalendarData();
  }

  @override
  void dispose() {
    enquiryController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> loadCalendarData() async {
    try {
      final res = await ApiService.getDisabledDates(
        id: 1,
        enquiryItem: 1,
        inPersonAddress: 1,
      );

      final data = res['data'];
      final formatter = DateFormat('dd/MM/yyyy');

      setState(() {
        disabledDates =
            (data['disabledatesarray'] as List)
                .map((d) => formatter.parse(d))
                .toSet();
        disabledWeekdays = List<int>.from(data['weeks']);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _goToConfirmation() {
    if (fullNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all personal details')),
      );
      return;
    }

    if (selectedDay == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    final formatter = DateFormat('yyyy-MM-dd');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BookConfirmAppointmentScreen(
              selectedOptions: {
                ...widget.selectedOptions,
                'full_name': fullNameController.text.trim(),
                'email': emailController.text.trim(),
                'phone': phoneController.text.trim(),
                'appoint_date': formatter.format(selectedDay!),
                'appoint_time': selectedTime!,
                'description': enquiryController.text.trim(),
              },
            ),
      ),
    );
  }

  void _submitAppointment() async {
    if (!isAdd) {
      // UPDATE appointment flow
      if (selectedDay == null || selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select date and time')),
        );
        return;
      }

      setState(() => isSubmitting = true);

      try {
        final dateFormatter = DateFormat('yyyy-MM-dd');
        final formattedDate = dateFormatter.format(selectedDay!);

        final formattedTime = convertTo24Hour(selectedTime!);

        final response = await ApiService.updateAppointment(
          appointmentId: widget.selectedOptions['id'],
          appointmentDate: formattedDate,
          appointmentTime: formattedTime,
          meetingType: 3,
          preferredLanguage: 1,
        );

        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appointment updated successfully')),
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/dashboard',
                (Route<dynamic> route) => false,
            arguments: AuthService.selectedMatterId!.toString(),
          );

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response['message'] ?? 'Failed to update appointment',
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        setState(() => isSubmitting = false);
      }
    } else {
      _goToConfirmation();
    }
  }

  String convertTo24Hour(String time12h) {
    try {
      final cleanTime = time12h.replaceAll(RegExp(r'\s+'), '').toUpperCase();

      final regex = RegExp(r'^(\d{1,2}):(\d{2})(AM|PM)$');
      final match = regex.firstMatch(cleanTime);

      if (match != null) {
        int hour = int.parse(match.group(1)!);
        final int minute = int.parse(match.group(2)!);
        final String period = match.group(3)!;

        if (period == 'PM' && hour != 12) {
          hour += 12;
        } else if (period == 'AM' && hour == 12) {
          hour = 0;
        }

        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      }

      throw FormatException('Invalid time format: $time12h');
    } catch (e) {
      debugPrint('Failed to parse time "$time12h": $e');
      return '00:00';
    }
  }


  String cleanTimeString(String input) {
    final regex = RegExp(r'\d{1,2}:\d{2}\s?[APap][Mm]');
    final match = regex.firstMatch(input);
    if (match != null) {
      final normalized = match.group(0)!
          .replaceAll(RegExp(r'\s+'), ' ')
          .replaceAll('\u202F', ' ')
          .replaceAll('\u00A0', ' ')
          .toUpperCase()
          .trim();
      return normalized;
    }
    throw FormatException('Invalid time format: $input');
  }


  @override
  Widget build(BuildContext context) {
    final inputEnabled = isAdd;

    return ScaffoldWrapper(
      activeStep: 4,
      title: 'Confirm Appointment',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Your Details & Appointment Time'),
            const SizedBox(height: 20),

            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                return isMobile
                    ? Column(
                      children: [
                        AppTextField(
                          label: 'Full Name',
                          controller: fullNameController,
                          enabled: inputEnabled,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Email Address',
                          controller: emailController,
                          enabled: inputEnabled,
                        ),
                      ],
                    )
                    : Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Full Name',
                            controller: fullNameController,
                            enabled: inputEnabled,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextField(
                            label: 'Email Address',
                            controller: emailController,
                            enabled: inputEnabled,
                          ),
                        ),
                      ],
                    );
              },
            ),

            const SizedBox(height: 20),
            PhoneField(controller: phoneController, enabled: inputEnabled),

            const SizedBox(height: 20),
            TextField(
              controller: enquiryController,
              maxLines: 4,
              enabled: inputEnabled,
              decoration: InputDecoration(
                labelText: 'Details of Enquiry',
                filled: true,
                fillColor: const Color(0xFFFFF1F1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.redAccent),
                ),
              ),
            ),

            const SizedBox(height: 32),
            const SectionTitle('Select Date & Time'),
            const SizedBox(height: 12),
            const TimezoneBanner(),
            const SizedBox(height: 20),

            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red))
            else
              CalendarSection(
                disabledDates: disabledDates,
                disabledWeekdays: disabledWeekdays,
                onTimeSelected: (time) => selectedTime = time,
                selectedDayCallback: (day) => selectedDay = day,
                preSelectedDay: selectedDay,
                preSelectedTime: selectedTime,
              ),

            const SizedBox(height: 40),
            Center(
              child: SizedBox(
                width: 220,
                height: 48,
                child: ElevatedButton(
                  onPressed:
                      isLoading || isSubmitting ? null : _submitAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F3C88),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child:
                      isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                            isAdd ? 'Review & Confirm' : 'Update Appointment',
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== REUSABLE WIDGETS ===================== */

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFFFF1F1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}

class PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const PhoneField({super.key, required this.controller, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone Number',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Center(child: Text('🇦🇺 +61')),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                enabled: enabled,
                decoration: InputDecoration(
                  hintText: '400 000 000',
                  filled: true,
                  fillColor: const Color(0xFFFFF1F1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TimezoneBanner extends StatelessWidget {
  const TimezoneBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF6D83F2), Color(0xFF7B4AA1)],
        ),
      ),
      child: const Text(
        '⏱  All times shown in Melbourne Time (AEST)',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class CalendarSection extends StatefulWidget {
  final Set<DateTime> disabledDates;
  final List<int> disabledWeekdays;
  final Function(String)? onTimeSelected;
  final Function(DateTime)? selectedDayCallback;
  final DateTime? preSelectedDay;
  final String? preSelectedTime;

  const CalendarSection({
    super.key,
    required this.disabledDates,
    required this.disabledWeekdays,
    this.onTimeSelected,
    this.selectedDayCallback,
    this.preSelectedDay,
    this.preSelectedTime,
  });

  @override
  State<CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<CalendarSection> {
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  bool loadingSlots = false;
  List<String> availableSlots = [];
  String? selectedSlot;

  bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool isDisabled(DateTime day) {
    if (widget.disabledDates.any((d) => sameDay(d, day))) return true;
    final apiWeekday = day.weekday % 7;
    return widget.disabledWeekdays.contains(apiWeekday);
  }

  @override
  void initState() {
    super.initState();
    selectedDay = widget.preSelectedDay;
    selectedSlot = widget.preSelectedTime;
    if (selectedDay != null) fetchAvailableSlots(selectedDay!);
  }

  Future<void> fetchAvailableSlots(DateTime date) async {
    setState(() {
      loadingSlots = true;
      availableSlots.clear();
    });

    final formattedDate = DateFormat('dd/MM/yyyy').format(date);

    try {
      final res = await ApiService.getDisabledSlots(
        serviceId: 1,
        enquiryItem: 1,
        inPersonAddress: 1,
        selectedDate: formattedDate,
      );

      setState(() {
        availableSlots = List<String>.from(res['data']['disabledtimeslotes']);
      });
    } catch (e) {
      debugPrint('Disabled slot API error: $e');
    } finally {
      setState(() => loadingSlots = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime(2025),
          lastDay: DateTime(2027),
          focusedDay: focusedDay,
          selectedDayPredicate:
              (d) => selectedDay != null && sameDay(selectedDay!, d),
          enabledDayPredicate: (day) => !isDisabled(day),
          onDaySelected: (selected, focused) {
            if (isDisabled(selected)) return;

            setState(() {
              selectedDay = selected;
              focusedDay = focused;
            });

            widget.selectedDayCallback?.call(selected);
            fetchAvailableSlots(selected);
          },
        ),
        const SizedBox(height: 16),
        loadingSlots
            ? const CircularProgressIndicator()
            : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3,
              ),
              itemCount: availableSlots.length,
              itemBuilder: (context, index) {
                final slot = availableSlots[index];
                final isSelected = slot == selectedSlot;
                return GestureDetector(
                  onTap:
                      widget.onTimeSelected != null
                          ? () {
                            setState(() => selectedSlot = slot);
                            widget.onTimeSelected?.call(slot);
                          }
                          : null,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFF1E3A8A)
                              : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      slot,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                );
              },
            ),
      ],
    );
  }
}
