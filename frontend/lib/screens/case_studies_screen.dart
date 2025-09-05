import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/case_study.dart';
import '../providers/case_studies_provider.dart';

class CaseStudiesScreen extends ConsumerStatefulWidget {
  const CaseStudiesScreen({super.key});

  @override
  ConsumerState<CaseStudiesScreen> createState() => _CaseStudiesScreenState();
}

class _CaseStudiesScreenState extends ConsumerState<CaseStudiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = '';
  String _selectedSource = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCaseStudies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadCaseStudies() {
    Future.microtask(() {
      ref.read(caseStudiesProvider.notifier).loadCaseStudies();
      ref.read(caseStudiesProvider.notifier).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final caseStudiesState = ref.watch(caseStudiesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Case Studies'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              _showFilterDialog();
            },
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Case Studies',
          ),
          IconButton(
            onPressed: () {
              _loadCaseStudies();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refreshing case studies...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All Studies'),
            Tab(text: 'Beginner'),
            Tab(text: 'Advanced'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCaseStudiesList(caseStudiesState, null),
          _buildCaseStudiesList(caseStudiesState, 'beginner'),
          _buildCaseStudiesList(caseStudiesState, 'advanced'),
        ],
      ),
    );
  }

  Widget _buildCaseStudiesList(CaseStudiesState state, String? difficultyFilter) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.error}',
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(caseStudiesProvider.notifier).clearError();
                _loadCaseStudies();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    List<CaseStudy> filteredStudies = state.caseStudies;
    
    // Apply difficulty filter
    if (difficultyFilter != null) {
      filteredStudies = filteredStudies
          .where((study) => study.difficultyLevel == difficultyFilter)
          .toList();
    }

    // Apply other filters
    if (_selectedCategory.isNotEmpty) {
      filteredStudies = filteredStudies
          .where((study) => study.category == _selectedCategory)
          .toList();
    }

    if (_selectedSource.isNotEmpty) {
      filteredStudies = filteredStudies
          .where((study) => study.source == _selectedSource)
          .toList();
    }

    if (filteredStudies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No case studies found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              difficultyFilter != null
                  ? 'No $difficultyFilter level case studies available'
                  : 'Try adjusting your filters',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(caseStudiesProvider.notifier).loadCaseStudies();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredStudies.length,
        itemBuilder: (context, index) {
          final caseStudy = filteredStudies[index];
          return _buildCaseStudyCard(caseStudy);
        },
      ),
    );
  }

  Widget _buildCaseStudyCard(CaseStudy caseStudy) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () => _showCaseStudyDetail(caseStudy),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with source and difficulty
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getSourceColor(caseStudy.source),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      caseStudy.source,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(caseStudy.difficultyLevel),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      caseStudy.difficultyLevel.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                caseStudy.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Summary
              Text(
                caseStudy.summary,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Tags
              if (caseStudy.tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: caseStudy.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSourceColor(String source) {
    switch (source.toLowerCase()) {
      case 'sebi':
        return const Color(0xFF1976D2);
      case 'nism':
        return const Color(0xFF7B1FA2);
      default:
        return const Color(0xFF424242);
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF4CAF50);
      case 'intermediate':
        return const Color(0xFFFF9800);
      case 'advanced':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Case Studies'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Category:', style: TextStyle(fontWeight: FontWeight.w500)),
            DropdownButton<String>(
              value: _selectedCategory.isEmpty ? null : _selectedCategory,
              hint: const Text('Select Category'),
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: '', child: Text('All Categories')),
                DropdownMenuItem(value: 'investor-education', child: Text('Investor Education')),
                DropdownMenuItem(value: 'regulations', child: Text('Regulations')),
                DropdownMenuItem(value: 'notices', child: Text('Notices')),
                DropdownMenuItem(value: 'innovation', child: Text('Innovation')),
              ],
              onChanged: (value) => setState(() => _selectedCategory = value ?? ''),
            ),
            const SizedBox(height: 16),
            
            const Text('Source:', style: TextStyle(fontWeight: FontWeight.w500)),
            DropdownButton<String>(
              value: _selectedSource.isEmpty ? null : _selectedSource,
              hint: const Text('Select Source'),
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: '', child: Text('All Sources')),
                DropdownMenuItem(value: 'SEBI', child: Text('SEBI')),
                DropdownMenuItem(value: 'NISM', child: Text('NISM')),
              ],
              onChanged: (value) => setState(() => _selectedSource = value ?? ''),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = '';
                _selectedSource = '';
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showCaseStudyDetail(CaseStudy caseStudy) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CaseStudyDetailScreen(caseStudy: caseStudy),
      ),
    );
  }
}

class CaseStudyDetailScreen extends StatelessWidget {
  final CaseStudy caseStudy;

  const CaseStudyDetailScreen({super.key, required this.caseStudy});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Case Study'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement sharing functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing coming soon!')),
              );
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getSourceColor(caseStudy.source),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            caseStudy.source,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(caseStudy.difficultyLevel),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            caseStudy.difficultyLevel.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      caseStudy.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Summary card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      caseStudy.summary,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tags card
            if (caseStudy.tags.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Key Topics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: caseStudy.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Source link card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Original Source',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        // TODO: Open URL in browser
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Opening: ${caseStudy.url}')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.link,
                              color: Color(0xFF2E7D32),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                caseStudy.url,
                                style: const TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.open_in_new,
                              color: Color(0xFF2E7D32),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSourceColor(String source) {
    switch (source.toLowerCase()) {
      case 'sebi':
        return const Color(0xFF1976D2);
      case 'nism':
        return const Color(0xFF7B1FA2);
      default:
        return const Color(0xFF424242);
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF4CAF50);
      case 'intermediate':
        return const Color(0xFFFF9800);
      case 'advanced':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}
