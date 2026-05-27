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
        barrierColor: Colors.black.withValues(alpha: 0.4),
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
        final isWeb = constraints.maxWidth > 600;
        final tilePadding = isWeb ? 14.0 : 16.0;
        final iconSize = isWeb ? 22.0 : 26.0;
        final fontSize = isWeb ? 12.5 : 13.5;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(_radius),
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
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              StaggeredGrid.count(
                crossAxisCount: isWeb ? 6 : 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  // --- Row 1: 3 tall tiles on web / 2 on mobile ---
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: isWeb ? 1.7 : 2.2,
                    child: _verticalTile(
                      context: context,
                      icon: Icons.event_available_rounded,
                      label: 'Book\nAppointment',
                      gradient: const [Color(0xFF2E7D32), Color(0xFF81C784)],
                      onTap: onBookAppointment,
                      iconSize: iconSize,
                      fontSize: fontSize,
                      padding: tilePadding,
                    ),
                  ),

                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: isWeb ? 1.7 : 2.2,
                    child: _verticalTile(
                      context: context,
                      icon: Icons.health_and_safety_rounded,
                      label: 'Health\nInsurance',
                      gradient: const [Color(0xFF6D4C41), Color(0xFFBCAAA4)],
                      onTap: onHealthInsurance ?? () {},
                      iconSize: iconSize,
                      fontSize: fontSize,
                      padding: tilePadding,
                    ),
                  ),

                  // PR Calculator: 3rd tall tile on web, full-width horizontal on mobile
                  StaggeredGridTile.count(
                    crossAxisCellCount: isWeb ? 2 : 4,
                    mainAxisCellCount: isWeb ? 1.7 : 1.1,
                    child: isWeb
                        ? _verticalTile(
                            context: context,
                            icon: Icons.calculate_rounded,
                            label: 'PR\nCalculator',
                            gradient: const [Color(0xFFC2185B), Color(0xFFF48FB1)],
                            onTap: onPRCalculator ?? () {},
                            iconSize: iconSize,
                            fontSize: fontSize,
                            padding: tilePadding,
                          )
                        : _horizontalTile(
                            context: context,
                            icon: Icons.calculate_rounded,
                            label: 'PR Calculator',
                            gradient: const [Color(0xFFC2185B), Color(0xFFF48FB1)],
                            onTap: onPRCalculator ?? () {},
                            iconSize: iconSize,
                            fontSize: fontSize,
                            padding: tilePadding,
                          ),
                  ),

                  // --- Small tiles: col2 each, 3-per-row on web, 2-per-row on mobile ---
                  _smallTile(
                    icon: Icons.school_rounded,
                    label: 'Student Fund\nCalculator',
                    gradient: const [Color(0xFF3949AB), Color(0xFF9FA8DA)],
                    onTap: onStudentFundCalculator ?? () {},
                    context: context,
                    iconSize: iconSize - 4,
                    fontSize: fontSize - 0.5,
                    padding: tilePadding - 2,
                  ),

                  _smallTile(
                    icon: Icons.manage_search_rounded,
                    label: 'Occupation\nSearch',
                    gradient: const [Color(0xFF00838F), Color(0xFF80DEEA)],
                    onTap: onOccupationSearch ?? () {},
                    context: context,
                    iconSize: iconSize - 4,
                    fontSize: fontSize - 0.5,
                    padding: tilePadding - 2,
                  ),

                  _smallTile(
                    icon: Icons.location_on_rounded,
                    label: 'Post Code\nChecker',
                    gradient: const [Color(0xFF7B1FA2), Color(0xFFCE93D8)],
                    onTap: onPostCodeChecker ?? () {},
                    context: context,
                    iconSize: iconSize - 4,
                    fontSize: fontSize - 0.5,
                    padding: tilePadding - 2,
                  ),

                  _smallTile(
                    icon: Icons.link_rounded,
                    label: 'Important\nLinks',
                    gradient: const [Color(0xFF1565C0), Color(0xFF90CAF9)],
                    onTap: onImportantLinks ?? () {},
                    context: context,
                    iconSize: iconSize - 4,
                    fontSize: fontSize - 0.5,
                    padding: tilePadding - 2,
                  ),

                  _smallTile(
                    icon: Icons.record_voice_over_rounded,
                    label: 'English\nRequirement',
                    gradient: const [Color(0xFFE64A19), Color(0xFFFFAB91)],
                    onTap: onEnglishRequirement ?? () {},
                    context: context,
                    iconSize: iconSize - 4,
                    fontSize: fontSize - 0.5,
                    padding: tilePadding - 2,
                  ),

                  _smallTile(
                    icon: Icons.travel_explore_rounded,
                    label: 'VAC\nSearch',
                    gradient: const [Color(0xFF00695C), Color(0xFF80CBC4)],
                    onTap: onVACSearch ?? () {},
                    context: context,
                    iconSize: iconSize - 4,
                    fontSize: fontSize - 0.5,
                    padding: tilePadding - 2,
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
    required List<Color> gradient,
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
    required List<Color> gradient,
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: iconSize, color: Colors.white),
            ),
            const SizedBox(width: 14),
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
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
    required double iconSize,
    required double fontSize,
    required double padding,
  }) {
    return StaggeredGridTile.count(
      crossAxisCellCount: 2,
      mainAxisCellCount: 1.25,
      child: InkWell(
        onTap: () => _handleTap(context, onTap),
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
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
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: fontSize,
                    color: Colors.white,
                    height: 1.2,
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
