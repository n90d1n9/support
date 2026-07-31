import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/app_constants.dart';
import '../providers/quick_reply_provider.dart';
import '../../team/quick_replay.dart';
import '../../ticket/models/ticket_category.dart';

class QuickReplySheet extends ConsumerStatefulWidget {
  final TicketCategory? category;

  const QuickReplySheet({super.key, this.category});

  @override
  ConsumerState<QuickReplySheet> createState() => _QuickReplySheetState();
}

class _QuickReplySheetState extends ConsumerState<QuickReplySheet> {
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
