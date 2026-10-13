import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gempa_terkini/services/earthquake_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Map<String, dynamic> quakeJson({String magnitude = '5.7'}) => {
  'Tanggal': '12 Okt 2026',
  'Jam': '04:34:53 WIB',
  'DateTime': '2026-10-11T21:34:53+00:00',
  'Coordinates': '0.64,121.75',
  'Lintang': '0.64 LU',
  'Bujur': '121.75 BT',
  'Magnitude': magnitude,
  'Kedalaman': '76 km',
  'Wilayah': '29 km BaratLaut POHUWATO-GORONTALO',
  'Potensi': 'Tidak berpotensi tsunami',
};

String envelope(Object? gempa) => jsonEncode({
  'Infogempa': {'gempa': gempa},
});

Matcher throwsServiceError(String messagePart) => throwsA(
  isA<EarthquakeServiceException>().having(
    (error) => error.message,
    'message',
    contains(messagePart),
  ),
);

void main() {
  test('memanggil berkas sesuai kategori dan mem-parsing isinya', () async {
    late Uri requested;
    final service = EarthquakeService(
      client: MockClient((request) async {
        requested = request.url;
        return http.Response(
          envelope([quakeJson(), quakeJson(magnitude: '5.1')]),
          200,
        );
      }),
    );

    final quakes = await service.fetchEarthquakes(EarthquakeFeed.significant);

    expect(
      requested.toString(),
      'https://data.bmkg.go.id/DataMKG/TEWS/gempaterkini.json',
    );
    expect(quakes.map((quake) => quake.magnitude), [5.7, 5.1]);
    expect(quakes.first.region, '29 km BaratLaut POHUWATO-GORONTALO');
  });

  test('menjelaskan kegagalan koneksi', () {
    final service = EarthquakeService(
      client: MockClient((_) => throw http.ClientException('offline')),
    );

    expect(
      service.fetchEarthquakes(EarthquakeFeed.felt),
      throwsServiceError('Periksa koneksi internet'),
    );
  });

  test('menyertakan kode status saat server menolak', () {
    final service = EarthquakeService(
      client: MockClient(
        (_) async => http.Response('Service Unavailable', 503),
      ),
    );

    expect(
      service.fetchEarthquakes(EarthquakeFeed.felt),
      throwsServiceError('503'),
    );
  });

  test('menolak isi yang bukan JSON', () {
    final service = EarthquakeService(
      client: MockClient((_) async => http.Response('<html></html>', 200)),
    );

    expect(
      service.fetchEarthquakes(EarthquakeFeed.felt),
      throwsServiceError('tidak dapat dibaca'),
    );
  });

  test('menolak JSON dengan bentuk yang tidak dikenali', () {
    final service = EarthquakeService(
      client: MockClient((_) async => http.Response('{"Infogempa": 1}', 200)),
    );

    expect(
      service.fetchEarthquakes(EarthquakeFeed.felt),
      throwsServiceError('tidak dapat dibaca'),
    );
  });

  test('menganggap daftar kosong sebagai kegagalan', () {
    final service = EarthquakeService(
      client: MockClient((_) async => http.Response(envelope([]), 200)),
    );

    expect(
      service.fetchEarthquakes(EarthquakeFeed.felt),
      throwsServiceError('belum memiliki data'),
    );
  });
}
