import 'package:flutter/material.dart';

import '../models/job_filter.dart';

/// Horizontally scrolling job-type chips.
class JobTypeFilterBar extends StatelessWidget {
  const JobTypeFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final JobType selected;
  final ValueChanged<JobType> onSelected;

  static const Map<JobType, IconData> _icons = {
    JobType.all: Icons.auto_awesome_rounded,
    JobType.fullTime: Icons.business_center_rounded,
    JobType.partTime: Icons.schedule_rounded,
    JobType.contract: Icons.assignment_rounded,
    JobType.permanent: Icons.verified_rounded,
    JobType.internship: Icons.school_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: JobType.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final type = JobType.values[index];
          final isSelected = type == selected;
          return ChoiceChip(
            selected: isSelected,
            onSelected: (_) => onSelected(type),
            avatar: Icon(
              _icons[type],
              size: 17,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            label: Text(type.label),
            labelStyle: theme.textTheme.labelLarge?.copyWith(
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
    );
  }
}
