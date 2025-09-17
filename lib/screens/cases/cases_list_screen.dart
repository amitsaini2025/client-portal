import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/case.dart';
import '../../services/api_service.dart';

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
        return const Color(0xFF5E8B7E);
      case 'in_progress':
        return const Color(0xFFF39C12);
      case 'pending_documents':
        return const Color(0xFFE74C3C);
      case 'under_review':
        return const Color(0xFF3498DB);
      case 'approved':
        return const Color(0xFF27AE60);
      default:
        return const Color(0xFFB0B7C3);
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFE74C3C);
      case 'medium':
        return const Color(0xFFF39C12);
      case 'low':
        return const Color(0xFF27AE60);
      default:
        return const Color(0xFFB0B7C3);
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
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to case creation screen
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Case'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E8B7E),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE3E8EF)),
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
                child: Center(child: CircularProgressIndicator()),
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
                      Text('Error: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _fetchCases(page: 1),
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
                            size: 64, color: Color(0xFFB0B7C3)),
                        SizedBox(height: 16),
                        Text(
                          'No cases found',
                          style:
                          TextStyle(fontSize: 18, color: Color(0xFF5E8B7E)),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your cases will appear here once they are created',
                          style:
                          TextStyle(fontSize: 14, color: Color(0xFFB0B7C3)),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
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
                            child: Center(child: CircularProgressIndicator()),
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
                            color: const Color(0xFF30475E),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          caseItem.description ?? 'No description available',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF5E8B7E),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(caseItem.status)
                              .withValues(alpha: 0.12),
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
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(caseItem.priority ?? 'low')
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          (caseItem.priority ?? 'low').toUpperCase(),
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: _getPriorityColor(caseItem.priority ?? 'low'),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
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
                          color: const Color(0xFF30475E),
                        ),
                      ),
                      Text(
                        '${_calculateProgress(caseItem)}%',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF5E8B7E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _calculateProgress(caseItem) / 100,
                    backgroundColor: const Color(0xFFE3E8EF),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF5E8B7E),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Details row
              Row(
                children: [
                  _buildDetailItem(
                    Icons.person,
                    'Agent: ${caseItem.agentId ?? 'Unassigned'}',
                    const Color(0xFF5E8B7E),
                  ),
                  const SizedBox(width: 24),
                  _buildDetailItem(
                    Icons.category,
                    caseItem.caseType ?? 'Unknown',
                    const Color(0xFF30475E),
                  ),
                  const SizedBox(width: 24),
                  if (caseItem.estimatedCompletion != null)
                    _buildDetailItem(
                      Icons.schedule,
                      'Due: ${_formatDate(caseItem.estimatedCompletion!)}',
                      const Color(0xFFF39C12),
                    ),
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
                      foregroundColor: const Color(0xFF5E8B7E),
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
                      backgroundColor: const Color(0xFF5E8B7E),
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
          color: const Color(0xFFF0F4F8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: const Color(0xFF5E8B7E)),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF30475E),
              ),
            ),
            Text(
              title,
              style: GoogleFonts.inter(fontSize: 12, color: Color(0xFF5E8B7E)),
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
        Text(text, style: GoogleFonts.inter(fontSize: 13, color: color)),
      ],
    );
  }

  int _calculateProgress(Case caseItem) {
    switch (caseItem.status.toLowerCase()) {
      case 'completed':
        return 100;
      case 'in_progress':
        return 65;
      case 'pending_documents':
        return 25;
      case 'under_review':
        return 50;
      case 'approved':
        return 90;
      default:
        return 0;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays < 0) {
      return '${difference.inDays.abs()} days ago';
    } else {
      return '${difference.inDays} days';
    }
  }
}
