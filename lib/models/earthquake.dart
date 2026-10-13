import 'package:flutter/foundation.dart';

/// Satu kejadian gempa bumi dari data terbuka BMKG.
@immutable
class Earthquake {
  const Earthquake({
    required this.dateTime,
    required this.date,
    required this.time,
    required this.latitude,
    required this.longitude,
    required this.magnitude,
    required this.depthKm,
    required this.region,
    this.potential,
    this.felt,
  });

  /// Melempar [FormatException] atau [TypeError] bila bentuk JSON tidak sesuai.
  factory Earthquake.fromJson(Map<String, dynamic> json) {
    final depth = (json['Kedalaman'] as String).replaceAll('km', '').trim();

    return Earthquake(
      dateTime: DateTime.parse(json['DateTime'] as String),
      date: json['Tanggal'] as String,
      time: json['Jam'] as String,
      latitude: json['Lintang'] as String,
      longitude: json['Bujur'] as String,
      magnitude: double.parse(json['Magnitude'] as String),
      depthKm: double.parse(depth),
      region: json['Wilayah'] as String,
      potential: json['Potensi'] as String?,
      felt: json['Dirasakan'] as String?,
    );
  }

  final DateTime dateTime;

  /// Tanggal siap tampil dari BMKG, mis. `13 Okt 2026`.
  final String date;

  /// Jam siap tampil dari BMKG, mis. `16:48:27 WIB`.
  final String time;

  /// Lintang siap tampil, mis. `9.83 LS`.
  final String latitude;

  /// Bujur siap tampil, mis. `118.98 BT`.
  final String longitude;

  final double magnitude;
  final double depthKm;
  final String region;

  /// Keterangan potensi tsunami; hanya ada di daftar gempa M 5.0+.
  final String? potential;

  /// Wilayah yang merasakan guncangan beserta skala MMI-nya; hanya ada di
  /// daftar gempa dirasakan.
  final String? felt;

  bool get hasTsunamiPotential {
    final text = potential?.toLowerCase() ?? '';
    return text.contains('berpotensi tsunami') && !text.contains('tidak');
  }
}
