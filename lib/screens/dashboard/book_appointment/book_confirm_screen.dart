import 'package:client/screens/dashboard/book_appointment/book_appointment_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../services/api_service.dart';
import 'booking_widget.dart';

class BookConfirmScreen extends StatefulWidget {
  final Map<String, dynamic> selectedOptions;

  const BookConfirmScreen({super.key, required this.selectedOptions});

  @override
  State<BookConfirmScreen> createState() => _BookConfirmScreenState();
}

class _BookConfirmScreenState extends State<BookConfirmScreen> {
  bool isLoading = true;
  String? error;

  Set<DateTime> disabledDates = {};
  List<int> disabledWeekdays = [];

  DateTime? selectedDay;
  String? selectedTime;

  // Controller for Details of Enquiry
  late TextEditingController enquiryController;

  @override
  void initState() {
    super.initState();
    enquiryController = TextEditingController(
        text: widget.selectedOptions['description'] ?? '');
    loadCalendarData();
  }

  @override
  void dispose() {
    enquiryController.dispose();
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
            (data['disabledatesarray'] as List).map((d) => formatter.parse(d)).toSet();
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

  Future<void> _createAppointment() async {
    final description = enquiryController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Details of Enquiry are required')),
      );
      return;
    }

    if (selectedDay == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final formatter = DateFormat('yyyy-MM-dd');
      final appointDate = formatter.format(selectedDay!);

      final serviceId = widget.selectedOptions['service_id'];
      final int serviceIdValue = serviceId is int ? serviceId : serviceId.id;

      final response = await ApiService.createAppointmentNew(
        noeId: widget.selectedOptions['noe_id'],
        serviceId: serviceIdValue,
        appointDate: appointDate,
        appointTime: selectedTime!,
        description: description,
        appointmentDetails: widget.selectedOptions['appointment_details'],
        preferredLanguage: widget.selectedOptions['preferred_language'],
        inPersonAddress: widget.selectedOptions['inperson_address'],
      );

      setState(() => isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookAppointmentSuccessScreen(data: response),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment created successfully')),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create appointment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  children: const [
                    AppTextField(label: 'Full Name'),
                    SizedBox(height: 16),
                    AppTextField(label: 'Email Address'),
                  ],
                )
                    : Row(
                  children: const [
                    Expanded(child: AppTextField(label: 'Full Name')),
                    SizedBox(width: 16),
                    Expanded(child: AppTextField(label: 'Email Address')),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            const PhoneField(),
            const SizedBox(height: 20),
            // Use controller for editable enquiry
            TextField(
              controller: enquiryController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Details of Enquiry',
                hintText: 'Please provide detailed information about your enquiry...',
                filled: true,
                fillColor: const Color(0xFFFFF1F1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.redAccent),
                ),
                enabledBorder: OutlineInputBorder(
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
              ),
            const SizedBox(height: 40),
            Center(
              child: SizedBox(
                width: 220,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _createAppointment,
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
                  child: const Text('Review & Confirm'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final int maxLines;
  final String? initialValue;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.maxLines = 1,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFFFF1F1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}

// SectionTitle, PhoneField, TimezoneBanner, CalendarSection remain unchanged
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E3A8A),
      ),
    );
  }
}

class PhoneField extends StatelessWidget {
  const PhoneField({super.key});

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
                decoration: InputDecoration(
                  hintText: '400 000 000',
                  filled: true,
                  fillColor: const Color(0xFFFFF1F1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.redAccent),
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

  const CalendarSection({
    super.key,
    required this.disabledDates,
    required this.disabledWeekdays,
    this.onTimeSelected,
    this.selectedDayCallback,
  });

  @override
  State<CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<CalendarSection> {
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  bool loadingSlots = false;
  List<String> availableSlots = [];
  String? selectedSlot; // <-- track selected time slot

  bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool isDisabled(DateTime day) {
    if (widget.disabledDates.any((d) => sameDay(d, day))) return true;
    final apiWeekday = day.weekday % 7;
    return widget.disabledWeekdays.contains(apiWeekday);
  }

  Future<void> fetchAvailableSlots(DateTime date) async {
    setState(() {
      loadingSlots = true;
      availableSlots.clear();
      selectedSlot = null;
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
          selectedDayPredicate: (d) => selectedDay != null && sameDay(selectedDay!, d),
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
              onTap: () {
                setState(() => selectedSlot = slot);
                widget.onTimeSelected?.call(slot);
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey.shade300,
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
