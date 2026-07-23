import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/ticket.dart';
import '../providers/ticket_providers.dart';
import '../utils/support_theme.dart';

// ============================================
// LOST & FOUND SCREEN
// ============================================
class LostFoundScreen extends ConsumerWidget {
  const LostFoundScreen({super.key});

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final cases = ref.watch(lostFoundProvider);
    final notifier = ref.read(lostFoundProvider.notifier);
    final dateFormat = DateFormat('MMM d, HH:mm');

    return Scaffold(
      backgroundColor: SupportColors.bg,
      appBar: AppBar(
        title: Text('Lost & Found (${cases.length})'),
        backgroundColor: SupportColors.bg,
        elevation: 0,
      ),
      body: cases.isEmpty
          ? _buildEmptyState()
          : _buildCasesList(
              ctx, cases.cast<LostFoundCase>(), notifier, dateFormat),
    );
  }

  // ==========================================
  // UI COMPONENTS
  // ==========================================

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: SupportColors.border,
          ),
          SizedBox(height: 12),
          Text(
            'No lost & found cases.',
            style: TextStyle(
              color: SupportColors.textSecondary,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'All cases have been resolved.',
            style: TextStyle(
              color: SupportColors.textSecondary,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCasesList(
    BuildContext ctx,
    List<LostFoundCase> cases,
    dynamic notifier,
    DateFormat dateFormat,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cases.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final caseItem = cases[index];
        return _buildCaseCard(
          ctx: ctx,
          caseItem: caseItem,
          notifier: notifier,
          dateFormat: dateFormat,
        );
      },
    );
  }

  Widget _buildCaseCard({
    required BuildContext ctx,
    required LostFoundCase caseItem,
    required dynamic notifier,
    required DateFormat dateFormat,
  }) {
    final statusColor = _getStatusColor(caseItem.status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SupportColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SupportColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Status and date
          _buildHeader(caseItem, statusColor, dateFormat),

          const SizedBox(height: 8),

          // Item description
          Text(
            caseItem.itemDescription,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          // Passenger info
          Text(
            'Passenger: ${caseItem.passengerName} · Ride: ${caseItem.rideId}',
            style: const TextStyle(
              fontSize: 12,
              color: SupportColors.textSecondary,
            ),
          ),

          // Driver info (if available)
          if (caseItem.driverName != null) ...[
            const SizedBox(height: 4),
            Text(
              'Driver: ${caseItem.driverName}',
              style: const TextStyle(
                fontSize: 12,
                color: SupportColors.textSecondary,
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Status buttons
          _buildStatusButtons(
            caseItem: caseItem,
            notifier: notifier,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    LostFoundCase caseItem,
    Color statusColor,
    DateFormat dateFormat,
  ) {
    return Row(
      children: [
        const Icon(
          Icons.search_rounded,
          size: 14,
          color: SupportColors.accent,
        ),
        const SizedBox(width: 6),
        Text(
          caseItem.status.label,
          style: TextStyle(
            fontSize: 12,
            color: statusColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Text(
          dateFormat.format(caseItem.reportedAt),
          style: const TextStyle(
            fontSize: 11,
            color: SupportColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusButtons({
    required LostFoundCase caseItem,
    required dynamic notifier,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: LostFoundStatus.values.map((status) {
          final isActive = caseItem.status == status;
          final color = _getStatusColor(status);

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => notifier.updateStatus(caseItem.id, status),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isActive
                      ? color.withValues(alpha: 0.18)
                      : SupportColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive ? color : SupportColors.border,
                  ),
                ),
                child: Text(
                  status.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? color : SupportColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==========================================
  // HELPERS
  // ==========================================

  Color _getStatusColor(LostFoundStatus status) {
    switch (status) {
      case LostFoundStatus.reported:
        return const Color(0xFFFFA94D);
      case LostFoundStatus.investigating:
        return const Color(0xFF54C7FC);
      case LostFoundStatus.found:
        return const Color(0xFF7BD389);
      case LostFoundStatus.returned:
        return SupportColors.accent;
      case LostFoundStatus.closed:
        return SupportColors.textSecondary;
    }
  }
}

// ============================================
// LOST & FOUND MODEL (if not already defined)
// ============================================
enum LostFoundStatus {
  reported('Reported'),
  investigating('Investigating'),
  found('Found'),
  returned('Returned'),
  closed('Closed');

  final String label;
  const LostFoundStatus(this.label);
}

class LostFoundCase {
  final String id;
  final String itemDescription;
  final String passengerName;
  final String passengerId;
  final String rideId;
  final String? driverName;
  final String? driverId;
  final LostFoundStatus status;
  final DateTime reportedAt;
  final DateTime? updatedAt;
  final String? notes;
  final List<String> images;

  LostFoundCase({
    required this.id,
    required this.itemDescription,
    required this.passengerName,
    required this.passengerId,
    required this.rideId,
    this.driverName,
    this.driverId,
    this.status = LostFoundStatus.reported,
    required this.reportedAt,
    this.updatedAt,
    this.notes,
    this.images = const [],
  });

  /// Create a copy with updated fields
  LostFoundCase copyWith({
    String? id,
    String? itemDescription,
    String? passengerName,
    String? passengerId,
    String? rideId,
    String? driverName,
    String? driverId,
    LostFoundStatus? status,
    DateTime? reportedAt,
    DateTime? updatedAt,
    String? notes,
    List<String>? images,
  }) {
    return LostFoundCase(
      id: id ?? this.id,
      itemDescription: itemDescription ?? this.itemDescription,
      passengerName: passengerName ?? this.passengerName,
      passengerId: passengerId ?? this.passengerId,
      rideId: rideId ?? this.rideId,
      driverName: driverName ?? this.driverName,
      driverId: driverId ?? this.driverId,
      status: status ?? this.status,
      reportedAt: reportedAt ?? this.reportedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      images: images ?? this.images,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemDescription': itemDescription,
      'passengerName': passengerName,
      'passengerId': passengerId,
      'rideId': rideId,
      'driverName': driverName,
      'driverId': driverId,
      'status': status.name,
      'reportedAt': reportedAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'notes': notes,
      'images': images,
    };
  }

  /// Create from JSON
  factory LostFoundCase.fromJson(Map<String, dynamic> json) {
    return LostFoundCase(
      id: json['id'] as String,
      itemDescription: json['itemDescription'] as String,
      passengerName: json['passengerName'] as String,
      passengerId: json['passengerId'] as String,
      rideId: json['rideId'] as String,
      driverName: json['driverName'] as String?,
      driverId: json['driverId'] as String?,
      status: LostFoundStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LostFoundStatus.reported,
      ),
      reportedAt: DateTime.parse(json['reportedAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      notes: json['notes'] as String?,
      images: List<String>.from(json['images'] ?? []),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LostFoundCase && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ============================================
// LOST & FOUND EXTENSIONS
// ============================================

extension LostFoundExtensions on LostFoundCase {
  /// Check if case is active (not closed)
  bool get isActive => status != LostFoundStatus.closed;

  /// Check if case has been resolved
  bool get isResolved =>
      status == LostFoundStatus.returned || status == LostFoundStatus.closed;

  /// Get time since reported
  Duration get timeSinceReported => DateTime.now().difference(reportedAt);

  /// Get formatted time since reported
  String get formattedTimeSinceReported {
    final diff = timeSinceReported;
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Get status color
  Color get statusColor {
    switch (status) {
      case LostFoundStatus.reported:
        return const Color(0xFFFFA94D);
      case LostFoundStatus.investigating:
        return const Color(0xFF54C7FC);
      case LostFoundStatus.found:
        return const Color(0xFF7BD389);
      case LostFoundStatus.returned:
        return SupportColors.accent;
      case LostFoundStatus.closed:
        return SupportColors.textSecondary;
    }
  }
}

// ============================================
// LOST & FOUND PROVIDER
// ============================================

class LostFoundProvider extends StateNotifier<List<LostFoundCase>> {
  LostFoundProvider() : super(_defaultCases);

  static final List<LostFoundCase> _defaultCases = [
    LostFoundCase(
      id: 'lf-001',
      itemDescription: 'Black leather wallet with ID and credit cards',
      passengerName: 'John Doe',
      passengerId: 'pax-001',
      rideId: 'RIDE-2024-001',
      driverName: 'Driver Name',
      status: LostFoundStatus.investigating,
      reportedAt: DateTime.now().subtract(const Duration(hours: 3)),
      notes: 'Driver is checking the vehicle',
    ),
    LostFoundCase(
      id: 'lf-002',
      itemDescription: 'iPhone 15 Pro - Silver',
      passengerName: 'Jane Smith',
      passengerId: 'pax-002',
      rideId: 'RIDE-2024-002',
      driverName: 'Driver Name',
      status: LostFoundStatus.found,
      reportedAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      notes: 'Item found and secured',
    ),
  ];

  /// Update case status
  void updateStatus(String caseId, LostFoundStatus newStatus) {
    final index = state.indexWhere((c) => c.id == caseId);
    if (index != -1) {
      final caseItem = state[index];
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index)
            caseItem.copyWith(
              status: newStatus,
              updatedAt: DateTime.now(),
            )
          else
            state[i],
      ];
    }
  }

  /// Add a new case
  void addCase({
    required String itemDescription,
    required String passengerName,
    required String passengerId,
    required String rideId,
    String? driverName,
    String? driverId,
    String? notes,
    List<String>? images,
  }) {
    final caseItem = LostFoundCase(
      id: 'lf-${DateTime.now().millisecondsSinceEpoch}',
      itemDescription: itemDescription,
      passengerName: passengerName,
      passengerId: passengerId,
      rideId: rideId,
      driverName: driverName,
      driverId: driverId,
      status: LostFoundStatus.reported,
      reportedAt: DateTime.now(),
      notes: notes,
      images: images ?? [],
    );
    state = [...state, caseItem];
  }

  /// Delete a case
  void deleteCase(String caseId) {
    state = state.where((c) => c.id != caseId).toList();
  }

  /// Get cases by status
  List<LostFoundCase> getByStatus(LostFoundStatus status) {
    return state.where((c) => c.status == status).toList();
  }

  /// Get active cases
  List<LostFoundCase> getActiveCases() {
    return state.where((c) => c.isActive).toList();
  }

  /// Search cases by query
  List<LostFoundCase> search(String query) {
    if (query.isEmpty) return state;
    final lowerQuery = query.toLowerCase();
    return state.where((c) {
      return c.itemDescription.toLowerCase().contains(lowerQuery) ||
          c.passengerName.toLowerCase().contains(lowerQuery) ||
          c.rideId.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

// ============================================
// USAGE EXAMPLE
// ============================================
class LostFoundDemo extends StatelessWidget {
  const LostFoundDemo({super.key});

  @override
  Widget build(BuildContext ctx) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LostFoundScreen(),
    );
  }
}
