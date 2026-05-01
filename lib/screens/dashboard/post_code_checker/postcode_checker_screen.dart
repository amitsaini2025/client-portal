import 'package:flutter/material.dart';
import 'package:client/services/api_service.dart';

import '../../../config/theme_config.dart';
import '../../../models/post_code_checker/postcode_result.dart';
import '../../../models/post_code_checker/postcode_search_item.dart';
import '../../../services/auth_service.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/common_app_bar.dart';

class PostcodeCheckerScreen extends StatefulWidget {
  const PostcodeCheckerScreen({super.key});

  @override
  State<PostcodeCheckerScreen> createState() => _PostcodeCheckerScreenState();
}

class _PostcodeCheckerScreenState extends State<PostcodeCheckerScreen> {
  final TextEditingController _controller = TextEditingController();

  List<PostcodeSearchItem> suggestions = [];
  PostcodeResult? result;
  bool loading = false;

  Future<void> _searchPostcode(String query) async {
    if (query.length < 2) return;

    final response = await ApiService.postcodeSearch(query);

    if (response['success']) {
      setState(() {
        suggestions = (response['data'] as List)
            .map((e) => PostcodeSearchItem.fromJson(e))
            .toList();
      });
    }
  }

  Future<void> _fetchResult(String postcode) async {
    setState(() {
      loading = true;
      suggestions.clear();
      result = null;
    });

    final response = await ApiService.postcodeResult(postcode);

    if (response['success']) {
      setState(() {
        result = PostcodeResult.fromJson(response['data']);
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        backgroundColor: ThemeConfig.goldenYellow,
        title: const Text(
          "Postcode Checker Tool",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),*/
      appBar: CommonAppBar(
        titleName: 'Postcode Checker Tool',
        matterID: AuthService.selectedMatterId,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppResponsive.maxContentWidth),
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
              if (loading) const Center(child: CircularProgressIndicator()),
              if (result != null) _buildResultCard(),
              /*const SizedBox(height: 24),
              _buildInfoBox(),*/
            ],
          ),
        ),
          ),
        ),
      ),
    );
  }

  // ================= UI SECTIONS =================

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
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

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "About designated regional areas and points",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            "Designated regional area categories (1–3) affect eligibility for certain visas and, in some cases, points on the skilled migration points test.",
          ),
          SizedBox(height: 12),
          Text("• Points for study in regional Australia: Completing eligible study while living and studying in a designated regional area can attract additional points."),
          SizedBox(height: 8),
          Text("• Points via nomination/sponsorship: State/territory nomination or eligible family sponsorship provides additional points."),
          SizedBox(height: 8),
          Text("• Visa eligibility conditions: Some visas require residence, work, or study in designated regional areas."),
          SizedBox(height: 12),
          Text(
            "Policy settings change from time to time. This tool is general information only and not migration advice.",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
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
          onChanged: _searchPostcode,
          decoration: InputDecoration(
            hintText: "e.g. Sydney or 2000",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
        itemCount: suggestions.length,
        itemBuilder: (_, i) {
          final item = suggestions[i];
          return ListTile(
            title: Text("${item.suburb} (${item.postcode}, ${item.state})"),
            onTap: () {
              _controller.text = item.suburb;
              FocusScope.of(context).unfocus();
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
