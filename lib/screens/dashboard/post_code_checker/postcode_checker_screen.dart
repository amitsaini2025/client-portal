import 'dart:async';
import 'dart:convert';

import 'package:client/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/post_code_checker/postcode_result.dart';
import '../../../models/post_code_checker/postcode_search_item.dart';
import '../../../services/auth_service.dart';
import '../../../utils/app_loader.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/common_app_bar.dart';

class PostcodeCheckerScreen extends StatefulWidget {
  const PostcodeCheckerScreen({super.key});

  @override
  State<PostcodeCheckerScreen> createState() => _PostcodeCheckerScreenState();
}

class _PostcodeCheckerScreenState extends State<PostcodeCheckerScreen> {
  static const String _postcodeCacheKey = "postcode_all_cache";

  final TextEditingController _controller = TextEditingController();

  Timer? _debounce;

  List<PostcodeSearchItem> allPostcodes = [];

  List<PostcodeSearchItem> suggestions = [];

  PostcodeResult? result;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    _loadPostcodes();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();

    super.dispose();
  }

  Future<void> _loadPostcodes() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final cached = prefs.getString(_postcodeCacheKey);
      if (cached != null) {
        final decoded = jsonDecode(cached);
        final data =
            (decoded as List)
                .map((e) => PostcodeSearchItem.fromJson(e))
                .toList();
        allPostcodes = data;
      }
    } catch (e) {
      debugPrint("Cache error: $e");
    }

    try {
      final response = await ApiService.postcodeAll();
      if (response['success']) {
        final data =
            (response['data'] as List)
                .map((e) => PostcodeSearchItem.fromJson(e))
                .toList();
        allPostcodes = data;
        await prefs.setString(_postcodeCacheKey, jsonEncode(response['data']));
      }
    } catch (e) {
      debugPrint("API error: $e");
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    final query = value.trim();

    if (query.isEmpty) {
      setState(() {
        suggestions = [];
      });

      return;
    }

    _debounce = Timer(const Duration(milliseconds: 100), () {
      _searchSuggestions(query);
    });
  }

  void _searchSuggestions(String query) {
    final q = query.toLowerCase();

    final results =
        allPostcodes
            .where((e) {
              return e.suburb.toLowerCase().contains(q) ||
                  e.postcode.toLowerCase().contains(q) ||
                  e.state.toLowerCase().contains(q);
            })
            .take(8)
            .toList();

    if (mounted) {
      setState(() {
        suggestions = results;
      });
    }
  }

  Future<void> _fetchResult(String postcode) async {
    setState(() {
      loading = true;
      suggestions.clear();
      result = null;
    });

    try {
      final response = await ApiService.postcodeResult(postcode);

      if (response['success']) {
        setState(() {
          result = PostcodeResult.fromJson(response['data']);

          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      debugPrint("Result error: $e");

      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        titleName: 'Postcode Checker Tool',
        matterID: AuthService.selectedMatterId,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppResponsive.maxContentWidth,
          ),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();

              setState(() {
                suggestions = [];
              });
            },
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Padding(
                padding: AppResponsive.pagePadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),

                    const SizedBox(height: 24),

                    _buildSearchField(),

                    if (suggestions.isNotEmpty) _buildSuggestions(),

                    const SizedBox(height: 16),

                    if (loading) const Center(child: AppLoader()),

                    if (result != null) _buildResultCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Australian Postcode Checker",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 8),

        Text(
          "Check if your Australian postcode qualifies for regional area points for skilled migration visas",
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Enter Australian Postcode or Suburb Name",
          style: TextStyle(fontSize: 14),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: _controller,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: "e.g. Sydney or 2000",
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();

                setState(() {
                  suggestions = [];
                  result = null;
                });
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestions() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: suggestions.length,
        itemBuilder: (_, i) {
          final item = suggestions[i];

          return ListTile(
            title: Text("${item.suburb} (${item.postcode}, ${item.state})"),
            onTap: () {
              _controller.text = item.suburb;

              FocusScope.of(context).unfocus();

              setState(() {
                suggestions = [];
              });

              _fetchResult(item.postcode);
            },
          );
        },
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Postcode Result",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          _row("Postcode", result!.postcode),

          _row("Area", result!.area),

          _row("State", result!.state),

          _row("Regional Status", result!.regionalStatus),

          _row("Category", result!.category),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 14),
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
