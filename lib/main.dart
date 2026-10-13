import 'package:flutter/material.dart';

import 'ui/screens/earthquake_screen.dart';

void main() {
  runApp(const GempaTerkiniApp());
}

class GempaTerkiniApp extends StatelessWidget {
  const GempaTerkiniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gempa Terkini',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: const EarthquakeScreen(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final colors = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1C5CAB),
      brightness: brightness,
    );

    return ThemeData(
      colorScheme: colors,
      // Warna tetap agar AppBar tidak berubah saat daftar digulir di bawahnya.
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        scrolledUnderElevation: 0,
      ),
    );
  }
}
