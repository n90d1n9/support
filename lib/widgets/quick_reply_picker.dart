import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/ticket/models/ticket.dart';
import '../features/operation/providers/agent_providers.dart';
import '../utils/app_theme.dart';

// ============================================
// QUICK REPLY PICKER - Entry Point
// ============================================
Future<String?> showQuickReplyPicker(
  BuildContext ctx,
  WidgetRef ref, {
  TicketCategory? category,
}) async {
  return showModalBottomSheet<String>(
    context: ctx,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(ctx),
      child: _QuickReplySheet(category: category),
    ),
  );
}

// ============================================
// QUICK REPLY SHEET
// ============================================
class _QuickReplySheet extends ConsumerStatefulWidget {
  final TicketCategory? category;

  const _QuickReplySheet({this.category});

  @override
  ConsumerState<_QuickReplySheet> createState() => _QuickReplySheetState();
}

class _QuickReplySheetState extends ConsumerState<_QuickReplySheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext ctx) {
    final notifier = ref.read(quickReplyProvider.notifier);
    final replies = notifier.search(_searchQuery, category: widget.category);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          _buildDragHandle(),

          // Header and search
          _buildHeaderAndSearch(),

          const Divider(height: 1),

          // Replies list
          _buildRepliesList(replies.cast<QuickReply>(), notifier),
        ],
      ),
    );
  }

  // ==========================================
  // UI COMPONENTS
  // ==========================================

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 6),
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeaderAndSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        children: [
          const Text(
            'Quick Replies',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _buildSearchField(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      autofocus: false,
      onChanged: (value) => setState(() => _searchQuery = value),
      decoration: InputDecoration(
        hintText: 'Search replies…',
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: const Icon(
          Icons.search,
          size: 18,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  Widget _buildRepliesList(
    List<QuickReply> replies,
    dynamic notifier,
  ) {
    if (replies.isEmpty) {
      return _buildEmptyState();
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 350),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: replies.length,
        itemBuilder: (ctx, index) {
          final reply = replies[index];
          return _buildReplyItem(reply, notifier);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 40,
            color: AppColors.border,
          ),
          SizedBox(height: 12),
          Text(
            'No quick replies found',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Try adjusting your search',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyItem(QuickReply reply, dynamic notifier) {
    return Card(
      color: AppColors.surfaceAlt,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          notifier.incrementUse(reply.id);
          Navigator.pop(context, reply.body);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  const Icon(
                    Icons.bolt_rounded,
                    size: 14,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    reply.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${reply.useCount}×',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),

              // Body preview
              Text(
                reply.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// QUICK REPLY MODEL (if not already defined)
// ============================================
class QuickReply {
  final String id;
  final String title;
  final String body;
  final TicketCategory? category;
  final int useCount;
  final DateTime createdAt;
  final DateTime? lastUsedAt;

  QuickReply({
    required this.id,
    required this.title,
    required this.body,
    this.category,
    this.useCount = 0,
    required this.createdAt,
    this.lastUsedAt,
  });

  /// Create a copy with updated fields
  QuickReply copyWith({
    String? id,
    String? title,
    String? body,
    TicketCategory? category,
    int? useCount,
    DateTime? createdAt,
    DateTime? lastUsedAt,
  }) {
    return QuickReply(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      useCount: useCount ?? this.useCount,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'category': category?.name,
      'useCount': useCount,
      'createdAt': createdAt.toIso8601String(),
      'lastUsedAt': lastUsedAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory QuickReply.fromJson(Map<String, dynamic> json) {
    return QuickReply(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      category: json['category'] != null
          ? TicketCategory.values.firstWhere(
              (e) => e.name == json['category'],
              orElse: () => TicketCategory.rideIssue,
            )
          : null,
      useCount: json['useCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsedAt: json['lastUsedAt'] != null
          ? DateTime.parse(json['lastUsedAt'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuickReply && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ============================================
// QUICK REPLY PROVIDER (if not already defined)
// ============================================
class QuickReplyProvider extends StateNotifier<List<QuickReply>> {
  QuickReplyProvider() : super(_defaultReplies);

  static final List<QuickReply> _defaultReplies = [
    QuickReply(
      id: 'qr-001',
      title: 'Refund Request Acknowledged',
      body:
          'Thank you for your refund request. We have received it and will process it within 2-3 business days. You will receive a confirmation email once completed.',
      category: TicketCategory.paymentIssue,
      useCount: 45,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      lastUsedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    QuickReply(
      id: 'qr-002',
      title: 'Apology for Delay',
      body:
          'We sincerely apologize for the delay. This is not the experience we want you to have. We are working on resolving this as quickly as possible.',
      category: TicketCategory.rideIssue,
      useCount: 38,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      lastUsedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    QuickReply(
      id: 'qr-003',
      title: 'Technical Issue Escalated',
      body:
          'We have escalated this technical issue to our engineering team. They will investigate and provide a solution. We will keep you updated on the progress.',
      category: TicketCategory.technicalProblem,
      useCount: 29,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastUsedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    QuickReply(
      id: 'qr-004',
      title: 'Safety Concern Acknowledged',
      body:
          'Thank you for reporting this safety concern. We take safety very seriously and are investigating this matter. A member of our safety team will reach out to you shortly.',
      category: TicketCategory.safetyIncident,
      useCount: 22,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      lastUsedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    QuickReply(
      id: 'qr-005',
      title: 'Lost Item - We\'re Looking',
      body:
          'We understand you lost an item in your ride. We are contacting the driver to check. We will update you as soon as we have more information.',
      category: TicketCategory.lostAndFound,
      useCount: 31,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      lastUsedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    QuickReply(
      id: 'qr-006',
      title: 'Fraud Report - Under Review',
      body:
          'Thank you for reporting this fraudulent activity. Our fraud team is reviewing your report and will take appropriate action. We may contact you for additional details.',
      category: TicketCategory.fraudReport,
      useCount: 18,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      lastUsedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    QuickReply(
      id: 'qr-007',
      title: 'General Acknowledgment',
      body:
          'Thank you for reaching out. We have received your request and will get back to you as soon as possible. If you have any additional information, please share it here.',
      useCount: 67,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      lastUsedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  /// Search quick replies by query and category
  List<QuickReply> search(String query, {TicketCategory? category}) {
    var results = state;

    // Filter by category if provided
    if (category != null) {
      results = results.where((reply) => reply.category == category).toList();
    }

    // Filter by search query
    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      results = results.where((reply) {
        return reply.title.toLowerCase().contains(lowerQuery) ||
            reply.body.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    // Sort by use count (most used first) and then by creation date
    results = List.from(results)
      ..sort((a, b) {
        final useCompare = b.useCount.compareTo(a.useCount);
        if (useCompare != 0) return useCompare;
        return b.createdAt.compareTo(a.createdAt);
      });

    return results;
  }

  /// Increment the use count of a quick reply
  void incrementUse(String id) {
    final index = state.indexWhere((reply) => reply.id == id);
    if (index != -1) {
      final reply = state[index];
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index)
            reply.copyWith(
              useCount: reply.useCount + 1,
              lastUsedAt: DateTime.now(),
            )
          else
            state[i],
      ];
    }
  }

  /// Add a new quick reply
  void addReply({
    required String title,
    required String body,
    TicketCategory? category,
  }) {
    final reply = QuickReply(
      id: 'qr-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      category: category,
      createdAt: DateTime.now(),
    );
    state = [...state, reply];
  }

  /// Delete a quick reply
  void deleteReply(String id) {
    state = state.where((reply) => reply.id != id).toList();
  }

  /// Update a quick reply
  void updateReply({
    required String id,
    String? title,
    String? body,
    TicketCategory? category,
  }) {
    final index = state.indexWhere((reply) => reply.id == id);
    if (index != -1) {
      final reply = state[index];
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index)
            reply.copyWith(
              title: title ?? reply.title,
              body: body ?? reply.body,
              category: category ?? reply.category,
            )
          else
            state[i],
      ];
    }
  }
}

// ============================================
// USAGE EXAMPLE
// ============================================
class QuickReplyDemo extends ConsumerWidget {
  const QuickReplyDemo({super.key});

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Quick Reply Demo'),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_rounded),
            onPressed: () async {
              final reply = await showQuickReplyPicker(ctx, ref);
              if (reply != null) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text('Selected: $reply')),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () async {
            final reply = await showQuickReplyPicker(ctx, ref);
            if (reply != null) {
              // Use the selected reply
              debugPrint('Selected reply: $reply');
            }
          },
          icon: const Icon(Icons.chat_rounded),
          label: const Text('Open Quick Reply Picker'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
