import 'package:client/config/theme_config.dart';
import 'package:client/widgets/common_app_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/workflow_stage.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/app_loader.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/workflow/workflow_progress_widget.dart';

class WorkflowStagesScreen extends StatefulWidget {
  final int? matterID;

  const WorkflowStagesScreen({super.key, required this.matterID});

  @override
  State<WorkflowStagesScreen> createState() => _WorkflowStagesScreenState();
}

class _WorkflowStagesScreenState extends State<WorkflowStagesScreen> {
  WorkflowStagesResponse? _workflowResponse;
  bool _isLoading = true;
  String? _error;

  final ImagePicker _imagePicker = ImagePicker();

  Uint8List? _selectedFileBytes;
  String? _selectedFileName;

  @override
  void initState() {
    super.initState();
    _loadWorkflowData();
  }

  Future<void> _loadWorkflowData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getWorkflowStages(
        clientMatterId: widget.matterID ?? 0,
      );

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _workflowResponse = WorkflowStagesResponse.fromJson(response['data']);

          AuthService.setClientMatterStageId(
            _workflowResponse!.activeStage!.id,
          );

          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load workflow';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openUploadOptions(WorkflowStage stage, int checklistId) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.folder),
                  title: const Text("My Files"),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickFromFiles(stage, checklistId);
                  },
                ),
                if (!kIsWeb)
                  ListTile(
                    leading: const Icon(Icons.photo),
                    title: const Text("Gallery"),
                    onTap: () async {
                      Navigator.pop(context);
                      await _pickFromGallery(stage, checklistId);
                    },
                  ),
                if (!kIsWeb)
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text("Camera"),
                    onTap: () async {
                      Navigator.pop(context);
                      await _pickFromCamera(stage, checklistId);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickFromFiles(WorkflowStage stage, int checklistId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes == null) return;
      _selectedFileBytes = file.bytes;
      _selectedFileName = file.name;
      await _uploadDocument(stage, checklistId);
    }
  }

  Future<void> _pickFromGallery(WorkflowStage stage, int checklistId) async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _selectedFileBytes = await image.readAsBytes();
      _selectedFileName = image.name;
      await _uploadDocument(stage, checklistId);
    }
  }

  Future<void> _pickFromCamera(WorkflowStage stage, int checklistId) async {
    final image = await _imagePicker.pickImage(source: ImageSource.camera);

    if (image != null) {
      _selectedFileBytes = await image.readAsBytes();
      _selectedFileName = image.name;
      await _uploadDocument(stage, checklistId);
    }
  }

  Future<void> _uploadDocument(WorkflowStage stage, int checklistId) async {
    if (_selectedFileBytes == null || _selectedFileName == null) return;
    _showUploadingDialog();
    try {
      final fileBytes = _selectedFileBytes!;
      final fileName = _selectedFileName!;
      final response = await ApiService.uploadWorkflowChecklistDocument(
        fileBytes: fileBytes,
        fileName: fileName,
        allowedChecklistId: checklistId,
        clientMatterId: widget.matterID ?? 0,
      );
      _hideUploadingDialog();
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Document uploaded successfully"),
            backgroundColor: Colors.green,
          ),
        );
        await _loadWorkflowData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? "Upload failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      _hideUploadingDialog();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Upload error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showUploadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 48,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320, minWidth: 200),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(width: 24, height: 24, child: AppLoader(size: 20)),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      "Uploading document...",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onBulkUploadTap(WorkflowStage stage) async {
    await Navigator.pushNamed(
      context,
      '/bulk-upload-documents',
      arguments: {
        'matter_id': widget.matterID,
        'stageId': stage.id,
        'allowedChecklistId': null,
      },
    );

    _loadWorkflowData();
  }

  Future<void> _onViewTap(WorkflowStage stage, int checklistId) async {
    if (stage.allowedChecklistCount > 0) {
      Navigator.pushNamed(
        context,
        '/workflow-view-documents-by-checklist',
        arguments: {
          'matter_id': widget.matterID,
          'stageId': stage.id,
          'stageName': stage.stageName,
          'checklistId': checklistId,
        },
      );
    }
  }

  void _hideUploadingDialog() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(
        titleName: 'Workflow Stages',
        matterID: widget.matterID ?? 0,
      ),
      /*appBar: AppBar(
        title: const Text(
          'Workflow Stages',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: ThemeConfig.goldenYellow,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),*/
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppResponsive.maxContentWidth,
          ),
          child:
              _isLoading
                  ? const Center(child: AppLoader())
                  : _error != null
                  ? _buildErrorWidget(_error!, _loadWorkflowData)
                  : _workflowResponse == null
                  ? const Center(child: Text('No workflow data available'))
                  : RefreshIndicator(
                    color: ThemeConfig.goldenYellow,
                    onRefresh: _loadWorkflowData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: AppResponsive.pagePadding(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_workflowResponse!.caseSummary != null)
                            _buildCaseSummary(_workflowResponse!.caseSummary!),

                          const SizedBox(height: 20),

                          WorkflowProgressWidget(
                            workflowResponse: _workflowResponse!,
                            onStageTap: _showStageDetails,
                            onChecklistPlusTap: _openUploadOptions,
                            onChecklistViewTap: _onViewTap,
                            onBulkUploadTap: _onBulkUploadTap,
                          ),
                        ],
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildCaseSummary(CaseSummary summary) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary.caseName ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ThemeConfig.navyBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text('Status: ${summary.caseStatus ?? ''}'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: ThemeConfig.goldenYellow),
          const SizedBox(height: 16),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConfig.navyBlue,
            ),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showStageDetails(WorkflowStage stage) {
    if (stage.allowedChecklistCount > 0) {
      /*Navigator.pushNamed(
        context,
        '/workflow-documents',
        arguments: {
          'stageId': stage.id,
          'stageName': stage.stageName
        },
      );*/
      /*showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Upload Documents'),
          content: const Text(
            'Do you want to upload documents in bulk?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/bulk-upload-documents',
                  arguments: {
                    'stageId': stage.id,
                    'allowedChecklistId': null,
                  },
                );
              },
              child: const Text('Yes, Bulk Upload'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      );*/
    } else {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(
                stage.stageName,
                style: const TextStyle(color: ThemeConfig.navyBlue),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status: ${stage.statusText}'),
                  if (stage.isCurrentStage)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: ThemeConfig.goldenYellow,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Current Stage',
                            style: TextStyle(
                              color: ThemeConfig.goldenYellow,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
      );
    }
  }
}
