import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/domain_config.dart';

/// Provider for managing the active support domain
class DomainNotifier extends StateNotifier<SupportDomain?> {
  DomainNotifier() : super(null);

  void setActiveDomain(SupportDomain domain) {
    state = domain;
  }

  void loadFromPreset(String presetId) {
    final presets = DomainPresets.getAllPresets();
    try {
      final domain = presets.firstWhere((d) => d.id == presetId);
      state = domain;
    } catch (_) {
      // If preset not found, keep current state
    }
  }

  SupportDomain? get activeDomain => state;

  bool get isDomainConfigured => state != null;

  String get activeDomainName => state?.name ?? 'Support Platform';

  List<CategoryDefinition> get categories => state?.categories ?? [];

  List<TeamDefinition> get teams => state?.teams ?? [];

  List<CustomerTypeDefinition> get customerTypes => state?.customerTypes ?? [];

  CategoryDefinition? getCategoryById(String id) => state?.getCategoryById(id);

  TeamDefinition? getTeamById(String id) => state?.getTeamById(id);

  CustomerTypeDefinition? getCustomerTypeById(String id) =>
      state?.getCustomerTypeById(id);

  void addCategory(CategoryDefinition category) {
    final currentState = state;
    if (currentState == null) return;
    state = currentState.copyWith(
      categories: [...currentState.categories, category],
      updatedAt: DateTime.now(),
    );
  }

  void updateCategory(String categoryId, CategoryDefinition updates) {
    final currentState = state;
    if (currentState == null) return;
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
  }

  void removeCategory(String categoryId) {
    final currentState = state;
    if (currentState == null) return;
    state = currentState.copyWith(
      categories: currentState.categories.where((c) => c.id != categoryId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  void addTeam(TeamDefinition team) {
    final currentState = state;
    if (currentState == null) return;
    state = currentState.copyWith(
      teams: [...currentState.teams, team],
      updatedAt: DateTime.now(),
    );
  }

  void updateTeam(String teamId, TeamDefinition updates) {
    final currentState = state;
    if (currentState == null) return;
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
  }

  void removeTeam(String teamId) {
    final currentState = state;
    if (currentState == null) return;
    state = currentState.copyWith(
      teams: currentState.teams.where((t) => t.id != teamId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  void addCustomerType(CustomerTypeDefinition customerType) {
    final currentState = state;
    if (currentState == null) return;
    state = currentState.copyWith(
      customerTypes: [...currentState.customerTypes, customerType],
      updatedAt: DateTime.now(),
    );
  }

  void updateCustomerType(String customerTypeId, CustomerTypeDefinition updates) {
    final currentState = state;
    if (currentState == null) return;
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
  }

  void removeCustomerType(String customerTypeId) {
    final currentState = state;
    if (currentState == null) return;
    state = currentState.copyWith(
      customerTypes: currentState.customerTypes.where((c) => c.id != customerTypeId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  void resetToPreset(String presetId) {
    loadFromPreset(presetId);
  }
}

final domainProvider =
    StateNotifierProvider<DomainNotifier, SupportDomain?>((_) => DomainNotifier());

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
final domainCustomerTypesProvider = Provider<List<CustomerTypeDefinition>>((ref) {
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
