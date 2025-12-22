import 'package:flutter/material.dart';

class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark
        ? colorScheme.surfaceContainerHighest
        : colorScheme.surfaceContainerLow;
    final highlightColor = isDark
        ? colorScheme.surfaceContainerLow
        : colorScheme.surfaceContainerHighest;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: const Row(
        children: [
          SkeletonLoader(width: 60, height: 60, borderRadius: 8),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(width: double.infinity, height: 16),
                SizedBox(height: 8),
                SkeletonLoader(width: 150, height: 12),
                SizedBox(height: 8),
                SkeletonLoader(width: 100, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonStatCard extends StatelessWidget {
  const SkeletonStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoader(width: 40, height: 40, borderRadius: 8),
              SkeletonLoader(width: 50, height: 24),
            ],
          ),
          SizedBox(height: 12),
          SkeletonLoader(width: 80, height: 12),
        ],
      ),
    );
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome skeleton
          const SkeletonLoader(width: 200, height: 24),
          const SizedBox(height: 8),
          const SkeletonLoader(width: 150, height: 16),
          const SizedBox(height: 24),

          // Stats grid skeleton
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: const [
              SkeletonStatCard(),
              SkeletonStatCard(),
              SkeletonStatCard(),
              SkeletonStatCard(),
            ],
          ),

          const SizedBox(height: 24),

          // Quick actions skeleton
          const SkeletonLoader(width: 120, height: 20),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: SkeletonLoader(width: 100, height: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: SkeletonLoader(width: 100, height: 16),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent activity skeleton
          const SkeletonLoader(width: 140, height: 20),
          const SizedBox(height: 12),
          const SkeletonCard(),
          const SizedBox(height: 8),
          const SkeletonCard(),
          const SizedBox(height: 8),
          const SkeletonCard(),
        ],
      ),
    );
  }
}

class ScreeningsListSkeleton extends StatelessWidget {
  const ScreeningsListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar skeleton
        Padding(
          padding: const EdgeInsets.all(16),
          child: SkeletonLoader(
            width: double.infinity,
            height: 48,
            borderRadius: 12,
          ),
        ),

        // Filter chips skeleton
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              SkeletonLoader(width: 60, height: 32, borderRadius: 16),
              const SizedBox(width: 8),
              SkeletonLoader(width: 80, height: 32, borderRadius: 16),
              const SizedBox(width: 8),
              SkeletonLoader(width: 90, height: 32, borderRadius: 16),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // List items skeleton
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            itemBuilder: (context, index) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: SkeletonCard(),
            ),
          ),
        ),
      ],
    );
  }
}
