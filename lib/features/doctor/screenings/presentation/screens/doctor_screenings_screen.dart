import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:serfix/app/routing/routes.dart';
import 'package:serfix/app/themes/app_colors.dart';
import 'package:serfix/features/doctor/screening/domain/entities/screening.dart';
import 'package:serfix/features/doctor/screening/domain/entities/screening_result.dart';
import 'package:serfix/features/doctor/screening/presentation/cubit/screening_cubit.dart';

class DoctorScreeningsScreen extends StatefulWidget {
  const DoctorScreeningsScreen({super.key});

  @override
  State<DoctorScreeningsScreen> createState() => _DoctorScreeningsScreenState();
}

class _DoctorScreeningsScreenState extends State<DoctorScreeningsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    context.read<ScreeningCubit>().loadScreenings();
  }

  List<Screening> _filterScreenings(List<Screening> screenings) {
    var filtered = screenings;

    // Apply status filter
    if (_selectedFilter != 'all') {
      if (_selectedFilter == 'normal' || _selectedFilter == 'abnormal') {
        filtered = filtered.where((s) {
          if (s.result == null) return false;
          return s.result!.classification.name == _selectedFilter;
        }).toList();
      } else {
        filtered = filtered
            .where((s) => s.status.name == _selectedFilter)
            .toList();
      }
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((s) {
        final patientId = s.patientIdentifier?.toLowerCase() ?? '';
        final notes = s.notes?.toLowerCase() ?? '';
        return patientId.contains(query) || notes.contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and Filter Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search screenings...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.lightGray),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.lightGray),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Filter Chips
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildFilterChip('All', 'all'),
              _buildFilterChip('Pending', 'pending'),
              _buildFilterChip('Completed', 'completed'),
              _buildFilterChip('Normal', 'normal'),
              _buildFilterChip('Abnormal', 'abnormal'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Screenings List
        Expanded(
          child: BlocBuilder<ScreeningCubit, ScreeningState>(
            builder: (context, state) {
              if (state is ScreeningLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ScreeningError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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

              if (state is ScreeningLoaded) {
                final screenings = _filterScreenings(state.screenings);

                if (screenings.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      context.read<ScreeningCubit>().loadScreenings(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: screenings.length,
                    itemBuilder: (context, index) {
                      return _buildScreeningCard(context, screenings[index]);
                    },
                  ),
                );
              }

              return _buildEmptyState();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.lightGray.withAlpha(128),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history, size: 48, color: AppColors.gray),
          ),
          const SizedBox(height: 24),
          Text(
            'No screenings found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'all'
                ? 'Try adjusting your filters'
                : 'Start by capturing a cervical image\nfor AI-powered analysis',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isEmpty && _selectedFilter == 'all')
            ElevatedButton.icon(
              onPressed: () => context.go(Routes.doctorCapture),
              icon: const Icon(Icons.camera_alt),
              label: const Text('New Screening'),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedFilter = value),
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withAlpha(51),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.lightGray,
        ),
      ),
    );
  }

  Widget _buildScreeningCard(BuildContext context, Screening screening) {
    final statusColor = _getStatusColor(screening.status);

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 60,
                  height: 60,
                  color: AppColors.lightGray,
                  child: Image.network(
                    screening.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.image_not_supported,
                      color: AppColors.gray,
                    ),
                    loadingBuilder: (_, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            screening.patientIdentifier ?? 'No Patient ID',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
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
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (screening.patientAge != null)
                      Text(
                        'Age: ${screening.patientAge}',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 14, color: AppColors.gray),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(screening.createdAt),
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                        if (screening.result != null) ...[
                          const SizedBox(width: 16),
                          _buildClassificationBadge(
                              screening.result!.classification),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: AppColors.gray),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassificationBadge(Classification classification) {
    Color color;
    switch (classification) {
      case Classification.normal:
        color = AppColors.success;
        break;
      case Classification.abnormal:
        color = AppColors.error;
        break;
      case Classification.inconclusive:
        color = AppColors.warning;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        classification.displayName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
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
}
