import 'package:flutter/material.dart';

import '../models/job.dart';
import 'company_avatar.dart';
import 'favorite_button.dart';
import 'info_pill.dart';
import 'tilt_card.dart';

/// Primary list item: company, title, location, type and salary.
class JobCard extends StatelessWidget {
  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
    this.trailing,
  });

  final Job job;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TiltCard(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'job-avatar-${job.id}',
                      child: CompanyAvatar(
                        initials: job.companyInitials,
                        seed: job.company,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.company,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            job.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.place_outlined,
                                size: 15,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
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
                    trailing ?? FavoriteButton(job: job),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
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
                  ],
                ),
                if (job.skills.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _SkillsRow(skills: job.skills),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      job.postedLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'View details',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact single-line skills strip: first few inferred skills plus a "+N".
class _SkillsRow extends StatelessWidget {
  const _SkillsRow({required this.skills});

  final List<String> skills;

  static const int _visible = 4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shown = skills.take(_visible).toList();
    final extra = skills.length - shown.length;

    Widget chip(String text, {bool muted = false}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: muted
            ? Colors.transparent
            : theme.colorScheme.secondaryContainer.withValues(alpha: 0.55),
        border: muted
            ? Border.all(color: theme.colorScheme.outlineVariant)
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: muted
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onSecondaryContainer,
        ),
      ),
    );

    return Row(
      children: [
        Icon(Icons.bolt_rounded, size: 15, color: theme.colorScheme.secondary),
        const SizedBox(width: 4),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              children: [
                for (final skill in shown) ...[
                  chip(skill),
                  const SizedBox(width: 6),
                ],
                if (extra > 0) chip('+$extra', muted: true),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
