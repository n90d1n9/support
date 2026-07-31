import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../features/ai/models/ai_insight.dart';
import '../features/ticket/models/comm_channel.dart';
import '../features/ticket/models/ticket_category.dart';
import '../features/ticket/models/ticket_message.dart';
import '../features/ticket/models/ticket_priority.dart';
import '../features/ticket/models/ticket_status.dart';
import '../features/sentiment/models/sentiment_level.dart';
import '../features/ticket/models/ticket.dart';
import '../features/ticket/providers/ticket_board_provider.dart';

final apiKeyProvider = StateProvider<String>((_) => '');

class ClaudeService {
  final String apiKey;
  static const _ep = 'https://api.anthropic.com/v1/messages';
  static const _model = 'claude-sonnet-4-6';
  const ClaudeService(this.apiKey);
  bool get isConfigured => apiKey.trim().isNotEmpty;
  Future<String> _call(String prompt, {int maxTokens = 400}) async {
    if (!isConfigured) throw Exception('No API key');
    final res = await http
        .post(Uri.parse(_ep),
            headers: {
              'Content-Type': 'application/json',
              'x-api-key': apiKey,
              'anthropic-version': '2023-06-01'
            },
            body: jsonEncode({
              'model': _model,
              'max_tokens': maxTokens,
              'messages': [
                {'role': 'user', 'content': prompt}
              ]
            }))
        .timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) {
      final b = jsonDecode(res.body);
      throw Exception(b['error']?['message'] ?? 'API error ${res.statusCode}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data['content'] as List)
        .where((b) => b['type'] == 'text')
        .map<String>((b) => b['text'] as String)
        .join('\n');
  }

  Future<Map<String, dynamic>> analyseTicket(Ticket ticket) async {
    final msgs = ticket.messages
        .where((m) => !m.isInternal)
        .take(8)
        .map((m) => '${m.isAgent ? "Agent" : "Customer"}: ${m.body}')
        .join('\n');
    final prompt =
        'Analyse this support ticket. Respond ONLY with valid JSON, no markdown fences.\nSubject: ${ticket.subject}\nCategory: ${ticket.category.label}\n$msgs\n\nJSON: {"sentiment":"positive"|"neutral"|"negative"|"urgent","summary":"one sentence","suggestedReplies":["r1","r2","r3"],"suggestedPriority":"critical"|"high"|"normal"|"low"}';
    final raw = await _call(prompt, maxTokens: 500);
    final clean = raw.replaceAll(RegExp(r'```[a-z]*|```'), '').trim();
    return jsonDecode(clean) as Map<String, dynamic>;
  }

  Future<String> summariseConversation(Ticket ticket) async {
    final msgs = ticket.messages
        .where((m) => !m.isInternal)
        .map((m) => '${m.isAgent ? "Agent" : "Customer"}: ${m.body}')
        .join('\n');
    return _call(
        'Summarise in 2-3 sentences: (1) what customer reported, (2) what agent did, (3) current status. No greeting, no markdown.\nTicket: ${ticket.subject}\n$msgs',
        maxTokens: 200);
  }
}

final claudeServiceProvider =
    Provider<ClaudeService>((ref) => ClaudeService(ref.watch(apiKeyProvider)));

enum AiCallState { idle, loading, done, error }

class AiInsightState {
  final AiCallState state;
  final AiInsight? insight;
  final String? error;
  const AiInsightState(
      {this.state = AiCallState.idle, this.insight, this.error});
  AiInsightState loading() => const AiInsightState(state: AiCallState.loading);
  AiInsightState success(AiInsight i) =>
      AiInsightState(state: AiCallState.done, insight: i);
  AiInsightState failed(String e) =>
      AiInsightState(state: AiCallState.error, error: e);
}

class AiInsightNotifier extends StateNotifier<Map<String, AiInsightState>> {
  final Ref _ref;
  AiInsightNotifier(this._ref) : super({});
  AiInsightState stateFor(String id) => state[id] ?? const AiInsightState();
  static const _autoTags = {
    TicketCategory.rideIssue: ['fare', 'ride'],
    TicketCategory.safetyIncident: ['safety', 'urgent'],
    TicketCategory.fraudReport: ['fraud', 'urgent'],
    TicketCategory.paymentIssue: ['payment', 'billing'],
    TicketCategory.walletIssue: ['wallet'],
    TicketCategory.lostAndFound: ['lost-item'],
    TicketCategory.technicalProblem: ['tech', 'app'],
    TicketCategory.driverComplaint: ['driver', 'complaint'],
    TicketCategory.passengerComplaint: ['passenger', 'complaint'],
    TicketCategory.billingIssue: ['billing', 'invoice'],
    TicketCategory.promotionIssue: ['promo', 'voucher'],
    TicketCategory.accountVerification: ['kyc', 'account']
  };
  void _autoTag(Ticket ticket) {
    if (ticket.tags.isNotEmpty) return;
    final tags = _autoTags[ticket.category] ?? [];
    final n = _ref.read(ticketBoardProvider.notifier);
    for (final t in tags) {
      n.addTag(ticket.id, t);
    }
  }

