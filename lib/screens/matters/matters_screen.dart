import 'package:flutter/material.dart';

import '../../config/theme_config.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/app_loader.dart';
import '../../utils/app_logger.dart';
import '../../utils/responsive_utils.dart';

class MattersScreen extends StatefulWidget {
  final bool? isFromFiles;

  const MattersScreen({super.key, required this.isFromFiles});

  @override
  State<MattersScreen> createState() => _MattersScreenState();
}

class _MattersScreenState extends State<MattersScreen> {
  late Future<Map<String, dynamic>> _mattersFuture;

  @override
  void initState() {
    super.initState();
    _mattersFuture = ApiService.getMatters();
  }

  void _confirmSelection() {
    if (!AuthService.isMatterSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a matter'),
          backgroundColor: Colors.redAccent.shade400,
        ),
      );
      return;
    }

    if (widget.isFromFiles == true) {
      Navigator.pop(context);
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard',
            (route) => false,
        arguments: AuthService.selectedMatterId.toString(),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Matter confirmed!'),
        backgroundColor: ThemeConfig.navyBlue,
      ),
    );

    AppLogger.info('Selected Matter ID: ${AuthService.selectedMatterId}');
  }

  @override
  Widget build(BuildContext context) {
    final viewportHeight = MediaQuery.of(context).size.height -
        kToolbarHeight -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Matter',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: ThemeConfig.goldenYellow,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _confirmSelection,
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // ── KEY CHANGE ──────────────────────────────────────────────────────────
      // Same pattern as BlogListScreen: ListView owns its own scroll so we
      // do NOT wrap in SingleChildScrollView. Instead SafeArea is outermost,
      // loading/error/empty states get SizedBox(viewportHeight) to stay
      // centred, and Center + ConstrainedBox move inside the ListView so
      // each card is width-capped on large screens.
      // ────────────────────────────────────────────────────────────────────────
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _mattersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: viewportHeight,
                child: const Center(child: AppLoader()),
              );
            } else if (snapshot.hasError) {
              return SizedBox(
                height: viewportHeight,
                child: Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            } else if (!snapshot.hasData ||
                snapshot.data!['data'] == null ||
                snapshot.data!['data']['matters'].isEmpty) {
              return SizedBox(
                height: viewportHeight,
                child: Center(
                  child: Text(
                    'No matters found.',
                    style: TextStyle(color: ThemeConfig.navyBlue),
                  ),
                ),
              );
            } else {
              final List matters = snapshot.data!['data']['matters'];
              final selectedMatterId = AuthService.selectedMatterId;

              return ListView.builder(
                padding: AppResponsive.pagePadding(
                  context,
                ).copyWith(top: 12, bottom: 12),
                itemCount: matters.length,
                itemBuilder: (context, index) {
                  final matter = matters[index];
                  final matterId = matter['matter_id'];
                  final matterName = matter["matter_name"];
                  final isSelected = selectedMatterId == matterId;

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppResponsive.maxContentWidth,
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          await AuthService.selectMatter(
                            matterId: matterId,
                            matterName: matterName,
                          );
                          setState(() {});
                        },
                        child: Card(
                          elevation: isSelected ? 6 : 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: isSelected
                                ? BorderSide(
                              color: ThemeConfig.navyBlue,
                              width: 2,
                            )
                                : BorderSide.none,
                          ),
                          color: isSelected
                              ? ThemeConfig.goldenYellow.withValues(alpha: 0.3)
                              : Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            title: Text(
                              matter['matter_name'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: ThemeConfig.navyBlue,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                              Icons.check_circle,
                              color: ThemeConfig.navyBlue,
                            )
                                : Icon(
                              Icons.radio_button_unchecked,
                              color: ThemeConfig.navyBlue
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}