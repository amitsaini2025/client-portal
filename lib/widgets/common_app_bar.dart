import 'package:flutter/material.dart';

import '../config/theme_config.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'dialog/login_required_dialog.dart';

class CommonAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String titleName;

  const CommonAppBar({super.key, required this.titleName});

  @override
  State<CommonAppBar> createState() => _CommonAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}

class _CommonAppBarState extends State<CommonAppBar> {
  int _unreadNotificationCount = 0;
  bool _isLoadingNotificationCount = false;

  @override
  void initState() {
    super.initState();
    _loadUnreadNotificationCount();
  }

  Future<void> _loadUnreadNotificationCount() async {
    if (!AuthService.isAuthenticated) return;

    setState(() => _isLoadingNotificationCount = true);

    try {
      final response = await ApiService.getUnreadNotificationCount();

      if (response['success'] == true) {
        final count = response['data']?['unread_count'] ?? 0;
        if (mounted) {
          setState(() {
            _unreadNotificationCount = count;
          });
        }
      }
    } catch (e) {
      debugPrint("Unread count error: $e");
    }

    if (mounted) setState(() => _isLoadingNotificationCount = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ThemeConfig.goldenYellow,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.titleName,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            AuthService.selectedMatterName ?? 'No Matter Selected',
            style: const TextStyle(fontSize: 13, color: Colors.white),
          ),
          Text(
            "ID: ${AuthService.selectedMatterId ?? ''}",
            style: const TextStyle(fontSize: 11, color: Colors.white),
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
              ),
              onPressed: () async {
                if (AuthService.isAuthenticated) {
                  await Navigator.pushNamed(context, '/notifications');
                  _loadUnreadNotificationCount(); // refresh after returning
                } else {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => LoginRequiredDialog(parentContext: context),
                  );
                }
              },
            ),
            if (_unreadNotificationCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    _unreadNotificationCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
