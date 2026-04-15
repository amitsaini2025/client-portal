import 'dart:async';

import 'package:flutter/material.dart';

import '../../../config/theme_config.dart';
import '../../../services/api_service.dart';

class OccupationSearchScreen extends StatefulWidget {
  const OccupationSearchScreen({super.key});

  @override
  State<OccupationSearchScreen> createState() => _OccupationSearchScreenState();
}

class _OccupationSearchScreenState extends State<OccupationSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  List suggestions = [];
  Map<String, dynamic>? details;

  bool loading = false;
  Timer? _debounce;

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (value.trim().length >= 2) {
        _search(value);
      } else {
        setState(() => suggestions = []);
      }
    });
  }

  Future<void> _search(String query) async {
    final res = await ApiService.searchOccupation(query);
    setState(() {
      suggestions = res['data'] ?? [];
    });
  }

  /// ✅ FIXED HERE (data is List → take first item)
  Future<void> _getDetails(String code) async {
    setState(() {
      loading = true;
      suggestions.clear();
    });

    final res = await ApiService.getOccupationDetails(code);

    setState(() {
      final dataList = res['data'];

      if (dataList is List && dataList.isNotEmpty) {
        details = dataList.first;
      } else {
        details = null;
      }

      loading = false;
    });
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
      appBar: AppBar(
        title: const Text('Occupation Search'),
        backgroundColor: ThemeConfig.goldenYellow,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search occupation',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            if (suggestions.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 6),
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: suggestions.length,
                  itemBuilder: (_, i) {
                    final item = suggestions[i];
                    return ListTile(
                      dense: true,
                      title: Text(
                        item['occupation_title'],
                        style: const TextStyle(fontSize: 13),
                      ),
                      onTap: () {
                        _controller.text = item['occupation_title'];
                        _getDetails(item['anzsco_code']);
                      },
                    );
                  },
                ),
              ),

            const SizedBox(height: 12),

            if (loading) const CircularProgressIndicator(),

            if (details != null && !loading)
              Expanded(child: SingleChildScrollView(child: _buildTable())),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    final visas = details!['visa_options'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${details!['anzsco_code']}: ${details!['occupation_title']}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        const Text(
          'Possible Visa Options',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),

        Table(
          border: TableBorder.all(color: Colors.grey.shade300, width: 0.5),
          columnWidths: const {
            0: FlexColumnWidth(2.5),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
            4: FlexColumnWidth(1),
            5: FlexColumnWidth(1),
          },
          children: [
            _headerRow(),
            ...visas.entries.map<TableRow>((e) => _row(e.value)).toList(),
          ],
        ),
      ],
    );
  }

  TableRow _headerRow() {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
      children: [
        _cell('Visa Type'),
        _cell('Eligibility'),
        _cell('MLTSSL'),
        _cell('STSOL'),
        _cell('ROL'),
        _cell('CSOL'),
      ],
    );
  }

  TableRow _row(Map data) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E3A8A),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  data['visa_type'],
                  style: const TextStyle(
                    fontSize: 8,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  data['visa_name'],
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        _iconCell(data['eligibility']),
        _iconCell(data['MLTSSL']),
        _iconCell(data['STSOL']),
        _iconCell(data['ROL']),
        _iconCell(data['CSOL']),
      ],
    );
  }

  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFEF4444);

  Widget _iconCell(bool value) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Icon(
        value ? Icons.check_circle : Icons.close,
        size: 16,
        color: value ? _green : _red,
      ),
    );
  }

  static Widget _cell(String text) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
