import 'package:flutter/material.dart';

import 'data/place_repository.dart';
import 'pages/home_page.dart';
import 'theme/app_theme.dart';
import 'widgets/filter_chips.dart';

/// Titik masuk aplikasi: memuat data sekali, lalu menyerahkannya ke beranda.
///
/// Pemuatan data dipisahkan dari widget halaman supaya sumber data dapat
/// diganti API pada tahap berikutnya tanpa mengubah tampilan.
class SelaApp extends StatefulWidget {
  const SelaApp({super.key, this.repository = const PlaceRepository()});

  final PlaceRepository repository;

  @override
  State<SelaApp> createState() => _SelaAppState();
}

class _SelaAppState extends State<SelaApp> {
  late Future<PlaceData> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.load();
  }

  void _retry() {
    setState(() => _future = widget.repository.load());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sela',
      debugShowCheckedModeBanner: false,
      theme: buildSelaTheme(),
      home: FutureBuilder<PlaceData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
            );
          }
          if (snapshot.hasError) {
            final error = snapshot.error;
            final message = error is PlaceDataException
                ? error.message
                : 'Terjadi kesalahan saat membaca data tempat.';
            return Scaffold(
              body: SafeArea(
                child: DataErrorView(message: message, onRetry: _retry),
              ),
            );
          }
          final data = snapshot.requireData;
          return HomePage(places: data.places, dataNote: data.note);
        },
      ),
    );
  }
}
