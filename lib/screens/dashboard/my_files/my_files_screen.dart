import 'package:flutter/material.dart';

import '../../../config/theme_config.dart';
import '../../../utils/responsive_utils.dart';
import '../../workflow/workflow_screen.dart';
import 'my_files_quick_action_card.dart';

class MyFilesScreen extends StatelessWidget {
  MyFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.white,
      appBar: AppBar(
        title: const Text(
          'My Files',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: ThemeConfig.goldenYellow,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppResponsive.maxContentWidth),
          child: Padding(
        padding: AppResponsive.pagePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MyFilesQuickActionsCard(
              onViewWorkflow: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const WorkflowScreen(),
                  ),
                );
              },
              onBilling: () {
                /*Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const BillingScreen(),
                            ),
                          );*/
                showSnack(
                  context,
                  "This feature will be available in a future update.",
                );
              },
              onDocumentStatus: () {
                Navigator.pushNamed(context, '/documents');
              },
              onUpcomingDeadlines: () {
                Navigator.pushNamed(context, '/tasks');
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, _MyFileItem item) {
    final bool isVertical = item.vertical;

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: isVertical ? 140 : 60,
        padding:
            isVertical
                ? const EdgeInsets.all(16)
                : const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [item.color.withOpacity(0.2), item.color.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: item.color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child:
            isVertical
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: item.color,
                      radius: 24,
                      child: Icon(item.icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: item.color.darken(0.2),
                      ),
                    ),
                    if (item.helperText != null) const SizedBox(height: 4),
                    if (item.helperText != null)
                      Text(
                        item.helperText!,
                        style: TextStyle(
                          color: item.color.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                  ],
                )
                : Row(
                  children: [
                    Icon(item.icon, color: item.color, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: item.color.darken(0.2),
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  final List<_MyFileItem> _items = [
    _MyFileItem(
      label: 'Upload Document',
      icon: Icons.upload_file,
      color: Colors.blue,
      vertical: true,
      helperText: 'Submit your documents securely',
      onTap: () {},
    ),
    _MyFileItem(
      label: 'Document Status',
      icon: Icons.folder_open,
      color: Colors.orange,
      vertical: false,
      helperText: 'Check all your documents',
      onTap: () {},
    ),
    _MyFileItem(
      label: 'View Workflow',
      icon: Icons.timeline,
      color: Colors.purple,
      vertical: false,
      onTap: () {},
    ),
    _MyFileItem(
      label: 'Billing',
      icon: Icons.receipt_long,
      color: Colors.red,
      vertical: false,
      onTap: () {},
    ),
    _MyFileItem(
      label: 'Page Summary',
      icon: Icons.description,
      color: Colors.green,
      vertical: false,
      onTap: () {},
    ),
  ];

  void showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}

class _MyFileItem {
  final String label;
  final IconData icon;
  final Color color;
  final bool vertical;
  final String? helperText;
  final VoidCallback onTap;

  _MyFileItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.vertical,
    required this.onTap,
    this.helperText,
  });
}

extension ColorUtils on Color {
  Color darken([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}
