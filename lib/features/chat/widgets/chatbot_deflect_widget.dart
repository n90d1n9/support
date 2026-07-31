import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../knowledge/models/kb_article.dart';
import '../../knowledge/providers/knowledge_base_provider.dart';
import '../../../utils/app_theme.dart';

class ChatbotDeflectStep extends ConsumerStatefulWidget {
  final VoidCallback onProceed;
  final ValueChanged<String> onSubjectConfirmed;
  const ChatbotDeflectStep(
      {super.key, required this.onProceed, required this.onSubjectConfirmed});
  @override
  ConsumerState<ChatbotDeflectStep> createState() => _State();
}

class _State extends ConsumerState<ChatbotDeflectStep> {
  final _ctrl = TextEditingController();
  bool _deflected = false;
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    final kb = ref.watch(knowledgeBaseProvider);
    final q = _ctrl.text.trim().toLowerCase();
    final suggestions = q.length > 5
        ? kb
            .where((a) =>
                a.title.toLowerCase().contains(q) ||
                a.summary.toLowerCase().contains(q) ||
                a.tags.any((t) => q.contains(t) || t.contains(q)))
            .take(3)
            .toList()
        : <KbArticle>[];
    if (_deflected) {
      return Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
                color: const Color(0xFF7BD389).withValues(alpha: 0.15),
                shape: BoxShape.circle),
            child: const Icon(Icons.check_circle_rounded,
                size: 40, color: Color(0xFF7BD389))),
        const SizedBox(height: 16),
        const Text('Great — glad we could help!',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        const Text('No ticket was created.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5)),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          FilledButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Done')),
          const SizedBox(width: 10),
          TextButton(
              onPressed: () {
                setState(() => _deflected = false);
                widget.onProceed();
              },
              child: const Text('Open a ticket anyway'))
        ])
      ]);
    }
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF6C8CFF), Color(0xFF4F6EF7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.support_agent_rounded,
                    color: Colors.white, size: 20)),
            const SizedBox(width: 12),
            const Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Hi! How can we help?',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  Text('Describe your issue and we\'ll find help.',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary))
                ]))
          ]),
          const SizedBox(height: 16),
          TextField(
              controller: _ctrl,
              autofocus: true,
              decoration: const InputDecoration(
                  hintText: 'e.g. Driver took detour, Wallet top-up missing…',
                  hintStyle:
                      TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  prefixIcon: Icon(Icons.chat_outlined,
                      color: AppColors.textSecondary)),
              onChanged: (_) => setState(() {})),
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text('Related articles',
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            ...suggestions.map((a) => _Article(
                article: a,
                onResolved: () => setState(() => _deflected = true)))
          ] else if (q.length > 5) ...[
            const SizedBox(height: 12),
            Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border)),
                child: const Row(children: [
                  Icon(Icons.info_outline_rounded,
                      size: 15, color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text('No matching articles — open a ticket below.',
                          style: TextStyle(
                              fontSize: 12.5, color: AppColors.textSecondary)))
                ]))
          ],
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
                child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'))),
            const SizedBox(width: 10),
            Expanded(
                flex: 2,
                child: FilledButton.icon(
                    onPressed: _ctrl.text.trim().length > 3
                        ? () {
                            widget.onSubjectConfirmed(_ctrl.text.trim());
                            widget.onProceed();
                          }
                        : null,
                    icon: const Icon(Icons.edit_note_rounded, size: 17),
                    label: const Text('Open a ticket')))
          ])
        ]);
  }
}

class _Article extends StatefulWidget {
  final KbArticle article;
  final VoidCallback onResolved;
  const _Article({required this.article, required this.onResolved});
  @override
  State<_Article> createState() => _ArticleState();
}

class _ArticleState extends State<_Article> {
  bool _exp = false;
  @override
  Widget build(BuildContext ctx) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border)),
      child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _exp = !_exp),
          child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.menu_book_outlined,
                          size: 14, color: AppColors.accent),
                      const SizedBox(width: 7),
                      Expanded(
                          child: Text(widget.article.title,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600))),
                      Icon(
                          _exp
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: AppColors.textSecondary)
                    ]),
                    if (_exp) ...[
                      const SizedBox(height: 8),
                      Text(widget.article.body,
                          style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                              height: 1.5)),
                      const SizedBox(height: 10),
                      SizedBox(
                          width: double.infinity,
                          child: FilledButton.tonal(
                              onPressed: widget.onResolved,
                              child: const Text('✓ This resolved my issue',
                                  style: TextStyle(fontSize: 12.5))))
                    ] else ...[
                      const SizedBox(height: 4),
                      Text(widget.article.summary,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis)
                    ]
                  ]))));
}
