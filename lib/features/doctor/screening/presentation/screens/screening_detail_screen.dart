import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:serfix/app/themes/app_colors.dart';
import 'package:serfix/core/extensions/snackbar_extension.dart';
import 'package:serfix/features/doctor/screening/domain/entities/screening.dart';
import 'package:serfix/features/doctor/screening/domain/entities/screening_result.dart';
import 'package:serfix/features/doctor/screening/presentation/cubit/screening_cubit.dart';

class ScreeningDetailScreen extends StatefulWidget {
  final String screeningId;

  const ScreeningDetailScreen({super.key, required this.screeningId});

  @override
  State<ScreeningDetailScreen> createState() => _ScreeningDetailScreenState();
}

class _ScreeningDetailScreenState extends State<ScreeningDetailScreen> {
  Screening? _screening;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScreening();
  }

  Future<void> _loadScreening() async {
    setState(() => _isLoading = true);
    final screening =
        await context.read<ScreeningCubit>().getScreeningById(widget.screeningId);
    setState(() {
      _screening = screening;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screening Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_screening != null)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'delete') {
                  _showDeleteDialog();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _screening == null
              ? _buildNotFound()
              : _buildContent(),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: AppColors.gray),
          const SizedBox(height: 16),
          Text(
            'Screening not found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final screening = _screening!;
    final result = screening.result;

    return RefreshIndicator(
      onRefresh: _loadScreening,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                color: AppColors.textPrimary,
                child: Image.network(
                  result?.resultImageUrl ?? screening.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: AppColors.gray,
                    ),
                  ),
                  loadingBuilder: (_, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
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

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Row(
                    children: [
                      _buildStatusBadge(screening.status),
                      const Spacer(),
                      Text(
                        _formatFullDate(screening.createdAt),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Result Card (if available)
                  if (result != null) ...[
                    _buildResultCard(result),
                    const SizedBox(height: 24),
                  ] else if (screening.status == ScreeningStatus.pending ||
                      screening.status == ScreeningStatus.processing) ...[
                    _buildPendingCard(screening.status),
                    const SizedBox(height: 24),
                  ],

                  // Patient Info
                  Text(
                    'Patient Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard([
                    _buildInfoRow(
                      'Patient ID',
                      screening.patientIdentifier ?? 'Not provided',
                    ),
                    if (screening.patientAge != null)
                      _buildInfoRow('Age', '${screening.patientAge} years'),
                  ]),

                  const SizedBox(height: 24),

                  // Notes
                  if (screening.notes != null &&
                      screening.notes!.isNotEmpty) ...[
                    Text(
                      'Notes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.lightGray),
                      ),
                      child: Text(
                        screening.notes!,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Technical Details
                  if (result != null) ...[
                    Text(
                      'Technical Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard([
                      if (result.modelVersion != null)
                        _buildInfoRow('Model Version', result.modelVersion!),
                      if (result.inferenceTimeMs != null)
                        _buildInfoRow(
                          'Processing Time',
                          '${result.inferenceTimeMs}ms',
                        ),
                      _buildInfoRow(
                        'Analyzed At',
                        _formatFullDate(result.createdAt),
                      ),
                    ]),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(ScreeningResult result) {
    Color classificationColor;
    IconData classificationIcon;

    switch (result.classification) {
      case Classification.normal:
        classificationColor = AppColors.success;
        classificationIcon = Icons.check_circle;
        break;
      case Classification.abnormal:
        classificationColor = AppColors.error;
        classificationIcon = Icons.warning;
        break;
      case Classification.inconclusive:
        classificationColor = AppColors.warning;
        classificationIcon = Icons.help;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: classificationColor.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: classificationColor.withAlpha(77)),
      ),
      child: Column(
        children: [
          Icon(classificationIcon, size: 48, color: classificationColor),
          const SizedBox(height: 12),
          Text(
            result.classification.displayName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: classificationColor,
            ),
          ),
          if (result.confidence != null) ...[
            const SizedBox(height: 8),
            Text(
              'Confidence: ${(result.confidence! * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                color: classificationColor,
              ),
            ),
          ],
          if (result.detections != null && result.detections!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              '${result.detections!.length} region(s) detected',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPendingCard(ScreeningStatus status) {
    final isPending = status == ScreeningStatus.pending;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withAlpha(77)),
      ),
      child: Column(
        children: [
          if (isPending)
            Icon(Icons.hourglass_empty, size: 48, color: AppColors.info)
          else
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(),
            ),
          const SizedBox(height: 12),
          Text(
            isPending ? 'Awaiting Analysis' : 'Processing...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.info,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isPending
                ? 'This screening is queued for AI analysis'
                : 'AI is analyzing the image',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ScreeningStatus status) {
    Color color;
    switch (status) {
      case ScreeningStatus.pending:
        color = AppColors.warning;
        break;
      case ScreeningStatus.processing:
        color = AppColors.info;
        break;
      case ScreeningStatus.completed:
        color = AppColors.success;
        break;
      case ScreeningStatus.failed:
        color = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Screening'),
        content: const Text(
          'Are you sure you want to delete this screening? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context
                  .read<ScreeningCubit>()
                  .deleteScreening(widget.screeningId);
              if (mounted) {
                context.showSuccessSnackBar('Screening deleted');
                context.pop();
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
