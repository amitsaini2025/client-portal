import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../../config/theme_config.dart';
import '../../utils/app_loader.dart';
import '../../utils/responsive_utils.dart';

class SendMessageScreen extends StatefulWidget {
  const SendMessageScreen({super.key});

  @override
  State<SendMessageScreen> createState() => _SendMessageScreenState();
}

class _SendMessageScreenState extends State<SendMessageScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final List<({Uint8List bytes, String name})> _selectedImageBytes = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        for (final img in images) {
          final bytes = await img.readAsBytes();
          setState(() {
            _selectedImageBytes.add((bytes: bytes, name: img.name));
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error picking images: $e');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes.add((bytes: bytes, name: image.name));
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error taking photo: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImageBytes.removeAt(index);
    });
  }

  Future<void> _sendMessage() async {
    if (_subjectController.text.trim().isEmpty ||
        _messageController.text.trim().isEmpty) {
      _showErrorSnackBar('Please fill in all required fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final messageData = {
        'subject': _subjectController.text.trim(),
        'message': _messageController.text.trim(),
        'attachments_bytes': _selectedImageBytes,
      };

      final response = await ApiService.sendMessage(messageData);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Message sent successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error sending message: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      backgroundColor: ThemeConfig.navyBlue,
      context: context,
      useSafeArea: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImages();
                },
              ),
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.white),
                  title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImageFromCamera();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.navyBlue,
      appBar: AppBar(
        title: const Text('Send Message', style: TextStyle(color: Colors.white)),
        backgroundColor: ThemeConfig.goldenYellow,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: AppLoader(),
              ),
            )
          else
            TextButton(
              onPressed: _sendMessage,
              child: const Text(
                'Send',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppResponsive.maxContentWidth),
          child: SingleChildScrollView(
        padding: AppResponsive.pagePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Subject Field
            TextFormField(
              controller: _subjectController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Subject *',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: 'Enter message subject',
                hintStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.subject, color: Colors.white),
                filled: true,
                fillColor: ThemeConfig.navyBlue.withOpacity(0.6),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: ThemeConfig.goldenYellow),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),

            // Message Field
            TextFormField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Message *',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: 'Type your message here...',
                hintStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.message, color: Colors.white),
                filled: true,
                fillColor: ThemeConfig.navyBlue.withOpacity(0.6),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: ThemeConfig.goldenYellow),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),

            // Photo Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ThemeConfig.navyBlue.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Attachments',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _showImageSourceDialog,
                        icon: const Icon(Icons.add_photo_alternate, size: 20, color: Colors.white),
                        label: const Text('Add Photos', style: TextStyle(color: Colors.white)),
                        style: TextButton.styleFrom(
                          foregroundColor: ThemeConfig.goldenYellow,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_selectedImageBytes.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white24,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.photo_library_outlined, size: 48, color: Colors.white54),
                          SizedBox(height: 12),
                          Text('No photos selected', style: TextStyle(color: Colors.white70)),
                          SizedBox(height: 4),
                          Text('Tap "Add Photos" to attach images', style: TextStyle(color: Colors.white54)),
                        ],
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: _selectedImageBytes.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                _selectedImageBytes[index].bytes,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Send Button
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _sendMessage,
                icon: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.send, color: Colors.white),
                label: Text(
                  _isLoading ? 'Sending...' : 'Send Message',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConfig.goldenYellow,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
          ),
        ),
      ),
    );
  }
}
