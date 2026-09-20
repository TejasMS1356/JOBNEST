import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';
import '../widgets/animated_list_entry.dart';
import '../widgets/job_card.dart';
import '../widgets/state_views.dart';
import 'job_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final jobs = favorites.favorites;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          if (jobs.isNotEmpty)
            TextButton.icon(
              onPressed: () => _confirmClear(context, favorites),
              icon: const Icon(Icons.delete_sweep_outlined, size: 20),
              label: const Text('Clear all'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: !favorites.isLoaded
          ? const Center(child: CircularProgressIndicator())
          : jobs.isEmpty
          ? const StateMessage(
              icon: Icons.favorite_border_rounded,
              title: 'No favorites yet',
              message: 'Tap the heart on any job to save it here. Your favorites stay on this device.',
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bookmark_rounded,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${jobs.length} saved ${jobs.length == 1 ? 'job' : 'jobs'}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    physics: const BouncingScrollPhysics(),
                    itemCount: jobs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      return AnimatedListEntry(
                        index: index,
                        child: Dismissible(
                          key: ValueKey(job.id),
                          direction: DismissDirection.endToStart,
                          background: _DismissBackground(),
                          onDismissed: (_) {
                            favorites.remove(job.id);
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text('Removed "${job.title}"'),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () => favorites.toggle(job),
                                  ),
                                ),
                              );
                          },
                          child: JobCard(
                            job: job,
                            onTap: () =>
                                Navigator.of(context)
                                    .push(JobDetailsScreen.route(job)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _confirmClear(
    BuildContext context,
    FavoritesProvider favorites,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear favorites?'),
        content: const Text('This removes every saved job from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await favorites.clear();
  }
}

class _DismissBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Icon(
        Icons.delete_outline_rounded,
        color: theme.colorScheme.onErrorContainer,
      ),
    );
  }
}
