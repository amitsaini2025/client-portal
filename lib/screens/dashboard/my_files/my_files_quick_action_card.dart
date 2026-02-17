import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../services/auth_service.dart';
import '../../../widgets/dialog/login_required_dialog.dart';

class MyFilesQuickActionsCard extends StatelessWidget {
  final VoidCallback onSendMessage;
  final VoidCallback? onViewWorkflow;
  final VoidCallback? onBilling;
  final VoidCallback? onCaseSummary;
  final VoidCallback? onDocumentStatus;
  final VoidCallback? onUpcomingDeadlines;
  final VoidCallback? onRecentActivity;
  final VoidCallback? onMessage;

  const MyFilesQuickActionsCard({
    super.key,
    required this.onSendMessage,
    this.onViewWorkflow,
    this.onBilling,
    this.onCaseSummary,
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
        color: const Color(0xFF2A2F57),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
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
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          if (AuthService.isAuthenticated) ...[
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
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
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.yellowAccent.shade400,
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
                        color: Colors.yellowAccent.shade400,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Text(
                      AuthService.selectedMatterName ?? 'No Matter Selected',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),

                    if (AuthService.isAuthenticated)
                      Text(
                        "ID: ${AuthService.selectedMatterId ?? ''}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
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
                /*case 0:
                  return _buildTile(
                    context,
                    icon: Icons.upload_file,
                    label: 'Upload\nDocument',
                    color: Colors.blueAccent.shade100,
                    onTap: onUploadDocument,
                  );*/
                case 0:
                  return _buildTile(
                    context,
                    icon: Icons.timeline,
                    label: 'View\nWorkflow',
                    color: Colors.purpleAccent.shade100,
                    onTap: onViewWorkflow ?? () {},
                  );
                case 1:
                  return _buildTile(
                    context,
                    icon: Icons.receipt_long,
                    label: 'Billing',
                    color: Colors.redAccent.shade100,
                    onTap: onBilling ?? () {},
                  );
                case 2:
                  return _buildTile(
                    context,
                    icon: Icons.assignment,
                    label: 'Case\nSummary',
                    color: Colors.indigoAccent.shade100,
                    onTap: onCaseSummary ?? () {},
                  );
                case 3:
                  return _buildTile(
                    context,
                    icon: Icons.description,
                    label: 'Document\nStatus',
                    color: Colors.orangeAccent.shade100,
                    onTap: onDocumentStatus ?? () {},
                  );
                case 4:
                  return _buildTile(
                    context,
                    icon: Icons.local_activity,
                    label: 'Recent\nActivity',
                    color: Colors.amber.shade300,
                    onTap: onRecentActivity ?? () {},
                  );
                case 5:
                  return _buildTile(
                    context,
                    icon: Icons.message,
                    label: 'Message',
                    color: Colors.greenAccent.shade100,
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
          color: const Color(0xFF262D50),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  height: 1.2,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: Colors.white38,
            ),
          ],
        ),
      ),
    );
  }
}
