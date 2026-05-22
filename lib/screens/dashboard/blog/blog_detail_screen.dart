import 'package:client/utils/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../config/theme_config.dart';
import '../../../services/api_service.dart';
import '../../../utils/responsive_utils.dart';

class BlogDetailScreen extends StatefulWidget {
  final int blogId;

  const BlogDetailScreen({super.key, required this.blogId});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  Map<String, dynamic>? blog;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBlogDetail();
  }

  Future<void> _fetchBlogDetail() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      blog = null;
    });

    Map<String, dynamic>? loadedBlog;

    try {
      final response = await ApiService.getBlogDetail(blogId: widget.blogId)
          .timeout(const Duration(seconds: 30));

      if (response['success'] == true) {
        loadedBlog = response['data'];
      } else {
        debugPrint("Failed to load blog");
      }
    } catch (e) {
      debugPrint("Error fetching blog: $e");
    }

    // Single setState — always reached, never gets stuck
    if (!mounted) return;
    setState(() {
      blog = loadedBlog;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewportHeight = MediaQuery.of(context).size.height -
        kToolbarHeight -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Blog Detail'),
        backgroundColor: ThemeConfig.goldenYellow,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppResponsive.maxContentWidth,
              ),
              child: isLoading
                  ? SizedBox(
                height: viewportHeight,
                child: const Center(child: AppLoader()),
              )
                  : blog == null
                  ? SizedBox(
                height: viewportHeight,
                child: const Center(child: Text('Blog not found')),
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Featured Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 220,
                      child: Image.network(
                        blog!['image'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.grey[300],
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.broken_image,
                              size: 50,
                            ),
                          );
                        },
                        loadingBuilder: (
                            context,
                            child,
                            loadingProgress,
                            ) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.grey[200],
                            alignment: Alignment.center,
                            child: const AppLoader(),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Blog Info
                  Padding(
                    padding:
                    AppResponsive.horizontalPadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category & Featured
                        if (blog!['featured'] == true)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Featured",
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),

                        // Date & Author
                        Row(
                          children: [
                            Text(
                              blog!['date'] ?? '',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "By ${blog!['author'] ?? 'Unknown'}",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            if (blog!['reading_time'] != null)
                              Text(
                                "${blog!['reading_time']} min read",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          blog!['title'] ?? '',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Description (HTML)
                        Html(
                          data: blog!['description'] ?? '',
                          style: {
                            "p": Style(
                              fontSize: FontSize(16),
                              color: Colors.grey[800],
                              margin: Margins.only(bottom: 12),
                            ),
                            "h1": Style(fontSize: FontSize(24)),
                            "h2": Style(fontSize: FontSize(20)),
                            "strong": Style(
                              fontWeight: FontWeight.bold,
                            ),
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}