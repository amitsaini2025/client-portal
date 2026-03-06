import 'package:client/config/theme_config.dart';
import 'package:flutter/material.dart';

import '../../models/workflow_stage.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/workflow/workflow_progress_widget.dart';

class WorkflowStagesScreen extends StatefulWidget {
  const WorkflowStagesScreen({super.key});

  @override
  State<WorkflowStagesScreen> createState() => _WorkflowStagesScreenState();
}

class _WorkflowStagesScreenState extends State<WorkflowStagesScreen> {
  WorkflowStagesResponse? _workflowResponse;
  bool _isLoading = true;
  String? _error;

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
        clientMatterId: AuthService.selectedMatterId ?? 0,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Workflow Stages',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: ThemeConfig.goldenYellow,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: ThemeConfig.navyBlue),
              )
              : _error != null
              ? _buildErrorWidget(_error!, _loadWorkflowData)
              : _workflowResponse == null
              ? const Center(child: Text('No workflow data available'))
              : RefreshIndicator(
                color: ThemeConfig.goldenYellow,
                onRefresh: _loadWorkflowData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_workflowResponse!.caseSummary != null)
                        _buildCaseSummary(_workflowResponse!.caseSummary!),

                      const SizedBox(height: 20),

                      WorkflowProgressWidget(
                        workflowResponse: _workflowResponse!,
                        onStageTap: _showStageDetails,
                      ),
                    ],
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
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Choose Upload Type'),
              content: const Text(
                'Do you want to upload documents in bulk or one by one?',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/upload-documents');
                  },
                  child: const Text('Single Upload'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/bulk-upload-documents');
                  },
                  child: const Text('Bulk Upload'),
                ),
              ],
            ),
      );
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
