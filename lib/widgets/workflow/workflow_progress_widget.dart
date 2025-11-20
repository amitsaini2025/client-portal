import 'package:flutter/material.dart';
import '../../models/workflow_stage.dart';

class WorkflowProgressWidget extends StatelessWidget {
  final WorkflowStagesResponse workflowResponse;
  final Function(WorkflowStage)? onStageTap;

  const WorkflowProgressWidget({
    super.key,
    required this.workflowResponse,
    this.onStageTap,
  });

  Color _getStageColor(WorkflowStage stage, BuildContext context) {
    if (stage.isCurrentStage || stage.isActive) {
      return Theme
          .of(context)
          .colorScheme
          .primary;
    }
    // Check if stage is before current stage
    final currentIndex = workflowResponse.currentStageIndex;
    final stageIndex = workflowResponse.workflowStages.indexOf(stage);
    if (currentIndex >= 0 && stageIndex < currentIndex) {
      return Colors.green;
    }
    return Colors.grey.shade300;
  }

  IconData _getStageIcon(WorkflowStage stage) {
    if (stage.isCurrentStage || stage.isActive) {
      return Icons.radio_button_checked;
    }
    // Check if stage is before current stage (completed)
    final currentIndex = workflowResponse.currentStageIndex;
    final stageIndex = workflowResponse.workflowStages.indexOf(stage);
    if (currentIndex >= 0 && stageIndex < currentIndex) {
      return Icons.check_circle;
    }
    return Icons.radio_button_unchecked;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Summary Card
        _buildProgressSummaryCard(context),
        const SizedBox(height: 24),

        // Progress Bar
        _buildProgressBar(context),
        const SizedBox(height: 24),

        // Workflow Stages List
        _buildStagesList(context),
      ],
    );
  }

  Widget _buildProgressSummaryCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Workflow Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(
                  context,
                  'Completed',
                  workflowResponse.completedStages.toString(),
                  Colors.green,
                  Icons.check_circle,
                ),
                _buildStat(
                  context,
                  'Current',
                  workflowResponse.hasActiveStage ? '1' : '0',
                  Colors.blue,
                  Icons.pending,
                ),
                _buildStat(
                  context,
                  'Remaining',
                  workflowResponse.remainingStages.toString(),
                  Colors.orange,
                  Icons.pending_actions,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context,
      String label,
      String value,
      Color color,
      IconData icon,) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final progress = workflowResponse.progressPercentage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Overall Progress',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            Text(
              '$progress%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme
                    .of(context)
                    .colorScheme
                    .primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress / 100,
            minHeight: 12,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme
                  .of(context)
                  .colorScheme
                  .primary,
            ),
          ),
        ),
        if (workflowResponse.hasActiveStage &&
            workflowResponse.activeStage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Current Stage: ${workflowResponse.activeStage!.stageName}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStagesList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'All Stages',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...workflowResponse.workflowStages
            .asMap()
            .entries
            .map((entry) {
          final index = entry.key;
          final stage = entry.value;
          final isLast = index == workflowResponse.workflowStages.length - 1;
          return _buildStageItem(context, stage, isLast);
        }).toList(),
      ],
    );
  }

  Widget _buildStageItem(BuildContext context, WorkflowStage stage,
      bool isLast) {
    final color = _getStageColor(stage, context);
    final icon = _getStageIcon(stage);
    final isCurrent = stage.isCurrentStage || stage.isActive;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline column
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: isCurrent
                    ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
                    : null,
              ),
              child: Icon(
                icon,
                color: color == Colors.grey.shade300
                    ? Colors.grey.shade600
                    : Colors.white,
                size: 24,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: color == Colors.grey.shade300
                    ? Colors.grey.shade300
                    : color,
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Stage info
        Expanded(
          child: GestureDetector(
            onTap: () => onStageTap?.call(stage),
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isCurrent
                    ? Theme
                    .of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.1)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCurrent
                      ? Theme
                      .of(context)
                      .colorScheme
                      .primary
                      : Colors.grey.shade300,
                  width: isCurrent ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage.stageName,
                    style: TextStyle(
                      fontWeight:
                      isCurrent ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                      color: isCurrent
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stage.statusText,
                    style: TextStyle(
                      fontSize: 12,
                      color: isCurrent
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Allowed Checklist Items
                  if (stage.allowedChecklist.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Allowed Checklist (${stage.allowedChecklistCount}) :',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isCurrent
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...stage.allowedChecklist.map(
                              (item) =>
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        style: TextStyle(fontSize: 12,
                                            color: isCurrent
                                                ? Colors.white
                                                : Colors.black87),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

}

// Compact version for dashboard
class CompactWorkflowProgress extends StatelessWidget {
  final WorkflowStagesResponse workflowResponse;

  const CompactWorkflowProgress({
    super.key,
    required this.workflowResponse,
  });

  @override
  Widget build(BuildContext context) {
    final progress = workflowResponse.progressPercentage;
    final currentStageName = workflowResponse.activeStage?.stageName ??
        'Not Started';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline,
                size: 16,
                color: Theme
                    .of(context)
                    .colorScheme
                    .primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  currentStageName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$progress%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme
                      .of(context)
                      .colorScheme
                      .primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 4,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme
                    .of(context)
                    .colorScheme
                    .primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
