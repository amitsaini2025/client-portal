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
  final VoidCallback? onVACSearch;

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
    this.onVACSearch,
  });

  static const double _radius = 16;

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
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),

          StaggeredGrid.count(
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [

              StaggeredGridTile.count(
                crossAxisCellCount: 2,
                mainAxisCellCount: 2.2,
                child: _verticalTile(
                  icon: Icons.schedule,
                  label: 'Book\nAppointment',
                  color: const Color(0xCC1B5E20),
                  onTap: onBookAppointment,
                ),
              ),

              StaggeredGridTile.count(
                crossAxisCellCount: 2,
                mainAxisCellCount: 2.2,
                child: _verticalTile(
                  icon: Icons.health_and_safety,
                  label: 'Health\nInsurance',
                  color: const Color(0xCC4E342E),
                  onTap: onHealthInsurance ?? () {},
                ),
              ),

              StaggeredGridTile.count(
                crossAxisCellCount: 4,
                mainAxisCellCount: 1.3,
                child: _horizontalTile(
                  icon: Icons.calculate,
                  label: 'PR\nCalculator',
                  color: const Color(0xCCB71C1C),
                  onTap: onPRCalculator ?? () {},
                ),
              ),

              _smallTile(Icons.calculate, 'Student\nFund Calculator',
                  const Color(0xCC4A148C), onStudentFundCalculator ?? () {}),

              _smallTile(Icons.search, 'Occupation\nSearch',
                  const Color(0xCC0D47A1), onOccupationSearch ?? () {}),

              _smallTile(Icons.code, 'Post\nCode Checker',
                  const Color(0xCC880E4F), onPostCodeChecker ?? () {}),

              _smallTile(Icons.school, 'Course\nSearch',
                  const Color(0xCCE65100), onCourseSearch ?? () {}),

              _smallTile(Icons.link, 'Important\nLinks',
                  const Color(0xCC004D40), onImportantLinks ?? () {}),

              _smallTile(Icons.language, 'English\nRequirement',
                  const Color(0xCC1A237E), onEnglishRequirement ?? () {}),

              _smallTile(Icons.web, 'VAC\nSearch',
                  const Color(0xCC880E4F), onVACSearch ?? () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _verticalTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
            Icon(icon, size: 32, color: Colors.white),
            const Spacer(),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.white,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _horizontalTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_radius),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: Row(
          children: [
            Icon(icon, size: 26, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallTile(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return StaggeredGridTile.count(
      crossAxisCellCount: 2,
      mainAxisCellCount: 1.2,
      child: InkWell(
        onTap: onTap,
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
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}