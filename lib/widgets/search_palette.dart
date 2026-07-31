import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/operation/widgets/search_provider.dart';
import '../utils/app_theme.dart';
import '../features/ticket/screens/ticket_detail_screen.dart';

void showSearchPalette(BuildContext ctx) {
  showDialog(
    context: ctx,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(ctx),
      child: const _SearchPalette(),
    ),
  );
}

class _SearchPalette extends ConsumerStatefulWidget {
  const _SearchPalette();

  @override
  ConsumerState<_SearchPalette> createState() => _SearchPaletteState();
}

class _SearchPaletteState extends ConsumerState<_SearchPalette> {
  late TextEditingController _controller;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    ref.read(searchQueryProvider.notifier).clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    final results = ref.watch(searchResultsProvider);
    final focusNode = FocusNode()..requestFocus();

    return KeyboardListener(
      focusNode: focusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          // Escape - close palette
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.pop(ctx);
          }

          // Arrow Down - next result
          if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
              results.isNotEmpty) {
            setState(() {
              _selectedIndex = (_selectedIndex + 1) % results.length;
            });
          }

          // Arrow Up - previous result
          if (event.logicalKey == LogicalKeyboardKey.arrowUp &&
              results.isNotEmpty) {
            setState(() {
              _selectedIndex =
                  (_selectedIndex - 1 + results.length) % results.length;
            });
          }

          // Enter - open selected result
          if (event.logicalKey == LogicalKeyboardKey.enter &&
              results.isNotEmpty) {
            _open(ctx, results[_selectedIndex]);
          }
        }
      },
      child: Align(
        alignment: const Alignment(0, -0.3),
        child: Container(
          width: 560,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 40,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search input field
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Search tickets, KB articles…',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (value) {
                          ref
                              .read(searchQueryProvider.notifier)
                              .setQuery(value);
                          setState(() => _selectedIndex = 0);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Close button
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Text(
                          'Esc',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),

              // Results or empty state
              _buildResults(ctx, results),

              // Keyboard shortcuts hint
              const Padding(
                padding: EdgeInsets.fromLTRB(14, 8, 14, 12),
                child: Row(
                  children: [
                    Text(
                      '↑↓ navigate  ↵ open  Esc close',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext ctx, List<Map<String, String>> results) {
    // No results after search
    if (results.isEmpty && _controller.text.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 36,
              color: AppColors.border,
            ),
            const SizedBox(height: 8),
            Text(
              'No results for "${_controller.text}"',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Initial empty state
    if (results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'Type to search tickets and KB articles…',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13.5,
          ),
        ),
      );
    }

    // Results list
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 340),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: results.length,
        itemBuilder: (_, index) {
          final result = results[index];
          final isSelected = index == _selectedIndex;
          final isTicket = result['type'] == 'ticket';

          return InkWell(
            onTap: () => _open(ctx, result),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: isSelected
                  ? AppColors.accent.withValues(alpha: 0.1)
                  : Colors.transparent,
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isTicket
                          ? AppColors.accent.withValues(alpha: 0.12)
                          : const Color(0xFF7BD389).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isTicket
                          ? Icons.confirmation_number_outlined
                          : Icons.menu_book_outlined,
                      size: 14,
                      color:
                          isTicket ? AppColors.accent : const Color(0xFF7BD389),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result['title'] ?? '',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          result['subtitle'] ?? '',
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
            ),
          );
        },
      ),
    );
  }

  void _open(BuildContext ctx, Map<String, String> result) {
    Navigator.pop(ctx);
    ref.read(searchQueryProvider.notifier).clear();

    final ticketId = result['ticketId'];
    if (ticketId != null) {
      Navigator.of(ctx).push(
        MaterialPageRoute(
          builder: (_) => TicketDetailScreen(ticketId: ticketId),
        ),
      );
    }
  }
}
