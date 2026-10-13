# Gempa Terkini

Aplikasi Flutter satu halaman yang menampilkan gempa bumi terbaru di Indonesia.
Seluruh data diambil langsung dari API terbuka BMKG saat aplikasi dibuka; tidak
ada data yang ditulis manual di dalam kode.

## Sumber data

API publik [Data Gempabumi Terbuka BMKG](https://data.bmkg.go.id/gempabumi/),
gratis dan tanpa API key.

| Kategori di aplikasi | Endpoint |
| --- | --- |
| Dirasakan | `https://data.bmkg.go.id/DataMKG/TEWS/gempadirasakan.json` |
| Magnitudo 5.0+ | `https://data.bmkg.go.id/DataMKG/TEWS/gempaterkini.json` |

Masing-masing endpoint berisi 15 gempa terakhir. Sumber data: BMKG (Badan
Meteorologi, Klimatologi, dan Geofisika).

## Isi halaman

- Kartu gempa terbaru: magnitudo beserta tingkatannya, wilayah, waktu,
  kedalaman, koordinat, serta keterangan dirasakan atau potensi tsunami.
- Ringkasan yang dihitung dari 15 gempa: terkuat, rata-rata, dan terdangkal.
- Daftar gempa sebelumnya.
- Tombol pilihan kategori dan tombol muat ulang.

Warna kotak magnitudo: hijau di bawah 4.0 (Kecil), kuning 4.0–4.9 (Ringan),
jingga 5.0–5.9 (Sedang), merah mulai 6.0 (Kuat).

## Struktur kode

```
lib/
├── main.dart
├── models/
│   └── earthquake.dart            # class immutable + factory fromJson
├── services/
│   └── earthquake_service.dart    # satu-satunya file yang memanggil http
└── ui/
    ├── screens/
    │   └── earthquake_screen.dart # memegang state: loading, sukses, error
    └── widgets/                   # hanya menerima data lewat constructor
        ├── earthquake_stats.dart
        ├── earthquake_tile.dart
        ├── error_view.dart
        ├── latest_earthquake_card.dart
        ├── loading_view.dart
        └── magnitude_badge.dart
```

## Tiga kondisi

| Kondisi | Yang tampil |
| --- | --- |
| Loading | Indikator putar dan teks "Mengambil data gempa dari BMKG…" |
| Sukses | Kartu gempa terbaru, ringkasan, dan daftar gempa |
| Error | Pesan penyebab kegagalan dan tombol **Coba lagi** |

Pesan error dibedakan menurut penyebabnya: tidak ada koneksi, server terlalu
lama merespons, server membalas dengan kode selain 200, atau format data tidak
terbaca.

## Menjalankan

```bash
flutter pub get
flutter run            # atau: flutter run -d chrome
flutter analyze
flutter test
```
