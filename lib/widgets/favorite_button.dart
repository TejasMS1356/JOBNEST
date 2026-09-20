import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/job.dart';
import '../providers/favorites_provider.dart';

/// Heart toggle with a springy scale animation and colour transition.
class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    super.key,
    required this.job,
    this.size = 22,
    this.showBackground = true,
  });

  final Job job;
  final double size;
  final bool showBackground;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
    lowerBound: 0,
    upperBound: 1,
    value: 1,
  );

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 45),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.35,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.elasticOut)),
      weight: 55,
    ),
  ]).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    final favorites = context.read<FavoritesProvider>();
    final messenger = ScaffoldMessenger.of(context);
    _controller.forward(from: 0);
    final added = await favorites.toggle(widget.job);
    if (!mounted) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(
            added
                ? 'Saved "${widget.job.title}" to favorites'
                : 'Removed from favorites',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFavorite = context.select<FavoritesProvider, bool>(
      (provider) => provider.isFavorite(widget.job.id),
    );

    return Semantics(
      button: true,
      label: isFavorite ? 'Remove from favorites' : 'Add to favorites',
      child: InkResponse(
        onTap: _onTap,
        radius: widget.size + 12,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.all(widget.showBackground ? 9 : 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: !widget.showBackground
                ? null
                : isFavorite
                ? theme.colorScheme.error.withValues(alpha: 0.12)
                : theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.6,
                  ),
          ),
          child: ScaleTransition(
            scale: _scale,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                key: ValueKey(isFavorite),
                size: widget.size,
                color: isFavorite
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
