import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class QuickActionsCard extends StatelessWidget {
  final VoidCallback onBookAppointment;
  final VoidCallback? onPersonalInformationUpload;
  final VoidCallback? onUpcomingDeadlines;
  final VoidCallback? onPRCalculator;
  final VoidCallback? onStudentFundCalculator;

  const QuickActionsCard({
    super.key,
    required this.onBookAppointment,
    this.onPersonalInformationUpload,
    this.onUpcomingDeadlines,
    this.onPRCalculator,
    this.onStudentFundCalculator
  });

  static const double _radius = 8;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          MasonryGridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            itemCount: 4,
            itemBuilder: (context, index) {
              switch (index) {

                case 0:
                  return _horizontalTile(
                    context,
                    icon: Icons.schedule,
                    label: 'Book\nAppointment',
                    color: Colors.green,
                    height: 60,
                    onTap: onBookAppointment,
                  );

                case 1:
                  return _horizontalTile(
                    context,
                    icon: Icons.person,
                    label: 'Personal\nInfo',
                    color: Colors.brown,
                    height: 60,
                    onTap: onPersonalInformationUpload ?? () {},
                  );

                case 2:
                  return _horizontalTile(
                    context,
                    icon: Icons.calculate,
                    label: 'PR\nCalculator',
                    color: Colors.red,
                    height: 60,
                    onTap: onPRCalculator ?? () {},
                  );

                case 3:
                  return _horizontalTile(
                    context,
                    icon: Icons.calculate,
                    label: 'Student\nFund Calculator',
                    color: Colors.purple,
                    height: 60,
                    onTap: onStudentFundCalculator ?? () {},
                  );

                default:
                  return _horizontalTile(
                    context,
                    icon: Icons.event,
                    label: 'Upcoming\nDeadlines',
                    color: Colors.teal,
                    height: 60,
                    onTap: onUpcomingDeadlines ?? () {},
                  );
              }
            },
          ),
        ],
      ),
    );
  }

  /// =================== TILE HELPERS ===================

  Widget _verticalTile(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String helperText,
        required Color color,
        required double height,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_radius),
      child: Container(
        height: height,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 10),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.1,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              helperText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color.withOpacity(0.7),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _horizontalTile(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required double height,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_radius),
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                  color: color.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _horizontalTileTextIcon(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required double height,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_radius),
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                  color: color.withOpacity(0.9),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Icon(icon, size: 20, color: color),
          ],
        ),
      ),
    );
  }
}
