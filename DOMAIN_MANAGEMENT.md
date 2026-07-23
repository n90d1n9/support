# Domain Management Feature

## Overview

The support system has been enhanced with **dynamic domain management**, making it no longer specific to only driving/ride-support use cases. The domain configuration is now dynamic and can be customized for different industries and business types.

## Key Changes

### 1. New Model: `domain_config.dart`

Created a flexible domain configuration model with:

- **SupportDomain**: Main configuration class containing:
  - Unique ID, name, and description
  - Dynamic list of categories
  - Dynamic list of teams
  - Dynamic list of customer types
  - Metadata map for extensibility
  - Timestamps for tracking changes

- **CategoryDefinition**: Configurable ticket categories with:
  - Custom ID, name, and description
  - Color coding (hex)
  - Safety critical flag
  - Sort order
  - Metadata

- **TeamDefinition**: Configurable support teams with:
  - Custom ID, name, and description
  - Color coding
  - Sort order
  - Metadata

- **CustomerTypeDefinition**: Configurable customer types with:
  - Custom ID, name, and description
  - Icon support
  - Sort order
  - Metadata

### 2. Pre-built Domain Presets

Four ready-to-use domain configurations:

1. **Ride Support** (default)
   - Categories: Ride Issue, Driver Complaint, Passenger Complaint, Payment Issue, Wallet Issue, Billing Issue, Promotion Issue, Lost & Found, Technical Problem, Account Verification, Fraud Report, Safety Incident
   - Teams: Ride Operations, Payments, Finance, Technical Support, Fraud, Safety, Fleet Operations
   - Customer Types: Passenger, Driver, Fleet Operator, Merchant, Admin

2. **E-Commerce Support**
   - Categories: Order Issue, Shipping Delay, Product Defect, Return Request, Refund Request, Payment Issue, Account Issue, Technical Problem, Fraud Report
   - Teams: Orders, Shipping, Returns, Payments, Technical Support, Fraud
   - Customer Types: Buyer, Seller, Vendor, Admin

3. **SaaS Support**
   - Categories: Bug Report, Feature Request, Integration Issue, Billing Issue, Account Access, Performance Issue, Security Concern, Data Export
   - Teams: Engineering, Customer Success, Billing, Security, Enterprise Support
   - Customer Types: End User, Admin, Developer, Enterprise

4. **Healthcare Support**
   - Categories: Appointment Issue, Prescription Question, Lab Results, Insurance & Billing, Telehealth Issue, Medical Record, Urgent Care, Emergency
   - Teams: Clinical Support, Billing, IT Support, Patient Services, Emergency Response
   - Customer Types: Patient, Healthcare Provider, Insurance Company, Admin

### 3. Provider Layer: `domain_providers.dart`

State management for domain configuration:

- **domainProvider**: Main state notifier for active domain
- **isDomainConfiguredProvider**: Boolean flag for domain status
- **activeDomainNameProvider**: Returns current domain name
- **domainPresetsProvider**: List of available presets
- **domainCategoriesProvider**: Quick access to categories
- **domainTeamsProvider**: Quick access to teams
- **domainCustomerTypesProvider**: Quick access to customer types
- Family providers for lookup by ID

Operations supported:
- Set active domain
- Load from preset
- Add/update/remove categories
- Add/update/remove teams
- Add/update/remove customer types
- Reset to preset

### 4. Updated Components

#### main.dart
- Imports domain providers
- App title now reflects active domain name
- Auto-initializes with Ride Support domain on first launch

#### app_shell.dart
- Displays active domain name in app bar
- Dynamically updates based on selected domain

#### settings_screen.dart
- New "Domain Configuration" section at the top
- Shows current domain info with stats
- Dropdown to select from presets
- Buttons for custom domain creation and management
- Visual management dialog for categories and teams

## Usage Examples

### Switching Domains Programmatically

```dart
// Load a preset
ref.read(domainProvider.notifier).loadFromPreset('domain-ecommerce');

// Or set directly
final domain = DomainPresets.createSaasDomain();
ref.read(domainProvider.notifier).setActiveDomain(domain);
```

### Accessing Domain Data

```dart
// Get current domain
final domain = ref.watch(domainProvider);

// Get domain name
final name = ref.watch(activeDomainNameProvider);

// Get categories
final categories = ref.watch(domainCategoriesProvider);

// Get specific category
final category = ref.watch(domainCategoryByIdProvider('cat-order-issue'));
```

### Customizing Categories

```dart
// Add a new category
final newCategory = CategoryDefinition(
  id: 'cat-custom',
  name: 'Custom Issue',
  colorHex: '#FF5733',
  sortOrder: 99,
);
ref.read(domainProvider.notifier).addCategory(newCategory);

// Update existing
final updated = category.copyWith(name: 'Updated Name');
ref.read(domainProvider.notifier).updateCategory(category.id, updated);

// Remove
ref.read(domainProvider.notifier).removeCategory(category.id);
```

## Benefits

1. **Multi-Industry Support**: Can be used for ride-sharing, e-commerce, SaaS, healthcare, or any other industry
2. **Customizable**: Businesses can define their own categories, teams, and customer types
3. **Quick Setup**: Pre-built presets for common use cases
4. **Dynamic UI**: App title and configuration adapt to selected domain
5. **Extensible**: Metadata maps allow for future enhancements without breaking changes
6. **Type-Safe**: Strong typing ensures configuration integrity

## Migration Notes

- Existing functionality remains unchanged
- Default behavior loads Ride Support domain for backward compatibility
- All existing enums (TicketCategory, SupportTeam, CustomerType) are still present but can be supplemented with dynamic definitions
- Future iterations could migrate fully to dynamic definitions

## Files Modified/Created

### Created:
- `/workspace/lib/models/domain_config.dart` - Domain models and presets
- `/workspace/lib/providers/domain_providers.dart` - State management

### Modified:
- `/workspace/lib/main.dart` - Domain initialization and title
- `/workspace/lib/screens/app_shell.dart` - Dynamic domain name display
- `/workspace/lib/screens/settings_screen.dart` - Domain management UI
