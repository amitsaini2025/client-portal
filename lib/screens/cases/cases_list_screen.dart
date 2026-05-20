import 'package:client/config/theme_config.dart';
import 'package:client/utils/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/new/case.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/responsive_utils.dart';

class CasesListScreen extends StatefulWidget {
  const CasesListScreen({super.key});

  @override
  State<CasesListScreen> createState() => _CasesListScreenState();
}

class _CasesListScreenState extends State<CasesListScreen> {
  List<Case> cases = [];
  bool isLoading = true;
  String? error;

  int currentPage = 1;
  final int perPage = 10;
  bool hasMore = true;
  bool isFetchingMore = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchCases(page: 1);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isFetchingMore &&
          hasMore) {
        _fetchMoreCases();
      }
    });
  }

  Future<void> _fetchCases({int page = 1}) async {
    try {
      if (page == 1) {
        setState(() {
          isLoading = true;
          error = null;
          cases.clear();
        });
      }

      final result = await ApiService.getClientCases(
        page: page,
        perPage: perPage,
        selMatterId: AuthService.selectedMatterId!.toString(),
      );

      if (result['success'] == true) {
        final List<dynamic> caseList =
            result['data']['cases'] ?? result['data'];
        final fetched = caseList.map((e) => Case.fromJson(e)).toList();

        setState(() {
          if (page == 1) {
            cases = fetched;
          } else {
            cases.addAll(fetched);
          }

          currentPage = page;
          hasMore = fetched.length == perPage;
          isLoading = false;
          isFetchingMore = false;
        });
      } else {
        setState(() {
          error = result['message'];
          isLoading = false;
          isFetchingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
        isFetchingMore = false;
      });
    }
  }

  Future<void> _fetchMoreCases() async {
    setState(() => isFetchingMore = true);
    await _fetchCases(page: currentPage + 1);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.greenAccent;
      case 'in_progress':
        return Colors.orangeAccent;
      case 'pending_documents':
        return Colors.redAccent;
      case 'under_review':
        return Colors.blueAccent;
      case 'approved':
        return Colors.lightGreen;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'in_progress':
        return 'In Progress';
      case 'pending_documents':
        return 'Pending Documents';
      case 'under_review':
        return 'Under Review';
      case 'approved':
        return 'Approved';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.navyBlue,
      appBar: AppBar(
        title: const Text("My Cases"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: ThemeConfig.goldenYellow,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppResponsive.maxContentWidth,
            ),
            child: RefreshIndicator(
              color: ThemeConfig.goldenYellow,
              onRefresh: () => _fetchCases(page: 1),
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppResponsive.pagePadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),
                    const SizedBox(height: 16),
                    _statsCard(),
                    const SizedBox(height: 24),

                    if (isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: AppLoader(),
                        ),
                      )
                    else if (error != null)
                      _errorView()
                    else if (cases.isEmpty)
                      _emptyView()
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final cols = AppResponsive.gridColumns(
                            context,
                            mobile: 1,
                            tablet: 2,
                            desktop: 3,
                          );
                          if (cols == 1) {
                            return Column(
                              children: [
                                for (final item in cases) _buildCaseCard(item),
                                if (isFetchingMore)
                                  const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: AppLoader(),
                                  ),
                              ],
                            );
                          }
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cols,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.6,
                                ),
                            itemCount: cases.length,
                            itemBuilder:
                                (context, index) =>
                                    _buildCaseCard(cases[index]),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'My Cases',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 18),
          label: const Text('New Case'),
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeConfig.goldenYellow,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeConfig.navyBlue.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeConfig.goldenYellow.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          _buildStatCard('Total Cases', cases.length.toString(), Icons.folder),
          const SizedBox(height: 12),
          _buildStatCard(
            'Active Cases',
            cases.where((c) => c.status != 'completed').length.toString(),
            Icons.work,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            'Pending Documents',
            cases
                .where((c) => c.status == 'pending_documents')
                .length
                .toString(),
            Icons.pending,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            'Completed',
            cases.where((c) => c.status == 'completed').length.toString(),
            Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildCaseCard(Case caseItem) {
    return Card(
      color: ThemeConfig.navyBlue.withValues(alpha: 0.8),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: ThemeConfig.goldenYellow.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TITLE + STATUS
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        caseItem.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        caseItem.stageName ?? 'No description available',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: ThemeConfig.goldenYellow,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        caseItem.status,
                      ).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getStatusText(caseItem.status),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(caseItem.status),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// PROGRESS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  caseItem.progressDisplay ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ThemeConfig.goldenYellow,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (caseItem.progressPercentage ?? 0) / 100,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(
                ThemeConfig.goldenYellow,
              ),
            ),

            const SizedBox(height: 16),

            /// AGENTS
            ...caseItem.agentsMap.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildDetailItem(
                  Icons.person,
                  '${entry.key}: ${entry.value.name}',
                  ThemeConfig.goldenYellow,
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// ACTION BUTTONS
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 12,
              runSpacing: 8,
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.timeline, size: 18),
                  label: const Text('Timeline'),
                  style: TextButton.styleFrom(
                    foregroundColor: ThemeConfig.goldenYellow,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('View Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConfig.goldenYellow,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: ThemeConfig.navyBlue.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ThemeConfig.goldenYellow.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: ThemeConfig.goldenYellow),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: ThemeConfig.goldenYellow,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontSize: 13, color: color),
          ),
        ),
      ],
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _fetchCases(page: 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConfig.goldenYellow,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: const [
            Icon(Icons.folder_open, size: 64, color: Colors.white54),
            SizedBox(height: 16),
            Text(
              'No cases found',
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
            SizedBox(height: 8),
            Text(
              'Your cases will appear here once they are created',
              style: TextStyle(fontSize: 14, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
