import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/earthquake.dart';

/// Tiga angka ringkasan yang dihitung dari [earthquakes].
class EarthquakeStats extends StatelessWidget {
  const EarthquakeStats({super.key, required this.earthquakes});

  /// Tidak boleh kosong.
  final List<Earthquake> earthquakes;

  @override
  Widget build(BuildContext context) {
    final magnitudes = earthquakes.map((quake) => quake.magnitude);
    final strongest = magnitudes.reduce(math.max);
    final average = magnitudes.reduce((a, b) => a + b) / earthquakes.length;
    final shallowest = earthquakes
        .map((quake) => quake.depthKm)
        .reduce(math.min);

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'Terkuat',
            value: 'M ${strongest.toStringAsFixed(1)}',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(
            label: 'Rata-rata',
            value: 'M ${average.toStringAsFixed(1)}',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(
            label: 'Terdangkal',
            value: '${shallowest.round()} km',
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
