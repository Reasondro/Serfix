import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:serfix/app/routing/routes.dart';
import 'package:serfix/app/themes/app_colors.dart';
import 'package:serfix/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:serfix/features/doctor/screening/domain/entities/screening.dart';
import 'package:serfix/features/doctor/screening/domain/repositories/screening_repository.dart';
import 'package:serfix/features/doctor/screening/presentation/cubit/screening_cubit.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ScreeningCubit>().loadScreenings();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    String doctorName = 'Doctor';
    if (authState is AuthAuthenticated) {
      doctorName = authState.user.fullName;
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ScreeningCubit>().loadScreenings(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $doctorName',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cervical Cancer Screening Dashboard',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),

            // Stats Cards
            BlocBuilder<ScreeningCubit, ScreeningState>(
              builder: (context, state) {
                ScreeningStats stats = ScreeningStats.empty();
                if (state is ScreeningLoaded) {
                  stats = state.stats;
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            icon: Icons.camera_alt,
                            title: 'Today',
                            value: stats.todayCount.toString(),
                            subtitle: 'Screenings',
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            icon: Icons.pending_actions,
                            title: 'Pending',
                            value: stats.pendingCount.toString(),
                            subtitle: 'Results',
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            icon: Icons.check_circle,
                            title: 'Completed',
                            value: stats.completedThisWeek.toString(),
                            subtitle: 'This Week',
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            icon: Icons.warning_amber,
                            title: 'Abnormal',
                            value: stats.abnormalCount.toString(),
                            subtitle: 'Detected',
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              icon: Icons.add_a_photo,
              title: 'New Screening',
              subtitle: 'Capture cervical image for AI analysis',
              onTap: () => context.go(Routes.doctorCapture),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              icon: Icons.history,
              title: 'View History',
              subtitle: 'Browse past screening results',
              onTap: () => context.go(Routes.doctorScreenings),
            ),

            const SizedBox(height: 32),

            // Recent Activity
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 16),

            BlocBuilder<ScreeningCubit, ScreeningState>(
              builder: (context, state) {
                if (state is ScreeningLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (state is ScreeningLoaded) {
                  final recentScreenings = state.screenings.take(5).toList();

                  if (recentScreenings.isEmpty) {
                    return _buildEmptyState();
                  }

                  return Column(
                    children: recentScreenings
                        .map((s) => _buildRecentScreeningCard(context, s))
                        .toList(),
                  );
                }

                if (state is ScreeningError) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text(state.message,
                            style: TextStyle(color: AppColors.error)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<ScreeningCubit>().loadScreenings(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return _buildEmptyState();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: AppColors.gray),
            const SizedBox(height: 12),
            Text(
              'No recent screenings',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentScreeningCard(BuildContext context, Screening screening) {
    final statusColor = _getStatusColor(screening.status);
    final classificationText = screening.result?.classification.displayName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push('${Routes.doctorScreenings}/${screening.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightGray),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getStatusIcon(screening.status),
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      screening.patientIdentifier ?? 'No Patient ID',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(screening.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      screening.status.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  if (classificationText != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      classificationText,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getClassificationColor(
                            screening.result!.classification),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ScreeningStatus status) {
    switch (status) {
      case ScreeningStatus.pending:
        return AppColors.warning;
      case ScreeningStatus.processing:
        return AppColors.info;
      case ScreeningStatus.completed:
        return AppColors.success;
      case ScreeningStatus.failed:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon(ScreeningStatus status) {
    switch (status) {
      case ScreeningStatus.pending:
        return Icons.hourglass_empty;
      case ScreeningStatus.processing:
        return Icons.sync;
      case ScreeningStatus.completed:
        return Icons.check_circle;
      case ScreeningStatus.failed:
        return Icons.error;
    }
  }

  Color _getClassificationColor(dynamic classification) {
    final name = classification.toString().split('.').last;
    switch (name) {
      case 'normal':
        return AppColors.success;
      case 'abnormal':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightGray),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style:
                        TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.gray),
          ],
        ),
      ),
    );
  }
}
