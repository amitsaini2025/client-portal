import 'package:flutter/material.dart';
import 'package:client/config/theme_config.dart';
import '../../models/new/recent_activity.dart';
import '../../services/api_service.dart';

class RecentActivityScreen extends StatefulWidget {
  const RecentActivityScreen({super.key});

  @override
  State<RecentActivityScreen> createState() => _RecentActivityScreenState();
}

class _RecentActivityScreenState extends State<RecentActivityScreen> {
  List<Activity> _activities = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getRecentActivities(
        page: 1,
        perPage: 10,
        search: _searchQuery,
      );

      final data = response['data']['activities'] as List<dynamic>? ?? [];
      final activities = data.map((json) => Activity.fromJson(json)).toList();

      setState(() {
        _activities = activities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load activities: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.navyBlue, // ✅ Background applied
      appBar: AppBar(
        title: const Text("Recent Activities"),
        centerTitle: true,
        backgroundColor: ThemeConfig.goldenYellow, // ✅ Themed AppBar
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadActivities,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _loadActivities();
              },
              style: const TextStyle(color: Colors.white), // ✅ White text
              decoration: InputDecoration(
                hintText: "Search activities...",
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: ThemeConfig.goldenYellow),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: ThemeConfig.goldenYellow),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: ThemeConfig.goldenYellow, width: 2),
                ),
                filled: true,
                fillColor: ThemeConfig.navyBlue.withOpacity(0.5),
              ),
            ),
          ),
          Expanded(child: _buildActivityList()),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Colors.white));

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: ThemeConfig.goldenYellow),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConfig.goldenYellow,
                foregroundColor: Colors.white,
              ),
              onPressed: _loadActivities,
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (_activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_alt, size: 64, color: Colors.white70),
            const SizedBox(height: 16),
            Text(
              "No activities found",
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadActivities,
      color: ThemeConfig.goldenYellow,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _activities.length,
        itemBuilder: (context, index) {
          final activity = _activities[index];
          return _buildActivityCard(activity);
        },
      ),
    );
  }

  Widget _buildActivityCard(Activity activity) {
    return Card(
      color: ThemeConfig.navyBlue.withOpacity(0.6), // ✅ Dark card
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: ThemeConfig.goldenYellow.withOpacity(0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(Icons.task, color: ThemeConfig.goldenYellow),
        title: Text(activity.title, style: const TextStyle(color: Colors.white)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activity.description.isNotEmpty ? activity.description : "No description",
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              "Group: ${activity.taskGroup ?? "N/A"}",
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
            ),
            Text(
              "Created: ${activity.createdAt} • ${activity.timeAgo}",
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
        onTap: () => _showActivityDetails(activity),
      ),
    );
  }

  void _showActivityDetails(Activity activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ThemeConfig.navyBlue, // ✅ Themed bottom sheet
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ThemeConfig.goldenYellow,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    activity.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow("Description", activity.description.isNotEmpty ? activity.description : "No description"),
                  _buildDetailRow("Task Group", activity.taskGroup),
                  _buildDetailRow("Created At", activity.createdAt),
                  _buildDetailRow("Updated At", activity.updatedAt),
                  _buildDetailRow("Time Ago", activity.timeAgo),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(fontWeight: FontWeight.bold, color: ThemeConfig.goldenYellow),
          ),
          Expanded(
            child: Text(value ?? "N/A", style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
