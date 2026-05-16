import 'package:client/utils/app_loader.dart';
import 'package:flutter/material.dart';

import '../../../config/theme_config.dart';
import '../../../models/blog.dart';
import '../../../services/api_service.dart';
import '../../../utils/responsive_utils.dart';

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
      final response = await ApiService.getFeaturedBlogs(
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
          mainAxisSize: MainAxisSize.min, // FIX
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  Image.network(
                    blog.image,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 160,
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
                        height: 160,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Center(child: AppLoader()),
                      );
                    },
                  ),
                  if (blog.featured)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 12, color: Colors.orange),
                            SizedBox(width: 4),
                            Text(
                              "Featured",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // FIXED: REMOVED Expanded (this caused crash)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    blog.date,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    blog.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    blog.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "By ${blog.author}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppResponsive.maxContentWidth,
          ),
          child: _blogs.isEmpty && _isLoading
              ? const Center(child: AppLoader())
              : RefreshIndicator(
            onRefresh: _onRefresh,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cols = AppResponsive.gridColumns(
                  context,
                  mobile: 1,
                  tablet: 2,
                  desktop: 3,
                );

                if (cols == 1) {
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount:
                    _blogs.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < _blogs.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: _buildBlogCard(_blogs[index]),
                        );
                      }
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: AppLoader()),
                      );
                    },
                  );
                }

                return GridView.builder(
                  controller: _scrollController,
                  padding: AppResponsive.pagePadding(context),
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.1,
                  ),
                  itemCount:
                  _blogs.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < _blogs.length) {
                      return _buildBlogCard(_blogs[index]);
                    }
                    return const Center(child: AppLoader());
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}