import 'package:flutter/material.dart';

import '../../models/earthquake.dart';
import 'magnitude_badge.dart';

/// Kartu utama di puncak halaman untuk gempa paling baru.
class LatestEarthquakeCard extends StatelessWidget {
  const LatestEarthquakeCard({super.key, required this.earthquake});

  final Earthquake earthquake;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final felt = earthquake.felt;
    final potential = earthquake.potential;

    return Card.filled(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MagnitudeBadge(magnitude: earthquake.magnitude, large: true),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GEMPA TERBARU',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        earthquake.region,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${earthquake.date} · ${earthquake.time}\n'
                        '${_timeAgo(earthquake.dateTime)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Fact(
                    label: 'Kedalaman',
                    value: '${earthquake.depthKm.round()} km',
                  ),
                ),
                Expanded(
                  child: _Fact(label: 'Lintang', value: earthquake.latitude),
                ),
                Expanded(
                  child: _Fact(label: 'Bujur', value: earthquake.longitude),
                ),
              ],
            ),
            if (felt != null) ...[
              const SizedBox(height: 16),
              _Note(
                icon: Icons.vibration,
                label: 'Dirasakan (skala MMI)',
                text: felt,
              ),
            ],
            if (potential != null) ...[
              const SizedBox(height: 16),
              _Note(
                icon: earthquake.hasTsunamiPotential
                    ? Icons.warning_amber_rounded
                    : Icons.tsunami,
                label: 'Potensi',
                text: potential,
                isWarning: earthquake.hasTsunamiPotential,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _timeAgo(DateTime time) {
    final elapsed = DateTime.now().difference(time);
    if (elapsed.inMinutes < 1) return 'Baru saja';
    if (elapsed.inHours < 1) return '${elapsed.inMinutes} menit lalu';
    if (elapsed.inDays < 1) return '${elapsed.inHours} jam lalu';
    return '${elapsed.inDays} hari lalu';
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({
    required this.icon,
    required this.label,
    required this.text,
    this.isWarning = false,
  });

  final IconData icon;
  final String label;
  final String text;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final background = isWarning ? colors.errorContainer : colors.surface;
    final foreground = isWarning ? colors.onErrorContainer : colors.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isWarning ? foreground : colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
