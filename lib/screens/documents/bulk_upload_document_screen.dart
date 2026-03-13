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

  List<AllowedChecklist> _checklists = [];

  Map<int, File?> _uploadedFiles = {};

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

        _checklists = list
            .map<AllowedChecklist>((e) => AllowedChecklist.fromJson(e))
            .toList();
      }

    } catch (e) {
      _showSnack("Checklist load error: $e", isError: true);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _pickFile(int checklistId) async {

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf','jpg','jpeg','png','doc','docx'],
    );

    if (result != null) {

      setState(() {
        _uploadedFiles[checklistId] = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadAll() async {

    final files = <File>[];
    final ids = <int>[];

    _uploadedFiles.forEach((id, file) {

      if (file != null) {
        files.add(file);
        ids.add(id);
      }
    });

    if (files.isEmpty) {
      _showSnack("Please upload at least one document", isError: true);
      return;
    }

    setState(() => _isUploading = true);

    try {

      final res = await ApiService.bulkUploadChecklistDocuments(
        files: files,
        allowedChecklistIds: ids,
        clientMatterId: AuthService.selectedMatterId!,
      );

      if (res['success'] == true) {

        _showSnack("Documents uploaded successfully");
        Navigator.pop(context);

      } else {

        _showSnack(res['message'] ?? "Upload failed", isError: true);
      }

    } catch (e) {
      _showSnack("Upload error: $e", isError: true);
    }

    setState(() => _isUploading = false);
  }

  void _showSnack(String msg,{bool isError=false}) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Widget _buildChecklistCard(AllowedChecklist checklist) {
    final file = _uploadedFiles[checklist.id];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              Expanded(
                child: Text(
                  checklist.checklistName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              if (checklist.isMandatory)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "Required",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          if (file != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [

                  const Icon(
                    Icons.description_rounded,
                    color: Colors.blue,
                    size: 28,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      file.path.split('/').last,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  TextButton.icon(
                    onPressed: () => _pickFile(checklist.id),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text("Replace"),
                  )
                ],
              ),
            )

          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _pickFile(checklist.id),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: ThemeConfig.goldenYellow,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.upload_file),
                label: const Text(
                  "Upload Document",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Upload Documents",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: ThemeConfig.goldenYellow,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: _checklists.length,
              itemBuilder: (_, i) {
                return _buildChecklistCard(_checklists[i]);
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadAll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConfig.goldenYellow,
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Upload Documents",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}