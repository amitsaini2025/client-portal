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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ThemeConfig.navyBlue),
      );
    }

    if (_error != null) {
      return _buildErrorWidget(_error!, _loadWorkflowData);
    }

    if (_workflowResponse == null) {
      return const Center(child: Text('No workflow data available'));
    }

    return RefreshIndicator(
      color: ThemeConfig.goldenYellow,
      onRefresh: _loadWorkflowData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: WorkflowProgressWidget(
          workflowResponse: _workflowResponse!,
          onStageTap: _showStageDetails,
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
      Navigator.pushNamed(
        context,
        '/workflow-documents',
        arguments: {'stageId': stage.id, 'stageName': stage.stageName},
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
