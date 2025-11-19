import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../models/workflow_checklist.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class WorkflowDocumentsScreen extends StatefulWidget {

  const WorkflowDocumentsScreen({super.key});

  @override
  State<WorkflowDocumentsScreen> createState() =>
      _WorkflowDocumentsScreenState();
}

class _WorkflowDocumentsScreenState extends State<WorkflowDocumentsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  WorkflowChecklistResponse? _checklistResponse;
  Map<int, bool> _uploadingStates = {};

  @override
  void initState() {
    super.initState();
    _loadChecklistData();
  }

  Future<void> _loadChecklistData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getWorkflowAllowedChecklist(
        clientMatterId: AuthService.selectedMatterId ?? 0,
      );

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _checklistResponse = WorkflowChecklistResponse.fromJson(
            response['data'],
          );
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load checklist';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadDocument(WorkflowChecklist checklist) async {
    setState(() => _uploadingStates[checklist.id] = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );

      if (result == null || result.files.single.path == null) return;

      final filePath = result.files.single.path!;

      final response = await ApiService.uploadWorkflowChecklistDocument(
        filePath: filePath,
        allowedChecklistId: checklist.id,
        clientMatterId: AuthService.selectedMatterId ?? 0,
      );

      if (response['success'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Upload successful')));
        _loadChecklistData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Upload failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() => _uploadingStates[checklist.id] = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorWidget(_errorMessage!, _loadChecklistData);
    }

    if (_checklistResponse == null ||
        _checklistResponse!.allowedChecklists.isEmpty) {
      return const Center(child: Text('No documents required.'));
    }

    return RefreshIndicator(
      onRefresh: _loadChecklistData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 16),
          ..._checklistResponse!.allowedChecklists.map(_buildChecklistItem),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(WorkflowChecklist checklist) {
    final isUploading = _uploadingStates[checklist.id] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checklist Name
            Text(
              checklist.checklistName,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            // Checklist Type
            if (checklist.type != null && checklist.type!.isNotEmpty)
              Text(
                'Type: ${checklist.type}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 8),
            // Upload / View Section
            if (checklist.isUpload && checklist.fileUrl != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      checklist.fileName ?? '',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      if (checklist.fileUrl!.isNotEmpty) {
                        Navigator.pushNamed(
                          context,
                          '/pdf-viewer',
                          arguments: {
                            'url': checklist.fileUrl,
                            'title': checklist.fileName,
                          },
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('File not available')),
                        );
                      }
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('View'),
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed:
                isUploading ? null : () => _uploadDocument(checklist),
                icon: isUploading
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.upload_file),
                label: Text(isUploading ? 'Uploading...' : 'Upload Document'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Documents Summary',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildChip(
                  'Total',
                  _checklistResponse!.totalAllowedChecklists.toString(),
                  Colors.blue,
                ),
                const SizedBox(width: 8),
                _buildChip(
                  'Required',
                  _checklistResponse!.mandatoryChecklists.toString(),
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, String value, Color color) {
    return Chip(
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color),
      label: Text(
        '$label: $value',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildErrorWidget(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