  Future<void> analyse(Ticket ticket) async {
    state = {...state, ticket.id: const AiInsightState().loading()};
    try {
      final svc = _ref.read(claudeServiceProvider);
      AiInsight insight;
      if (!svc.isConfigured) {
        await Future.delayed(const Duration(milliseconds: 600));
        insight = _heuristic(ticket);
      } else {
        final j = await svc.analyseTicket(ticket);
        insight = _fromJson(j, ticket);
      }
      state = {...state, ticket.id: const AiInsightState().success(insight)};
      _autoTag(ticket);
      _ref.read(ticketBoardProvider.notifier).setAiInsight(ticket.id, insight);
    } catch (_) {
      final insight = _heuristic(ticket);
      state = {...state, ticket.id: const AiInsightState().success(insight)};
      _autoTag(ticket);
    }
  }

  AiInsight _fromJson(Map<String, dynamic> j, Ticket ticket) {
    SentimentLevel s;
    switch (j['sentiment'] ?? 'neutral') {
      case 'urgent':
        s = SentimentLevel.urgent;
        break;
      case 'negative':
        s = SentimentLevel.negative;
        break;
      case 'positive':
        s = SentimentLevel.positive;
        break;
      default:
        s = SentimentLevel.neutral;
    }
    TicketPriority p;
    switch (j['suggestedPriority'] ?? 'normal') {
      case 'critical':
        p = TicketPriority.critical;
        break;
      case 'high':
        p = TicketPriority.high;
        break;
      case 'low':
        p = TicketPriority.low;
        break;
      default:
        p = TicketPriority.normal;
    }
    return AiInsight(
        suggestedCategory: ticket.category,
        suggestedPriority: p,
        sentiment: s,
        summary: j['summary'] as String,
        suggestedReplies: List<String>.from(j['suggestedReplies'] as List));
  }

  AiInsight _heuristic(Ticket ticket) {
    final text = (ticket.messages
            .lastWhere((m) => !m.isAgent,
                orElse: () => TicketMessage(
                    id: '_',
                    channel: CommChannel.inAppChat,
                    authorId: '_',
                    authorName: '_',
                    isAgent: false,
                    body: ticket.subject,
                    sentAt: ticket.createdAt))
            .body)
        .toLowerCase();
    final s = text.contains('unsafe') ||
            text.contains('fraud') ||
            text.contains('danger')
        ? SentimentLevel.urgent
        : text.contains('refund') ||
                text.contains('angry') ||
                text.contains('bad')
            ? SentimentLevel.negative
            : text.contains('thanks') || text.contains('great')
                ? SentimentLevel.positive
                : SentimentLevel.neutral;
    return AiInsight(
        suggestedCategory: ticket.category,
        suggestedPriority: s == SentimentLevel.urgent
            ? TicketPriority.critical
            : s == SentimentLevel.negative
                ? TicketPriority.high
                : ticket.priority,
        sentiment: s,
        summary:
            'Customer reports "${ticket.category.label}". Sentiment: ${s.label}.',
        suggestedReplies: const [
          'Thank you for reaching out — I\'m looking into this right away.',
          'I\'m sorry for the inconvenience. Could you share more details?',
          'This has been resolved. Please let us know if anything else comes up.'
        ]);
  }
}

final aiInsightProvider =
    StateNotifierProvider<AiInsightNotifier, Map<String, AiInsightState>>(
        (ref) => AiInsightNotifier(ref));

class SummaryNotifier extends StateNotifier<Map<String, String>> {
  final Ref _ref;
  SummaryNotifier(this._ref) : super({});
  final Set<String> _loading = {};
  bool isLoading(String id) => _loading.contains(id);
  String? summaryFor(String id) => state[id];
  Future<void> summarise(Ticket ticket) async {
    if (_loading.contains(ticket.id)) return;
    _loading.add(ticket.id);
    state = {...state};
    try {
      final svc = _ref.read(claudeServiceProvider);
      final s = svc.isConfigured
          ? await svc.summariseConversation(ticket)
          : _fallback(ticket);
      state = {...state, ticket.id: s};
    } catch (_) {
      state = {...state, ticket.id: _fallback(ticket)};
    } finally {
      _loading.remove(ticket.id);
      state = {...state};
    }
  }

  String _fallback(Ticket t) =>
      'Customer ${t.customerName} reported "${t.subject}". ${t.assignedAgentName ?? 'An agent'} responded across ${t.messages.length} message${t.messages.length != 1 ? "s" : ""}. Status: ${t.status.label}.';
}

final summaryProvider =
    StateNotifierProvider<SummaryNotifier, Map<String, String>>(
        (ref) => SummaryNotifier(ref));
