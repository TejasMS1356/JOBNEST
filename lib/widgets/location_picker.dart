import 'package:flutter/material.dart';

import '../models/job_filter.dart';

/// Pill that shows the active Indian city and opens a searchable picker.
class LocationPicker extends StatelessWidget {
  const LocationPicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  /// Empty string means all of India.
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAllIndia = selected.isEmpty;
    return Material(
      color: isAllIndia
          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
          : theme.colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openPicker(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 18,
                color: isAllIndia
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                isAllIndia ? 'All India' : selected,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isAllIndia
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.expand_more_rounded,
                size: 18,
                color: isAllIndia
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onPrimaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _CitySheet(selected: selected),
    );
    if (result != null) onSelected(result);
  }
}

class _CitySheet extends StatefulWidget {
  const _CitySheet({required this.selected});

  final String selected;

  @override
  State<_CitySheet> createState() => _CitySheetState();
}

class _CitySheetState extends State<_CitySheet> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cities = indianCities
        .where((c) => c.toLowerCase().contains(_filter.toLowerCase()))
        .toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      builder: (context, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Choose a city', style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  'Jobs are limited to India. Pick a hub or search all cities.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  autofocus: false,
                  onChanged: (v) => setState(() => _filter = v.trim()),
                  decoration: const InputDecoration(
                    hintText: 'Search city',
                    prefixIcon: Icon(Icons.search_rounded),
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              children: [
                if (_filter.isEmpty)
                  _CityTile(
                    label: 'All India',
                    icon: Icons.public_rounded,
                    selected: widget.selected.isEmpty,
                    onTap: () => Navigator.pop(context, ''),
                  ),
                for (final city in cities)
                  _CityTile(
                    label: city,
                    icon: Icons.location_city_rounded,
                    selected: widget.selected == city,
                    onTap: () => Navigator.pop(context, city),
                  ),
                if (cities.isEmpty && _filter.isNotEmpty)
                  _CityTile(
                    label: 'Use "$_filter"',
                    icon: Icons.add_location_alt_rounded,
                    selected: false,
                    onTap: () => Navigator.pop(context, _filter),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CityTile extends StatelessWidget {
  const _CityTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      selected: selected,
      selectedTileColor: theme.colorScheme.primaryContainer.withValues(
        alpha: 0.5,
      ),
      leading: Icon(icon),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
          : null,
    );
  }
}
