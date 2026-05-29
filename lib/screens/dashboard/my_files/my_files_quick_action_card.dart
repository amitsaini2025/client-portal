import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../services/auth_service.dart';
import '../../../widgets/dialog/login_required_dialog.dart';

class MyFilesQuickActionsCard extends StatelessWidget {
  final VoidCallback? onViewWorkflow;
  final VoidCallback? onBilling;
  final VoidCallback? onDocumentStatus;
  final VoidCallback? onUpcomingDeadlines;
  final VoidCallback? onMessage;

  const MyFilesQuickActionsCard({
    super.key,
    this.onViewWorkflow,
    this.onBilling,
    this.onDocumentStatus,
    this.onUpcomingDeadlines,
    this.onMessage,
  });

  static const double _radius = 14;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = constraints.maxWidth > 600;
        final tilePadding = isWeb ? 12.0 : 16.0;
        final iconSize = isWeb ? 20.0 : 26.0;
        final fontSize = isWeb ? 12.5 : 13.5;
        final iconPad = isWeb ? 8.0 : 8.0;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9B000),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'My Files',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (AuthService.isAuthenticated) ...[
                _matterSelector(context),
                const SizedBox(height: 16),
              ],

              StaggeredGrid.count(
                crossAxisCount: isWeb ? 6 : 4,
                mainAxisSpacing: isWeb ? 10 : 12,
                crossAxisSpacing: isWeb ? 10 : 12,
                children: [
                  // Big tiles: horizontal on web, vertical on mobile
                  StaggeredGridTile.count(
                    crossAxisCellCount: isWeb ? 3 : 2,
                    mainAxisCellCount: isWeb ? 0.85 : 2.2,
                    child: isWeb
                        ? _horizontalTile(
                            context: context,
                            icon: Icons.account_tree_rounded,
                            label: 'View Workflow',
                            gradient: const [Color(0xFF6A1B9A), Color(0xFFCE93D8)],
                            onTap: onViewWorkflow ?? () {},
                            iconSize: iconSize,
                            fontSize: fontSize,
                            padding: tilePadding,
                            iconPad: iconPad,
                          )
                        : _verticalTile(
                            context: context,
                            icon: Icons.account_tree_rounded,
                            label: 'View\nWorkflow',
                            gradient: const [Color(0xFF6A1B9A), Color(0xFFCE93D8)],
                            onTap: onViewWorkflow ?? () {},
                            iconSize: iconSize,
                            fontSize: fontSize,
                            padding: tilePadding,
                          ),
                  ),

                  StaggeredGridTile.count(
                    crossAxisCellCount: isWeb ? 3 : 2,
                    mainAxisCellCount: isWeb ? 0.85 : 2.2,
                    child: isWeb
                        ? _horizontalTile(
                            context: context,
                            icon: Icons.receipt_long_rounded,
                            label: 'Billing',
                            gradient: const [Color(0xFFC62828), Color(0xFFEF9A9A)],
                            onTap: onBilling ?? () {},
                            iconSize: iconSize,
                            fontSize: fontSize,
                            padding: tilePadding,
                            iconPad: iconPad,
                          )
                        : _verticalTile(
                            context: context,
                            icon: Icons.receipt_long_rounded,
                            label: 'Billing',
                            gradient: const [Color(0xFFC62828), Color(0xFFEF9A9A)],
                            onTap: onBilling ?? () {},
                            iconSize: iconSize,
                            fontSize: fontSize,
                            padding: tilePadding,
                          ),
                  ),

                  // Small tiles
                  _tile(
                    context: context,
                    icon: Icons.chat_bubble_rounded,
                    label: 'Messages',
                    gradient: const [Color(0xFF2E7D32), Color(0xFF81C784)],
                    onTap: onMessage ?? () {},
                    iconSize: iconSize - 2,
                    fontSize: fontSize - 0.5,
                    padding: tilePadding - 2,
                    iconPad: iconPad - 2,
                    crossAxisCellCount: isWeb ? 3 : 2,
                    isWeb: isWeb,
                  ),

                  /*_tile(
                    context: context,
                    icon: Icons.folder_copy_rounded,
                    label: 'Documents',
                    gradient: const [Color(0xFF1565C0), Color(0xFF90CAF9)],
                    onTap: onDocumentStatus ?? () {},
                    iconSize: iconSize - 2,
                    fontSize: fontSize - 0.5,
                    padding: tilePadding - 2,
                    iconPad: iconPad - 2,
                    crossAxisCellCount: 2,
                    isWeb: isWeb,
                  ),

                  _tile(
                    context: context,
                    icon: Icons.alarm_rounded,
                    label: 'Upcoming Deadlines',
                    gradient: const [Color(0xFFE65100), Color(0xFFFFCC80)],
                    onTap: onUpcomingDeadlines ?? () {},
                    iconSize: iconSize - 2,
                    fontSize: fontSize - 0.5,
                    padding: tilePadding - 2,
                    iconPad: iconPad - 2,
                    crossAxisCellCount: isWeb ? 2 : 4,
                    isWeb: isWeb,
                  ),*/
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _matterSelector(BuildContext context) {
    void openDialog() {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Change Matter"),
          content: const Text("Do you want to change the selected matter?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/matters',
                  arguments: {'from_my_files': true},
                );
              },
              child: const Text("Yes"),
            ),
          ],
        ),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: openDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E7D6B), Color(0xFF1A4F45)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.folder_special_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ACTIVE MATTER',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    AuthService.selectedMatterName ?? 'No Matter Selected',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (AuthService.selectedMatterId != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'ID: ${AuthService.selectedMatterId}',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
              ),
              child: const Text(
                'Switch',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Vertical tile — icon top, label bottom (mobile big tiles)
  Widget _verticalTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
    required double iconSize,
    required double fontSize,
    required double padding,
  }) {
    return InkWell(
      onTap: () => _handleAuth(context, onTap),
      borderRadius: BorderRadius.circular(_radius),
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: iconSize, color: Colors.white),
            ),
            const Spacer(),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Horizontal tile — icon left, label right (web big tiles)
  Widget _horizontalTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
    required double iconSize,
    required double fontSize,
    required double padding,
    required double iconPad,
  }) {
    return InkWell(
      onTap: () => _handleAuth(context, onTap),
      borderRadius: BorderRadius.circular(_radius),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: padding + 2, vertical: padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(iconPad),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: iconSize, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: fontSize,
                  height: 1.3,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  // Small tile — always horizontal, wraps in StaggeredGridTile
  Widget _tile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
    required double iconSize,
    required double fontSize,
    required double padding,
    required double iconPad,
    required int crossAxisCellCount,
    required bool isWeb,
  }) {
    return StaggeredGridTile.count(
      crossAxisCellCount: crossAxisCellCount,
      mainAxisCellCount: isWeb ? 0.72 : 1.25,
      child: InkWell(
        onTap: () => _handleAuth(context, onTap),
        borderRadius: BorderRadius.circular(_radius),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: padding + 2, vertical: padding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(iconPad),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: iconSize, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: fontSize,
                    height: 1.25,
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
