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

  static const double _radius = 18;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            'My Files',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),

          if (AuthService.isAuthenticated) ...[
            _matterSelector(context),
            const SizedBox(height: 20),
          ],

          StaggeredGrid.count(
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [

              StaggeredGridTile.count(
                crossAxisCellCount: 2,
                mainAxisCellCount: 2.2,
                child: _verticalTile(
                  icon: Icons.timeline,
                  label: 'View\nWorkflow',
                  color: const Color(0xCC6A1B9A),
                  onTap: onViewWorkflow ?? () {},
                ),
              ),

              StaggeredGridTile.count(
                crossAxisCellCount: 2,
                mainAxisCellCount: 2.2,
                child: _verticalTile(
                  icon: Icons.receipt_long,
                  label: 'Billing',
                  color: const Color(0xCCC62828),
                  onTap: onBilling ?? () {},
                ),
              ),

              StaggeredGridTile.count(
                crossAxisCellCount: 4,
                mainAxisCellCount: 1.3,
                child: _horizontalTile(
                  icon: Icons.description,
                  label: 'Document Status',
                  color: const Color(0xCCEF6C00),
                  onTap: onDocumentStatus ?? () {},
                ),
              ),

              _smallTile(
                icon: Icons.local_activity,
                label: 'Recent\nActivity',
                color: const Color(0xCCF9A825),
                onTap: onRecentActivity ?? () {},
                context: context,
              ),

              _smallTile(
                icon: Icons.message,
                label: 'Message',
                color: const Color(0xCC2E7D32),
                onTap: onMessage ?? () {},
                context: context,
              ),

              StaggeredGridTile.count(
                crossAxisCellCount: 4,
                mainAxisCellCount: 1.2,
                child: _horizontalTile(
                  icon: Icons.send,
                  label: 'Send Message',
                  color: const Color(0xCC1565C0),
                  onTap: onSendMessage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _matterSelector(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Selected Matter",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AuthService.selectedMatterName ?? 'No Matter Selected',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "ID: ${AuthService.selectedMatterId ?? ''}",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _verticalTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Builder(builder: (context) {
      return InkWell(
        onTap: () => _handleAuth(context, onTap),
        borderRadius: BorderRadius.circular(_radius),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 30, color: Colors.white),
              const Spacer(),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _horizontalTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Builder(builder: (context) {
      return InkWell(
        onTap: () => _handleAuth(context, onTap),
        borderRadius: BorderRadius.circular(_radius),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: Row(
            children: [
              Icon(icon, size: 24, color: Colors.white),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _smallTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return StaggeredGridTile.count(
      crossAxisCellCount: 2,
      mainAxisCellCount: 1.2,
      child: InkWell(
        onTap: () => _handleAuth(context, onTap),
        borderRadius: BorderRadius.circular(_radius),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAuth(BuildContext context, VoidCallback onTap) {
    if (!AuthService.isAuthenticated) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => const LoginRequiredDialog(),
      );
      return;
    }
    onTap();
  }
}