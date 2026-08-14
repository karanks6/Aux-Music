import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key, this.sessionCode});
  final String? sessionCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pass the Aux'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Start a session',
            onPressed: () {
              // TODO: Start Pass the Aux session in Phase 2
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outlined,
              size: 64,
              color: context.colors.paperMuted.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AuxSpacing.lg),
            Text(
              sessionCode != null
                  ? 'Joining session "$sessionCode"…'
                  : 'Start a group session and share the code.',
              style: AuxTypography.body.copyWith(color: context.colors.paperMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
