import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../services/auth_service.dart';
import '../../../widgets/dialog/login_required_dialog.dart';

class MyFilesQuickActionsCard extends StatelessWidget {
  final VoidCallback onSendMessage;
  final VoidCallback? onViewWorkflow;
  final VoidCallback? onBilling;
  final VoidCallback? onDocumentStatus;
  final VoidCallback? onUpcomingDeadlines;
  final VoidCallback? onRecentActivity;
  final VoidCallback? onMessage;

  const MyFilesQuickActionsCard({
    super.key,
    required this.onSendMessage,
    this.onViewWorkflow,
    this.onBilling,
    this.onDocumentStatus,
    this.onUpcomingDeadlines,
    this.onRecentActivity,
    this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5), // Slightly darker white to match dashboard
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'My Files',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          if (AuthService.isAuthenticated) ...[
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Change Matter"),
                    content: const Text(
                      "Do you want to change the selected matter?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("No"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/matters');
                        },
                        child: const Text("Yes"),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0), // Matches slightly darker background
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blueAccent.shade400,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Click here to change matter",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent.shade400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AuthService.selectedMatterName ?? 'No Matter Selected',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (AuthService.isAuthenticated)
                      Text(
                        "ID: ${AuthService.selectedMatterId ?? ''}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          MasonryGridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemCount: 7,
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return _buildTile(
                    context,
                    icon: Icons.timeline,
                    label: 'View\nWorkflow',
                    color: Colors.purple.shade300,
                    onTap: onViewWorkflow ?? () {},
                  );
                case 1:
                  return _buildTile(
                    context,
                    icon: Icons.receipt_long,
                    label: 'Billing',
                    color: Colors.red.shade300,
                    onTap: onBilling ?? () {},
                  );
                case 2:
                  return _buildTile(
                    context,
                    icon: Icons.description,
                    label: 'Document\nStatus',
                    color: Colors.orange.shade300,
                    onTap: onDocumentStatus ?? () {},
                  );
                case 3:
                  return _buildTile(
                    context,
                    icon: Icons.local_activity,
                    label: 'Recent\nActivity',
                    color: Colors.amber.shade300,
                    onTap: onRecentActivity ?? () {},
                  );
                case 4:
                  return _buildTile(
                    context,
                    icon: Icons.message,
                    label: 'Message',
                    color: Colors.green.shade300,
                    onTap: onMessage ?? () {},
                  );
                default:
                  return const SizedBox.shrink();
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
      onTap: () {
        if (!AuthService.isAuthenticated) {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (_) => const LoginRequiredDialog(),
          );
          return;
        }
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEFEFEF), // Slightly darker than dashboard
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(6),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  height: 1.2,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}