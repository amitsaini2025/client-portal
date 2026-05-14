import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/theme_config.dart';
import '../../../models/new/allowed_checklist.dart';
import '../../../services/api_service.dart';
import '../../../utils/app_loader.dart';
import '../../../utils/responsive_utils.dart';

class WorkflowViewDocumentsByChecklistScreen extends StatefulWidget {
  final int matterId;
  final int stageId;
  final int allowedCheckListId;

  const WorkflowViewDocumentsByChecklistScreen({
    super.key,
    required this.matterId,
    required this.stageId,
    required this.allowedCheckListId,
  });

  @override
  State<WorkflowViewDocumentsByChecklistScreen> createState() =>
      _WorkflowViewDocumentsByChecklistScreenState();
}

class _WorkflowViewDocumentsByChecklistScreenState
    extends State<WorkflowViewDocumentsByChecklistScreen> {
  bool _isLoading = false;
  List<AllowedChecklist> _checklists = [];

  @override
  void initState() {
    super.initState();
    _loadChecklists();
  }

  Future<void> _loadChecklists() async {
    setState(() => _isLoading = true);

    try {
      final res = await ApiService.getWorkflowAllowedChecklist(
        clientMatterId: widget.matterId,
        stageId: widget.stageId,
        allowedChecklistID: widget.allowedCheckListId,
      );

      if (res['success'] == true) {
        final list = res['data']['allowed_checklists'] ?? [];

        _checklists =
            list
                .map<AllowedChecklist>((e) => AllowedChecklist.fromJson(e))
                .toList();
      }
    } catch (e) {
      _showSnack("Checklist load error: $e", isError: true);
    }

    setState(() => _isLoading = false);
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> openFile(String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showSnack("Unable to open document", isError: true);
    }
  }

  IconData getFileIcon(String url) {
    if (url.toLowerCase().endsWith(".pdf")) {
      return Icons.picture_as_pdf;
    } else if (url.toLowerCase().endsWith(".jpg") ||
        url.toLowerCase().endsWith(".png") ||
        url.toLowerCase().endsWith(".jpeg")) {
      return Icons.image;
    } else {
      return Icons.insert_drive_file;
    }
  }

  Color getFileColor(String url) {
    if (url.toLowerCase().endsWith(".pdf")) {
      return Colors.red;
    } else if (url.toLowerCase().endsWith(".jpg") ||
        url.toLowerCase().endsWith(".png") ||
        url.toLowerCase().endsWith(".jpeg")) {
      return Colors.blue;
    } else {
      return Colors.grey;
    }
  }

  Widget buildDocumentCard(AllowedChecklist doc) {
    final fileColor = getFileColor(doc.fileUrl);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        leading: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: fileColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(getFileIcon(doc.fileUrl), color: fileColor, size: 26),
        ),

        title: Text(
          doc.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Uploaded: ${doc.uploadDocDate}",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 6),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  doc.docStatusText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        trailing: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            openFile(doc.fileUrl);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.open_in_new, color: Colors.green, size: 22),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: ThemeConfig.goldenYellow,
        iconTheme: const IconThemeData(color: ThemeConfig.white),
        title: const Text(
          'Checklist Documents',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppResponsive.maxContentWidth),
          child: _isLoading
              ? const Center(child: AppLoader())
              : _checklists.isEmpty
              ? const Center(child: Text("No documents uploaded"))
              : ListView.builder(
                padding: AppResponsive.pagePadding(context),
                itemCount: _checklists.length,
                itemBuilder: (context, index) {
                  final doc = _checklists[index];
                  return buildDocumentCard(doc);
                },
              ),
        ),
      ),
    );
  }
}
