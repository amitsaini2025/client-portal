import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class QuickActionsCard extends StatelessWidget {
  final VoidCallback onBookAppointment;
  final VoidCallback? onHealthInsurance;
  final VoidCallback? onUpcomingDeadlines;
  final VoidCallback? onPRCalculator;
  final VoidCallback? onStudentFundCalculator;
  final VoidCallback? onOccupationSearch;
  final VoidCallback? onPostCodeChecker;
  final VoidCallback? onCourseSearch;
  final VoidCallback? onImportantLinks;
  final VoidCallback? onEnglishRequirement;
  final VoidCallback? onWebSearch;

  const QuickActionsCard({
    super.key,
    required this.onBookAppointment,
    this.onHealthInsurance,
    this.onUpcomingDeadlines,
    this.onPRCalculator,
    this.onStudentFundCalculator,
    this.onOccupationSearch,
    this.onPostCodeChecker,
    this.onCourseSearch,
    this.onImportantLinks,
    this.onEnglishRequirement,
    this.onWebSearch,
  });

  static const double _radius = 12;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          MasonryGridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            itemCount: 10, // updated
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return _tile(
                    icon: Icons.schedule,
                    label: 'Book\nAppointment',
                    color: Colors.green,
                    onTap: onBookAppointment,
                  );
                case 1:
                  return _tile(
                    icon: Icons.health_and_safety,
                    label: 'Health\nInsurance',
                    color: Colors.brown,
                    onTap: onHealthInsurance ?? () {},
                  );
                case 2:
                  return _tile(
                    icon: Icons.calculate,
                    label: 'PR\nCalculator',
                    color: Colors.red,
                    onTap: onPRCalculator ?? () {},
                  );
                case 3:
                  return _tile(
                    icon: Icons.calculate,
                    label: 'Student\nFund Calculator',
                    color: Colors.purple,
                    onTap: onStudentFundCalculator ?? () {},
                  );
                case 4:
                  return _tile(
                    icon: Icons.search,
                    label: 'Occupation\nSearch',
                    color: Colors.blue,
                    onTap: onOccupationSearch ?? () {},
                  );
                case 5:
                  return _tile(
                    icon: Icons.code,
                    label: 'Post\nCode Checker',
                    color: Colors.redAccent,
                    onTap: onPostCodeChecker ?? () {},
                  );
                case 6:
                  return _tile(
                    icon: Icons.school,
                    label: 'Course\nSearch',
                    color: Colors.orange,
                    onTap: onCourseSearch ?? () {},
                  );
                case 7:
                  return _tile(
                    icon: Icons.link,
                    label: 'Important\nLinks',
                    color: Colors.teal,
                    onTap: onImportantLinks ?? () {},
                  );
                case 8:
                  return _tile(
                    icon: Icons.language,
                    label: 'English\nRequirement',
                    color: Colors.indigo,
                    onTap: onEnglishRequirement ?? () {},
                  );
                case 9:
                  return _tile(
                    icon: Icons.web,
                    label: 'Web\nSearch',
                    color: Colors.pink,
                    onTap: onWebSearch ?? () {},
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

  Widget _tile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_radius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color.withOpacity(0.95),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
