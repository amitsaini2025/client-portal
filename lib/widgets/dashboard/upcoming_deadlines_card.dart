import 'package:client/models/upcoming_deadline_summary.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../models/deadline.dart';

class UpcomingDeadlinesCard extends StatelessWidget {
  final UpcomingDeadlineSummary? upcomingDeadlineSummary;
  final List<Task> tasks;
  final List<Deadline> deadlines;

  const UpcomingDeadlinesCard({
    super.key,
    required this.upcomingDeadlineSummary,
    required this.tasks,
    required this.deadlines,
  });

  @override
  Widget build(BuildContext context) {
    final upcomingTasks = tasks
        .where((t) =>
    t.dueDate != null && t.dueDate!.isAfter(DateTime.now()) && t.status != 'completed')
        .toList();

    final upcomingDeadlines = deadlines
        .where((d) => d.dueDate.isNotEmpty && DateTime.parse(d.dueDate).isAfter(DateTime.now()))
        .toList();

    // Sort by date
    upcomingTasks.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    upcomingDeadlines.sort((a, b) => DateTime.parse(a.dueDate).compareTo(DateTime.parse(b.dueDate)));

    // Get items due in next 7 days
    final nextWeek = DateTime.now().add(const Duration(days: 7));
    final urgentTasks = upcomingTasks.where((t) => t.dueDate!.isBefore(nextWeek)).toList();
    final urgentDeadlines =
    upcomingDeadlines.where((d) => DateTime.parse(d.dueDate).isBefore(nextWeek)).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming Deadlines',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/tasks');
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Summary Statistics
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context: context,
                  icon: Icons.assignment,
                  label: 'Due This Week',
                  value: upcomingDeadlineSummary!.dueThisWeekCount.toString(),
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  context: context,
                  icon: Icons.schedule,
                  label: 'Deadlines',
                  value: upcomingDeadlineSummary!.appointmentsCount.toString(),
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  context: context,
                  icon: Icons.warning,
                  label: 'Overdue',
                  value: upcomingDeadlineSummary!.overdueCount.toString(),
                  color: Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Urgent Items
          if (urgentTasks.isNotEmpty || urgentDeadlines.isNotEmpty) ...[
            Text(
              'Due This Week',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // Tasks
            ...urgentTasks.take(3).map((task) => _buildTaskItem(context, task)),

            // Deadlines
            ...urgentDeadlines.take(3).map((deadline) => _buildDeadlineItem(context, deadline)),

            if (urgentTasks.length > 3 || urgentDeadlines.length > 3) ...[
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    // TODO: Navigate to full deadlines view
                  },
                  child: Text(
                    'View ${urgentTasks.length + urgentDeadlines.length - 6} more items',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
            ],
          ] else ...[
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 48,
                    color: Colors.green.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'All caught up!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No urgent deadlines this week',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: color.withValues(alpha: 0.8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task) {
    final daysLeft = task.dueDate!.difference(DateTime.now()).inDays;
    final isUrgent = daysLeft <= 2;
    final color = isUrgent ? Colors.red : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.assignment, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title ?? 'Untitled Task',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: color),
                    const SizedBox(width: 4),
                    Text(
                      daysLeft == 0
                          ? 'Due today'
                          : daysLeft == 1
                          ? 'Due tomorrow'
                          : 'Due in $daysLeft days',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              task.priority ?? 'medium',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineItem(BuildContext context, Deadline deadline) {
    final dueDate = DateTime.parse(deadline.dueDate);
    final daysLeft = dueDate.difference(DateTime.now()).inDays;
    final isUrgent = daysLeft <= 2;
    final color = isUrgent ? Colors.red : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.schedule, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deadline.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: color),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(dueDate),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              deadline.status,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}