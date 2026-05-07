import 'dart:async';
import 'package:flutter/material.dart';

import '../../../models/visa_search/visa_model.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../utils/app_loader.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/common_app_bar.dart';
import 'visa_estimate_screen.dart';

class VacSearchScreen extends StatefulWidget {
  const VacSearchScreen({super.key});

  @override
  State<VacSearchScreen> createState() => _VacSearchScreenState();
}

class _VacSearchScreenState extends State<VacSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  List<VisaModel> suggestions = [];
  bool loading = false;

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      final query = value.trim();

      if (query.isEmpty) {
        setState(() => suggestions = []);
        return;
      }

      if (query.length >= 2) {
        _searchSuggestions(query);
      } else {
        setState(() => suggestions = []);
      }
    });
  }

  Future<void> _searchSuggestions(String query) async {
    setState(() => loading = true);

    try {
      final res = await ApiService.getVisaList(page: 1, q: query);

      if (res['success'] == true) {
        final List data = res['data']['data'];

        setState(() {
          suggestions =
              data.map((e) => VisaModel.fromJson(e)).take(6).toList();
        });
      }
    } catch (_) {
      setState(() => suggestions = []);
    }

    setState(() => loading = false);
  }

  Future<void> _navigateToEstimate(VisaModel item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VisaEstimateScreen(visa: item),
      ),
    );

    _controller.clear();
    setState(() {
      suggestions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CommonAppBar(
        titleName: "VAC Search",
        matterID: AuthService.selectedMatterId,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppResponsive.maxContentWidth),
          child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() => suggestions = []);
        },
        child: Padding(
          padding: AppResponsive.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _searchField(),

              if (suggestions.isNotEmpty) _dropdown(),

              if (loading)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(child: AppLoader()),
                ),
            ],
          ),
        ),
          ),
        ),
      ),
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _controller,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: "Search visa or subclass...",
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _controller.clear();
            setState(() => suggestions = []);
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _dropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: suggestions.length,
        itemBuilder: (_, i) {
          final item = suggestions[i];

          return ListTile(
            title: Text(item.label),
            subtitle: Text("Subclass ${item.subclass}"),
            onTap: () {
              _controller.text = item.label;
              FocusScope.of(context).unfocus();

              setState(() => suggestions = []);

              _navigateToEstimate(item);
            },
          );
        },
      ),
    );
  }
}