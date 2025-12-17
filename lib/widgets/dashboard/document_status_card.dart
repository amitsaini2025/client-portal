import 'package:client/models/document_status_summary.dart';
import 'package:flutter/material.dart';
import '../../models/document.dart';

class DocumentStatusCard extends StatelessWidget {
  final DocumentStatusSummary? documentStatusSummary;
  final List<Document> documents;

  const DocumentStatusCard({
    super.key,
    required this.documentStatusSummary,
    required this.documents,
  });

  @override
  Widget build(BuildContext context) {
    final approvedDocs = documentStatusSummary?.approved ?? 0;
    final pendingDocs = documentStatusSummary?.pending ?? 0;
    final rejectedDocs = documentStatusSummary?.rejected ?? 0;
    final totalDocs = documents.length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Document Status',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/documents');
                },
                child: const Text(
                  'View All',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Document Stats
          Row(
            children: [
              _buildStatItem(context,
                  icon: Icons.check_circle, label: 'Approved', value: approvedDocs.toString(), color: Colors.green),
              const SizedBox(width: 6),
              _buildStatItem(context,
                  icon: Icons.pending, label: 'Pending', value: pendingDocs.toString(), color: Colors.orange),
              const SizedBox(width: 6),
              _buildStatItem(context,
                  icon: Icons.error, label: 'Rejected', value: rejectedDocs.toString(), color: Colors.red),
            ],
          ),
          const SizedBox(height: 12),

          // Recent Documents
          if (documents.isNotEmpty) ...[
            Text(
              'Recent Documents',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            ...documents.take(3).map((doc) => _buildDocumentItem(context, doc)),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.description, size: 40, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 12),
                  Text(
                    'No documents yet',
                    style: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Upload documents to get started',
                    style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context,
      {required IconData icon, required String label, required String value, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem(BuildContext context, Document document) {
    final statusColor = _getStatusColor(document.status ?? '');
    final statusText = _getStatusText(document.status ?? '');
    final statusIcon = _getStatusIcon(document.status ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(statusIcon, color: statusColor, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.name ?? 'Untitled Document',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                if (document.uploadedAt != null)
                  Text(
                    'Uploaded ${_getTimeAgo(document.uploadedAt!)}',
                    style: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 10),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              statusText,
              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending_review':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'under_review':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Approved';
      case 'pending_review':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      case 'under_review':
        return 'Reviewing';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'pending_review':
        return Icons.pending;
      case 'rejected':
        return Icons.error;
      case 'under_review':
        return Icons.visibility;
      default:
        return Icons.description;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
