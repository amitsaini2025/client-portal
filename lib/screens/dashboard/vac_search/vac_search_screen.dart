import 'dart:async';

import 'package:client/screens/dashboard/vac_search/visa_estimate_screen.dart';
import 'package:flutter/material.dart';

import '../../../config/theme_config.dart';
import '../../../models/visa_search/visa_model.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/common_app_bar.dart';

class VacSearchScreen extends StatefulWidget {
  const VacSearchScreen({super.key});

  @override
  State<VacSearchScreen> createState() => _VacSearchScreenState();
}

class _VacSearchScreenState extends State<VacSearchScreen> {
  List<VisaModel> _visas = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;

  int _currentPage = 1;
  int _lastPage = 1;

  String _currentQuery = "";
  String _lastSearchedText = "";

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchVisas(query: "");

    _searchController.addListener(_onSearchChanged);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !_isLoadingMore &&
          _currentPage < _lastPage) {
        _loadMore();
      }
    });
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 600), () {
      final query = _searchController.text.trim();

      if (query == _lastSearchedText) return;

      _lastSearchedText = query;
      _currentQuery = query;

      if (query.isEmpty) {
        _fetchVisas(query: "");
        return;
      }

      if (query.length >= 3) {
        _fetchVisas(query: query);
      }
    });
  }

  Future<void> _fetchVisas({required String query}) async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _visas = [];
    });

    try {
      final response = await ApiService.getVisaList(page: 1, q: query);

      if (response['success'] == true) {
        final List data = response['data']['data'];
        final visas = data.map((e) => VisaModel.fromJson(e)).toList();

        setState(() {
          _visas = visas;
          _isLoading = false;
          _currentPage = response['data']['pagination']['current_page'];
          _lastPage = response['data']['pagination']['last_page'];
        });
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _loadMore() async {
    if (_currentPage >= _lastPage) return;

    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;

      final response = await ApiService.getVisaList(
        page: nextPage,
        q: _currentQuery,
      );

      if (response['success'] == true) {
        final List data = response['data']['data'];
        final visas = data.map((e) => VisaModel.fromJson(e)).toList();

        setState(() {
          _visas.addAll(visas);
          _currentPage = nextPage;
          _lastPage = response['data']['pagination']['last_page'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Load more error: $e")));
    }

    setState(() => _isLoadingMore = false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Widget _visaCard(VisaModel visa) {
    final streamText = visa.stream?.isNotEmpty == true ? visa.stream! : "N/A";

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VisaEstimateScreen(visa: visa)),
          ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: ThemeConfig.goldenYellow.withOpacity(.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.flight_takeoff_rounded,
                color: ThemeConfig.goldenYellow,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visa.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _chip("Subclass ${visa.subclass}"),
                      const SizedBox(width: 6),
                      if (streamText != "N/A") _chip("Stream $streamText"),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: "Search visa or subclass...",
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CommonAppBar(
        titleName: "VAC Search",
        matterID: AuthService.selectedMatterId,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  _searchBar(),
                  Expanded(
                    child:
                        _visas.isEmpty
                            ? const Center(child: Text("No visa found"))
                            : ListView.builder(
                              controller: _scrollController,
                              itemCount:
                                  _visas.length + (_isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _visas.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                return _visaCard(_visas[index]);
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
