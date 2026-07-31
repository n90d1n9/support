import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../operation/models/notification.dart';
import '../providers/notification_providers.dart';
import '../../../utils/app_theme.dart';

class NotificationBell extends ConsumerWidget {
  final ValueChanged<String>? onTicketTap;
  const NotificationBell({super.key, this.onTicketTap});
  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider);
    return Stack(clipBehavior: Clip.none, children: [
      IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 22),
          tooltip: 'Notifications',
          onPressed: () => showModalBottomSheet(
              context: ctx,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => ProviderScope(
                  parent: ProviderScope.containerOf(ctx),
                  child: _NotifSheet(onTicketTap: onTicketTap)))),
      if (unread > 0)
        Positioned(
            right: 6,
            top: 6,
            child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                    color: Color(0xFFFF5C72), shape: BoxShape.circle),
                child: Center(
                    child: Text(unread > 9 ? '9+' : '$unread',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800)))))
    ]);
  }
}

class _NotifSheet extends ConsumerWidget {
  final ValueChanged<String>? onTicketTap;
  const _NotifSheet({this.onTicketTap});
  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final notifs = ref.watch(notificationProvider);
    final n = ref.read(notificationProvider.notifier);
    return DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.92,
        minChildSize: 0.3,
        builder: (ctx, sc) => Container(
            decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child: Column(children: [
              Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2))),
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                  child: Row(children: [
                    const Text('Notifications',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    TextButton(
                        onPressed: n.markAllRead,
                        child: const Text('Mark all read',
                            style: TextStyle(fontSize: 12.5))),
                    TextButton(
                        onPressed: n.clearAll,
                        child: const Text('Clear all',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.5)))
                  ])),
              const Divider(height: 1),
              Expanded(
                  child: notifs.isEmpty
                      ? const Center(
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.notifications_off_rounded,
                              size: 40, color: AppColors.border),
                          SizedBox(height: 8),
                          Text('No notifications',
                              style: TextStyle(color: AppColors.textSecondary))
                        ]))
                      : ListView.builder(
                          controller: sc,
                          itemCount: notifs.length,
                          itemBuilder: (ctx, i) {
                            final no = notifs[i];
                            return Dismissible(
                                key: Key(no.id),
                                onDismissed: (_) => n.dismiss(no.id),
                                background: Container(
                                    color: const Color(0xFFFF5C72)
                                        .withValues(alpha: 0.2),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 16),
                                    child: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Color(0xFFFF5C72))),
                                child: ListTile(
                                    leading: Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                            color: no.type.isUrgent
                                                ? const Color(0xFFFF5C72)
                                                    .withValues(alpha: 0.15)
                                                : AppColors.accent
                                                    .withValues(alpha: 0.12),
                                            shape: BoxShape.circle),
                                        child: Icon(
                                            no.type.isUrgent
                                                ? Icons.warning_rounded
                                                : Icons.info_outline_rounded,
                                            color: no.type.isUrgent
                                                ? const Color(0xFFFF5C72)
                                                : AppColors.accent,
                                            size: 18)),
                                    title: Text(no.message, style: TextStyle(fontSize: 13, fontWeight: no.read ? FontWeight.w400 : FontWeight.w700)),
                                    subtitle: Text(DateFormat('HH:mm').format(no.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                    tileColor: no.read ? null : AppColors.accent.withValues(alpha: 0.04),
                                    onTap: () {
                                      n.markRead(no.id);
                                      if (no.ticketId != null) {
                                        onTicketTap?.call(no.ticketId!);
                                      }
                                      Navigator.pop(ctx);
                                    }));
                          }))
            ])));
  }
}
