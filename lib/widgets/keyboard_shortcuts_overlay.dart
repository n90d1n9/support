import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/app_theme.dart';

class KeyboardShortcutsHandler extends ConsumerStatefulWidget {
  final Widget child;
  final VoidCallback onNewTicket, onSearch;
  final ValueChanged<int> onNavigate;
  const KeyboardShortcutsHandler(
      {super.key,
      required this.child,
      required this.onNewTicket,
      required this.onSearch,
      required this.onNavigate});
  @override
  ConsumerState<KeyboardShortcutsHandler> createState() => _KSHState();
}

class _KSHState extends ConsumerState<KeyboardShortcutsHandler> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent e) {
    if (e is! KeyDownEvent) return false;
    final focus = FocusManager.instance.primaryFocus;
    if (focus != null && focus.context?.widget is EditableText) return false;
    final key = e.logicalKey;
    final ctrl = HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    if (ctrl && key == LogicalKeyboardKey.keyK) {
      widget.onSearch();
      return true;
    }
    if (key == LogicalKeyboardKey.question) {
      _showOverlay();
      return true;
    }
    if (key == LogicalKeyboardKey.keyN) {
      widget.onNewTicket();
      return true;
    }
    if (key == LogicalKeyboardKey.digit1) {
      widget.onNavigate(0);
      return true;
    }
    if (key == LogicalKeyboardKey.digit2) {
      widget.onNavigate(1);
      return true;
    }
    if (key == LogicalKeyboardKey.digit3) {
      widget.onNavigate(2);
      return true;
    }
    if (key == LogicalKeyboardKey.digit4) {
      widget.onNavigate(3);
      return true;
    }
    if (key == LogicalKeyboardKey.digit5) {
      widget.onNavigate(4);
      return true;
    }
    return false;
  }

  void _showOverlay() {
    showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        builder: (_) => const _HelpDialog());
  }

  @override
  Widget build(BuildContext ctx) => widget.child;
}

class _HelpDialog extends StatelessWidget {
  const _HelpDialog();
  @override
  Widget build(BuildContext ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
          width: 440,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35), blurRadius: 40)
              ]),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text('Keyboard shortcuts',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () => Navigator.pop(ctx),
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 28, minHeight: 28))
                ]),
                const SizedBox(height: 14),
                ...[
                  [
                    'Navigation',
                    [
                      'N — New ticket',
                      '⌘K — Global search',
                      '1-5 — Switch tabs'
                    ]
                  ],
                  [
                    'General',
                    ['? — Show this help', 'Esc — Close dialogs']
                  ]
                ].expand((g) => [
                      Text(g[0] as String,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: .05)),
                      const SizedBox(height: 6),
                      ...(g[1] as List<String>).map((s) {
                        final p = s.split(' — ');
                        return Padding(
                            padding: const EdgeInsets.only(bottom: 7),
                            child: Row(children: [
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: AppColors.surfaceAlt,
                                      borderRadius: BorderRadius.circular(6),
                                      border:
                                          Border.all(color: AppColors.border),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.15),
                                            blurRadius: 0,
                                            offset: const Offset(0, 2))
                                      ]),
                                  child: Text(p[0],
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700))),
                              const SizedBox(width: 12),
                              Text(p[1],
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textPrimary))
                            ]));
                      }),
                      const SizedBox(height: 12)
                    ])
              ])));
}

class ShortcutsHelpButton extends StatelessWidget {
  const ShortcutsHelpButton({super.key});
  @override
  Widget build(BuildContext ctx) => Tooltip(
      message: 'Keyboard shortcuts (?)',
      child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => showDialog(
              context: ctx,
              barrierColor: Colors.black.withValues(alpha: 0.5),
              builder: (_) => const _HelpDialog()),
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.keyboard_rounded,
                    size: 13, color: AppColors.textSecondary),
                SizedBox(width: 4),
                Text('?',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary))
              ]))));
}
