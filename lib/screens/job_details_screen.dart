import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/job.dart';
import '../widgets/company_avatar.dart';
import '../widgets/favorite_button.dart';
import '../widgets/info_pill.dart';

class JobDetailsScreen extends StatelessWidget {
  const JobDetailsScreen({super.key, required this.job});

  final Job job;

  static Route<void> route(Job job) => PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 380),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, __, ___) => JobDetailsScreen(job: job),
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );

  Future<void> _apply(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final url = job.redirectUrl;
    if (url == null || url.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No application link for this job.')),
      );
      return;
    }
    final uri = Uri.tryParse(url);
    final launched = uri == null
        ? false
        : await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open the application link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final skills = job.skills;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 250,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FavoriteButton(job: job, size: 24),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _HeaderBackground(job: job),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      InfoPill(
                        icon: Icons.work_outline,
                        label: job.employmentType,
                      ),
                      InfoPill(
                        icon: Icons.payments_outlined,
                        label: job.salaryLabel,
                        color: theme.colorScheme.tertiary,
                      ),
                      InfoPill(
                        icon: Icons.trending_up_rounded,
                        label: job.experienceLabel,
                        color: theme.colorScheme.secondary,
                      ),
                      InfoPill(
                        icon: Icons.schedule_rounded,
                        label: job.postedLabel,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _Section(
                    title: 'Job description',
                    child: Text(
                      job.description.isEmpty
                          ? 'The employer did not provide a description for this role. Use the apply button to read the full listing on Adzuna.'
                          : job.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _Section(
                    title: 'Skills',
                    child: skills.isEmpty
                        ? Text(
                            'No specific skills listed for this role.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final skill in skills)
                                Chip(
                                  label: Text(skill),
                                  backgroundColor: theme
                                      .colorScheme
                                      .primaryContainer
                                      .withValues(alpha: 0.45),
                                  labelStyle: theme.textTheme.labelMedium
                                      ?.copyWith(
                                        color: theme
                                            .colorScheme
                                            .onPrimaryContainer,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 28),
                  _Section(
                    title: 'Experience',
                    child: Row(
                      children: [
                        Icon(
                          Icons.workspace_premium_rounded,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            job.experienceLabel == 'Not specified'
                                ? 'Experience requirement not specified by the employer.'
                                : '${job.experienceLabel} of relevant experience',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (job.category != null) ...[
                    const SizedBox(height: 28),
                    _Section(
                      title: 'Category',
                      child: Text(
                        job.category!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _ApplyBar(job: job, onApply: () => _apply(context)),
    );
  }
}

class _HeaderBackground extends StatelessWidget {
  const _HeaderBackground({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.22),
            theme.colorScheme.tertiary.withValues(alpha: 0.14),
            theme.scaffoldBackgroundColor,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'job-avatar-${job.id}',
                child: CompanyAvatar(
                  initials: job.companyInitials,
                  seed: job.company,
                  size: 62,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                job.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      job.company,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.place_outlined,
                    size: 15,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      job.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(title, style: theme.textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}

class _ApplyBar extends StatelessWidget {
  const _ApplyBar({required this.job, required this.onApply});

  final Job job;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        14 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.salaryLabel,
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  job.employmentType,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          FavoriteButton(job: job, size: 24),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: onApply,
            icon: const Icon(Icons.open_in_new_rounded, size: 20),
            label: const Text('Apply now'),
          ),
        ],
      ),
    );
  }
}
