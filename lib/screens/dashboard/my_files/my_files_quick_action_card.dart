import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../services/auth_service.dart';
import '../../../widgets/dialog/login_required_dialog.dart';

class MyFilesQuickActionsCard extends StatelessWidget {
  final VoidCallback? onViewWorkflow;
  final VoidCallback? onBilling;
  final VoidCallback? onDocumentStatus;
  final VoidCallback? onUpcomingDeadlines;
  final VoidCallback? onRecentActivity;
  final VoidCallback? onMessage;

  const MyFilesQuickActionsCard({
    super.key,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = constraints.maxWidth > 600;
        final tilePadding = isWeb ? 12.0 : 20.0;
        final iconSize = isWeb ? 24.0 : 30.0;
        final fontSize = isWeb ? 13.0 : 15.0;

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
                crossAxisCount: isWeb ? 6 : 4, // more columns on web
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [

                  StaggeredGridTile.count(
                    crossAxisCellCount: isWeb ? 2 : 2,
                    mainAxisCellCount: isWeb ? 1.5 : 2.2,
                    child: _verticalTile(
                      icon: Icons.timeline,
                      label: 'View\nWorkflow',
                      color: const Color(0xCC6A1B9A),
                      onTap: onViewWorkflow ?? () {},
                      iconSize: iconSize,
                      fontSize: fontSize,
                      padding: tilePadding,
                    ),
                  ),

                  StaggeredGridTile.count(
                    crossAxisCellCount: isWeb ? 2 : 2,
                    mainAxisCellCount: isWeb ? 1.5 : 2.2,
                    child: _verticalTile(
                      icon: Icons.receipt_long,
                      label: 'Billing',
                      color: const Color(0xCCC62828),
                      onTap: onBilling ?? () {},
                      iconSize: iconSize,
                      fontSize: fontSize,
                      padding: tilePadding,
                    ),
                  ),

                  /*StaggeredGridTile.count(
                    crossAxisCellCount: isWeb ? 4 : 4,
                    mainAxisCellCount: isWeb ? 1.0 : 1.3,
                    child: _horizontalTile(
                      icon: Icons.description,
                      label: 'Document Status',
                      color: const Color(0xCCEF6C00),
                      onTap: onDocumentStatus ?? () {},
                      iconSize: iconSize - 6,
                      fontSize: fontSize,
                      padding: tilePadding - 2,
                    ),
                  ),*/

                  _smallTile(
                    icon: Icons.local_activity,
                    label: 'Recent\nActivity',
                    color: const Color(0xCCF9A825),
                    onTap: onRecentActivity ?? () {},
                    context: context,
                    iconSize: iconSize - 6,
                    fontSize: fontSize - 1,
                    padding: tilePadding - 4,
                  ),

                  _smallTile(
                    icon: Icons.message,
                    label: 'Message',
                    color: const Color(0xCC2E7D32),
                    onTap: onMessage ?? () {},
                    context: context,
                    iconSize: iconSize - 6,
                    fontSize: fontSize - 1,
                    padding: tilePadding - 4,
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
    required double iconSize,
    required double fontSize,
    required double padding,
  }) {
    return Builder(builder: (context) {
      return InkWell(
        onTap: () => _handleAuth(context, onTap),
        borderRadius: BorderRadius.circular(_radius),
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: iconSize, color: Colors.white),
              const Spacer(),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: fontSize,
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
    required double iconSize,
    required double fontSize,
    required double padding,
  }) {
    return Builder(builder: (context) {
      return InkWell(
        onTap: () => _handleAuth(context, onTap),
        borderRadius: BorderRadius.circular(_radius),
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: Row(
            children: [
              Icon(icon, size: iconSize, color: Colors.white),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: fontSize,
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
    required double iconSize,
    required double fontSize,
    required double padding,
  }) {
    return StaggeredGridTile.count(
      crossAxisCellCount: 2,
      mainAxisCellCount: 1.2,
      child: InkWell(
        onTap: () => _handleAuth(context, onTap),
        borderRadius: BorderRadius.circular(_radius),
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: Row(
            children: [
              Icon(icon, size: iconSize, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: fontSize,
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
        builder: (_) => LoginRequiredDialog(parentContext: context),
      );
      return;
    }
    onTap();
  }
}