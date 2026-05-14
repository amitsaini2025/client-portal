import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

class LoginRequiredDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onCancel;
  final BuildContext parentContext;

  const LoginRequiredDialog({
    super.key,
    this.title = "Login Required",
    this.message = "Please login to continue.",
    this.onCancel,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.lock_outline,
            color: ThemeConfig.goldenYellow,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ThemeConfig.navyBlue,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(
          color: ThemeConfig.navyBlue.withValues(alpha: 0.8),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: ThemeConfig.goldenYellow),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.of(parentContext).pop();
            onCancel?.call();
          },
          child: Text(
            "Cancel",
            style: TextStyle(color: ThemeConfig.navyBlue),
          ),
        ),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeConfig.goldenYellow,
            foregroundColor: ThemeConfig.navyBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.of(parentContext).pop();
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
                  (route) => false,
            );
          },
          child: const Text("Login"),
        ),
      ],
    );
  }
}
