import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/domain_config.dart';

/// Provider for managing the active support domain
class DomainNotifier extends StateNotifier<SupportDomain?> {
  DomainNotifier() : super(null);

  /// Set the active domain
  void setActiveDomain(SupportDomain domain) {
    state = domain;
  }

  /// Load domain from a preset by ID
  void loadFromPreset(String presetId) {
    final presets = DomainPresets.getAllPresets();
    try {
      final domain = presets.firstWhere((d) => d.id == presetId);
      state = domain;
    } catch (_) {
      // If preset not found, keep current state
    }
  }

  /// Get the active domain
  SupportDomain? get activeDomain => state;

  /// Check if a domain is configured
  bool get isDomainConfigured => state != null;

  /// Get the active domain name
  String get activeDomainName => state?.name ?? 'Support Platform';

  /// Get all categories
  List<CategoryDefinition> get categories => state?.categories ?? [];

  /// Get all teams
  List<TeamDefinition> get teams => state?.teams ?? [];

  /// Get all customer types
  List<CustomerTypeDefinition> get customerTypes => state?.customerTypes ?? [];

  /// Get category by ID
  CategoryDefinition? getCategoryById(String id) => state?.getCategoryById(id);

  /// Get team by ID
  TeamDefinition? getTeamById(String id) => state?.getTeamById(id);

  /// Get customer type by ID
  CustomerTypeDefinition? getCustomerTypeById(String id) =>
      state?.getCustomerTypeById(id);

  /// Get category by name (case-insensitive)
  CategoryDefinition? getCategoryByName(String name) =>
      state?.getCategoryByName(name);

  /// Get team by name (case-insensitive)
  TeamDefinition? getTeamByName(String name) => state?.getTeamByName(name);

  /// Get customer type by name (case-insensitive)
  CustomerTypeDefinition? getCustomerTypeByName(String name) =>
      state?.getCustomerTypeByName(name);

  /// Validate current domain configuration
  DomainValidationResult? validateDomain() => state?.validate();

  /// Add a new category with duplicate ID check
  bool addCategory(CategoryDefinition category) {
    final currentState = state;
    if (currentState == null) return false;
    
    // Check for duplicate ID
    if (currentState.getCategoryById(category.id) != null) {
      return false;
    }
    
    state = currentState.copyWith(
      categories: [...currentState.categories, category],
      updatedAt: DateTime.now(),
    );
    return true;
  }

  /// Update an existing category
  bool updateCategory(String categoryId, CategoryDefinition updates) {
    final currentState = state;
    if (currentState == null) return false;
    
    // Check if category exists
    if (currentState.getCategoryById(categoryId) == null) {
      return false;
    }
    
    final updatedCategories = currentState.categories.map((c) {
      if (c.id == categoryId) {
        return updates;
      }
      return c;
    }).toList();
    state = currentState.copyWith(
      categories: updatedCategories,
      updatedAt: DateTime.now(),
    );
    return true;
  }

  /// Remove a category by ID
  bool removeCategory(String categoryId) {
    final currentState = state;
    if (currentState == null) return false;
    
    final newCategories = currentState.categories
        .where((c) => c.id != categoryId)
        .toList();
    
    if (newCategories.length == currentState.categories.length) {
      return false; // Category not found
    }
    
    state = currentState.copyWith(
      categories: newCategories,
      updatedAt: DateTime.now(),
    );
    return true;
  }

  /// Add a new team with duplicate ID check
  bool addTeam(TeamDefinition team) {
    final currentState = state;
    if (currentState == null) return false;
    
    // Check for duplicate ID
    if (currentState.getTeamById(team.id) != null) {
      return false;
    }
    
    state = currentState.copyWith(
      teams: [...currentState.teams, team],
      updatedAt: DateTime.now(),
    );
    return true;
  }

  /// Update an existing team
  bool updateTeam(String teamId, TeamDefinition updates) {
    final currentState = state;
    if (currentState == null) return false;
    
    // Check if team exists
    if (currentState.getTeamById(teamId) == null) {
      return false;
    }
    
    final updatedTeams = currentState.teams.map((t) {
      if (t.id == teamId) {
        return updates;
      }
      return t;
    }).toList();
    state = currentState.copyWith(
      teams: updatedTeams,
      updatedAt: DateTime.now(),
    );
    return true;
  }

