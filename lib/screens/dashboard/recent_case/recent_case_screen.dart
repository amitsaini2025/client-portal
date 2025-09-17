import 'package:flutter/material.dart';

import '../../../models/case_item.dart';
import '../../../services/api_service.dart';

class RecentCasesScreen extends StatefulWidget {
  const RecentCasesScreen({Key? key}) : super(key: key);

  @override
  State<RecentCasesScreen> createState() => _RecentCasesScreenState();
}

class _RecentCasesScreenState extends State<RecentCasesScreen> {
  List<CaseItem> _cases = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasNextPage = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchCases();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!_isLoading && _hasNextPage) {
          _fetchCases();
        }
      }
    });
  }

  Future<void> _fetchCases() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.getClientCases(
        page: _currentPage,
        perPage: 10,
      );

      if (response['success'] == true) {
        final List<dynamic> list = response['data']['cases'];
        final newCases = list.map((e) => CaseItem.fromJson(e)).toList();

        final pagination = response['data']['pagination'];
        setState(() {
          _cases.addAll(newCases.cast<CaseItem>());
          _hasNextPage = pagination['has_next_page'] ?? false;
          _currentPage++;
        });
      }
    } catch (e) {
      debugPrint("Error fetching cases: $e");
    }

    setState(() => _isLoading = false);
  }

  Widget _buildCaseCard(CaseItem caseItem) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Text(
            caseItem.id.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        title: Text(
          caseItem.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(caseItem.caseNumber),
            Text("Status: ${caseItem.status}"),
            Text("Stage: ${caseItem.stageName}"),
            Text("Updated: ${caseItem.lastUpdated}"),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: navigate to details
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recent Cases"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body:
          _cases.isEmpty && _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _cases.clear();
                    _currentPage = 1;
                    _hasNextPage = true;
                  });
                  await _fetchCases();
                },
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _cases.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < _cases.length) {
                      return _buildCaseCard(_cases[index]);
                    } else {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                  },
                ),
              ),
    );
  }
}
