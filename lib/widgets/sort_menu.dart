import 'package:flutter/material.dart';

import '../models/job_filter.dart';

/// Compact "Sort by" pill that opens a Material 3 menu of [JobSort] options.
class SortMenu extends StatelessWidget {
  const SortMenu({super.key, required this.selected, required this.onSelected});

  final JobSort selected;
  final ValueChanged<JobSort> onSelected;

  static const Map<JobSort, IconData> _icons = {
    JobSort.relevance: Icons.auto_awesome_outlined,
    JobSort.newest: Icons.schedule_rounded,
    JobSort.oldest: Icons.history_rounded,
    JobSort.salaryHighToLow: Icons.trending_down_rounded,
    JobSort.salaryLowToHigh: Icons.trending_up_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDefault = selected == JobSort.relevance;
    return MenuAnchor(
      alignmentOffset: const Offset(0, 6),
      style: MenuStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevation: const WidgetStatePropertyAll(6),
      ),
      menuChildren: [
        for (final sort in JobSort.values)
          MenuItemButton(
            leadingIcon: Icon(_icons[sort], size: 18),
            trailingIcon: sort == selected
                ? Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  )
                : null,
            onPressed: () => onSelected(sort),
            child: Text(sort.label),
          ),
        if (!isDefault) ...[
          const Divider(height: 8),
          MenuItemButton(
            leadingIcon: const Icon(Icons.close_rounded, size: 18),
            onPressed: () => onSelected(JobSort.relevance),
            child: const Text('Clear sort'),
          ),
        ],
      ],
      builder: (context, controller, _) => Material(
        color: isDefault
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
            : theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () =>
              controller.isOpen ? controller.close() : controller.open(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.swap_vert_rounded,
                  size: 18,
                  color: isDefault
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  isDefault ? 'Sort' : selected.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDefault
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
