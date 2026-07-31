import 'package:flutter/material.dart';

/// Knowledge article types for comprehensive knowledge management
enum KbArticleType {
  faq('FAQ', 'Frequently Asked Questions'),
  article('Article', 'General knowledge article'),
  companyProcedure('Company Procedure', 'Standard operating procedures'),
  rule('Rule', 'Company rules and regulations'),
  risk('Risk', 'Risk management and mitigation'),
  policy('Policy', 'Policy documents'),
  guideline('Guideline', 'Best practice guidelines'),
  troubleshooting('Troubleshooting', 'Troubleshooting guides'),
  internalProcedure('Internal Procedure', 'Internal team procedures'),
  decisionTree('Decision Tree', 'Decision-making flowcharts'),
  training('Training', 'Training materials'),
  compliance('Compliance', 'Compliance and regulatory information');

  final String label;
  final String description;
  const KbArticleType(this.label, this.description);

  /// Get icon for each article type
  IconData get icon {
    switch (this) {
      case KbArticleType.faq:
        return Icons.help_outline;
      case KbArticleType.article:
        return Icons.article_outlined;
      case KbArticleType.companyProcedure:
        return Icons.folder_open_outlined;
      case KbArticleType.rule:
        return Icons.gavel_outlined;
      case KbArticleType.risk:
        return Icons.warning_amber_outlined;
      case KbArticleType.policy:
        return Icons.policy_outlined;
      case KbArticleType.guideline:
        return Icons.lightbulb_outline;
      case KbArticleType.troubleshooting:
        return Icons.build_outlined;
      case KbArticleType.internalProcedure:
        return Icons.admin_panel_settings_outlined;
      case KbArticleType.decisionTree:
        return Icons.account_tree_outlined;
      case KbArticleType.training:
        return Icons.school_outlined;
      case KbArticleType.compliance:
        return Icons.verified_outlined;
    }
  }

  /// Color associated with each type for visual distinction
  int get colorValue {
    switch (this) {
      case KbArticleType.faq:
        return 0xFF2196F3; // Blue
      case KbArticleType.article:
        return 0xFF4CAF50; // Green
      case KbArticleType.companyProcedure:
        return 0xFF9C27B0; // Purple
      case KbArticleType.rule:
        return 0xFFF44336; // Red
      case KbArticleType.risk:
        return 0xFFFF9800; // Orange
      case KbArticleType.policy:
        return 0xFF3F51B5; // Indigo
      case KbArticleType.guideline:
        return 0xFF00BCD4; // Cyan
      case KbArticleType.troubleshooting:
        return 0xFF795548; // Brown
      case KbArticleType.internalProcedure:
        return 0xFF607D8B; // Blue Grey
      case KbArticleType.decisionTree:
        return 0xFFE91E63; // Pink
      case KbArticleType.training:
        return 0xFFFFC107; // Amber
      case KbArticleType.compliance:
        return 0xFF009688; // Teal
    }
  }

  /// Parse from string label
  static KbArticleType fromLabel(String label) {
    return KbArticleType.values.firstWhere(
      (e) => e.label.toLowerCase() == label.toLowerCase(),
      orElse: () => KbArticleType.article,
    );
  }
}
