import 'package:flutter/material.dart';

class QuickActionsCard extends StatelessWidget {
  final VoidCallback onUploadDocument;
  final VoidCallback onBookAppointment;
  final VoidCallback onSendMessage;
  final VoidCallback? onViewWorkflow;
  final VoidCallback? onBilling;

  const QuickActionsCard({
    super.key,
    required this.onUploadDocument,
    required this.onBookAppointment,
    required this.onSendMessage,
    this.onViewWorkflow,
    this.onBilling
  });

  @override
  Widget build(BuildContext context) {
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
          Text(
            'Quick Actions',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          _buildActionButton(
            context: context,
            icon: Icons.upload_file,
            label: 'Upload Document',
            onTap: onUploadDocument,
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            context: context,
            icon: Icons.schedule,
            label: 'Book Appointment',
            onTap: onBookAppointment,
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            context: context,
            icon: Icons.message,
            label: 'Send Message',
            onTap: onSendMessage,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            context: context,
            icon: Icons.timeline,
            label: 'View Workflow',
            onTap: onViewWorkflow ?? () {},
            color: Colors.purple,
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            context: context,
            icon: Icons.timeline,
            label: 'Billing',
            onTap: onBilling ?? () {},
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity, // match parent width
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16), // smaller height
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24), // smaller icon
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
