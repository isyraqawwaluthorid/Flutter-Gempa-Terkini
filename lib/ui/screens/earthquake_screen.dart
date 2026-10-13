import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/earthquake.dart';
import '../../services/earthquake_service.dart';
import '../widgets/earthquake_stats.dart';
import '../widgets/earthquake_tile.dart';
import '../widgets/error_view.dart';
import '../widgets/latest_earthquake_card.dart';
import '../widgets/loading_view.dart';

enum _Status { loading, success, error }

/// Halaman tunggal aplikasi: memegang state dan meneruskan data ke widget.
class EarthquakeScreen extends StatefulWidget {
  const EarthquakeScreen({super.key, this.service});

  /// Bisa diganti saat pengujian; bawaannya [EarthquakeService] asli.
  final EarthquakeService? service;

  @override
  State<EarthquakeScreen> createState() => _EarthquakeScreenState();
}

class _EarthquakeScreenState extends State<EarthquakeScreen> {
  static const _maxContentWidth = 640.0;

  late final EarthquakeService _service = widget.service ?? EarthquakeService();

  EarthquakeFeed _feed = EarthquakeFeed.felt;
  _Status _status = _Status.loading;
  List<Earthquake> _earthquakes = const [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final feed = _feed;
    try {
      final earthquakes = await _service.fetchEarthquakes(feed);
      // Abaikan jawaban yang datang setelah pengguna berpindah kategori.
      if (!mounted || feed != _feed) return;
      setState(() {
        _earthquakes = earthquakes;
        _status = _Status.success;
      });
    } on EarthquakeServiceException catch (error) {
      if (!mounted || feed != _feed) return;
      setState(() {
        _errorMessage = error.message;
        _status = _Status.error;
      });
    }
  }

  void _reload([EarthquakeFeed? feed]) {
    setState(() {
      _feed = feed ?? _feed;
      _status = _Status.loading;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Gempa Terkini'),
            Text(
              'Sumber data: BMKG',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _status == _Status.loading ? null : _reload,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: _maxContentWidth - 32,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<EarthquakeFeed>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: EarthquakeFeed.felt,
                        icon: Icon(Icons.vibration),
                        label: Text('Dirasakan'),
                      ),
                      ButtonSegment(
                        value: EarthquakeFeed.significant,
                        icon: Icon(Icons.public),
                        label: Text('Magnitudo 5.0+'),
                      ),
                    ],
                    selected: {_feed},
                    onSelectionChanged: (selection) => _reload(selection.first),
                  ),
                ),
              ),
            ),
            Expanded(
              child: switch (_status) {
                _Status.loading => const LoadingView(
                  message: 'Mengambil data gempa dari BMKG…',
                ),
                _Status.error => ErrorView(
                  message: _errorMessage,
                  onRetry: _reload,
                ),
                _Status.success => _buildContent(theme),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    final sectionTitle = switch (_feed) {
      EarthquakeFeed.felt => 'gempa terakhir yang dirasakan',
      EarthquakeFeed.significant => 'gempa terakhir bermagnitudo 5.0 ke atas',
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        // Lebar isi dibatasi supaya tetap nyaman dibaca di layar lebar.
        final sidePadding = math.max(
          16.0,
          (constraints.maxWidth - _maxContentWidth) / 2 + 16,
        );

        return ListView.separated(
          padding: EdgeInsets.fromLTRB(sidePadding, 0, sidePadding, 24),
          // Gempa pertama tampil di kartu utama, sisanya di daftar, lalu
          // satu baris penutup untuk atribusi.
          itemCount: _earthquakes.length + 1,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LatestEarthquakeCard(earthquake: _earthquakes.first),
                  const SizedBox(height: 24),
                  Text(
                    '${_earthquakes.length} $sectionTitle',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  EarthquakeStats(earthquakes: _earthquakes),
                  const SizedBox(height: 4),
                ],
              );
            }
            if (index == _earthquakes.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Data gempa bumi bersumber dari BMKG (Badan Meteorologi, '
                  'Klimatologi, dan Geofisika).',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            return EarthquakeTile(earthquake: _earthquakes[index]);
          },
        );
      },
    );
  }
}
