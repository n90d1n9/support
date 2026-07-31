import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../ticket/models/ticket.dart';
import '../../operation/models/notification.dart';
import '../../ticket/providers/ticket_board_provider.dart';
import '../../ticket/providers/ticket_providers.dart';
import '../../operation/providers/agent_providers.dart';
import '../../notification/providers/notification_providers.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/quick_reply_picker.dart';

class ConversationPanel extends ConsumerStatefulWidget {
  final Ticket ticket;
  final String currentUserId, currentUserName;
  final bool isAgent;
  final TextEditingController? externalController;
  const ConversationPanel(
      {super.key,
      required this.ticket,
      required this.currentUserId,
      required this.currentUserName,
      this.isAgent = true,
      this.externalController});
  @override
  ConsumerState<ConversationPanel> createState() => _ConversationPanelState();
}

class _ConversationPanelState extends ConsumerState<ConversationPanel>
    with SingleTickerProviderStateMixin {
  late TextEditingController _ctrl;
  late TabController _tabCtrl;
  bool _internalNote = false;
  CommChannel _channel = CommChannel.inAppChat;
  List<String> _mentionSuggestions = [];
  @override
  void initState() {
    super.initState();
    _ctrl = widget.externalController ?? TextEditingController();
    _tabCtrl = TabController(length: 5, vsync: this);
    _tabCtrl.addListener(() {
      if (_tabCtrl.indexIsChanging) return;
      const chs = [
        CommChannel.inAppChat,
        CommChannel.email,
        CommChannel.phone,
        CommChannel.whatsApp,
        CommChannel.internalNote
      ];
      setState(() {
        _channel = chs[_tabCtrl.index];
        _internalNote = _channel == CommChannel.internalNote;
      });
    });
    _ctrl.addListener(_onText);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _ctrl.removeListener(_onText);
    if (widget.externalController == null) _ctrl.dispose();
    super.dispose();
  }

  void _onText() {
    final text = _ctrl.text;
    final cursor = _ctrl.selection.baseOffset;
    if (cursor < 0) return;
    final before = text.substring(0, cursor);
    final atIdx = before.lastIndexOf('@');
    if (atIdx >= 0) {
      final q = before.substring(atIdx + 1).toLowerCase();
      if (!q.contains(' ') && q.isNotEmpty) {
        final matches = ref
            .read(agentProvider)
            .where((a) => a.name.toLowerCase().startsWith(q))
            .map((a) => a.name)
            .take(4)
            .toList();
        if (mounted) {
          setState(() {
            _mentionSuggestions = matches;
          });
        }
        return;
      }
    }
    if (mounted && _mentionSuggestions.isNotEmpty) {
      setState(() => _mentionSuggestions = []);
    }
  }

  void _insertMention(String name) {
    final text = _ctrl.text;
    final cursor = _ctrl.selection.baseOffset;
    final before = text.substring(0, cursor);
    final atIdx = before.lastIndexOf('@');
    if (atIdx < 0) return;
    final after = text.substring(cursor);
    final newText = '${before.substring(0, atIdx)}@$name $after';
    _ctrl.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: atIdx + name.length + 2));
    setState(() => _mentionSuggestions = []);
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    ref.read(ticketBoardProvider.notifier).addMessage(widget.ticket.id,
        authorId: widget.currentUserId,
        authorName: widget.currentUserName,
        isAgent: widget.isAgent,
        body: text,
        isInternal: _internalNote,
        channel: _channel);
    if (_internalNote) {
      final agents = ref.read(agentProvider);
      final regex = RegExp(r'@(\w+)');
      for (final m in regex.allMatches(text)) {
        final mn = m.group(1)!;
        final agent = agents.firstWhere(
            (a) => a.name.toLowerCase() == mn.toLowerCase(),
            orElse: () => agents.first);
        if (agent.name.toLowerCase() == mn.toLowerCase()) {
          ref.read(notificationProvider.notifier).add(
              type: NotificationType.customerReplied,
              message:
                  '@${widget.currentUserName} mentioned you in ${widget.ticket.ticketNumber}',
              ticketId: widget.ticket.id,
              ticketNumber: widget.ticket.ticketNumber);
        }
      }
    }
    _ctrl.clear();
    setState(() => _mentionSuggestions = []);
  }

  Widget _buildBody(String text) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'@(\w+)');
    int last = 0;
    for (final m in regex.allMatches(text)) {
      if (m.start > last) {
        spans.add(TextSpan(
            text: text.substring(last, m.start),
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 13.5, height: 1.45)));
      }
      spans.add(TextSpan(
          text: m.group(0),
          style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
              height: 1.45)));
      last = m.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(
          text: text.substring(last),
          style: const TextStyle(
              color: AppColors.textPrimary, fontSize: 13.5, height: 1.45)));
    }
    return RichText(text: TextSpan(children: spans));
  }

  IconData _chIcon(CommChannel ch) {
    switch (ch) {
      case CommChannel.inAppChat:
        return Icons.chat_bubble_outline_rounded;
      case CommChannel.email:
        return Icons.email_outlined;
      case CommChannel.whatsApp:
        return Icons.phone_android_rounded;
      case CommChannel.phone:
        return Icons.call_outlined;
      case CommChannel.internalNote:
        return Icons.lock_outline;
    }
  }

  @override
  Widget build(BuildContext ctx) {
    final ticket =
        ref.watch(ticketByIdProvider(widget.ticket.id)) ?? widget.ticket;
    final messages = ticket.messages;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (widget.isAgent)
        Container(
            color: AppColors.surfaceAlt,
            child: TabBar(
                controller: _tabCtrl,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelStyle: const TextStyle(
                    fontSize: 11.5, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontSize: 11.5),
                indicatorColor: AppColors.accent,
                labelColor: AppColors.accent,
                unselectedLabelColor: AppColors.textSecondary,
                tabs: const [
                  Tab(
                      icon: Icon(Icons.chat_bubble_outline_rounded, size: 14),
                      text: 'Chat'),
                  Tab(
                      icon: Icon(Icons.email_outlined, size: 14),
                      text: 'Email'),
                  Tab(icon: Icon(Icons.call_outlined, size: 14), text: 'Phone'),
                  Tab(
                      icon: Icon(Icons.phone_android_rounded, size: 14),
                      text: 'WhatsApp'),
                  Tab(
                      icon: Icon(Icons.lock_outline, size: 14),
                      text: 'Internal')
                ])),
      Expanded(
          child: messages.isEmpty
              ? const Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.chat_bubble_outline_rounded,
                      size: 36, color: AppColors.border),
                  SizedBox(height: 8),
                  Text('No messages yet',
                      style: TextStyle(color: AppColors.textSecondary))
                ]))
              : ListView.builder(
                  reverse: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  itemCount: messages.length,
                  itemBuilder: (ctx, i) {
                    final msg = messages[messages.length - 1 - i];
                    final isInt = msg.isInternal;
                    final isAg = msg.isAgent;
                    return Align(
                        alignment:
                            isAg ? Alignment.centerRight : Alignment.centerLeft,
                        child: Column(
                            crossAxisAlignment: isAg
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Row(mainAxisSize: MainAxisSize.min, children: [
                                if (isInt)
                                  const Padding(
                                      padding: EdgeInsets.only(right: 3),
                                      child: Icon(Icons.lock_outline,
                                          size: 11, color: Color(0xFFFFA94D))),
                                Text(msg.authorName,
                                    style: const TextStyle(
                                        fontSize: 10.5,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(width: 5),
                                Icon(_chIcon(msg.channel),
                                    size: 10, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(DateFormat('HH:mm').format(msg.sentAt),
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondary))
                              ]),
                              const SizedBox(height: 3),
                              Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 360),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 13, vertical: 9),
                                  decoration: BoxDecoration(
                                      color: isInt
                                          ? const Color(0xFFFFA94D)
                                              .withValues(alpha: 0.10)
                                          : isAg
                                              ? AppColors.accent
                                                  .withValues(alpha: 0.14)
                                              : AppColors.surfaceAlt,
                                      borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(14),
                                          topRight: const Radius.circular(14),
                                          bottomLeft: isAg
                                              ? const Radius.circular(14)
                                              : const Radius.circular(3),
                                          bottomRight: isAg
                                              ? const Radius.circular(3)
                                              : const Radius.circular(14)),
                                      border: Border.all(
                                          color: isInt
                                              ? const Color(0xFFFFA94D)
                                                  .withValues(alpha: 0.35)
                                              : AppColors.border)),
                                  child: _buildBody(msg.body))
                            ]));
                  },
                )),
      if (_mentionSuggestions.isNotEmpty)
        Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, -2))
                ]),
            child: Column(
                children: _mentionSuggestions
                    .map((name) => InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => _insertMention(name),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Row(children: [
                              CircleAvatar(
                                  radius: 11,
                                  backgroundColor:
                                      AppColors.accent.withValues(alpha: 0.2),
                                  child: Text(name[0].toUpperCase(),
                                      style: const TextStyle(
                                          color: AppColors.accent,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700))),
                              const SizedBox(width: 8),
                              Text('@$name',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600))
                            ]))))
                    .toList())),
      const Divider(height: 1),
      const SizedBox(height: 4),
      if (_internalNote)
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
                color: const Color(0xFFFFA94D).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: const Color(0xFFFFA94D).withValues(alpha: 0.4))),
            child: const Row(children: [
              Icon(Icons.lock_outline, size: 13, color: Color(0xFFFFA94D)),
              SizedBox(width: 6),
              Text('Internal note · @AgentName to notify',
                  style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFFFFA94D),
                      fontWeight: FontWeight.w600))
            ])),
      Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            if (widget.isAgent)
              IconButton(
                  onPressed: () async {
                    final r = await showQuickReplyPicker(ctx, ref,
                        category: widget.ticket.category);
                    if (r != null) {
                      _ctrl.text = r;
                      _ctrl.selection = TextSelection.fromPosition(
                          TextPosition(offset: r.length));
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.bolt_rounded,
                      size: 20, color: AppColors.accent),
                  padding: const EdgeInsets.all(4),
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  tooltip: 'Quick replies'),
            Expanded(
                child: TextField(
                    controller: _ctrl,
                    minLines: 1,
                    maxLines: 5,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 14),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                        hintText: _internalNote
                            ? 'Internal note… @mention an agent'
                            : 'Write a reply…',
                        hintStyle: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                        filled: true,
                        fillColor: AppColors.surfaceAlt,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none)))),
            const SizedBox(width: 6),
            IconButton.filled(
                onPressed: _send,
                icon: const Icon(Icons.send_rounded, size: 18),
                style: IconButton.styleFrom(
                    backgroundColor: _internalNote
                        ? const Color(0xFFFFA94D)
                        : AppColors.accent)),
          ])),
    ]);
  }
}
