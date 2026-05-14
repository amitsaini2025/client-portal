import 'package:client/models/case_summary.dart';
import 'package:flutter/material.dart';
import '../../models/case.dart';

class CaseSummaryCard extends StatelessWidget {
  final CaseSummary? caseSummary;
  final List<Case> cases;

  const CaseSummaryCard({
    super.key,
    required this.caseSummary,
    required this.cases,
  });

  @override
  Widget build(BuildContext context) {
    final activeCases = caseSummary?.activeCases ?? 0;
    final completedCases = caseSummary?.completedCases ?? 0;
    final totalCases = caseSummary?.totalCases ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
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
                'Case Summary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/recent-cases');
                },
                child: const Text(
                  'View All',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Case Stats
          Row(
            children: [
              _buildStatItem(context, icon: Icons.folder_open, label: 'Active', value: activeCases.toString(), color: Colors.blue),
              const SizedBox(width: 6),
              _buildStatItem(context, icon: Icons.check_circle, label: 'Completed', value: completedCases.toString(), color: Colors.green),
              const SizedBox(width: 6),
              _buildStatItem(context, icon: Icons.analytics, label: 'Total', value: totalCases.toString(), color: Colors.purple),
            ],
          ),
          const SizedBox(height: 12),

          // Recent Cases
          if (cases.isNotEmpty) ...[
            Text(
              'Recent Cases',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            ...cases.take(3).map((caseItem) => _buildCaseItem(context, caseItem)),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.folder_open, size: 40, color: Colors.grey.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  Text(
                    'No cases yet',
                    style: TextStyle(color: Colors.grey.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your cases will appear here once they are created',
                    style: TextStyle(color: Colors.grey.withValues(alpha: 0.5), fontSize: 11),
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

  Widget _buildStatItem(BuildContext context,
      {required IconData icon, required String label, required String value, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            Text(label, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseItem(BuildContext context, Case caseItem) {
    final statusColor = _getStatusColor(caseItem.status);
    final statusText = _getStatusText(caseItem.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.folder, color: statusColor, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  caseItem.title.replaceAll(RegExp(r'\s+'), ' ').trim(),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  caseItem.caseNumber.toString(),
                  style: TextStyle(color: Colors.grey.withValues(alpha: 0.7), fontSize: 10),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              statusText,
              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'pending_documents':
        return Colors.orange;
      case 'pending_review':
        return Colors.yellow.shade700;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'in_progress':
        return 'In Progress';
      case 'pending_documents':
        return 'Pending Docs';
      case 'pending_review':
        return 'Under Review';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }
}
