import 'package:client/services/api_service_bansal_immigration.dart';
import 'package:flutter/material.dart';

import '../../../config/theme_config.dart';
import '../../../models/blog.dart';

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({Key? key}) : super(key: key);

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  List<Blog> _blogs = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasNextPage = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchBlogs();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!_isLoading && _hasNextPage) {
          _fetchBlogs();
        }
      }
    });
  }

  Future<void> _fetchBlogs() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiServiceBansalImmigration.getFeaturedBlogs(
        page: _currentPage,
        perPage: 10,
      );

      if (response['success'] == true) {
        final List list = response['data'];
        final blogs = list.map((e) => Blog.fromJson(e)).toList();

        final pagination = response['pagination'];

        setState(() {
          _blogs.addAll(blogs);
          _hasNextPage = pagination['has_more_pages'] ?? false;
          _currentPage++;
        });
      }
    } catch (e) {
      debugPrint("Error fetching blogs: $e");
    }

    setState(() => _isLoading = false);
  }

  Future<void> _onRefresh() async {
    setState(() {
      _blogs.clear();
      _currentPage = 1;
      _hasNextPage = true;
    });
    await _fetchBlogs();
  }

  Widget _buildBlogCard(Blog blog) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12),
        ],
      ),

      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/blogs/detail',
            arguments: {'blogId': blog.id},
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    blog.image,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.broken_image,
                          size: 40,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                          ),
                        ),
                      );
                    },
                    headers: {
                      "Access-Control-Allow-Origin": "*",
                    },
                  ),
                ),
                if (blog.featured)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.orange),
                          SizedBox(width: 4),
                          Text(
                            "Featured",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blog.date,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    blog.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    blog.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        "By ${blog.author}",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        title: const Text('Blogs'),
        backgroundColor: ThemeConfig.goldenYellow,
        foregroundColor: Colors.white,
      ),
      body:
          _blogs.isEmpty && _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _blogs.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < _blogs.length) {
                      return _buildBlogCard(_blogs[index]);
                    } else {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                  },
                ),
              ),
    );
  }
}
