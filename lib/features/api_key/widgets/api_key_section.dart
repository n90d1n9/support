import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/api_providers.dart';
import '../../../constants/app_constants.dart';
import '../../settings/widgets/setting_card.dart';

class ApiKeySection extends ConsumerStatefulWidget {
  const ApiKeySection();

  @override
  ConsumerState<ApiKeySection> createState() => _ApiKeySectionState();
}

class _ApiKeySectionState extends ConsumerState<ApiKeySection> {
  late TextEditingController _controller;
  bool _isObscured = true;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(apiKeyProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    final isConfigured = ref.watch(claudeServiceProvider).isConfigured;
    final statusColor =
        isConfigured ? const Color(0xFF7BD389) : const Color(0xFFFFA94D);

    return SettingsCard(
      title: 'Claude API Key',
      icon: Icons.key_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status indicator
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isConfigured
                      ? const Color(0xFF7BD389)
                      : const Color(0xFFFF5C72),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isConfigured
                    ? 'Connected — AI enabled'
                    : 'Not configured — using heuristics',
                style: TextStyle(
                  fontSize: 12.5,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // API Key input
          TextField(
            controller: _controller,
            obscureText: _isObscured,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'sk-ant-api03-…',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => setState(() => _isObscured = !_isObscured),
              ),
            ),
            onChanged: (_) => setState(() => _isSaved = false),
          ),

          const SizedBox(height: 10),

          // Actions
          Row(
            children: [
              FilledButton(
                onPressed: () {
                  ref.read(apiKeyProvider.notifier).state =
                      _controller.text.trim();
                  setState(() => _isSaved = true);
                },
                child: const Text('Save key'),
              ),
              const SizedBox(width: 8),
              if (_isSaved)
                const Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: Color(0xFF7BD389),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Saved',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF7BD389),
                      ),
                    ),
                  ],
                ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  _controller.clear();
                  ref.read(apiKeyProvider.notifier).state = '';
                  setState(() => _isSaved = false);
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
