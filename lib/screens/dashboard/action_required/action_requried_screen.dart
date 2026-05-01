import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme_config.dart';
import '../../../utils/responsive_utils.dart';
import '../../../models/action_required.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../workflow/message/workflow_messages_screen.dart';
import '../../workflow/workflow_stages_screen.dart';
import '../billing_list/billing_list_screen.dart';
import '../notification/notification_detail_screen.dart';
import '../personal_info/personal_information_screen.dart';

class ActionRequiredScreen extends StatefulWidget {
  const ActionRequiredScreen({super.key});

  @override
  State<ActionRequiredScreen> createState() => _ActionRequiredScreenState();
}

class _ActionRequiredScreenState extends State<ActionRequiredScreen> {
  List<ActionRequiredModel> _items = [];

  bool _isLoading = true;
  bool _isFetchingMore = false;

  int _currentPage = 1;
  int _lastPage = 1;

  final int _limit = 20;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchActionRequired(page: 1);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isFetchingMore &&
        _currentPage < _lastPage) {
      _fetchActionRequired(page: _currentPage + 1);
    }
  }

  Future<void> _fetchActionRequired({required int page}) async {
    try {
      if (page == 1) {
        setState(() => _isLoading = true);
      } else {
        setState(() => _isFetchingMore = true);
      }

      final data = await ApiService.getActionRequiredList(
        page: page,
        limit: _limit,
      );

      debugPrint("🔥 API RESPONSE: $data");

      if (!mounted) return;

      final innerData = data['data'] ?? {};

      List<dynamic> list = [];

      if (innerData['action_required'] != null) {
        list = innerData['action_required'];
      }
      else if (innerData['latest_unread'] != null) {
        list = [innerData['latest_unread']];
      }

      final pagination = innerData['pagination'] ?? {};

      final parsed = list.map((e) => ActionRequiredModel.fromJson(e)).toList();

      setState(() {
        if (page == 1) {
          _items = parsed;
        } else {
          _items.addAll(parsed);
        }

        _currentPage = pagination['current_page'] ?? 1;
        _lastPage = pagination['last_page'] ?? 1;

        _isLoading = false;
        _isFetchingMore = false;
      });
    } catch (e) {
      debugPrint("❌ ERROR: $e");

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isFetchingMore = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _fetchActionRequired(page: 1);
  }

  Future<void> _handleItemTap(
    BuildContext context,
    ActionRequiredModel item,
  ) async {
    final Map<String, dynamic> matters = await ApiService.getMatters();
    final int matterId = item.clientMatterId;
    String? matterName;
    if (matters["data"]["matters"] != null) {
      for (var m in matters["data"]["matters"]) {
        if (m["matter_id"] == matterId) {
          matterName = m["matter_name"] ?? "";
          break;
        }
      }
    }
    matterName ??= "Unknown";

    await AuthService.selectMatter(matterId: matterId, matterName: matterName);

    Widget? screen;

    final type = item.notificationType.trim();
    final url = item.url.trim();

    switch (type) {
      case "message":
        screen = WorkflowMessagesScreen(matterID: matterId);
        break;

      case "stage_change":
      case "matter_discontinued":
      case "matter_reopened":
      case "checklist":
      case "checklist_added":
      case "document_approved":
      case "document_rejected":
      case "document_deleted":
      case "document_downloaded":
        screen = WorkflowStagesScreen(matterID: matterId);
        break;

      case "detail_approved":
      case "detail_rejected":
        screen = PersonalInformationScreen();
        break;

      case "invoice_sent_to_client_app":
        screen = BillingListScreen(matterID: matterId);
        break;

      case "action_completed":
        screen = WorkflowStagesScreen(matterID: matterId);
        break;

      default:
        screen = WorkflowStagesScreen(matterID: matterId);
        break;
    }

    if (!mounted) return;

    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));
  }

  String _formatDate(DateTime dt) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(dt);
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'checklist_upload':
        return Icons.checklist;
      case 'document':
        return Icons.description;
      case 'message':
        return Icons.chat;
      default:
        return Icons.notifications;
    }
  }

  String _getTypeLabel(String type) {
    return type.replaceAll('_', ' ').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Action Required"),
        backgroundColor: ThemeConfig.goldenYellow,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppResponsive.maxContentWidth),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
              ? const Center(child: Text("No action required"))
              : RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: AppResponsive.pagePadding(context),
                  itemCount: _items.length + (_isFetchingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _items.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final item = _items[index];

                    return InkWell(
                      onTap: () => _handleItemTap(context, item),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                item.isRead
                                    ? Colors.grey.shade200
                                    : ThemeConfig.goldenYellow.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getTypeIcon(item.type),
                              color: ThemeConfig.goldenYellow,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getTypeLabel(item.type),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: ThemeConfig.goldenYellow,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.message,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "${item.senderName} • ${_formatDate(item.createdAt)}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!item.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: ThemeConfig.goldenYellow,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
        ),
      ),
    );
  }
}
