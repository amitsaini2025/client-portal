import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../services/auth_service.dart';
import '../dialog/login_signup_dialog.dart';

class QuickActionsCard extends StatelessWidget {
  final VoidCallback onBookAppointment;
  final VoidCallback? onHealthInsurance;
  final VoidCallback? onUpcomingDeadlines;
  final VoidCallback? onPRCalculator;
  final VoidCallback? onStudentFundCalculator;
  final VoidCallback? onOccupationSearch;
  final VoidCallback? onPostCodeChecker;
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
    this.onImportantLinks,
    this.onEnglishRequirement,
    this.onVACSearch,
  });

  static const double _radius = 16;

  void _handleTap(BuildContext context, VoidCallback callback) {
    if (AuthService.isAuthenticated) {
      callback();
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha:0.4),
        builder: (context) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: LoginSignupDialog(parentContext: context),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = constraints.maxWidth > 600; // detect web/large screen
        final crossAxisCount = isWeb ? 6 : 4;
        final tilePadding = isWeb ? 12.0 : 20.0;
        final iconSize = isWeb ? 26.0 : 32.0;
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
                'Quick Actions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 20),

              StaggeredGrid.count(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  StaggeredGridTile.count(
                    crossAxisCellCount: isWeb ? 2 : 2,
                    mainAxisCellCount: isWeb ? 1.5 : 2.2,
                    child: _verticalTile(
                      context: context,
                      icon: Icons.schedule,
                      label: 'Book\nAppointment',
                      color: const Color(0xCC1B5E20),
                      onTap: onBookAppointment,
                      iconSize: iconSize,
                      fontSize: fontSize,
                      padding: tilePadding,
                    ),
                  ),

                  StaggeredGridTile.count(
                    crossAxisCellCount: isWeb ? 2 : 2,
                    mainAxisCellCount: isWeb ? 1.5 : 2.2,
                    child: _verticalTile(
                      context: context,
                      icon: Icons.health_and_safety,
                      label: 'Health\nInsurance',
                      color: const Color(0xCC4E342E),
                      onTap: onHealthInsurance ?? () {},
                      iconSize: iconSize,
                      fontSize: fontSize,
                      padding: tilePadding,
                    ),
                  ),

                  StaggeredGridTile.count(
                    crossAxisCellCount: isWeb ? 4 : 4,
                    mainAxisCellCount: isWeb ? 1.0 : 1.3,
                    child: _horizontalTile(
                      context: context,
                      icon: Icons.calculate,
                      label: 'PR\nCalculator',
                      color: const Color(0xCCB71C1C),
                      onTap: onPRCalculator ?? () {},
                      iconSize: iconSize - 2,
                      fontSize: fontSize,
                      padding: tilePadding - 2,
                    ),
                  ),

                  _smallTile(
                    Icons.calculate,
                    'Student\nFund Calculator',
                    const Color(0xCC4A148C),
                    onStudentFundCalculator ?? () {},
                    context: context,
                    iconSize: iconSize - 6,
                    fontSize: fontSize - 1,
                    padding: tilePadding - 4,
                  ),

                  _smallTile(
                    Icons.search,
                    'Occupation\nSearch',
                    const Color(0xCC0D47A1),
                    onOccupationSearch ?? () {},
                    context: context,
                    iconSize: iconSize - 6,
                    fontSize: fontSize - 1,
                    padding: tilePadding - 4,
                  ),

                  _smallTile(
                    Icons.code,
                    'Post\nCode Checker',
                    const Color(0xCC880E4F),
                    onPostCodeChecker ?? () {},
                    context: context,
                    iconSize: iconSize - 6,
                    fontSize: fontSize - 1,
                    padding: tilePadding - 4,
                  ),

                  _smallTile(
                    Icons.link,
                    'Important\nLinks',
                    const Color(0xCC004D40),
                    onImportantLinks ?? () {},
                    context: context,
                    iconSize: iconSize - 6,
                    fontSize: fontSize - 1,
                    padding: tilePadding - 4,
                  ),

                  _smallTile(
                    Icons.language,
                    'English\nRequirement',
                    const Color(0xCC1A237E),
                    onEnglishRequirement ?? () {},
                    context: context,
                    iconSize: iconSize - 6,
                    fontSize: fontSize - 1,
                    padding: tilePadding - 4,
                  ),

                  _smallTile(
                    Icons.web,
                    'VAC\nSearch',
                    const Color(0xCC880E4F),
                    onVACSearch ?? () {},
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

  Widget _verticalTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required double iconSize,
    required double fontSize,
    required double padding,
  }) {
    return InkWell(
      onTap: () => _handleTap(context, onTap),
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
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
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
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required double iconSize,
    required double fontSize,
    required double padding,
  }) {
    return InkWell(
      onTap: () => _handleTap(context, onTap),
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
                  fontWeight: FontWeight.w600,
                  fontSize: fontSize,
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
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap, {
    required BuildContext context,
    required double iconSize,
    required double fontSize,
    required double padding,
  }) {
    return StaggeredGridTile.count(
      crossAxisCellCount: 2,
      mainAxisCellCount: 1.2,
      child: InkWell(
        onTap: () => _handleTap(context, onTap),
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
                    fontWeight: FontWeight.w500,
                    fontSize: fontSize,
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
