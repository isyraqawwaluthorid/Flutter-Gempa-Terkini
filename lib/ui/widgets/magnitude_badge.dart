import 'package:flutter/material.dart';

/// Tingkat kekuatan gempa berdasarkan magnitudonya.
enum MagnitudeLevel {
  minor('Kecil', Color(0xFF0CA30C), Color(0xFF0B0B0B)),
  light('Ringan', Color(0xFFFAB219), Color(0xFF0B0B0B)),
  moderate('Sedang', Color(0xFFEC835A), Color(0xFF0B0B0B)),
  strong('Kuat', Color(0xFFD03B3B), Color(0xFFFFFFFF));

  const MagnitudeLevel(this.label, this.color, this.onColor);

  factory MagnitudeLevel.of(double magnitude) => switch (magnitude) {
    < 4.0 => minor,
    < 5.0 => light,
    < 6.0 => moderate,
    _ => strong,
  };

  final String label;
  final Color color;

  /// Warna teks yang tetap terbaca di atas [color].
  final Color onColor;
}

/// Kotak berwarna berisi angka magnitudo. Versi [large] ikut menampilkan
/// nama tingkatannya.
class MagnitudeBadge extends StatelessWidget {
  const MagnitudeBadge({
    super.key,
    required this.magnitude,
    this.large = false,
  });

  final double magnitude;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final level = MagnitudeLevel.of(magnitude);
    final textTheme = Theme.of(context).textTheme;
    final size = large ? 112.0 : 52.0;

    return Semantics(
      label: 'Magnitudo ${magnitude.toStringAsFixed(1)}, ${level.label}',
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        padding: EdgeInsets.all(large ? 10 : 6),
        decoration: BoxDecoration(
          color: level.color,
          borderRadius: BorderRadius.circular(large ? 24 : 14),
        ),
        // Menyusut bila ukuran font sistem diperbesar, alih-alih meluap.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                magnitude.toStringAsFixed(1),
                style: TextStyle(
                  color: level.onColor,
                  fontSize: large ? 48 : 18,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              if (large)
                Text(
                  level.label,
                  style: textTheme.labelLarge?.copyWith(color: level.onColor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
