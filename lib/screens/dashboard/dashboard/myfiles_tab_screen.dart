import 'dart:ui';

import 'package:client/services/auth_service.dart';
import 'package:flutter/material.dart';

import '../../../services/api_service.dart';
import '../../../widgets/dialog/login_required_dialog.dart';
import '../../workflow/workflow_stages_screen.dart';
import '../my_files/my_files_quick_action_card.dart';

class MyFilesTabScreen extends StatefulWidget {
  const MyFilesTabScreen({super.key});

  @override
  State<MyFilesTabScreen> createState() => _MyFilesTabScreenState();
}

class _MyFilesTabScreenState extends State<MyFilesTabScreen> {
  bool _isBlocked = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    try {
      final bool isLoggedIn = await AuthService.isAuthenticated;
      if (!isLoggedIn) {
        setState(() => _isLoading = false);

        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black.withOpacity(0.4),
          builder: (context) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: LoginRequiredDialog(
                parentContext: context,
                onCancel: () {
                  DefaultTabController.of(this.context).animateTo(0);
                },
              ),
            );
          },
        );

        return;
      }

      final int? cpStatus = AuthService.cpStatus;
      if (cpStatus == 1) {
        setState(() => _isLoading = false);
        return;
      }

      final result = await ApiService.checkUserAuthentication();

      if (result['success'] == true) {
        int status = result['data']['cp_status'];

        if (status == 1) {
          _showMatterSelect();
        } else if (status == 2) {
          setState(() {
            _isBlocked = true;
          });

          Future.delayed(Duration.zero, () {
            _showBlockedDialog();
          });
        }
      }
    } catch (e) {
      debugPrint("Error checking user status: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showBlockedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Access Restricted"),
            content: const Text(
              "Your account approval is pending. Please contact support.",
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  DefaultTabController.of(this.context).animateTo(0);
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMatterSelect() {
    if (!AuthService.isMatterSelected) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => AlertDialog(
              title: const Text("Select Matter"),
              content: const Text("Please select matter."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/matters');
                  },
                  child: const Text("Ok"),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return AbsorbPointer(
      absorbing: _isBlocked,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            MyFilesQuickActionsCard(
              onViewWorkflow: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const WorkflowStagesScreen(),
                  ),
                );
              },
              onBilling: () {
                Navigator.pushNamed(context, '/billing-list');
              },
              onDocumentStatus: () {
                Navigator.pushNamed(context, '/documents');
              },
              onUpcomingDeadlines: () {
                Navigator.pushNamed(context, '/tasks');
              },
              onRecentActivity: () {
                Navigator.pushNamed(context, '/recent-activity');
              },
              onMessage: () {
                Navigator.pushNamed(context, '/workflow-message');
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
