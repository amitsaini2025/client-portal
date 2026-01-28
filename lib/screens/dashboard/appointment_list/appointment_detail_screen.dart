import 'package:flutter/material.dart';

import '../../../config/theme_config.dart';
import '../../../services/api_service.dart';

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
      final response = await ApiService.getAppointmentById(
        widget.appointmentId,
      );

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
      appBar: AppBar(
        title: const Text(
          'Appointment Details',
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
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    final d = data!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE9EDF5), Color(0xFFF4F6FB)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// SERVICE TITLE
          Text(
            _capitalize(d['specific_service'] ?? ''),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          /// TIME
          Row(
            children: [
              const Icon(Icons.access_time, size: 18),
              const SizedBox(width: 8),
              Text(
                _formatTimeRange(d['appointment_time'], d['duration_minutes']),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// DATE
          Row(
            children: [
              const Icon(Icons.calendar_month, size: 18),
              const SizedBox(width: 8),
              Text(
                _formatFullDate(d['appointment_date']),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// ENQUIRY
          Text(
            d['enquiry_details'] ?? '',
            style: const TextStyle(fontSize: 16),
          ),

          const SizedBox(height: 40),

          /// CREATED BY
          const Text("Created By:", style: TextStyle(fontSize: 16)),

          const SizedBox(height: 12),

          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.blue,
                child: Text(
                  _creatorInitial(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Super1",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text("admin1@gmail.com", style: TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _creatorInitial() {
    return "S";
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
      "Dec",
    ];
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return "${d.day} ${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.year}";
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

extension TimeFormat on TimeOfDay {
  String formatDummy() {
    final h = hourOfPeriod == 0 ? 12 : hourOfPeriod;
    final m = minute.toString().padLeft(2, '0');
    final p = period == DayPeriod.am ? "AM" : "PM";
    return "$h:$m $p";
  }
}
