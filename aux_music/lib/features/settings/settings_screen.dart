import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/di/providers.dart';
import '../../core/providers/library_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final reduceMotion = ref.watch(reduceMotionProvider);
    final offlineMode = ref.watch(offlineModeProvider);
    final healthStatuses = ref.watch(sourceHealthProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AuxSpacing.sm),
        children: [
          // ── Appearance ──────────────────────────────────────────
          const _SectionHeader('Appearance'),
          SwitchListTile(
            title: Text(
              'Dark mode',
              style: AuxTypography.body.copyWith(color: AuxColors.paper),
            ),
            value: themeMode == ThemeMode.dark,
            onChanged: (on) => ref.read(themeModeProvider.notifier).state =
                on ? ThemeMode.dark : ThemeMode.light,
            activeColor: AuxColors.signalTeal,
          ),
          SwitchListTile(
            title: Text(
              'Reduce motion',
              style: AuxTypography.body.copyWith(color: AuxColors.paper),
            ),
            subtitle: Text(
              'Disables the Now Playing pulse ring and parallax effects',
              style: AuxTypography.caption.copyWith(color: AuxColors.paperMuted),
            ),
            value: reduceMotion,
            onChanged: (on) =>
                ref.read(reduceMotionProvider.notifier).state = on,
            activeColor: AuxColors.signalTeal,
          ),

          // ── Data & Offline ──────────────────────────────────────
          const _SectionHeader('Data & Offline'),
          SwitchListTile(
            title: Text(
              'Force offline mode',
              style: AuxTypography.body.copyWith(color: AuxColors.paper),
            ),
            subtitle: Text(
              'Only play downloaded tracks, save data',
              style: AuxTypography.caption.copyWith(color: AuxColors.paperMuted),
            ),
            value: offlineMode,
            onChanged: (on) =>
                ref.read(offlineModeProvider.notifier).state = on,
            activeColor: AuxColors.signalTeal,
          ),
          ListTile(
            title: Text(
              'Export downloaded library',
              style: AuxTypography.body.copyWith(color: AuxColors.paper),
            ),
            subtitle: Text(
              'Generate an .m3u playlist of all offline tracks',
              style: AuxTypography.caption.copyWith(color: AuxColors.paperMuted),
            ),
            trailing: const Icon(Icons.download_rounded, color: AuxColors.paperMuted),
            onTap: () async {
              try {
                final m3uContent = await ref.read(libraryRepositoryProvider).generateM3uExport();
                final tempDir = await getTemporaryDirectory();
                final file = File('${tempDir.path}/aux_music_offline.m3u');
                await file.writeAsString(m3uContent);
                
                // Share the file
                await Share.shareXFiles(
                  [XFile(file.path)],
                  text: 'My Aux Music Offline Library',
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export failed: $e')),
                  );
                }
              }
            },
          ),

          // ── Source Health ────────────────────────────────────────
          const _SectionHeader('Music Sources'),
          ...healthStatuses.map((status) => ListTile(
                title: Text(
                  status.displayName,
                  style: AuxTypography.body.copyWith(color: AuxColors.paper),
                ),
                subtitle: Text(
                  status.isHealthy
                      ? 'Online'
                      : status.errorMessage ?? 'Unavailable',
                  style: AuxTypography.caption.copyWith(
                    color: status.isHealthy
                        ? AuxColors.positive
                        : AuxColors.danger,
                  ),
                ),
                trailing: Icon(
                  status.isHealthy
                      ? Icons.check_circle_outline_rounded
                      : Icons.error_outline_rounded,
                  color: status.isHealthy ? AuxColors.positive : AuxColors.danger,
                ),
              )),

          // ── About ───────────────────────────────────────────────
          const _SectionHeader('About'),
          ListTile(
            title: Text(
              'Aux',
              style: AuxTypography.body.copyWith(color: AuxColors.paper),
            ),
            subtitle: Text(
              'Version 0.1.0 · 100% free, open music streaming',
              style: AuxTypography.caption.copyWith(color: AuxColors.paperMuted),
            ),
            leading: const Icon(Icons.info_outline_rounded,
                color: AuxColors.paperMuted),
          ),
          ListTile(
            title: Text(
              'Where does support go?',
              style: AuxTypography.body.copyWith(color: AuxColors.paper),
            ),
            subtitle: Text(
              'All costs are covered by the development team. Aux is and will remain free.',
              style: AuxTypography.caption.copyWith(color: AuxColors.paperMuted),
            ),
            leading: const Icon(Icons.volunteer_activism_outlined,
                color: AuxColors.paperMuted),
          ),

          const SizedBox(height: AuxSpacing.xxxl),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AuxSpacing.lg, AuxSpacing.xl, AuxSpacing.lg, AuxSpacing.xs,
      ),
      child: Text(
        title.toUpperCase(),
        style: AuxTypography.captionMedium.copyWith(
          color: AuxColors.ember,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
