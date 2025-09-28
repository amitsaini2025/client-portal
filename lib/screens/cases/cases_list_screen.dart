import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/config/theme_config.dart';
import '../../models/new/case.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

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
        final data = result['data'];

        final List<dynamic> caseList = data['cases'] ?? data;
        final fetchedCases =
        caseList.map((json) => Case.fromJson(json)).toList();

        setState(() {
          if (page == 1) {
            cases = fetchedCases;
          } else {
            cases.addAll(fetchedCases);
          }

          currentPage = page;
          hasMore = fetchedCases.length == perPage;
          isLoading = false;
          isFetchingMore = false;
        });
      } else {
        setState(() {
          error = result['message'] ?? 'Failed to fetch cases';
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
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
                  onPressed: () {
                    // TODO: Navigate to case creation screen
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Case'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConfig.goldenYellow,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Case statistics
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ThemeConfig.navyBlue.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ThemeConfig.goldenYellow.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  _buildStatCard(
                    'Total Cases',
                    cases.length.toString(),
                    Icons.folder,
                  ),
                  const SizedBox(width: 24),
                  _buildStatCard(
                    'Active Cases',
                    cases.where((c) => c.status != 'completed').length.toString(),
                    Icons.work,
                  ),
                  const SizedBox(width: 24),
                  _buildStatCard(
                    'Pending Documents',
                    cases
                        .where((c) => c.status == 'pending_documents')
                        .length
                        .toString(),
                    Icons.pending,
                  ),
                  const SizedBox(width: 24),
                  _buildStatCard(
                    'Completed',
                    cases.where((c) => c.status == 'completed').length.toString(),
                    Icons.check_circle,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // States
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: ThemeConfig.goldenYellow,
                  ),
                ),
              )
            else if (error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $error',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _fetchCases(page: 1),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeConfig.goldenYellow,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (cases.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.folder_open,
                            size: 64, color: Colors.white54),
                        SizedBox(height: 16),
                        Text(
                          'No cases found',
                          style:
                          TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your cases will appear here once they are created',
                          style:
                          TextStyle(fontSize: 14, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    color: ThemeConfig.goldenYellow,
                    onRefresh: () => _fetchCases(page: 1),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: cases.length + (isFetchingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < cases.length) {
                          final caseItem = cases[index];
                          return _buildCaseCard(caseItem);
                        } else {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: ThemeConfig.goldenYellow,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseCard(Case caseItem) {
    return Card(
      color: ThemeConfig.navyBlue.withOpacity(0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: ThemeConfig.goldenYellow.withOpacity(0.4)),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to case detail screen
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + chips
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          caseItem.title,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          caseItem.stageName ?? 'No description available',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: ThemeConfig.goldenYellow,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(caseItem.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getStatusText(caseItem.status),
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(caseItem.status),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                ],
              ),

              const SizedBox(height: 16),

              // Details row
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ...caseItem.agentsMap.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildDetailItem(
                        Icons.person,
                        '${entry.key}: ${entry.value.name}',
                        ThemeConfig.goldenYellow,
                      ),
                    );
                  }),
                ],
              ),

              const SizedBox(height: 16),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Navigate to case timeline
                    },
                    icon: const Icon(Icons.timeline, size: 18),
                    label: const Text('Timeline'),
                    style: TextButton.styleFrom(
                      foregroundColor: ThemeConfig.goldenYellow,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to case detail
                    },
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('View Details'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConfig.goldenYellow,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeConfig.navyBlue.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ThemeConfig.goldenYellow.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: ThemeConfig.goldenYellow),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: ThemeConfig.goldenYellow,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.inter(fontSize: 13, color: color),
        ),
      ],
    );
  }
}
