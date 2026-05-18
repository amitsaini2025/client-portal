import 'package:client/screens/dashboard/health_insurance/student_visa_oshc_screen/student_visa_oshcs_screen.dart';
import 'package:client/screens/dashboard/health_insurance/temporary_graduate_health_insurance/temporary_graduate_ovhc_screen.dart';
import 'package:client/screens/dashboard/health_insurance/tourist_visa_ovhcs_screen/tourist_visa_ovhcs_screen.dart';
import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/common_app_bar.dart';

class HealthInsuranceScreen extends StatelessWidget {
  const HealthInsuranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        backgroundColor: ThemeConfig.goldenYellow,
        title: const Text(
          "Health Insurance",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),*/
      appBar: CommonAppBar(
        titleName: 'Health Insurance',
        matterID: AuthService.selectedMatterId,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppResponsive.maxContentWidth),
          child: Padding(
        padding: AppResponsive.pagePadding(context),
        child: GridView.count(
          crossAxisCount: AppResponsive.gridColumns(context, mobile: 2, tablet: 3, desktop: 4),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.2,
          children: [
            _tile(
              context,
              label: 'Student Visa (OSHC)',
              icon: Icons.school,
              color: Colors.green,
              screen: const StudentVisaOSHCScreen(),
            ),
            _tile(
              context,
              label: 'Tourist Visa (OVHC)',
              icon: Icons.airplanemode_active,
              color: Colors.orange,
              screen: const TouristVisaOVHCScreen(),
            ),
            _tile(
              context,
              label: 'Temporary Graduate (OVHC)',
              icon: Icons.person,
              color: Colors.blue,
              screen: const TemporaryGraduateOVHCScreen(),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }

  Widget _tile(BuildContext context,
      {required String label,
        required IconData icon,
        required Color color,
        required Widget screen}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha:0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
