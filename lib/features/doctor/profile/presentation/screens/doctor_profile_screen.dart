import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:serfix/app/routing/routes.dart';
import 'package:serfix/features/auth/presentation/cubit/auth_cubit.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<AuthCubit, UserAuthState>(
      builder: (context, state) {
        String name = 'Doctor';
        String email = '';

        if (state is AuthAuthenticated) {
          name = state.user.fullName;
          email = state.user.email;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Medical Professional',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Menu Items
              _buildMenuItem(
                context,
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: () => context.push(Routes.doctorEditProfile),
              ),
              _buildMenuItem(
                context,
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () => context.push(Routes.doctorSettings),
              ),
              _buildMenuItem(
                context,
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () => context.push(Routes.doctorHelp),
              ),
              _buildMenuItem(
                context,
                icon: Icons.info_outline,
                title: 'About Serfix',
                onTap: () => _showAboutDialog(context),
              ),

              const SizedBox(height: 16),

              // Sign Out Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showSignOutDialog(context),
                  icon: Icon(Icons.logout, color: colorScheme.error),
                  label: Text(
                    'Sign Out',
                    style: TextStyle(color: colorScheme.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: colorScheme.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // App Version
              Text(
                'Serfix v1.0.0',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colorScheme.onSurfaceVariant),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: colorScheme.surface,
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().signOut();
            },
            child: Text(
              'Sign Out',
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.medical_services_outlined, color: colorScheme.primary),
            const SizedBox(width: 8),
            const Text('About Serfix'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI-Powered Cervical Cancer Screening',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Text(
              'Serfix uses advanced AI technology to assist medical professionals in cervical cancer screening. Our YOLO-based model analyzes images to detect potential abnormalities.',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Version 1.0.0',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
