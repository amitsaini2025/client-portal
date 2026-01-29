import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../services/api_service.dart';
import 'booking_widget.dart';

class BookConfirmScreen extends StatefulWidget {
  const BookConfirmScreen({super.key});

  @override
  State<BookConfirmScreen> createState() => _BookConfirmScreenState();
}

class _BookConfirmScreenState extends State<BookConfirmScreen> {
  bool isLoading = true;
  String? error;

  Set<DateTime> disabledDates = {};
  List<int> disabledWeekdays = [];

  @override
  void initState() {
    super.initState();
    loadCalendarData();
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

            const AppTextField(
              label: 'Details of Enquiry',
              maxLines: 4,
              hint: 'Please provide detailed information about your enquiry...',
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
              ),

            const SizedBox(height: 40),

            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(140, 48),
                  ),
                  child: const Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(180, 48),
                  ),
                  child: const Text('Review & Confirm'),
                ),
              ],
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

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
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

  const CalendarSection({
    super.key,
    required this.disabledDates,
    required this.disabledWeekdays,
  });

  @override
  State<CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<CalendarSection> {
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  bool loadingSlots = false;
  List<String> disabledSlots = [];

  bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool isDisabled(DateTime day) {
    if (widget.disabledDates.any((d) => sameDay(d, day))) return true;
    final apiWeekday = day.weekday % 7; // Sunday = 0
    return widget.disabledWeekdays.contains(apiWeekday);
  }

  /// 🔥 CALL API ON DATE SELECT
  Future<void> fetchDisabledSlots(DateTime date) async {
    setState(() {
      loadingSlots = true;
      disabledSlots.clear();
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
        disabledSlots =
        List<String>.from(res['data']['disabledtimeslotes']);
      });
    } catch (e) {
      debugPrint('Disabled slot API error: $e');
    } finally {
      setState(() {
        loadingSlots = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TableCalendar(
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

              fetchDisabledSlots(selected);
            },

            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
            ),

            calendarStyle: CalendarStyle(
              disabledTextStyle: const TextStyle(color: Colors.grey),
              disabledDecoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Color(0xFF1E3A8A),
                shape: BoxShape.circle,
              ),
              todayDecoration: const BoxDecoration(
                color: Color(0xFFDBEAFE),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: selectedDay == null
              ? const Center(
            child: Text(
              'Select a date',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          )
              : loadingSlots
              ? const Center(child: CircularProgressIndicator())
              : disabledSlots.isEmpty
              ? const Center(
            child: Text(
              'No disabled time slots',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          )
              : GridView.builder(
            shrinkWrap: true,
            physics:
            const NeverScrollableScrollPhysics(),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3,
            ),
            itemCount: disabledSlots.length,
            itemBuilder: (context, index) {
              final slot = disabledSlots[index];

              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade400,
                  ),
                ),
                child: Text(
                  slot,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
