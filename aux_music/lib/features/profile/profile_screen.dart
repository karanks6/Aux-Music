import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/di/providers.dart';
import '../../core/providers/library_providers.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final reduceMotion = ref.watch(reduceMotionProvider);
    final offlineMode = ref.watch(offlineModeProvider);
    final healthStatuses = ref.watch(sourceHealthProvider);
    final user = ref.watch(authServiceProvider);

    final String displayName = user.displayName;
    final String email = ref.read(authStateProvider).valueOrNull?.email ?? 'No email';
    final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: context.colors.ink,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: context.colors.ink,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AuxSpacing.sm),
        children: [
          // ── Profile Header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AuxSpacing.xl),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AuxColors.signalTeal.withOpacity(0.15),
                  child: Text(
                    initial,
                    style: AuxTypography.display.copyWith(
                      color: AuxColors.signalTeal,
                      fontSize: 32,
                    ),
                  ),
                ),
                const SizedBox(width: AuxSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: AuxTypography.titleMd.copyWith(color: context.colors.paper),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: AuxTypography.body.copyWith(color: context.colors.paperMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Divider(color: context.colors.hairline),

          // ── Appearance ──────────────────────────────────────────
          const _SectionHeader('Appearance'),
          SwitchListTile(
            title: Text(
              'Dark mode',
              style: AuxTypography.body.copyWith(color: context.colors.paper),
            ),
            value: themeMode == ThemeMode.dark,
            onChanged: (on) => ref.read(themeModeProvider.notifier).state =
                on ? ThemeMode.dark : ThemeMode.light,
            activeColor: AuxColors.ember,
          ),
          SwitchListTile(
            title: Text(
              'Reduce motion',
              style: AuxTypography.body.copyWith(color: context.colors.paper),
            ),
            subtitle: Text(
              'Disables the Now Playing pulse ring and parallax effects',
              style: AuxTypography.caption.copyWith(color: context.colors.paperMuted),
            ),
            value: reduceMotion,
            onChanged: (on) =>
                ref.read(reduceMotionProvider.notifier).state = on,
            activeColor: AuxColors.ember,
          ),

          // ── Data & Offline ──────────────────────────────────────
          const _SectionHeader('Data & Offline'),
          SwitchListTile(
            title: Text(
              'Force offline mode',
              style: AuxTypography.body.copyWith(color: context.colors.paper),
            ),
            subtitle: Text(
              'Only play downloaded tracks, save data',
              style: AuxTypography.caption.copyWith(color: context.colors.paperMuted),
            ),
            value: offlineMode,
            onChanged: (on) =>
                ref.read(offlineModeProvider.notifier).state = on,
            activeColor: AuxColors.ember,
          ),
          ListTile(
            title: Text(
              'Export downloaded library',
              style: AuxTypography.body.copyWith(color: context.colors.paper),
            ),
            subtitle: Text(
              'Generate an .m3u playlist of all offline tracks',
              style: AuxTypography.caption.copyWith(color: context.colors.paperMuted),
            ),
            trailing: Icon(Icons.download_rounded, color: context.colors.paperMuted),
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
                  style: AuxTypography.body.copyWith(color: context.colors.paper),
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

          // ── Account ──────────────────────────────────────────────
          const _SectionHeader('Account'),
          ListTile(
            title: Text(
              'Sign Out',
              style: AuxTypography.body.copyWith(color: AuxColors.danger),
            ),
            leading: const Icon(Icons.logout_rounded, color: AuxColors.danger),
            onTap: () async {
              await ref.read(authServiceProvider).signOut();
            },
          ),

          // ── About ───────────────────────────────────────────────
          const _SectionHeader('About'),
          ListTile(
            title: Text(
              'App Version',
              style: AuxTypography.body.copyWith(color: context.colors.paper),
            ),
            subtitle: Text(
              '0.1.0',
              style: AuxTypography.caption.copyWith(color: context.colors.paperMuted),
            ),
            leading: Icon(Icons.info_outline_rounded, color: context.colors.paperMuted),
          ),
          ListTile(
            title: Text(
              'Developer',
              style: AuxTypography.body.copyWith(color: context.colors.paper),
            ),
            subtitle: Text(
              'Karan S Suvarna',
              style: AuxTypography.caption.copyWith(color: context.colors.paperMuted),
            ),
            leading: Icon(Icons.person_outline_rounded, color: context.colors.paperMuted),
          ),
          ListTile(
            title: Text(
              'Contact',
              style: AuxTypography.body.copyWith(color: context.colors.paper),
            ),
            subtitle: Text(
              'suvarnakaran77@gmail.com',
              style: AuxTypography.caption.copyWith(color: context.colors.paperMuted),
            ),
            leading: Icon(Icons.email_outlined, color: context.colors.paperMuted),
          ),
          ListTile(
            title: Text(
              'GitHub',
              style: AuxTypography.body.copyWith(color: context.colors.paper),
            ),
            subtitle: Text(
              'https://github.com/karanks6',
              style: AuxTypography.caption.copyWith(color: context.colors.paperMuted),
            ),
            leading: Icon(Icons.code_rounded, color: context.colors.paperMuted),
            onTap: () async {
              final url = Uri.parse('https://github.com/karanks6');
              try {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } catch (e) {
                debugPrint('Could not launch GitHub: $e');
              }
            },
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
