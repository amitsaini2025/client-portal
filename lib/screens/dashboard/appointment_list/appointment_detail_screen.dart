import 'package:flutter/material.dart';
import '../../../config/theme_config.dart';
import '../../../services/api_service.dart';
import '../../../utils/responsive_utils.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final int appointmentId;

  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    try {
      final response =
      await ApiService.getAppointmentById(widget.appointmentId);

      setState(() {
        data = response['data'];
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
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text(
          'Appointment Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: ThemeConfig.goldenYellow,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppResponsive.maxContentWidth),
          child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final d = data!;

    return SingleChildScrollView(
      padding: AppResponsive.pagePadding(context),
      child: Column(
        children: [
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _capitalize(d['specific_service'] ?? ''),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.calendar_month,
                  text: _formatFullDate(d['appointment_date']),
                ),
                _InfoRow(
                  icon: Icons.schedule,
                  text: _formatTimeRange(
                    d['appointment_time'],
                    d['duration_minutes'],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Client Information",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                _KeyValue("Name", d['full_name']),
                _KeyValue("Email", d['email']),
                _KeyValue("Phone", d['phone']),
                _KeyValue("Location", d['location']),
              ],
            ),
          ),

          const SizedBox(height: 14),

          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Appointment Details",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                _KeyValue("Meeting Type", d['meeting_type_display']),
                _KeyValue("Language", d['preferred_language']),
                _KeyValue("Enquiry Type", d['enquiry_type_display']),
                _KeyValue("Status", d['status_display']),
              ],
            ),
          ),

          const SizedBox(height: 14),

          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Payment Summary",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                _KeyValue("Amount", "\$${d['amount']}"),
                _KeyValue("Discount", "\$${d['discount_amount']}"),
                _KeyValue("Final Amount", "\$${d['final_amount']}"),
                _KeyValue("Payment Status", d['payment']),
              ],
            ),
          ),

          const SizedBox(height: 14),

          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Enquiry Notes",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  d['enquiry_details'] ?? "-",
                  style: const TextStyle(color: Colors.black54, height: 1.4),
                ),
              ],
            ),
          ),

          if (d['cancellation_reason'] != null) ...[
            const SizedBox(height: 14),
            _InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Cancellation",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    d['cancellation_reason'],
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _capitalize(String text) {
    return text
        .replaceAll("-", " ")
        .split(" ")
        .map((e) => e.isEmpty ? e : "${e[0].toUpperCase()}${e.substring(1)}")
        .join(" ");
  }

  String _formatFullDate(String date) {
    final d = DateTime.parse(date);
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return "${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}";
  }

  String _formatTimeRange(String time, int duration) {
    final parts = time.split(":");
    final start = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final endMinutes = start.hour * 60 + start.minute + duration;
    final end = TimeOfDay(
      hour: (endMinutes ~/ 60) % 24,
      minute: endMinutes % 60,
    );

    return "${start.formatDummy()} - ${end.formatDummy()}";
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;

  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  final String keyText;
  final String? value;

  const _KeyValue(this.keyText, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            keyText,
            style: const TextStyle(color: Colors.black54),
          ),
          Flexible(
            child: Text(
              value ?? "-",
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

extension TimeFormat on TimeOfDay {
  String formatDummy() {
    final h = hourOfPeriod == 0 ? 12 : hourOfPeriod;
    final m = minute.toString().padLeft(2, '0');
    final p = period == DayPeriod.am ? "AM" : "PM";
    return "$h:$m $p";
  }
}
