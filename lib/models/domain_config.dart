import 'package:flutter/foundation.dart';

/// Represents a configurable domain for the support system
@immutable
class SupportDomain {
  final String id;
  final String name;
  final String description;
  final List<CategoryDefinition> categories;
  final List<TeamDefinition> teams;
  final List<CustomerTypeDefinition> customerTypes;
  final Map<String, String> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupportDomain({
    required this.id,
    required this.name,
    required this.description,
    this.categories = const [],
    this.teams = const [],
    this.customerTypes = const [],
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  SupportDomain copyWith({
    String? name,
    String? description,
    List<CategoryDefinition>? categories,
    List<TeamDefinition>? teams,
    List<CustomerTypeDefinition>? customerTypes,
    Map<String, String>? metadata,
    DateTime? updatedAt,
  }) {
    return SupportDomain(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      categories: categories ?? this.categories,
      teams: teams ?? this.teams,
      customerTypes: customerTypes ?? this.customerTypes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  CategoryDefinition? getCategoryById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  TeamDefinition? getTeamById(String id) {
    try {
      return teams.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  CustomerTypeDefinition? getCustomerTypeById(String id) {
    try {
      return customerTypes.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// A configurable category definition
@immutable
class CategoryDefinition {
  final String id;
  final String name;
  final String description;
  final String colorHex;
  final bool isSafetyCritical;
  final int sortOrder;
  final Map<String, String> metadata;

  const CategoryDefinition({
    required this.id,
    required this.name,
    this.description = '',
    this.colorHex = '#6C8CFF',
    this.isSafetyCritical = false,
    this.sortOrder = 0,
    this.metadata = const {},
  });

  CategoryDefinition copyWith({
    String? name,
    String? description,
    String? colorHex,
    bool? isSafetyCritical,
    int? sortOrder,
    Map<String, String>? metadata,
  }) {
    return CategoryDefinition(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      colorHex: colorHex ?? this.colorHex,
      isSafetyCritical: isSafetyCritical ?? this.isSafetyCritical,
      sortOrder: sortOrder ?? this.sortOrder,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// A configurable team definition
@immutable
class TeamDefinition {
  final String id;
  final String name;
  final String description;
  final String colorHex;
  final int sortOrder;
  final Map<String, String> metadata;

  const TeamDefinition({
    required this.id,
    required this.name,
    this.description = '',
    this.colorHex = '#4F6EF7',
    this.sortOrder = 0,
    this.metadata = const {},
  });

  TeamDefinition copyWith({
    String? name,
    String? description,
    String? colorHex,
    int? sortOrder,
    Map<String, String>? metadata,
  }) {
    return TeamDefinition(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// A configurable customer type definition
@immutable
class CustomerTypeDefinition {
  final String id;
  final String name;
  final String description;
  final String iconCodePoint;
  final int sortOrder;
  final Map<String, String> metadata;

  const CustomerTypeDefinition({
    required this.id,
    required this.name,
    this.description = '',
    this.iconCodePoint = '',
    this.sortOrder = 0,
    this.metadata = const {},
  });

  CustomerTypeDefinition copyWith({
    String? name,
    String? description,
    String? iconCodePoint,
    int? sortOrder,
    Map<String, String>? metadata,
  }) {
    return CustomerTypeDefinition(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      sortOrder: sortOrder ?? this.sortOrder,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Pre-built domain configurations for common use cases
class DomainPresets {
  static SupportDomain createRideSupportDomain() {
    final now = DateTime.now();
    return SupportDomain(
      id: 'domain-ride-support',
      name: 'Ride Support',
      description: 'Support system for ride-sharing operations',
      categories: [
        const CategoryDefinition(id: 'cat-ride-issue', name: 'Ride Issue', colorHex: '#FF6B6B', sortOrder: 1),
        const CategoryDefinition(id: 'cat-driver-complaint', name: 'Driver Complaint', colorHex: '#FFA94D', sortOrder: 2),
        const CategoryDefinition(id: 'cat-passenger-complaint', name: 'Passenger Complaint', colorHex: '#FFD43B', sortOrder: 3),
        const CategoryDefinition(id: 'cat-payment-issue', name: 'Payment Issue', colorHex: '#69DB7C', sortOrder: 4),
        const CategoryDefinition(id: 'cat-wallet-issue', name: 'Wallet Issue', colorHex: '#38D9A9', sortOrder: 5),
        const CategoryDefinition(id: 'cat-billing-issue', name: 'Billing Issue', colorHex: '#4FD1C5', sortOrder: 6),
        const CategoryDefinition(id: 'cat-promotion-issue', name: 'Promotion Issue', colorHex: '#4ECDC4', sortOrder: 7),
        const CategoryDefinition(id: 'cat-lost-found', name: 'Lost & Found', colorHex: '#74C0FC', sortOrder: 8),
        const CategoryDefinition(id: 'cat-technical-problem', name: 'Technical Problem', colorHex: '#A78BFA', sortOrder: 9),
        const CategoryDefinition(id: 'cat-account-verification', name: 'Account Verification', colorHex: '#DA70D6', sortOrder: 10),
        const CategoryDefinition(id: 'cat-fraud-report', name: 'Fraud Report', colorHex: '#F06595', isSafetyCritical: true, sortOrder: 11),
        const CategoryDefinition(id: 'cat-safety-incident', name: 'Safety Incident', colorHex: '#E03131', isSafetyCritical: true, sortOrder: 12),
      ],
      teams: [
        const TeamDefinition(id: 'team-ride-ops', name: 'Ride Operations', sortOrder: 1),
        const TeamDefinition(id: 'team-payments', name: 'Payments', sortOrder: 2),
        const TeamDefinition(id: 'team-finance', name: 'Finance', sortOrder: 3),
        const TeamDefinition(id: 'team-tech-support', name: 'Technical Support', sortOrder: 4),
        const TeamDefinition(id: 'team-fraud', name: 'Fraud', sortOrder: 5),
        const TeamDefinition(id: 'team-safety', name: 'Safety', sortOrder: 6),
        const TeamDefinition(id: 'team-fleet-ops', name: 'Fleet Operations', sortOrder: 7),
      ],
      customerTypes: [
        const CustomerTypeDefinition(id: 'cust-passenger', name: 'Passenger', sortOrder: 1),
        const CustomerTypeDefinition(id: 'cust-driver', name: 'Driver', sortOrder: 2),
        const CustomerTypeDefinition(id: 'cust-fleet-operator', name: 'Fleet Operator', sortOrder: 3),
        const CustomerTypeDefinition(id: 'cust-merchant', name: 'Merchant', sortOrder: 4),
        const CustomerTypeDefinition(id: 'cust-admin', name: 'Admin', sortOrder: 5),
      ],
      createdAt: now,
      updatedAt: now,
    );
  }

  static SupportDomain createEcommerceDomain() {
    final now = DateTime.now();
    return SupportDomain(
      id: 'domain-ecommerce',
      name: 'E-Commerce Support',
      description: 'Support system for online retail operations',
      categories: [
        const CategoryDefinition(id: 'cat-order-issue', name: 'Order Issue', colorHex: '#FF6B6B', sortOrder: 1),
        const CategoryDefinition(id: 'cat-shipping-delay', name: 'Shipping Delay', colorHex: '#FFA94D', sortOrder: 2),
        const CategoryDefinition(id: 'cat-product-defect', name: 'Product Defect', colorHex: '#FFD43B', sortOrder: 3),
        const CategoryDefinition(id: 'cat-return-request', name: 'Return Request', colorHex: '#69DB7C', sortOrder: 4),
        const CategoryDefinition(id: 'cat-refund-request', name: 'Refund Request', colorHex: '#38D9A9', sortOrder: 5),
        const CategoryDefinition(id: 'cat-payment-issue', name: 'Payment Issue', colorHex: '#4FD1C5', sortOrder: 6),
        const CategoryDefinition(id: 'cat-account-issue', name: 'Account Issue', colorHex: '#74C0FC', sortOrder: 7),
        const CategoryDefinition(id: 'cat-technical-problem', name: 'Technical Problem', colorHex: '#A78BFA', sortOrder: 8),
        const CategoryDefinition(id: 'cat-fraud-report', name: 'Fraud Report', colorHex: '#F06595', isSafetyCritical: true, sortOrder: 9),
      ],
      teams: [
        const TeamDefinition(id: 'team-orders', name: 'Orders', sortOrder: 1),
        const TeamDefinition(id: 'team-shipping', name: 'Shipping', sortOrder: 2),
        const TeamDefinition(id: 'team-returns', name: 'Returns', sortOrder: 3),
        const TeamDefinition(id: 'team-payments', name: 'Payments', sortOrder: 4),
        const TeamDefinition(id: 'team-tech-support', name: 'Technical Support', sortOrder: 5),
        const TeamDefinition(id: 'team-fraud', name: 'Fraud', sortOrder: 6),
      ],
      customerTypes: [
        const CustomerTypeDefinition(id: 'cust-buyer', name: 'Buyer', sortOrder: 1),
        const CustomerTypeDefinition(id: 'cust-seller', name: 'Seller', sortOrder: 2),
        const CustomerTypeDefinition(id: 'cust-vendor', name: 'Vendor', sortOrder: 3),
        const CustomerTypeDefinition(id: 'cust-admin', name: 'Admin', sortOrder: 4),
      ],
      createdAt: now,
      updatedAt: now,
    );
  }

  static SupportDomain createSaasDomain() {
    final now = DateTime.now();
    return SupportDomain(
      id: 'domain-saas',
      name: 'SaaS Support',
      description: 'Support system for software-as-a-service products',
      categories: [
        const CategoryDefinition(id: 'cat-bug-report', name: 'Bug Report', colorHex: '#FF6B6B', sortOrder: 1),
        const CategoryDefinition(id: 'cat-feature-request', name: 'Feature Request', colorHex: '#FFA94D', sortOrder: 2),
        const CategoryDefinition(id: 'cat-integration-issue', name: 'Integration Issue', colorHex: '#FFD43B', sortOrder: 3),
        const CategoryDefinition(id: 'cat-billing-issue', name: 'Billing Issue', colorHex: '#69DB7C', sortOrder: 4),
        const CategoryDefinition(id: 'cat-account-access', name: 'Account Access', colorHex: '#38D9A9', sortOrder: 5),
        const CategoryDefinition(id: 'cat-performance-issue', name: 'Performance Issue', colorHex: '#4FD1C5', sortOrder: 6),
        const CategoryDefinition(id: 'cat-security-concern', name: 'Security Concern', colorHex: '#F06595', isSafetyCritical: true, sortOrder: 7),
        const CategoryDefinition(id: 'cat-data-export', name: 'Data Export', colorHex: '#74C0FC', sortOrder: 8),
      ],
      teams: [
        const TeamDefinition(id: 'team-engineering', name: 'Engineering', sortOrder: 1),
        const TeamDefinition(id: 'team-customer-success', name: 'Customer Success', sortOrder: 2),
        const TeamDefinition(id: 'team-billing', name: 'Billing', sortOrder: 3),
        const TeamDefinition(id: 'team-security', name: 'Security', sortOrder: 4),
        const TeamDefinition(id: 'team-enterprise', name: 'Enterprise Support', sortOrder: 5),
      ],
      customerTypes: [
        const CustomerTypeDefinition(id: 'cust-end-user', name: 'End User', sortOrder: 1),
        const CustomerTypeDefinition(id: 'cust-admin', name: 'Admin', sortOrder: 2),
        const CustomerTypeDefinition(id: 'cust-developer', name: 'Developer', sortOrder: 3),
        const CustomerTypeDefinition(id: 'cust-enterprise', name: 'Enterprise', sortOrder: 4),
      ],
      createdAt: now,
      updatedAt: now,
    );
  }

  static SupportDomain createHealthcareDomain() {
    final now = DateTime.now();
    return SupportDomain(
      id: 'domain-healthcare',
      name: 'Healthcare Support',
      description: 'Support system for healthcare services',
      categories: [
        const CategoryDefinition(id: 'cat-appointment-issue', name: 'Appointment Issue', colorHex: '#FF6B6B', sortOrder: 1),
        const CategoryDefinition(id: 'cat-prescription-question', name: 'Prescription Question', colorHex: '#FFA94D', sortOrder: 2),
        const CategoryDefinition(id: 'cat-lab-results', name: 'Lab Results', colorHex: '#FFD43B', sortOrder: 3),
        const CategoryDefinition(id: 'cat-insurance-billing', name: 'Insurance & Billing', colorHex: '#69DB7C', sortOrder: 4),
        const CategoryDefinition(id: 'cat-telehealth-issue', name: 'Telehealth Issue', colorHex: '#38D9A9', sortOrder: 5),
        const CategoryDefinition(id: 'cat-medical-record', name: 'Medical Record', colorHex: '#4FD1C5', sortOrder: 6),
        const CategoryDefinition(id: 'cat-urgent-care', name: 'Urgent Care', colorHex: '#E03131', isSafetyCritical: true, sortOrder: 7),
        const CategoryDefinition(id: 'cat-emergency', name: 'Emergency', colorHex: '#C92A2A', isSafetyCritical: true, sortOrder: 8),
      ],
      teams: [
        const TeamDefinition(id: 'team-clinical', name: 'Clinical Support', sortOrder: 1),
        const TeamDefinition(id: 'team-billing', name: 'Billing', sortOrder: 2),
        const TeamDefinition(id: 'team-it-support', name: 'IT Support', sortOrder: 3),
        const TeamDefinition(id: 'team-patient-services', name: 'Patient Services', sortOrder: 4),
        const TeamDefinition(id: 'team-emergency', name: 'Emergency Response', sortOrder: 5),
      ],
      customerTypes: [
        const CustomerTypeDefinition(id: 'cust-patient', name: 'Patient', sortOrder: 1),
        const CustomerTypeDefinition(id: 'cust-provider', name: 'Healthcare Provider', sortOrder: 2),
        const CustomerTypeDefinition(id: 'cust-insurer', name: 'Insurance Company', sortOrder: 3),
        const CustomerTypeDefinition(id: 'cust-admin', name: 'Admin', sortOrder: 4),
      ],
      createdAt: now,
      updatedAt: now,
    );
  }

  static List<SupportDomain> getAllPresets() {
    return [
      createRideSupportDomain(),
      createEcommerceDomain(),
      createSaasDomain(),
      createHealthcareDomain(),
    ];
  }
}
