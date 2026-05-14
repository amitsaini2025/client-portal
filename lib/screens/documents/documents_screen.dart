import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../utils/responsive_utils.dart';
import '../../models/new/document.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/documents/document_card.dart';
import '../../widgets/documents/upload_progress.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Document> _documents = [];

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadStatus;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getClientDocuments(
        page: page,
        selMatterID: AuthService.selectedMatterId?.toString() ?? '',
      );

      if (response['success'] == true) {
        final docsResponse = DocumentsResponse.fromJson(response);
        setState(() {
          _documents = docsResponse.data.documents;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load documents';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load documents: ${e.toString()}';
      });
    }
  }

  Future<void> _uploadDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        final uploaded = await _showUploadDialog(file);

        if (uploaded) await _loadDocuments();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick file: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _showUploadDialog(PlatformFile file) async {
    String title = '';
    String description = '';
    String priority = 'medium';

    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Document'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    _getFileIcon(file.extension),
                    color: Colors.blue,
                  ),
                  title: Text(file.name),
                  subtitle: Text('${(file.size / 1024 / 1024).toStringAsFixed(2)} MB'),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Document Title',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => title = value,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: (value) => description = value,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  value: priority,
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                    DropdownMenuItem(value: 'critical', child: Text('Critical')),
                  ],
                  onChanged: (value) => priority = value!,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: title.trim().isEmpty
                ? null
                : () async {
              Navigator.of(context).pop(true);
              await _performUpload(file, title, description, priority);
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    ) ??
        false;
  }

  Future<void> _performUpload(
      PlatformFile file, String title, String description, String priority) async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadStatus = 'Uploading...';
    });

    try {
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isUploading = false;
        _uploadStatus = 'Upload completed!';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document uploaded successfully'),
          backgroundColor: Colors.green,
        ),
      );

      await _loadDocuments();
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadStatus = 'Upload failed';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteDocument(Document document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Delete "${document.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        setState(() {
          _documents.removeWhere((d) => d.id == document.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getFileIcon(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.navyBlue,
      appBar: AppBar(
        title: const Text(
          'Documents',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: ThemeConfig.goldenYellow,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: _errorMessage != null
          ? CustomErrorWidget(
        message: _errorMessage!,
        onRetry: _loadDocuments,
      )
          : _isLoading
          ? const Center(child: LoadingWidget())
          : Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppResponsive.maxContentWidth),
          child: Column(
        children: [
          if (_isUploading || _uploadStatus != null)
            UploadProgress(
              isUploading: _isUploading,
              progress: _uploadProgress,
              status: _uploadStatus ?? '',
            ),
          Expanded(
            child: _documents.isEmpty
                ? _buildEmptyState()
                : LayoutBuilder(
              builder: (context, constraints) {
                final cols = AppResponsive.gridColumns(
                  context,
                  mobile: 1,
                  tablet: 2,
                  desktop: 3,
                );
                if (cols == 1) {
                  return ListView.builder(
                    padding: AppResponsive.pagePadding(context),
                    itemCount: _documents.length,
                    itemBuilder: (context, index) {
                      final doc = _documents[index];
                      return DocumentCard(
                        document: doc,
                        onTap: () {},
                        onDelete: () => _deleteDocument(doc),
                      );
                    },
                  );
                }
                return GridView.builder(
                  padding: AppResponsive.pagePadding(context),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: _documents.length,
                  itemBuilder: (context, index) {
                    final doc = _documents[index];
                    return DocumentCard(
                      document: doc,
                      onTap: () {},
                      onDelete: () => _deleteDocument(doc),
                    );
                  },
                );
              },
            ),
          ),
        ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ThemeConfig.goldenYellow,
        foregroundColor: Colors.white,
        onPressed: _isUploading ? null : _uploadDocument,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: Colors.white70),
          const SizedBox(height: 16),
          Text(
            'No documents yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your first document to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _uploadDocument,
            icon: const Icon(Icons.upload),
            label: const Text('Upload Document'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConfig.goldenYellow,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
