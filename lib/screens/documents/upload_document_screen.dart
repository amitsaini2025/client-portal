import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:client/config/theme_config.dart'; // Added for colors
import '../../models/new/allowed_checklist.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class UploadDocumentScreen extends StatefulWidget {
  const UploadDocumentScreen({super.key});

  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  final TextEditingController _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  File? _selectedFile;
  String? _selectedFileName;
  String? _selectedFileType;

  List<AllowedChecklist> _checklists = [];
  int? _selectedChecklistId;

  bool _isLoading = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadChecklists();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadChecklists() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.getWorkflowAllowedChecklist(
        clientMatterId: AuthService.selectedMatterId!,
      );

      if (response['success'] == true) {
        final List<dynamic> list = response['data']['allowed_checklists'] ?? [];
        setState(() {
          _checklists =
              list.map((json) => AllowedChecklist.fromJson(json)).toList();
        });
        if ( list.isEmpty) {
          _showErrorSnackBar("No checklist available for this matter.");
        }
      } else {
        _showErrorSnackBar("Failed to fetch allowed checklist");
      }
    } catch (e) {
      _showErrorSnackBar('Error loading checklist: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'jpg',
          'jpeg',
          'png',
          'gif'
        ],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        setState(() {
          _selectedFile = file;
          _selectedFileName = result.files.first.name;
          _selectedFileType = result.files.first.extension;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking file: $e');
    }
  }

  Future<void> _uploadDocument() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null) {
      _showErrorSnackBar('Please select a file to upload');
      return;
    }
    if (_selectedChecklistId == null) {
      _showErrorSnackBar('Please select a checklist');
      return;
    }

    setState(() => _isUploading = true);

    try {
      final response = await ApiService.uploadWorkflowChecklistDocument(
        filePath: _selectedFile!.path,
        allowedChecklistId: _selectedChecklistId!,
        clientMatterId: AuthService.selectedMatterId!,
      );

      if (response['success'] == true) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        _showErrorSnackBar(response['message'] ?? 'Upload failed');
      }
    } catch (e) {
      _showErrorSnackBar('Error uploading document: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.navyBlue,
      appBar: AppBar(
        title: const Text('Upload Document'),
        backgroundColor: ThemeConfig.goldenYellow,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: ThemeConfig.goldenYellow),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildFilePicker(),
              const SizedBox(height: 24),
              _buildDocumentDetails(context),
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _uploadDocument,
                  icon: _isUploading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                      : const Icon(Icons.upload),
                  label: Text(
                    _isUploading ? 'Uploading...' : 'Upload Document',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConfig.goldenYellow,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePicker() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeConfig.navyBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeConfig.goldenYellow.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Document',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white)),
          const SizedBox(height: 16),
          if (_selectedFile == null)
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: ThemeConfig.goldenYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ThemeConfig.goldenYellow.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_upload_outlined,
                        size: 48, color: Colors.white),
                    const SizedBox(height: 12),
                    Text('Tap to select a file',
                        style: TextStyle(color: ThemeConfig.goldenYellow)),
                  ],
                ),
              ),
            )
          else
            Row(
              children: [
                const Icon(Icons.attach_file, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(
                      _selectedFileName ?? '',
                      style: const TextStyle(color: Colors.white),
                    )),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => setState(() {
                    _selectedFile = null;
                    _selectedFileName = null;
                    _selectedFileType = null;
                  }),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeConfig.navyBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeConfig.goldenYellow.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Document Details',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white)),
          const SizedBox(height: 20),
          TextFormField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Title *',
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ThemeConfig.goldenYellow),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ThemeConfig.goldenYellow, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (v) =>
            v == null || v.trim().isEmpty ? 'Title required' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _selectedChecklistId,
            decoration: InputDecoration(
              labelText: 'Related Checklist',
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ThemeConfig.goldenYellow),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ThemeConfig.goldenYellow, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            dropdownColor: ThemeConfig.navyBlue,
            style: const TextStyle(color: Colors.white),
            items: _checklists
                .map((c) => DropdownMenuItem<int>(
              value: c.id,
              child: Text(c.checklistName,
                  style: const TextStyle(color: Colors.white)),
            ))
                .toList(),
            onChanged: (v) => setState(() => _selectedChecklistId = v),
            validator: (v) =>
            v == null ? 'Please select a checklist' : null,
          ),
        ],
      ),
    );
  }
}
