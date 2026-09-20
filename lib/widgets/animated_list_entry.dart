import 'package:flutter/material.dart';

/// Staggered fade + slide used when list items first appear.
class AnimatedListEntry extends StatefulWidget {
  const AnimatedListEntry({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  State<AnimatedListEntry> createState() => _AnimatedListEntryState();
}

class _AnimatedListEntryState extends State<AnimatedListEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void initState() {
    super.initState();
    final delay = Duration(milliseconds: 60 * (widget.index % 8));
    Future<void>.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: AnimatedBuilder(
        animation: curved,
        builder: (context, child) {
          final t = curved.value;
          final matrix = Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..translateByDouble(0.0, 28 * (1 - t), 0.0, 1.0)
            ..rotateX(-0.22 * (1 - t));
          return Transform(
            alignment: Alignment.topCenter,
            transform: matrix,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
