import 'package:flutter_test/flutter_test.dart';
import 'package:gempa_terkini/models/earthquake.dart';

void main() {
  const feltJson = <String, dynamic>{
    'Tanggal': '13 Okt 2026',
    'Jam': '16:48:27 WIB',
    'DateTime': '2026-10-13T09:48:27+00:00',
    'Coordinates': '-9.83,118.98',
    'Lintang': '9.83 LS',
    'Bujur': '118.98 BT',
    'Magnitude': '4.3',
    'Kedalaman': '9 km',
    'Wilayah': 'Pusat gempa berada di laut 27 km selatan Kodi',
    'Dirasakan': 'III Kab. Sumba Barat Daya',
  };

  group('Earthquake.fromJson', () {
    test('mengubah teks dari BMKG menjadi nilai bertipe', () {
      final quake = Earthquake.fromJson(feltJson);

      expect(quake.dateTime, DateTime.utc(2026, 10, 13, 9, 48, 27));
      expect(quake.date, '13 Okt 2026');
      expect(quake.time, '16:48:27 WIB');
      expect(quake.latitude, '9.83 LS');
      expect(quake.longitude, '118.98 BT');
      expect(quake.magnitude, 4.3);
      expect(quake.depthKm, 9);
      expect(quake.region, 'Pusat gempa berada di laut 27 km selatan Kodi');
      expect(quake.felt, 'III Kab. Sumba Barat Daya');
      expect(quake.potential, isNull);
    });

    test('menolak JSON yang kehilangan field wajib', () {
      final incomplete = Map<String, dynamic>.of(feltJson)..remove('Magnitude');

      expect(() => Earthquake.fromJson(incomplete), throwsA(isA<TypeError>()));
    });

    test('menolak magnitudo yang bukan angka', () {
      final invalid = {...feltJson, 'Magnitude': 'besar'};

      expect(
        () => Earthquake.fromJson(invalid),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('hasTsunamiPotential', () {
    Earthquake withPotential(String? potential) =>
        Earthquake.fromJson({...feltJson, 'Potensi': ?potential});

    test('false bila BMKG menyatakan tidak berpotensi', () {
      expect(
        withPotential('Tidak berpotensi tsunami').hasTsunamiPotential,
        isFalse,
      );
    });

    test('true bila BMKG menyatakan berpotensi', () {
      expect(
        withPotential('Berpotensi tsunami untuk diteruskan pada masyarakat')
            .hasTsunamiPotential,
        isTrue,
      );
    });

    test('false bila keterangan potensi tidak ada', () {
      expect(withPotential(null).hasTsunamiPotential, isFalse);
    });
  });
}
