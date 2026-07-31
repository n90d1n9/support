import 'package:flutter/material.dart';

import 'skill_matrix_widget.dart';
import '../../settings/widgets/setting_card.dart';

class SkillMatrixSection extends StatelessWidget {
  const SkillMatrixSection({super.key});

  @override
  Widget build(BuildContext ctx) {
    return const SettingsCard(
      title: 'Agent Skill Matrix',
      icon: Icons.grid_on_rounded,
      child: SkillMatrixWidget(),
    );
  }
}
