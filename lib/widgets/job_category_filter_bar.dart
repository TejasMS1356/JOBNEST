import 'package:flutter/material.dart';

import '../models/job_filter.dart';

/// Horizontally scrolling industry/category chips (IT, marketing, sales...).
class JobCategoryFilterBar extends StatelessWidget {
  const JobCategoryFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final JobCategory selected;
  final ValueChanged<JobCategory> onSelected;

  static const Map<JobCategory, IconData> _icons = {
    JobCategory.all: Icons.grid_view_rounded,
    JobCategory.tech: Icons.terminal_rounded,
    JobCategory.software: Icons.code_rounded,
    JobCategory.fullStack: Icons.layers_rounded,
    JobCategory.data: Icons.insights_rounded,
    JobCategory.cloud: Icons.cloud_rounded,
    JobCategory.finance: Icons.account_balance_rounded,
    JobCategory.fresher: Icons.school_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: JobCategory.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = JobCategory.values[index];
          final isSelected = category == selected;
          return FilterChip(
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) => onSelected(category),
            visualDensity: VisualDensity.compact,
            avatar: Icon(
              _icons[category],
              size: 16,
              color: isSelected
                  ? theme.colorScheme.onSecondaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
            label: Text(category.label),
            labelStyle: theme.textTheme.labelMedium?.copyWith(
              color: isSelected
                  ? theme.colorScheme.onSecondaryContainer
                  : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            selectedColor: theme.colorScheme.secondaryContainer,
          );
        },
      ),
    );
  }
}
