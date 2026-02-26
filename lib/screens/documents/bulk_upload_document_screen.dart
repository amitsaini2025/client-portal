import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../config/theme_config.dart';
import '../../models/new/allowed_checklist.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class BulkUploadDocumentScreen extends StatefulWidget {
  const BulkUploadDocumentScreen({super.key});

  @override
  State<BulkUploadDocumentScreen> createState() =>
      _BulkUploadDocumentScreenState();
}

class _BulkUploadDocumentScreenState extends State<BulkUploadDocumentScreen> {
  List<File> _files = [];
  List<AllowedChecklist> _checklists = [];
  Map<int, int?> _fileChecklistMap = {};

  bool _isLoading = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadChecklists();
  }

  Future<void> _loadChecklists() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.getWorkflowAllowedChecklist(
        clientMatterId: AuthService.selectedMatterId!,
      );

      if (res['success'] == true) {
        final list = res['data']['allowed_checklists'] ?? [];
        _checklists =
            list
                .map<AllowedChecklist>((e) => AllowedChecklist.fromJson(e))
                .toList();
      } else {
        _showSnack(
          res['message'] ?? "Failed to load checklists",
          isError: true,
        );
      }
    } catch (e) {
      _showSnack("Checklist load error: $e", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Pick multiple files
  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );

    if (result != null) {
      _files.addAll(result.paths.map((p) => File(p!)));
      for (int i = 0; i < _files.length; i++) {
        _fileChecklistMap[i] ??= null;
      }
      setState(() {});
    }
  }

  Future<void> _upload() async {
    if (_files.isEmpty) {
      _showSnack("Please select files", isError: true);
      return;
    }

    if (_fileChecklistMap.values.any((e) => e == null)) {
      _showSnack("Please assign checklist to all files", isError: true);
      return;
    }

    setState(() => _isUploading = true);

    try {
      final response = await ApiService.bulkUploadChecklistDocuments(
        files: _files,
        allowedChecklistIds: _fileChecklistMap.values.cast<int>().toList(),
        clientMatterId: AuthService.selectedMatterId!,
      );

      if (response['success'] == true) {
        _showSnack("Uploaded successfully");
        Navigator.pop(context);
      } else {
        _showSnack(response['message'] ?? "Upload failed", isError: true);
      }
    } catch (e) {
      _showSnack("Upload error: $e", isError: true);
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // Remove a file
  void _removeFile(int index) {
    _files.removeAt(index);
    _fileChecklistMap.remove(index);

    // Re-index checklist map
    final newMap = <int, int?>{};
    for (int i = 0; i < _files.length; i++) {
      newMap[i] = _fileChecklistMap[i] ?? null;
    }
    _fileChecklistMap = newMap;

    setState(() {});
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Bulk Upload",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: ThemeConfig.goldenYellow,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: ElevatedButton.icon(
                      onPressed: _pickFiles,
                      icon: const Icon(Icons.attach_file),
                      label: const Text("Select Files"),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child:
                        _files.isEmpty
                            ? const Center(child: Text("No files selected"))
                            : ListView.builder(
                              itemCount: _files.length,
                              itemBuilder: (_, i) {
                                final file = _files[i];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.insert_drive_file,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                file.path.split('/').last,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              DropdownButtonFormField<int>(
                                                value: _fileChecklistMap[i],
                                                hint: const Text(
                                                  "Select Checklist",
                                                ),
                                                items:
                                                    _checklists
                                                        .map(
                                                          (
                                                            c,
                                                          ) => DropdownMenuItem<
                                                            int
                                                          >(
                                                            value: c.id,
                                                            child: Text(
                                                              c.checklistName,
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                                onChanged: (v) {
                                                  _fileChecklistMap[i] = v;
                                                  setState(() {});
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => _removeFile(i),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : _upload,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeConfig.goldenYellow,
                        ),
                        child:
                            _isUploading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text("Upload All"),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
