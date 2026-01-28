import 'package:flutter/material.dart';

import '../../../config/theme_config.dart';
import '../../../services/api_service.dart';
import 'appointment_detail_screen.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  bool isLoading = true;
  String? error;
  List appointments = [];

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    try {
      final response = await ApiService.getAppointments(page: 1, perPage: 50);

      final list = response['data']['data'];

      setState(() {
        appointments = list;
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
      appBar: AppBar(
        title: const Text(
          'Appointments',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: ThemeConfig.goldenYellow,
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(child: Text(error!))
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final item = appointments[index];
                  final isLatest = false;

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => AppointmentDetailScreen(
                                appointmentId: item['id'],
                              ),
                        ),
                      );
                    },
                    child: AppointmentCard(data: item, highlighted: isLatest),
                  );
                },
              ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool highlighted;

  const AppointmentCard({
    super.key,
    required this.data,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = highlighted ? const Color(0xFF6C7CF0) : Colors.white;
    final textColor = highlighted ? Colors.white : Colors.black87;
    final subTextColor = highlighted ? Colors.white70 : Colors.black54;

    final createdBy = data['assigned_admin']?['name'];
    final avatarChar =
        createdBy != null && createdBy.isNotEmpty
            ? createdBy[0].toUpperCase()
            : data['full_name'][0].toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatDate(data['appointment_date']),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            _formatTime(data['appointment_time'], data['duration_minutes']),
            style: TextStyle(color: subTextColor),
          ),

          const SizedBox(height: 6),

          Text(
            _timeAgo(data['created_at']),
            style: TextStyle(color: subTextColor, fontSize: 12),
          ),

          const SizedBox(height: 14),

          Text(
            data['service_type'] ?? '',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            data['enquiry_details'] ?? '',
            style: TextStyle(color: subTextColor),
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("Created By:", style: TextStyle(color: subTextColor)),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 16,
                backgroundColor:
                    highlighted ? Colors.white : const Color(0xFF6C7CF0),
                child: Text(
                  avatarChar,
                  style: TextStyle(
                    color: highlighted ? const Color(0xFF6C7CF0) : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    final d = DateTime.parse(date);
    return "${d.day.toString().padLeft(2, '0')}/"
        "${d.month.toString().padLeft(2, '0')}/${d.year}";
  }

  String _formatTime(String time, int duration) {
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

  String _timeAgo(String dateTime) {
    final dt = DateTime.parse(dateTime);
    final diff = DateTime.now().difference(dt);

    if (diff.inMinutes < 1) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} minutes ago";
    if (diff.inHours < 24) return "${diff.inHours} hours ago";
    if (diff.inDays < 30) return "${diff.inDays} days ago";
    return "${(diff.inDays / 30).floor()} months ago";
  }
}

/*extension TimeFormat on TimeOfDay {
  String formatDummy() {
    final h = hourOfPeriod == 0 ? 12 : hourOfPeriod;
    final m = minute.toString().padLeft(2, '0');
    final p = period == DayPeriod.am ? "AM" : "PM";
    return "$h:$m $p";
  }
}*/
