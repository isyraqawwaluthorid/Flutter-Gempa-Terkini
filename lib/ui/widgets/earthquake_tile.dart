import 'package:flutter/material.dart';

import '../../models/earthquake.dart';
import 'magnitude_badge.dart';

/// Satu baris pada daftar riwayat gempa.
class EarthquakeTile extends StatelessWidget {
  const EarthquakeTile({super.key, required this.earthquake});

  final Earthquake earthquake;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final felt = earthquake.felt;
    final detail = felt ?? earthquake.potential;
    final isWarning = felt == null && earthquake.hasTsunamiPotential;
    final detailColor = isWarning ? colors.error : colors.onSurfaceVariant;

    final IconData detailIcon;
    if (felt != null) {
      detailIcon = Icons.vibration;
    } else if (isWarning) {
      detailIcon = Icons.warning_amber_rounded;
    } else {
      detailIcon = Icons.tsunami;
    }

    return Card.filled(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MagnitudeBadge(magnitude: earthquake.magnitude),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    earthquake.region,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${earthquake.date} · ${earthquake.time} · '
                    '${earthquake.depthKm.round()} km',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  if (detail != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(detailIcon, size: 16, color: detailColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            detail,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: detailColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
