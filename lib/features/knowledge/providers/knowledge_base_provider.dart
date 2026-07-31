// Knowledge Base - Full CRUD Operations
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ticket/models/ticket_category.dart';
import '../models/kb_article.dart';
import '../models/kb_article_type.dart';

class KnowledgeBaseNotifier extends StateNotifier<List<KbArticle>> {
  KnowledgeBaseNotifier() : super(_seed());

  static List<KbArticle> _seed() {
    final now = DateTime.now();
    return [
      KbArticle(
        id: 'kb-1',
        title: 'How to handle fare disputes',
        summary:
            'Step-by-step guide for reviewing and resolving fare disputes.',
        body:
            'Verify ride GPS trace, compare against metered fare, check for detours >15% of optimal route, then offer partial refund if discrepancy confirmed.',
        type: KbArticleType.troubleshooting,
        relatedCategory: TicketCategory.rideIssue,
        tags: const ['fare', 'dispute', 'ride'],
        helpfulCount: 42,
        viewCount: 350,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 5)),
        authorId: 'agent-001',
        authorName: 'Support Team',
        isPublished: true,
        version: '1.2',
      ),
      KbArticle(
        id: 'kb-2',
        title: 'Refund policy — full vs partial',
        summary:
            'When to issue a full refund versus partial refund or wallet credit.',
        body:
            'Full refunds apply when service was not rendered. Partial refunds apply for quality issues. Wallet credit is preferred for goodwill gestures under the threshold.',
        type: KbArticleType.policy,
        relatedCategory: TicketCategory.paymentIssue,
        tags: const ['refund', 'policy', 'payment'],
        helpfulCount: 87,
        viewCount: 520,
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now.subtract(const Duration(days: 12)),
        authorId: 'agent-002',
        authorName: 'Finance Team',
        isPublished: true,
        version: '2.0',
      ),
      KbArticle(
        id: 'kb-3',
        title: 'Safety incident escalation procedure',
        summary: 'Mandatory steps when a safety incident ticket is created.',
        body:
            'Restrict ticket access to Safety team. Escalate to supervisor within 5 minutes. Preserve all evidence and notify Trust & Safety lead.',
        type: KbArticleType.internalProcedure,
        relatedCategory: TicketCategory.safetyIncident,
        tags: const ['safety', 'escalation', 'sop'],
        internalOnly: true,
        helpfulCount: 19,
        viewCount: 145,
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now.subtract(const Duration(days: 2)),
        authorId: 'agent-003',
        authorName: 'Safety Team',
        isPublished: true,
        version: '3.1',
      ),
      KbArticle(
        id: 'kb-4',
        title: 'Lost item reported — what to do',
        summary: 'Guide for handling lost & found reports from passengers.',
        body:
            'Collect ride ID, item description, and photos. Contact driver via in-app channel to confirm item, then arrange pickup convenient for both parties.',
        type: KbArticleType.faq,
        relatedCategory: TicketCategory.lostAndFound,
        tags: const ['lost', 'found', 'item'],
        helpfulCount: 63,
        viewCount: 890,
        createdAt: now.subtract(const Duration(days: 90)),
        updatedAt: now.subtract(const Duration(days: 30)),
        authorId: 'agent-001',
        authorName: 'Support Team',
        isPublished: true,
        version: '1.5',
      ),
      KbArticle(
        id: 'kb-5',
        title: 'Company Code of Conduct',
        summary: 'Essential rules and regulations for all employees.',
        body:
            'All employees must adhere to professional standards, maintain confidentiality, and follow ethical guidelines in all business interactions.',
        type: KbArticleType.rule,
        tags: const ['conduct', 'rules', 'compliance'],
        helpfulCount: 34,
        viewCount: 1200,
        createdAt: now.subtract(const Duration(days: 120)),
        updatedAt: now.subtract(const Duration(days: 60)),
        authorId: 'hr-001',
        authorName: 'HR Department',
        isPublished: true,
        version: '4.0',
      ),
      KbArticle(
        id: 'kb-6',
        title: 'Risk Assessment Framework',
        summary: 'Framework for identifying and mitigating operational risks.',
        body:
            'Use this framework to assess risks across categories: operational, financial, reputational, and compliance. Rate each risk by likelihood and impact.',
        type: KbArticleType.risk,
        tags: const ['risk', 'assessment', 'framework'],
        helpfulCount: 28,
        viewCount: 210,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 7)),
        authorId: 'risk-001',
        authorName: 'Risk Management',
        isPublished: true,
        version: '1.0',
      ),
      KbArticle(
        id: 'kb-7',
        title: 'New Agent Onboarding Guide',
        summary: 'Complete training material for new support agents.',
        body:
            'Welcome to the team! This guide covers everything you need to know: tools, processes, escalation paths, and best practices for customer support.',
        type: KbArticleType.training,
        tags: const ['training', 'onboarding', 'new-agent'],
        helpfulCount: 56,
        viewCount: 430,
        createdAt: now.subtract(const Duration(days: 200)),
        updatedAt: now.subtract(const Duration(days: 10)),
        authorId: 'hr-002',
        authorName: 'Training Team',
        isPublished: true,
        version: '5.2',
      ),
    ];
  }

  // ============ CREATE ============
  /// Create a new knowledge article
  KbArticle create({
    required String title,
    required String summary,
    required String body,
    required KbArticleType type,
    TicketCategory? relatedCategory,
    List<String> tags = const [],
    bool internalOnly = false,
    String? authorId,
    String? authorName,
    bool isPublished = false,
  }) {
    final newArticle = KbArticle(
      id: 'kb-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      summary: summary,
      body: body,
      type: type,
      relatedCategory: relatedCategory,
      tags: tags,
      internalOnly: internalOnly,
      authorId: authorId,
      authorName: authorName,
      isPublished: isPublished,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      version: '1.0',
    );
    state = [...state, newArticle];
    return newArticle;
  }

  // ============ READ ============
  /// Get all articles (optionally filter by published status)
  List<KbArticle> getAll({bool? publishedOnly, bool? internalOnly}) {
    var result = state;
    if (publishedOnly == true) {
      result = result.where((a) => a.isPublished).toList();
    }
    if (internalOnly == true) {
      result = result.where((a) => a.internalOnly).toList();
    } else if (internalOnly == false) {
      result = result.where((a) => !a.internalOnly).toList();
    }
    return result;
  }

  /// Search articles by query
  List<KbArticle> search(String q) {
    if (q.trim().isEmpty) return state;
    final ql = q.toLowerCase();
    return state
        .where((a) =>
            a.title.toLowerCase().contains(ql) ||
            a.summary.toLowerCase().contains(ql) ||
            a.body.toLowerCase().contains(ql) ||
            a.tags.any((t) => t.toLowerCase().contains(ql)))
        .toList();
  }

  /// Get article by ID
  KbArticle? byId(String id) {
    try {
      return state.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get articles by type
  List<KbArticle> getByType(KbArticleType type) {
    return state.where((a) => a.type == type).toList();
  }

  /// Get articles by category
  List<KbArticle> getByCategory(TicketCategory category) {
    return state.where((a) => a.relatedCategory == category).toList();
  }

  /// Increment view count
  void incrementViewCount(String id) {
    state = [
      for (final a in state)
        if (a.id == id)
          a.copyWith(viewCount: a.viewCount + 1, updatedAt: DateTime.now())
        else
          a,
    ];
  }

  // ============ UPDATE ============
  /// Update an existing article
  KbArticle? update(
    String id, {
    String? title,
    String? summary,
    String? body,
    KbArticleType? type,
    TicketCategory? relatedCategory,
    List<String>? tags,
    bool? internalOnly,
    bool? isPublished,
    String? authorId,
    String? authorName,
  }) {
    final index = state.indexWhere((a) => a.id == id);
    if (index == -1) return null;

    final existing = state[index];

    // Increment version on update
    final newVersion = _incrementVersion(existing.version);

    final updated = existing.copyWith(
      title: title,
      summary: summary,
      body: body,
      type: type,
      relatedCategory: relatedCategory,
      tags: tags,
      internalOnly: internalOnly,
      isPublished: isPublished,
      authorId: authorId,
      authorName: authorName,
      updatedAt: DateTime.now(),
      version: newVersion,
    );

    state = [...state];
    state[index] = updated;
    return updated;
  }

  /// Update just the publish status
  void togglePublishStatus(String id) {
    final index = state.indexWhere((a) => a.id == id);
    if (index != -1) {
      state = [...state];
      state[index] = state[index].copyWith(
        isPublished: !state[index].isPublished,
        updatedAt: DateTime.now(),
      );
    }
  }

  // ============ DELETE ============
  /// Delete an article by ID
  bool delete(String id) {
    final index = state.indexWhere((a) => a.id == id);
    if (index == -1) return false;
    state = [...state]..removeAt(index);
    return true;
  }

  /// Delete multiple articles by IDs
  void deleteMultiple(List<String> ids) {
    state = state.where((a) => !ids.contains(a.id)).toList();
  }

  // ============ HELPER METHODS ============
  /// Mark article as helpful
  void markHelpful(String id) {
    final index = state.indexWhere((a) => a.id == id);
    if (index != -1) {
      state = [...state];
      state[index] = state[index].copyWith(
        helpfulCount: state[index].helpfulCount + 1,
      );
    }
  }

  /// Get popular articles (by helpful count)
  List<KbArticle> getPopularArticles({int limit = 5}) {
    final sorted = List<KbArticle>.from(state)
      ..sort((a, b) => b.helpfulCount.compareTo(a.helpfulCount));
    return sorted.take(limit).toList();
  }

  /// Get recent articles
  List<KbArticle> getRecentArticles({int limit = 5}) {
    final sorted = List<KbArticle>.from(state)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(limit).toList();
  }

  /// Get most viewed articles
  List<KbArticle> getMostViewedArticles({int limit = 5}) {
    final sorted = List<KbArticle>.from(state)
      ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
    return sorted.take(limit).toList();
  }

  /// Get related articles based on tags
  List<KbArticle> getRelatedArticles(KbArticle article, {int limit = 3}) {
    final related = state.where((a) {
      if (a.id == article.id) return false;
      return a.tags.any((tag) => article.tags.contains(tag));
    }).toList();

    related.sort((a, b) {
      final aMatches = a.tags.where((tag) => article.tags.contains(tag)).length;
      final bMatches = b.tags.where((tag) => article.tags.contains(tag)).length;
      return bMatches.compareTo(aMatches);
    });

    return related.take(limit).toList();
  }

  /// Version increment helper
  String _incrementVersion(String? version) {
    if (version == null) return '1.0';
    final parts = version.split('.');
    if (parts.length != 2) return '1.0';
    try {
      final minor = int.parse(parts[1]);
      return '${parts[0]}.${minor + 1}';
    } catch (_) {
      return '$version.1';
    }
  }
}

final knowledgeBaseProvider =
    StateNotifierProvider<KnowledgeBaseNotifier, List<KbArticle>>(
        (_) => KnowledgeBaseNotifier());
final kbSearchQueryProvider = StateProvider<String>((_) => '');
final filteredKbArticlesProvider = Provider<List<KbArticle>>((ref) {
  final q = ref.watch(kbSearchQueryProvider);
  return ref.watch(knowledgeBaseProvider.notifier).search(q);
});
