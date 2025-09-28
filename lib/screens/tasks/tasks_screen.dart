import 'package:flutter/material.dart';
import '../../models/new/task.dart';
import '../../services/api_service.dart';
import '../../config/theme_config.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _statusFilter = 'all';
  String _priorityFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getClientTasks(
        page: 1,
        perPage: 10,
        search: _searchQuery,
        status: _statusFilter,
        priority: _priorityFilter,
      );

      final data = response['data']['items'] as List<dynamic>? ?? [];
      final tasks = data.map((json) => Task.fromJson(json)).toList();

      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load tasks: ${e.toString()}';
      });
    }
  }

  List<Task> get _filteredTasks {
    return _tasks.where((task) {
      final matchesSearch =
      (task.title?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
          false);
      final matchesStatus =
          _statusFilter == 'all' || task.status == _statusFilter;
      final matchesPriority =
          _priorityFilter == 'all' || task.priority == _priorityFilter;
      return matchesSearch && matchesStatus && matchesPriority;
    }).toList();
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'high':
        return 'High';
      case 'medium':
        return 'Medium';
      case 'low':
        return 'Low';
      default:
        return priority;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'high':
        return Icons.priority_high;
      case 'medium':
        return Icons.remove;
      case 'low':
        return Icons.keyboard_arrow_down;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return ThemeConfig.goldenYellow;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'in_progress':
        return Icons.timeline;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  bool _isDueSoon(DateTime dueDate) {
    final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
    return daysUntilDue <= 3 && daysUntilDue >= 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.navyBlue,
      appBar: AppBar(
        title: const Text('Tasks'),
        backgroundColor: ThemeConfig.goldenYellow,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(child: _buildTaskList()),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              _loadTasks();
            },
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[800],
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all', 'status'),
                const SizedBox(width: 8),
                _buildFilterChip('Pending', 'pending', 'status'),
                const SizedBox(width: 8),
                _buildFilterChip('In Progress', 'in_progress', 'status'),
                const SizedBox(width: 8),
                _buildFilterChip('Completed', 'completed', 'status'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All Priorities', 'all', 'priority'),
                const SizedBox(width: 8),
                _buildFilterChip('High', 'high', 'priority'),
                const SizedBox(width: 8),
                _buildFilterChip('Medium', 'medium', 'priority'),
                const SizedBox(width: 8),
                _buildFilterChip('Low', 'low', 'priority'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String type) {
    final isSelected =
    type == 'status' ? _statusFilter == value : _priorityFilter == value;

    return FilterChip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (type == 'status') {
            _statusFilter = value;
          } else {
            _priorityFilter = value;
          }
        });
        _loadTasks();
      },
      selectedColor: ThemeConfig.goldenYellow.withOpacity(0.2),
      checkmarkColor: ThemeConfig.goldenYellow,
      backgroundColor: Colors.grey[700],
    );
  }

  Widget _buildTaskList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ThemeConfig.goldenYellow),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_errorMessage!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTasks,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConfig.goldenYellow,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty ||
                  _statusFilter != 'all' ||
                  _priorityFilter != 'all'
                  ? 'No tasks match your search'
                  : 'No tasks found',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: ThemeConfig.goldenYellow,
      onRefresh: _loadTasks,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredTasks.length,
        itemBuilder: (context, index) {
          final task = _filteredTasks[index];
          return _buildTaskCard(task);
        },
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Card(
      color: Colors.grey[800],
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showTaskDetails(task),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ThemeConfig.goldenYellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.task,
                        color: ThemeConfig.goldenYellow, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.title ?? 'Untitled Task',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        decoration: task.status == 'completed'
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule,
                      size: 16, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(task.dueDate,
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskDetails(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ThemeConfig.navyBlue,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20))),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    task.title ?? 'Untitled Task',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                      Icons.schedule, 'Due Date', task.dueDate),
                  _buildDetailRow(Icons.priority_high, 'Priority',
                      _getPriorityText(task.priority ?? 'unknown')),
                  _buildDetailRow(Icons.info, 'Status',
                      _getStatusText(task.status ?? 'unknown')),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: ThemeConfig.goldenYellow),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
