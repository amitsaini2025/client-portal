import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../config/theme_config.dart';
import '../../../fcm_service.dart';
import '../../../models/blog.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../utils/app_loader.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/common/error_widget.dart';
import '../../../widgets/dashboard/quick_actions_card.dart';
import '../../../widgets/dialog/login_signup_dialog.dart';
import '../book_appointment/book_location_screen.dart';

class DashboardTabScreen extends StatefulWidget {
  final String? matterId;

  const DashboardTabScreen({super.key, required this.matterId});

  @override
  State<DashboardTabScreen> createState() => _DashboardTabScreenState();
}

class _DashboardTabScreenState extends State<DashboardTabScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  List<Blog> _blogs = [];
  bool _isLoadingBlogs = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _loadRecentBlogs();
    if (!kIsWeb && defaultTargetPlatform != TargetPlatform.windows) {
      _setupNotifications();
    }
  }

  Future<void> _setupNotifications() async {
    final fcmService = FCMService();

    fcmService.setupMessageListeners(
      onForegroundMessage: (RemoteMessage message) {
        if (!mounted) return;
        debugPrint('Got a message whilst in the foreground!');
        if (message.notification != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message.notification!.body ?? 'New notification'),
              backgroundColor: Color(0xFF5E8B7E),
              duration: Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      },
      onBackgroundMessageTap: (RemoteMessage message) {
        debugPrint(
          'Notification tapped while app in background: ${message.messageId}',
        );
      },
    );

    String? token = await fcmService.getToken();
    if (token != null) {
      await ApiService.registerFCMToken(token);
    }
  }

  Future<void> _loadRecentBlogs() async {
    setState(() => _isLoadingBlogs = true);

    try {
      final response = await ApiService.getFeaturedBlogs(page: 1, perPage: 5);
      if (response['success'] == true) {
        final List list = response['data'];
        _blogs = list.map((e) => Blog.fromJson(e)).toList();
      }
    } catch (_) {}

    setState(() => _isLoadingBlogs = false);
  }

  Future<void> _loadDashboardData() async {
    if (widget.matterId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.getDashboard(
        selMatterId: widget.matterId!,
      );

      if (result['success'] == true) {
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result['message'] ?? 'Failed to load dashboard';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child:
            _isLoading
                ? const AppLoader()
                : _errorMessage != null
                ? CustomErrorWidget(
                  message: _errorMessage!,
                  onRetry: _loadDashboardData,
                )
                : RefreshIndicator(
                  onRefresh: () async {
                    await Future.wait([
                      _loadDashboardData(),
                      _loadRecentBlogs(),
                    ]);
                  },
                  child: SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppResponsive.maxContentWidth,
                        ),
                        child: Container(
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildRecentUpdatesSection(),
                              const SizedBox(height: 24),
                              Padding(
                                padding: AppResponsive.pagePadding(context),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    QuickActionsCard(
                                      onBookAppointment: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const BookLocationScreen(),
                                          ),
                                        );
                                      },
                                      onHealthInsurance: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/health-insurance',
                                        );
                                      },
                                      onUpcomingDeadlines: () {
                                        Navigator.pushNamed(context, '/tasks');
                                      },
                                      onPRCalculator: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/pr-calculator',
                                        );
                                      },
                                      onStudentFundCalculator: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/student-fund-calculator',
                                        );
                                      },
                                      onOccupationSearch: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/occupation-search',
                                        );
                                      },
                                      onPostCodeChecker: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/post-code-checker',
                                        );
                                      },
                                      onImportantLinks:
                                          () => {
                                            Navigator.pushNamed(
                                              context,
                                              '/important-links',
                                            ),
                                          },
                                      onEnglishRequirement:
                                          () => {
                                            Navigator.pushNamed(
                                              context,
                                              '/english-requirements',
                                            ),
                                          },
                                      onVACSearch:
                                          () => {
                                            Navigator.pushNamed(
                                              context,
                                              '/vac-search',
                                            ),
                                          },
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/claude-chat-bot');
        },
        backgroundColor: ThemeConfig.goldenYellow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 6,
        tooltip: 'Claude AI Assistant',
        child: const Icon(Icons.chat, size: 28, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildRecentUpdatesSection() {
    final double blogCardWidth = AppResponsive.value<double>(
      context,
      mobile: 260,
      tablet: 300,
      desktop: 340,
    );
    final double blogSectionHeight = AppResponsive.value<double>(
      context,
      mobile: 140,
      tablet: 165,
      desktop: 220,
    );

    final isDesktop = AppResponsive.isDesktop(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppResponsive.horizontalPadding(
            context,
          ).copyWith(top: isDesktop ? 24 : 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Recent updates",
                    style: TextStyle(
                      fontSize: isDesktop ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (isDesktop) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 28,
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9B000),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ],
              ),
              const Spacer(),
              TextButton(
                onPressed:
                    () => {
                      if (AuthService.isAuthenticated)
                        Navigator.pushNamed(context, '/blogs')
                      else
                        {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            barrierColor: Colors.black.withValues(alpha: 0.4),
                            builder: (context) {
                              return BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                                child: LoginSignupDialog(
                                  parentContext: context,
                                  onCancel: () {},
                                ),
                              );
                            },
                          ),
                        },
                    },
                child: const Text("View all"),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: blogSectionHeight,
          child:
              _isLoadingBlogs
                  ? const Center(child: AppLoader())
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _blogs.length,
                    padding: AppResponsive.horizontalPadding(context),
                    itemBuilder: (context, index) {
                      final blog = _blogs[index];

                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          if (AuthService.isAuthenticated) {
                            Navigator.pushNamed(
                              context,
                              '/blogs/detail',
                              arguments: {'blogId': blog.id},
                            );
                          } else {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              barrierColor: Colors.black.withValues(alpha: 0.4),
                              builder: (context) {
                                return BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 6,
                                    sigmaY: 6,
                                  ),
                                  child: LoginSignupDialog(
                                    parentContext: context,
                                    onCancel: () {},
                                  ),
                                );
                              },
                            );
                          }
                        },
                        child: Container(
                          width: blogCardWidth,
                          margin: EdgeInsets.only(
                            right: index == _blogs.length - 1 ? 0 : 16,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            image: DecorationImage(
                              image: NetworkImage(blog.image),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.2),
                                    Colors.black.withValues(alpha: 0.7),
                                  ],
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    blog.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    blog.date,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
