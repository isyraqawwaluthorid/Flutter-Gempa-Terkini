import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/earthquake.dart';

/// Daftar gempa yang disediakan BMKG; masing-masing berisi 15 gempa terakhir.
enum EarthquakeFeed {
  felt('gempadirasakan.json'),
  significant('gempaterkini.json');

  const EarthquakeFeed(this.fileName);

  final String fileName;
}

/// Kegagalan pengambilan data, dengan [message] yang siap ditampilkan ke
/// pengguna.
class EarthquakeServiceException implements Exception {
  const EarthquakeServiceException(this.message);

  final String message;

  @override
  String toString() => 'EarthquakeServiceException: $message';
}

/// Satu-satunya pintu aplikasi ke API BMKG (https://data.bmkg.go.id/gempabumi).
class EarthquakeService {
  EarthquakeService({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://data.bmkg.go.id/DataMKG/TEWS';
  static const _timeout = Duration(seconds: 15);
  static const _unreadableMessage =
      'Data dari BMKG tidak dapat dibaca karena formatnya berubah.';

  final http.Client _client;

  /// Mengambil gempa pada [feed], terurut dari yang terbaru.
  ///
  /// Semua kegagalan dilempar sebagai [EarthquakeServiceException].
  Future<List<Earthquake>> fetchEarthquakes(EarthquakeFeed feed) async {
    final uri = Uri.parse('$_baseUrl/${feed.fileName}');

    final http.Response response;
    try {
      response = await _client.get(uri).timeout(_timeout);
    } on TimeoutException {
      throw const EarthquakeServiceException(
        'Server BMKG terlalu lama merespons. Coba lagi beberapa saat lagi.',
      );
    } on Exception {
      throw const EarthquakeServiceException(
        'Tidak dapat terhubung ke server BMKG. '
        'Periksa koneksi internet Anda, lalu coba lagi.',
      );
    }

    if (response.statusCode != 200) {
      throw EarthquakeServiceException(
        'Server BMKG sedang bermasalah (kode ${response.statusCode}). '
        'Coba lagi beberapa saat lagi.',
      );
    }

    final List<Earthquake> earthquakes;
    try {
      // BMKG tidak mengirim charset, jadi decode UTF-8 secara eksplisit.
      final body =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final info = body['Infogempa'] as Map<String, dynamic>;
      final items = info['gempa'] as List<dynamic>;

      earthquakes = [
        for (final item in items)
          Earthquake.fromJson(item as Map<String, dynamic>),
      ];
    } on FormatException {
      throw const EarthquakeServiceException(_unreadableMessage);
    } on TypeError {
      throw const EarthquakeServiceException(_unreadableMessage);
    }

    if (earthquakes.isEmpty) {
      throw const EarthquakeServiceException(
        'BMKG belum memiliki data gempa untuk kategori ini.',
      );
    }
    return earthquakes;
  }
}
