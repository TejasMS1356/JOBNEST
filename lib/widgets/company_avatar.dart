import 'package:flutter/material.dart';

/// Company logo fetched by guessing the company's domain, falling back to a
/// gradient monogram (Adzuna does not return logos).
class CompanyAvatar extends StatelessWidget {
  const CompanyAvatar({
    super.key,
    required this.initials,
    required this.seed,
    this.size = 52,
  });

  final String initials;
  final String seed;
  final double size;

  static const List<List<Color>> _palettes = [
    [Color(0xFF6A5AE0), Color(0xFF9C8CFF)],
    [Color(0xFF00A6A6), Color(0xFF4FD1C5)],
    [Color(0xFFEA5455), Color(0xFFFF8F6B)],
    [Color(0xFF2D6CDF), Color(0xFF63A4FF)],
    [Color(0xFFDB7F2C), Color(0xFFF5B963)],
    [Color(0xFF1E9E5A), Color(0xFF63D48F)],
    [Color(0xFF8E44AD), Color(0xFFC77DFF)],
  ];

  static final RegExp _suffixes = RegExp(
    r'\b(pvt|private|ltd|limited|llp|inc|corp|corporation|co|company|'
    r'technologies|technology|tech|solutions|services|systems|software|'
    r'india|global|group|international|consulting|consultancy|labs|digital|'
    r'it|the|and|&)\b',
    caseSensitive: false,
  );

  /// Best-effort `company.com` guess from a display name.
  static String? domainFor(String company) {
    final cleaned = company
        .replaceAll(RegExp(r'\(.*?\)'), ' ')
        .replaceAll(_suffixes, ' ')
        .replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '')
        .trim();
    final words = cleaned.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final slug = words.take(2).join().toLowerCase();
    if (slug.length < 3) return null;
    return '$slug.com';
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.32);
    final domain = domainFor(seed);
    final fallback = _Monogram(initials: initials, seed: seed, size: size);
    if (domain == null) return fallback;

    final px = (size * 3).round();
    final sources = [
      'https://logo.clearbit.com/$domain?size=$px',
      'https://www.google.com/s2/favicons?domain=$domain&sz=128',
    ];

    Widget attempt(int i) {
      if (i >= sources.length) return fallback;
      return Image.network(
        sources[i],
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => attempt(i + 1),
        frameBuilder: (context, child, frame, wasSync) {
          if (frame == null) return fallback;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: DecoratedBox(
              key: const ValueKey('logo'),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: radius,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant
                      .withValues(alpha: 0.6),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(size * 0.12),
                child: child,
              ),
            ),
          );
        },
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(borderRadius: radius, child: attempt(0)),
    );
  }
}

class _Monogram extends StatelessWidget {
  const _Monogram({
    required this.initials,
    required this.seed,
    required this.size,
  });

  final String initials;
  final String seed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = CompanyAvatar
        ._palettes[seed.hashCode.abs() % CompanyAvatar._palettes.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.32),
        gradient: LinearGradient(
          colors: palette,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: palette.last.withValues(alpha: 0.32),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.34,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
