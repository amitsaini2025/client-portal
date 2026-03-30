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
  List<VisaModel> _allVisas = [];
  List<VisaModel> _filteredVisas = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;

  int _currentPage = 1;
  int _lastPage = 1;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchVisas();
    _searchController.addListener(_filterVisas);

    // Pagination listener
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100 &&
          !_isLoadingMore &&
          _currentPage < _lastPage) {
        _loadMore();
      }
    });
  }

  Future<void> _fetchVisas() async {
    try {
      final response = await ApiService.getVisaList(page: 1);

      if (response['success'] == true) {
        final List data = response['data']['data'];

        final visas = data.map((e) => VisaModel.fromJson(e)).toList();

        setState(() {
          _allVisas = visas;
          _filteredVisas = visas;
          _isLoading = false;

          _currentPage = response['data']['pagination']['current_page'];
          _lastPage = response['data']['pagination']['last_page'];
        });
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;

      final response = await ApiService.getVisaList(page: nextPage);

      if (response['success'] == true) {
        final List data = response['data']['data'];
        final visas = data.map((e) => VisaModel.fromJson(e)).toList();

        setState(() {
          _allVisas.addAll(visas);
          _filteredVisas.addAll(visas);
          _currentPage = nextPage;

          _lastPage = response['data']['pagination']['last_page'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Load more error: $e")));
    }

    setState(() => _isLoadingMore = false);
  }

  void _filterVisas() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredVisas = _allVisas.where((visa) {
        return visa.label.toLowerCase().contains(query) ||
            visa.subclass.toLowerCase().contains(query) ||
            (visa.stream?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _visaCard(VisaModel visa) {
    final streamText = visa.stream?.isNotEmpty == true ? visa.stream! : "N/A";

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VisaEstimateScreen(visa: visa),
        ),
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
                      _chip("Stream $streamText"),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _searchBar(),
          Expanded(
            child: _filteredVisas.isEmpty
                ? const Center(child: Text("No visa found"))
                : ListView.builder(
              controller: _scrollController,
              itemCount: _filteredVisas.length +
                  (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _filteredVisas.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                return _visaCard(_filteredVisas[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}