  /// Remove a team by ID
  bool removeTeam(String teamId) {
    final currentState = state;
    if (currentState == null) return false;
    
    final newTeams = currentState.teams.where((t) => t.id != teamId).toList();
    
    if (newTeams.length == currentState.teams.length) {
      return false; // Team not found
    }
    
    state = currentState.copyWith(
      teams: newTeams,
      updatedAt: DateTime.now(),
    );
    return true;
  }

  /// Add a new customer type with duplicate ID check
  bool addCustomerType(CustomerTypeDefinition customerType) {
    final currentState = state;
    if (currentState == null) return false;
    
    // Check for duplicate ID
    if (currentState.getCustomerTypeById(customerType.id) != null) {
      return false;
    }
    
    state = currentState.copyWith(
      customerTypes: [...currentState.customerTypes, customerType],
      updatedAt: DateTime.now(),
    );
    return true;
  }

  /// Update an existing customer type
  bool updateCustomerType(
      String customerTypeId, CustomerTypeDefinition updates) {
    final currentState = state;
    if (currentState == null) return false;
    
    // Check if customer type exists
    if (currentState.getCustomerTypeById(customerTypeId) == null) {
      return false;
    }
    
    final updatedCustomerTypes = currentState.customerTypes.map((c) {
      if (c.id == customerTypeId) {
        return updates;
      }
      return c;
    }).toList();
    state = currentState.copyWith(
      customerTypes: updatedCustomerTypes,
      updatedAt: DateTime.now(),
    );
    return true;
  }

  /// Remove a customer type by ID
  bool removeCustomerType(String customerTypeId) {
    final currentState = state;
    if (currentState == null) return false;
    
    final newCustomerTypes = currentState.customerTypes
        .where((c) => c.id != customerTypeId)
        .toList();
    
    if (newCustomerTypes.length == currentState.customerTypes.length) {
      return false; // Customer type not found
    }
    
    state = currentState.copyWith(
      customerTypes: newCustomerTypes,
      updatedAt: DateTime.now(),
    );
    return true;
  }

  /// Reset to a preset configuration
  void resetToPreset(String presetId) {
    loadFromPreset(presetId);
  }

  /// Import domain from JSON
  bool importFromJson(Map<String, dynamic> json) {
    try {
      final domain = SupportDomain.fromJson(json);
      state = domain;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Export current domain to JSON
  Map<String, dynamic>? exportToJson() {
    return state?.toJson();
  }
}

final domainProvider = StateNotifierProvider<DomainNotifier, SupportDomain?>(
    (_) => DomainNotifier());

/// Provider that returns true if a domain is configured
final isDomainConfiguredProvider = Provider<bool>((ref) {
  return ref.watch(domainProvider) != null;
});

/// Provider that returns the active domain name
final activeDomainNameProvider = Provider<String>((ref) {
  return ref.watch(domainProvider)?.name ?? 'Support Platform';
});

/// Provider that returns the list of available domain presets
final domainPresetsProvider = Provider<List<SupportDomain>>((ref) {
  return DomainPresets.getAllPresets();
});

/// Provider for quick access to categories
final domainCategoriesProvider = Provider<List<CategoryDefinition>>((ref) {
  return ref.watch(domainProvider)?.categories ?? [];
});

/// Provider for quick access to teams
final domainTeamsProvider = Provider<List<TeamDefinition>>((ref) {
  return ref.watch(domainProvider)?.teams ?? [];
});

/// Provider for quick access to customer types
final domainCustomerTypesProvider =
    Provider<List<CustomerTypeDefinition>>((ref) {
  return ref.watch(domainProvider)?.customerTypes ?? [];
});

/// Family provider to get a category by ID
final domainCategoryByIdProvider =
    Provider.family<CategoryDefinition?, String>((ref, id) {
  return ref.watch(domainProvider)?.getCategoryById(id);
});

/// Family provider to get a team by ID
final domainTeamByIdProvider =
    Provider.family<TeamDefinition?, String>((ref, id) {
  return ref.watch(domainProvider)?.getTeamById(id);
});

/// Family provider to get a customer type by ID
final domainCustomerTypeByIdProvider =
    Provider.family<CustomerTypeDefinition?, String>((ref, id) {
  return ref.watch(domainProvider)?.getCustomerTypeById(id);
});
