import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serfix/app/themes/cubit/theme_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),
          const SizedBox(height: 8),
          _buildThemeSelector(context, colorScheme),

          const SizedBox(height: 24),

          // Notifications Section
          _buildSectionHeader(context, 'Notifications'),
          const SizedBox(height: 8),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            subtitle: 'Receive alerts when results are ready',
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Implement notification settings
              },
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.email_outlined,
            title: 'Email Notifications',
            subtitle: 'Get email summaries of screenings',
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // TODO: Implement email notification settings
              },
            ),
          ),

          const SizedBox(height: 24),

          // Privacy Section
          _buildSectionHeader(context, 'Privacy & Security'),
          const SizedBox(height: 8),
          _buildSettingsTile(
            context,
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: () {
              // TODO: Navigate to change password
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.fingerprint,
            title: 'Biometric Login',
            subtitle: 'Use fingerprint or face ID',
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // TODO: Implement biometric settings
              },
            ),
          ),

          const SizedBox(height: 24),

          // Data Section
          _buildSectionHeader(context, 'Data'),
          const SizedBox(height: 8),
          _buildSettingsTile(
            context,
            icon: Icons.storage_outlined,
            title: 'Clear Cache',
            subtitle: 'Free up storage space',
            onTap: () {
              _showClearCacheDialog(context);
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.download_outlined,
            title: 'Export Data',
            subtitle: 'Download your screening history',
            onTap: () {
              // TODO: Implement data export
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, ColorScheme colorScheme) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              _buildThemeOption(
                context,
                icon: Icons.brightness_auto,
                title: 'System',
                subtitle: 'Follow device settings',
                isSelected: state.themeMode == ThemeMode.system,
                onTap: () =>
                    context.read<ThemeCubit>().setThemeMode(ThemeMode.system),
              ),
              Divider(height: 1, color: colorScheme.outlineVariant),
              _buildThemeOption(
                context,
                icon: Icons.light_mode,
                title: 'Light',
                subtitle: 'Always use light theme',
                isSelected: state.themeMode == ThemeMode.light,
                onTap: () =>
                    context.read<ThemeCubit>().setThemeMode(ThemeMode.light),
              ),
              Divider(height: 1, color: colorScheme.outlineVariant),
              _buildThemeOption(
                context,
                icon: Icons.dark_mode,
                title: 'Dark',
                subtitle: 'Always use dark theme',
                isSelected: state.themeMode == ThemeMode.dark,
                onTap: () =>
                    context.read<ThemeCubit>().setThemeMode(ThemeMode.dark),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: colorScheme.primary)
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colorScheme.onSurfaceVariant, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: trailing ??
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will remove cached images and temporary files. Your screening data will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
