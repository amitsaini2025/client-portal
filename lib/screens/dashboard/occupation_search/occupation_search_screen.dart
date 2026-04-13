import 'dart:async';
import 'package:client/services/api_service.dart';
import 'package:flutter/material.dart';

import '../../../models/occupation.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/common_app_bar.dart';

class OccupationSearchScreen extends StatefulWidget {
  const OccupationSearchScreen({super.key});

  @override
  State<OccupationSearchScreen> createState() => _OccupationSearchScreenState();
}

class _OccupationSearchScreenState extends State<OccupationSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  List<Occupation> suggestions = [];
  List<Occupation> selectedResults = [];
  bool loading = false;

  Timer? _debounce;

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.trim().length >= 2) {
        _searchSuggestions(value.trim());
      } else {
        setState(() => suggestions = []);
      }
    });
  }

  Future<void> _searchSuggestions(String query) async {
    try {
      final response = await ApiService.occupationFinder(query);

      final List list = response["data"] ?? [];
      setState(() {
        suggestions = list.map((e) => Occupation.fromJson(e)).toList();
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() => suggestions = []);
    }
  }

  Future<void> _fetchOccupation(String title) async {
    setState(() {
      loading = true;
      selectedResults = [];
      suggestions.clear();
    });

    try {
      final response = await ApiService.occupationFinder(title);
      final List list = response["data"] ?? [];

      selectedResults = list.map((e) => Occupation.fromJson(e)).toList();
    } catch (e) {
      debugPrint(e.toString());
      selectedResults = [];
    }

    setState(() => loading = false);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        titleName: 'Occupation Search',
        matterID: AuthService.selectedMatterId,
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSearchField(),

              if (suggestions.isNotEmpty) _buildSuggestionDropdown(),

              if (loading) const SizedBox(height: 20),
              if (loading) const CircularProgressIndicator(),

              if (!loading && selectedResults.isNotEmpty)
                ...selectedResults.map((e) => OccupationCard(e)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Search Occupation", style: TextStyle(fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: "e.g. Software Engineer",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                setState(() {
                  suggestions = [];
                  selectedResults = [];
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionDropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (_, i) {
          final item = suggestions[i];
          return ListTile(
            title: Text("${item.title} (${item.anzscoCode})"),
            onTap: () {
              _controller.text = item.title;
              FocusScope.of(context).unfocus();
              _fetchOccupation(item.title);
            },
          );
        },
      ),
    );
  }
}

class OccupationCard extends StatefulWidget {
  final Occupation occupation;

  const OccupationCard(this.occupation, {super.key});

  @override
  State<OccupationCard> createState() => _OccupationCardState();
}

class _OccupationCardState extends State<OccupationCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final occupation = widget.occupation;

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              occupation.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'ANZSCO:  ${occupation.anzscoCode}',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF3B82F6),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            const Divider(),

            _rowWithBadge('SKILL LEVEL', 'LEVEL ${occupation.skillLevel}'),

            const Divider(),

            _row('ASSESSING AUTHORITY', occupation.assessingAuthority ?? "n/a"),

            const Divider(),

            _row('ASSESSMENT VALIDITY', '${occupation.validityYears} years'),

            const SizedBox(height: 16),

            const Text(
              'ELIGIBLE VISA LISTS:',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              children: occupation.occupationLists.map((e) {
                final isGreen = e == 'MLTSSL';
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                    isGreen
                        ? const Color(0xFF10B981)
                        : const Color(0xFF6B7280),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    e,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 14),

            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                children: [
                  const TextSpan(
                    text: 'Also known as: ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: occupation.alternateTitles),
                ],
              ),
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: () => setState(() => expanded = !expanded),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      expanded ? 'Less Information' : 'More Information',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (expanded) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  occupation.additionalInfo ?? "n/a",
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _rowWithBadge(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}