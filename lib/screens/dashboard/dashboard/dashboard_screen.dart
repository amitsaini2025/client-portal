import 'package:flutter/material.dart';

import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/stripe_service.dart';
import '../../../widgets/dialog/login_required_dialog.dart';
import 'dashboard_tab_screen.dart';
import 'myfiles_tab_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String? matterId;

  const DashboardScreen({super.key, required this.matterId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isLoadingUser = true;
  String? userName;
  bool isAuthenticated = false;

  int _unreadNotificationCount = 0;
  bool _isLoadingNotificationCount = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadUnreadNotificationCount();
  }

  Future<void> _loadUser() async {
    isAuthenticated = AuthService.isAuthenticated;

    if (isAuthenticated) {
      final name = await AuthManager.getUserName();
      setState(() {
        userName = name;
        isLoadingUser = false;
      });
    } else {
      setState(() {
        isLoadingUser = false;
      });
    }
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,

        appBar: AppBar(
          backgroundColor: const Color(0xFFF9B000),
          foregroundColor: Colors.black,
          elevation: 0,

          title:
              isLoadingUser
                  ? null
                  : Text(
                    isAuthenticated && userName != null && userName!.isNotEmpty
                        ? "Welcome, $userName"
                        : "Welcome, Guest",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
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
                      _loadUnreadNotificationCount(); // refresh after return
                    } else {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder:
                            (_) => LoginRequiredDialog(parentContext: context),
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
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.white),
              onPressed: () {
                if (AuthService.isAuthenticated) {
                  Navigator.pushNamed(context, '/profile');
                } else {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => LoginRequiredDialog(parentContext: context),
                  );
                }
              },
            ),

            /*IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                if (isAuthenticated) {
                  Navigator.pushNamed(context, '/notifications');
                } else {
                  showDialog(
                    context: context,
                    builder: (_) => LoginRequiredDialog(parentContext: context),
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.white),
              onPressed: () {
                if (isAuthenticated) {
                  Navigator.pushNamed(context, '/profile');
                } else {
                  showDialog(
                    context: context,
                    builder: (_) => LoginRequiredDialog(parentContext: context),
                  );
                }
              },
            ),*/
          ],
        ),

        body: TabBarView(
          children: [
            DashboardTabScreen(matterId: widget.matterId),
            const MyFilesTabScreen(),
          ],
        ),
        bottomNavigationBar: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          decoration: const BoxDecoration(
            color: Color(0xFFF2F2F2),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: const Color(0xFFF9B000),
                  borderRadius: BorderRadius.circular(30),
                ),
                indicatorPadding: const EdgeInsets.all(4),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black87,
                splashFactory: NoSplash.splashFactory,
                overlayColor: const MaterialStatePropertyAll(
                  Colors.transparent,
                ),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home_outlined, size: 20),
                        SizedBox(width: 6),
                        Text("Home"),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_outlined, size: 20),
                        SizedBox(width: 6),
                        Text("Files"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
