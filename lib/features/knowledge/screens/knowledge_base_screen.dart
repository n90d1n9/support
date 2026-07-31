import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_constants.dart';
import '../models/kb_article.dart';
import '../providers/knowledge_base_provider.dart';
import '../../../constants/app_constants.dart';

class KnowledgeBaseScreen extends ConsumerWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final articles = ref.watch(filteredKbArticlesProvider);
    final notifier = ref.read(knowledgeBaseProvider.notifier);
    final searchNotifier = ref.read(kbSearchQueryProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Knowledge Base'),
        backgroundColor: AppColors.bg,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(searchNotifier),

          // Articles list
          Expanded(
            child: _buildArticlesList(articles, notifier),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // UI COMPONENTS
  // ==========================================

  Widget _buildSearchBar(dynamic searchNotifier) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: TextField(
        onChanged: (value) => searchNotifier.state = value,
        decoration: InputDecoration(
          hintText: 'Search articles…',
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
          ),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildArticlesList(List<KbArticle> articles, dynamic notifier) {
    if (articles.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: articles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final article = articles[index];
        return _buildArticleCard(article, notifier);
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: AppColors.border,
          ),
          SizedBox(height: 12),
          Text(
            'No articles found',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Try adjusting your search terms',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(KbArticle article, dynamic notifier) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Type badge and helpful count
          _buildArticleHeader(article, notifier),

          const SizedBox(height: 8),

          // Title
          Text(
            article.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          // Summary
          Text(
            article.summary,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 8),

          // Tags
          _buildTags(article.tags),
        ],
      ),
    );
  }

  Widget _buildArticleHeader(KbArticle article, dynamic notifier) {
    return Row(
      children: [
        // Type badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            article.type.label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        ),
        const Spacer(),

        // Helpful button
        GestureDetector(
          onTap: () => notifier.markHelpful(article.id),
          child: Row(
            children: [
              const Icon(
                Icons.thumb_up_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${article.helpfulCount}',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTags(List<String> tags) {
    if (tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            '#$tag',
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.textSecondary,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ============================================
// KNOWLEDGE BASE SEARCH DELEGATE (Optional Helper)
// ============================================
class KnowledgeBaseSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext ctx) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) {
            close(ctx, '');
          } else {
            query = '';
          }
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext ctx) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(ctx, ''),
    );
  }

  @override
  Widget buildResults(BuildContext ctx) {
    // Use the existing filtered articles from the provider
    return Consumer(
      builder: (context, ref, _) {
        final articles = ref.watch(filteredKbArticlesProvider);
        final notifier = ref.read(knowledgeBaseProvider.notifier);

        if (articles.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: AppColors.border,
                ),
                SizedBox(height: 12),
                Text(
                  'No results found',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: articles.length,
          itemBuilder: (_, index) {
            final article = articles[index];
            return _buildSearchResultCard(article, notifier);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext ctx) {
    // Show suggestions as user types
    return Consumer(
      builder: (context, ref, _) {
        final articles = ref.watch(filteredKbArticlesProvider);
        final notifier = ref.read(knowledgeBaseProvider.notifier);

        if (query.isEmpty) {
          return _buildRecentSearches(ctx);
        }

        if (articles.isEmpty) {
          return const Center(
            child: Text(
              'No suggestions found',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: articles.length > 5 ? 5 : articles.length,
          itemBuilder: (_, index) {
            final article = articles[index];
            return ListTile(
              leading: const Icon(
                Icons.article_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
              title: Text(
                article.title,
                style: const TextStyle(fontSize: 14),
              ),
              subtitle: Text(
                article.summary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              onTap: () {
                query = article.title;
                showResults(ctx);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRecentSearches(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Searches',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ...['Refund policy', 'Trip cancellation', 'Payment issues'].map(
            (term) => ListTile(
              leading: const Icon(
                Icons.history_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
              title: Text(
                term,
                style: const TextStyle(fontSize: 14),
              ),
              onTap: () {
                query = term;
                showResults(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultCard(KbArticle article, dynamic notifier) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    article.type.label,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => notifier.markHelpful(article.id),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.thumb_up_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${article.helpfulCount}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              article.summary,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
