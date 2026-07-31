import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/app_constants.dart';
import '../../api_key/widgets/api_key_section.dart';
import '../../domain/widgets/domain_section.dart';
import '../../operation/widgets/business_hours_section.dart';
import '../../operation/widgets/export_section.dart';
import '../../operation/widgets/workflow_section.dart';
import '../../team/widgets/skill_matrix_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.bg,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          DomainSection(),
          SizedBox(height: 14),
          ApiKeySection(),
          SizedBox(height: 14),
          BusinessHoursSection(),
          SizedBox(height: 14),
          SkillMatrixSection(),
          SizedBox(height: 14),
          WorkflowSection(),
          SizedBox(height: 14),
          ExportSection(),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}

extension SettingsExtensions on BuildContext {
  /// Show a settings toast message
  void showSettingsToast(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
