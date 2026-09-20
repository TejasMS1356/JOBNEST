import 'package:flutter/material.dart';

import '../widgets/tilt_card.dart';
import 'root_shell.dart';

/// Animated landing page shown once on launch: the JobNest logo scales and
/// fades in, followed by a tagline and the terms & conditions notice.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _background = Color(0xFFFFFFFF);
  static const _ink = Color(0xFF111827);
  static const _accent = Color(0xFF1E90FF);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  late final Animation<double> _logoScale = Tween<double>(begin: 0.82, end: 1)
      .animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0, 0.65, curve: Curves.easeOutCubic),
        ),
      );
  late final Animation<double> _logoFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.45, curve: Curves.easeOut),
  );
  late final Animation<double> _textFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
  );
  late final Animation<Offset> _textSlide = Tween<Offset>(
    begin: const Offset(0, 0.4),
    end: Offset.zero,
  ).animate(_textFade);
  late final Animation<double> _termsFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.7, 1, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
    Future<void>.delayed(const Duration(milliseconds: 2800), _enterApp);
  }

  void _enterApp() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const RootShell(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final logoSize = (size.shortestSide * 0.62).clamp(180.0, 320.0);

    return Scaffold(
      backgroundColor: _background,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _enterApp,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FadeTransition(
                        opacity: _logoFade,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: AnimatedBuilder(
                            animation: _glow,
                            builder: (_, child) {
                              final t = Curves.easeInOut.transform(_glow.value);
                              return Container(
                                width: logoSize,
                                height: logoSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _accent.withValues(
                                        alpha: 0.10 + 0.10 * t,
                                      ),
                                      blurRadius: 60 + 30 * t,
                                      spreadRadius: 2 + 6 * t,
                                    ),
                                  ],
                                ),
                                child: child,
                              );
                            },
                            child: FloatingTilt(
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FadeTransition(
                        opacity: _textFade,
                        child: SlideTransition(
                          position: _textSlide,
                          child: Text(
                            'Find your first tech job in India',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: _ink.withValues(alpha: 0.8),
                                  letterSpacing: 0.4,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              FadeTransition(
                opacity: _termsFade,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            minHeight: 3,
                            color: _accent,
                            backgroundColor: _accent.withValues(alpha: 0.15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'By continuing you agree to the JobNest Terms & '
                        'Conditions and Privacy Policy. Job listings are '
                        'provided by Adzuna and their respective employers; '
                        'JobNest is not responsible for the accuracy of '
                        'third-party postings. Applications are completed on '
                        'the employer\'s website.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10.5,
                          height: 1.4,
                          color: _ink.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '© ${DateTime.now().year} JobNest',
                        style: TextStyle(
                          fontSize: 10,
                          color: _ink.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
