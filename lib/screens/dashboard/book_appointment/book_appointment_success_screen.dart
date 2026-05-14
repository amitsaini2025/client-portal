import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../utils/responsive_utils.dart';

class BookAppointmentSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const BookAppointmentSuccessScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final appointment = data['data'];

    final date = DateFormat(
      'MMM dd, yyyy',
    ).format(DateTime.parse(appointment['appointment_date']));
    final time = appointment['appointment_time'];
    final reference = "#${appointment['id']}";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppResponsive.maxContentWidth,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),

                Container(
                  height: 80,
                  width: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF22C55E),
                  ),
                  child: const Icon(Icons.check, size: 40, color: Colors.white),
                ),

                const SizedBox(height: 20),

                const Text(
                  "🎉 Appointment Confirmed!",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Your appointment has been successfully booked",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 30),

                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 420),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .05),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Column(
                          children: [
                            Text(
                              "Booking Reference",
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: 6),
                          ],
                        ),
                      ),

                      Center(
                        child: Text(
                          reference,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),

                      const Divider(height: 40),

                      _item(
                        Icons.person,
                        "Full Name",
                        appointment['full_name'],
                      ),
                      _item(Icons.email, "Email", appointment['email']),
                      _item(Icons.phone, "Phone", appointment['phone']),
                      _item(Icons.calendar_month, "Date", date),
                      _item(Icons.access_time, "Time", time),
                      _item(
                        Icons.place,
                        "Location",
                        appointment['location'].toString().toUpperCase(),
                      ),
                      _item(Icons.badge, "Type", appointment['service_type']),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: 220,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (r) => r.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F3C88),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Back to Home",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // ✅ FIX
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),

          Expanded( // ✅ FIX (MAIN ONE)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}