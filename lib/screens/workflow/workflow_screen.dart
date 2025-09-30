import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/workflow_stage.dart';
import '../../models/workflow_checklist.dart';
import '../../services/api_service.dart';
import '../../widgets/workflow/workflow_progress_widget.dart';

class WorkflowScreen extends StatefulWidget {
  final int clientMatterId;
  final String matterName;

  const WorkflowScreen({
    super.key,
    required this.clientMatterId,
    required this.matterName,
  });

  @override
  State<WorkflowScreen> createState() => _WorkflowScreenState();
}

class _WorkflowScreenState extends State<WorkflowScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  WorkflowStagesResponse? _workflowResponse;
  WorkflowChecklistResponse? _checklistResponse;
  bool _isLoadingWorkflow = true;
  bool _isLoadingChecklist = true;
  String? _errorWorkflow;
  String? _errorChecklist;

  Map<int, bool> _uploadingStates = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadWorkflowData();
    _loadChecklistData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkflowData() async {
    setState(() {
      _isLoadingWorkflow = true;
      _errorWorkflow = null;
    });

    try {
      final response = await ApiService.getWorkflowStages(
        clientMatterId: widget.clientMatterId,
      );

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _workflowResponse = WorkflowStagesResponse.fromJson(response['data']);
          _isLoadingWorkflow = false;
        });
      } else {
        setState(() {
          _errorWorkflow = response['message'] ?? 'Failed to load workflow';
          _isLoadingWorkflow = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorWorkflow = e.toString();
        _isLoadingWorkflow = false;
      });
    }
  }

  Future<void> _loadChecklistData() async {
    setState(() {
      _isLoadingChecklist = true;
      _errorChecklist = null;
    });

    try {
      final response = await ApiService.getWorkflowAllowedChecklist(
        clientMatterId: widget.clientMatterId,
      );

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _checklistResponse = WorkflowChecklistResponse.fromJson(response['data']);
          _isLoadingChecklist = false;
        });
      } else {
        setState(() {
          _errorChecklist = response['message'] ?? 'Failed to load checklist';
          _isLoadingChecklist = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorChecklist = e.toString();
        _isLoadingChecklist = false;
      });
    }
  }

  Future<void> _uploadDocument(WorkflowChecklist checklist) async {
    setState(() {
      _uploadingStates[checklist.id] = true;
    });

    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;

        // Upload to server
        final response = await ApiService.uploadWorkflowChecklistDocument(
          filePath: filePath,
          allowedChecklistId: checklist.id,
          clientMatterId: widget.clientMatterId,
        );

        if (response['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Document uploaded successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
          // Reload checklist to show updated data
          await _loadChecklistData();
        } else {
          throw Exception(response['message'] ?? 'Upload failed');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _uploadingStates[checklist.id] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Workflow', style: TextStyle(fontSize: 18)),
            Text(
              widget.matterName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Stages'),
            Tab(text: 'Documents'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStagesTab(),
          _buildDocumentsTab(),
        ],
      ),
    );
  }

  Widget _buildStagesTab() {
    if (_isLoadingWorkflow) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorWorkflow != null) {
      return _buildErrorWidget(_errorWorkflow!, _loadWorkflowData);
    }

    if (_workflowResponse == null) {
      return const Center(child: Text('No workflow data available'));
    }

    return RefreshIndicator(
      onRefresh: _loadWorkflowData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: WorkflowProgressWidget(
          workflowResponse: _workflowResponse!,
          onStageTap: (stage) {
            // Could show stage details dialog here
            _showStageDetails(stage);
          },
        ),
      ),
    );
  }

  Widget _buildDocumentsTab() {
    if (_isLoadingChecklist) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorChecklist != null) {
      return _buildErrorWidget(_errorChecklist!, _loadChecklistData);
    }

    if (_checklistResponse == null ||
        _checklistResponse!.allowedChecklists.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.description_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No documents required at this stage',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadChecklistData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary Card
          _buildChecklistSummaryCard(),
          const SizedBox(height: 16),

          // Current Stage Info
          if (_workflowResponse?.hasActiveStage == true) ...[
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Current Stage: ${_checklistResponse!.applicationInfo.currentStage}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Checklist Items
          ..._checklistResponse!.allowedChecklists.map((checklist) {
            return _buildChecklistItem(checklist);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildChecklistSummaryCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Documents Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSummaryChip(
                  'Total',
                  _checklistResponse!.totalAllowedChecklists.toString(),
                  Colors.blue,
                ),
                const SizedBox(width: 8),
                _buildSummaryChip(
                  'Required',
                  _checklistResponse!.mandatoryChecklists.toString(),
                  Colors.red,
                ),
                const SizedBox(width: 8),
                _buildSummaryChip(
                  'Optional',
                  (_checklistResponse!.totalAllowedChecklists -
                          _checklistResponse!.mandatoryChecklists)
                      .toString(),
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryChip(String label, String value, Color color) {
    return Chip(
      label: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color, width: 1),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    checklist.checklistName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (checklist.isMandatory)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Text(
                      'Required',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
              ],
            ),
            if (checklist.description != null && checklist.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                checklist.description!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
            if (checklist.hasDueDate) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: checklist.isOverdue ? Colors.red : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${checklist.dueDate}',
                    style: TextStyle(
                      fontSize: 12,
                      color: checklist.isOverdue ? Colors.red : Colors.grey.shade600,
                      fontWeight: checklist.isOverdue ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isUploading ? null : () => _uploadDocument(checklist),
                icon: isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.upload_file),
                label: Text(isUploading ? 'Uploading...' : 'Upload Document'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
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

  void _showStageDetails(WorkflowStage stage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(stage.stageName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${stage.statusText}'),
            const SizedBox(height: 8),
            Text('Stage ID: ${stage.id}'),
            if (stage.isCurrentStage) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.blue.shade700, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Current Stage',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
