import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_config.dart';
import '../models/job.dart';
import '../models/job_filter.dart';
import '../providers/job_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/animated_list_entry.dart';
import '../widgets/job_card.dart';
import '../widgets/job_category_filter_bar.dart';
import '../widgets/job_search_field.dart';
import '../widgets/job_type_filter_bar.dart';
import '../widgets/location_picker.dart';
import '../widgets/sort_menu.dart';
import '../widgets/state_views.dart';
import 'job_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JobProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: provider.refresh,
          edgeOffset: 12,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: _Header(
                  jobCount: provider.jobs.length,
                  location: provider.location,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                  child: JobSearchField(
                    initialValue: provider.keywords,
                    onChanged: provider.search,
                    onSubmitted: provider.submitSearch,
                    onCleared: provider.clearSearch,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: Row(
                    children: [
                      LocationPicker(
                        selected: provider.location,
                        onSelected: provider.selectLocation,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          provider.selectedCategory == JobCategory.all
                              ? 'Tech & finance roles'
                              : provider.selectedCategory.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SortMenu(
                        selected: provider.sort,
                        onSelected: provider.selectSort,
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: JobCategoryFilterBar(
                  selected: provider.selectedCategory,
                  onSelected: provider.selectCategory,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(
                child: JobTypeFilterBar(
                  selected: provider.selectedType,
                  onSelected: provider.selectType,
                ),
              ),
              if (!AppConfig.hasCredentials)
                const SliverToBoxAdapter(child: _DemoBanner()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                sliver: _JobsSliver(provider: provider),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: provider.status == JobStatus.success
          ? null
          : FloatingActionButton.small(
              onPressed: provider.refresh,
              tooltip: 'Reload jobs',
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              child: const Icon(Icons.refresh_rounded),
            ),
    );
  }
}

class _JobsSliver extends StatelessWidget {
  const _JobsSliver({required this.provider});

  final JobProvider provider;

  @override
  Widget build(BuildContext context) {
    switch (provider.status) {
      case JobStatus.initial:
      case JobStatus.loading:
        return SliverList.separated(
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (_, __) => const JobCardSkeleton(),
        );
      case JobStatus.error:
        return SliverFillRemaining(
          hasScrollBody: false,
          child: StateMessage(
            icon: Icons.cloud_off_rounded,
            iconColor: Theme.of(context).colorScheme.error,
            title: 'Could not load jobs',
            message: provider.errorMessage ?? 'Please try again.',
            actionLabel: 'Retry',
            onAction: provider.refresh,
          ),
        );
      case JobStatus.empty:
        return SliverFillRemaining(
          hasScrollBody: false,
          child: StateMessage(
            icon: Icons.search_off_rounded,
            title: 'No jobs found',
            message: provider.keywords.isEmpty
                ? 'Try another city, category or job type, or pull down to refresh.'
                : 'Nothing matched "${provider.keywords}"${provider.location.isEmpty ? '' : ' in ${provider.location}'}. Try broader keywords or another filter.',
            actionLabel: 'Refresh',
            onAction: provider.refresh,
          ),
        );
      case JobStatus.refreshing:
      case JobStatus.success:
        final jobs = provider.jobs;
        final width = MediaQuery.sizeOf(context).width;
        final columns = width >= 1200
            ? 3
            : width >= 720
            ? 2
            : 1;

        if (columns == 1) {
          return SliverList.separated(
            itemCount: jobs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) => AnimatedListEntry(
              index: index,
              child: _JobTile(job: jobs[index]),
            ),
          );
        }

        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            mainAxisExtent: 306,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => AnimatedListEntry(
              index: index,
              child: _JobTile(job: jobs[index]),
            ),
            childCount: jobs.length,
          ),
        );
    }
  }
}

class _JobTile extends StatelessWidget {
  const _JobTile({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    return JobCard(
      job: job,
      onTap: () => Navigator.of(context).push(JobDetailsScreen.route(job)),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.jobCount, required this.location});

  final int jobCount;
  final String location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.isEmpty
                      ? 'Find your next role in India'
                      : 'Find your next role in $location',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.tertiary,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'JobNest',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                if (jobCount > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    jobCount == 1
                        ? '1 opportunity available'
                        : '$jobCount opportunities available',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
            onPressed: () => themeProvider.toggle(theme.brightness),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => RotationTransition(
                turns: Tween<double>(begin: 0.75, end: 1).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 20,
              color: theme.colorScheme.tertiary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Demo data — add your Adzuna app id and key to load live jobs.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
