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
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text(
          'Appointments',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: ThemeConfig.goldenYellow,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final item = appointments[index];

          return AppointmentCard(
            data: item,
          );
        },
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const AppointmentCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final createdBy = data['assigned_admin']?['name'];
    final avatarChar = createdBy != null && createdBy.isNotEmpty
        ? createdBy[0].toUpperCase()
        : data['full_name'][0].toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatDate(data['appointment_date']),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                _formatTime(
                  data['appointment_time'],
                  data['duration_minutes'],
                ),
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            _timeAgo(data['created_at']),
            style: const TextStyle(fontSize: 12, color: Colors.black45),
          ),

          const Divider(height: 24),

          Text(
            data['service_type'] ?? '',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            data['enquiry_details'] ?? '',
            style: const TextStyle(
              color: Colors.black54,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _LightActionButton(
                  icon: Icons.info_outline,
                  label: "Appointment Details",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AppointmentDetailScreen(
                          appointmentId: data['id'],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _LightActionButton(
                  icon: Icons.history,
                  label: "Payment History",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AppointmentDetailScreen(
                          appointmentId: data['id'],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Created By",
                style: TextStyle(fontSize: 12, color: Colors.black45),
              ),
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color(0xFF6C7CF0),
                    child: Text(
                      avatarChar,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    createdBy ?? data['full_name'],
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
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

class _LightActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LightActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.black54),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
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
