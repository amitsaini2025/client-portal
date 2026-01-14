import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class MyFilesQuickActionsCard extends StatelessWidget {
  final VoidCallback onUploadDocument;
  final VoidCallback onSendMessage;
  final VoidCallback? onViewWorkflow;
  final VoidCallback? onBilling;
  final VoidCallback? onCaseSummary;
  final VoidCallback? onDocumentStatus;
  final VoidCallback? onUpcomingDeadlines;
  final VoidCallback? onRecentActivity;

  const MyFilesQuickActionsCard({
    super.key,
    required this.onUploadDocument,
    required this.onSendMessage,
    this.onViewWorkflow,
    this.onBilling,
    this.onCaseSummary,
    this.onDocumentStatus,
    this.onUpcomingDeadlines,
    this.onRecentActivity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2F57),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Files',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          MasonryGridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemCount: 6,
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return _buildTile(
                      context,
                      icon: Icons.upload_file,
                      label: 'Upload\nDocument',
                      color: Colors.blueAccent.shade100,
                      onTap: onUploadDocument);
                case 1:
                  return _buildTile(
                      context,
                      icon: Icons.timeline,
                      label: 'View\nWorkflow',
                      color: Colors.purpleAccent.shade100,
                      onTap: onViewWorkflow ?? () {});
                case 2:
                  return _buildTile(
                      context,
                      icon: Icons.receipt_long,
                      label: 'Billing',
                      color: Colors.redAccent.shade100,
                      onTap: onBilling ?? () {});
                case 3:
                  return _buildTile(
                      context,
                      icon: Icons.assignment,
                      label: 'Case\nSummary',
                      color: Colors.indigoAccent.shade100,
                      onTap: onCaseSummary ?? () {});
                case 4:
                  return _buildTile(
                      context,
                      icon: Icons.description,
                      label: 'Document\nStatus',
                      color: Colors.orangeAccent.shade100,
                      onTap: onDocumentStatus ?? () {});
                case 5:
                  return _buildTile(
                      context,
                      icon: Icons.local_activity,
                      label: 'Recent\nActivity',
                      color: Colors.amber.shade300,
                      onTap: onRecentActivity ?? () {});
                default:
                  return _buildTile(
                      context,
                      icon: Icons.event,
                      label: 'Upcoming\nDeadlines',
                      color: Colors.tealAccent.shade100,
                      onTap: onUpcomingDeadlines ?? () {});
              }
            },
          ),
        ],
      ),
    );
  }


  Widget _buildTile(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF262D50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(6),
              child: Icon(icon, size: 18, color: color), // smaller icon
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  height: 1.2,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}
