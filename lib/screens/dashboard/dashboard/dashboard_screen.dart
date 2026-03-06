import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUser();
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
            IconButton(
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
                    builder: (_) => const LoginRequiredDialog(),
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
                    builder: (_) => const LoginRequiredDialog(),
                  );
                }
              },
            ),
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
          child: TabBar(
            indicator: BoxDecoration(
              color: Color(0xFFF9B000),
              borderRadius: BorderRadius.circular(50),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black87,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            tabs: const [
              Tab(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Icon(Icons.home_outlined, size: 22),
                ),
                text: "Home",
              ),
              Tab(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Icon(Icons.folder_outlined, size: 22),
                ),
                text: "Files",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
