import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Wraps a card in a subtle 3D perspective tilt that follows the finger while
/// pressed and springs back on release.
class TiltCard extends StatefulWidget {
  const TiltCard({
    super.key,
    required this.child,
    this.maxTilt = 0.08,
    this.pressedScale = 0.975,
  });

  final Widget child;
  final double maxTilt;
  final double pressedScale;

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    reverseDuration: const Duration(milliseconds: 420),
  );
  Offset _pointer = Offset.zero;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _update(Offset local, Size size) {
    if (size.isEmpty) return;
    final dx = ((local.dx / size.width) * 2 - 1).clamp(-1.0, 1.0);
    final dy = ((local.dy / size.height) * 2 - 1).clamp(-1.0, 1.0);
    setState(() => _pointer = Offset(dx, dy));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (e) {
            _update(e.localPosition, size);
            _controller.forward();
          },
          onPointerMove: (e) => _update(e.localPosition, size),
          onPointerUp: (_) => _controller.reverse(),
          onPointerCancel: (_) => _controller.reverse(),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = Curves.easeOutBack.transform(_controller.value);
              final rotX = -_pointer.dy * widget.maxTilt * t;
              final rotY = _pointer.dx * widget.maxTilt * t;
              final scale = 1 - (1 - widget.pressedScale) * t;
              final matrix = Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateX(rotX)
                ..rotateY(rotY)
                ..scaleByDouble(scale, scale, 1.0, 1.0);
              return Transform(
                alignment: Alignment.center,
                transform: matrix,
                child: child,
              );
            },
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Soft floating loop used for hero imagery (e.g. the splash logo).
class FloatingTilt extends StatefulWidget {
  const FloatingTilt({super.key, required this.child});

  final Widget child;

  @override
  State<FloatingTilt> createState() => _FloatingTiltState();
}

class _FloatingTiltState extends State<FloatingTilt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 6000),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final a = _controller.value * 2 * math.pi;
        final matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.0010)
          ..rotateY(math.sin(a) * 0.14)
          ..rotateX(math.cos(a) * 0.07)
          ..translateByDouble(0.0, math.sin(a * 2) * 4, 0.0, 1.0);
        return Transform(
          alignment: Alignment.center,
          transform: matrix,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
