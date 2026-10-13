import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gempa_terkini/models/earthquake.dart';
import 'package:gempa_terkini/services/earthquake_service.dart';
import 'package:gempa_terkini/ui/screens/earthquake_screen.dart';
import 'package:gempa_terkini/ui/widgets/earthquake_tile.dart';
import 'package:gempa_terkini/ui/widgets/latest_earthquake_card.dart';

/// Service palsu: setiap panggilan menunggu sampai tes menyelesaikannya.
class FakeEarthquakeService implements EarthquakeService {
  final requests = <EarthquakeFeed>[];
  var _pending = Completer<List<Earthquake>>();

  @override
  Future<List<Earthquake>> fetchEarthquakes(EarthquakeFeed feed) {
    requests.add(feed);
    _pending = Completer<List<Earthquake>>();
    return _pending.future;
  }

  void succeed(List<Earthquake> earthquakes) => _pending.complete(earthquakes);

  void fail(String message) =>
      _pending.completeError(EarthquakeServiceException(message));
}

Earthquake quake(String region, double magnitude) => Earthquake(
  dateTime: DateTime.utc(2026, 10, 13, 9, 48, 27),
  date: '13 Okt 2026',
  time: '16:48:27 WIB',
  latitude: '9.83 LS',
  longitude: '118.98 BT',
  magnitude: magnitude,
  depthKm: 9,
  region: region,
  felt: 'III Kab. Sumba Barat Daya',
);

void main() {
  late FakeEarthquakeService service;

  setUp(() => service = FakeEarthquakeService());

  Future<void> pumpScreen(WidgetTester tester) =>
      tester.pumpWidget(MaterialApp(home: EarthquakeScreen(service: service)));

  testWidgets('menampilkan loading lalu data dari service', (tester) async {
    await pumpScreen(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Mengambil data gempa dari BMKG…'), findsOneWidget);

    service.succeed([quake('Kodi', 4.3), quake('Mentawai', 6.1)]);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(
      find.descendant(
        of: find.byType(LatestEarthquakeCard),
        matching: find.text('Kodi'),
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(EarthquakeTile, 'Mentawai'), findsOneWidget);
    expect(find.text('2 gempa terakhir yang dirasakan'), findsOneWidget);
    expect(find.text('M 6.1'), findsOneWidget);
  });

  testWidgets('menampilkan pesan error dan memuat ulang lewat Coba lagi', (
    tester,
  ) async {
    await pumpScreen(tester);

    service.fail('Tidak dapat terhubung ke server BMKG.');
    await tester.pump();

    expect(find.text('Gagal memuat data'), findsOneWidget);
    expect(find.text('Tidak dapat terhubung ke server BMKG.'), findsOneWidget);

    await tester.tap(find.text('Coba lagi'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(service.requests, hasLength(2));

    service.succeed([quake('Kodi', 4.3)]);
    await tester.pump();

    expect(find.text('Gagal memuat data'), findsNothing);
    expect(find.byType(LatestEarthquakeCard), findsOneWidget);
  });

  testWidgets('berpindah kategori memuat daftar gempa M 5.0+', (tester) async {
    await pumpScreen(tester);
    service.succeed([quake('Kodi', 4.3)]);
    await tester.pump();

    await tester.tap(find.text('Magnitudo 5.0+'));
    await tester.pump();

    expect(service.requests, [EarthquakeFeed.felt, EarthquakeFeed.significant]);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    service.succeed([quake('Gorontalo', 5.7)]);
    await tester.pump();

    expect(
      find.text('1 gempa terakhir bermagnitudo 5.0 ke atas'),
      findsOneWidget,
    );
  });
}
