import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sela/models/facility.dart';
import 'package:sela/models/place.dart';
import 'package:sela/pages/home_page.dart';
import 'package:sela/pages/place_detail_page.dart';
import 'package:sela/pages/places_page.dart';
import 'package:sela/theme/app_theme.dart';
import 'package:sela/widgets/filter_chips.dart';
import 'package:sela/widgets/place_card.dart';

Place _place({
  required String id,
  required String name,
  required String area,
  List<String> modes = const ['fokus'],
  List<String> facilities = const ['wifi'],
  int priceMin = 10000,
  int priceMax = 20000,
}) {
  return Place.fromJson({
    'id': id,
    'name': name,
    'area': area,
    'address': 'Jl. $area No. 1',
    'description': 'Deskripsi untuk $name.',
    'atmosphere': 'Tenang',
    'studyModes': modes,
    'modeNotes': {'fokus': 'Meja dekat jendela.'},
    'facilities': facilities,
    'priceMin': priceMin,
    'priceMax': priceMax,
    'openingHours': '08.00–20.00 (contoh)',
    'imageAsset': 'assets/images/reading_room.jpg',
  });
}

final _places = [
  _place(
    id: '1',
    name: 'Ruang Arunika',
    area: 'Lowokwaru',
    priceMin: 0,
    priceMax: 0,
  ),
  _place(
    id: '2',
    name: 'Kopi Teduh',
    area: 'Sigura-gura',
    modes: ['fokus', 'diskusi'],
    facilities: ['wifi', 'stopkontak', 'kopi'],
  ),
  _place(
    id: '3',
    name: 'Studio Kolaborasi',
    area: 'Soekarno Hatta',
    modes: ['diskusi'],
    facilities: ['wifi', 'meja_besar'],
    priceMin: 20000,
    priceMax: 45000,
  ),
];

Widget _wrap(Widget child) => MaterialApp(theme: buildSelaTheme(), home: child);

/// Layar uji dibuat cukup tinggi agar seluruh isi halaman terbangun tanpa
/// perlu menggulir. Pengujian overflow memakai ukuran layar sendiri.
Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(600, 1400),
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(_wrap(child));
  await tester.pumpAndSettle();
}

void main() {
  group('Halaman beranda', () {
    testWidgets('menampilkan identitas, pencarian, dan rekomendasi', (
      tester,
    ) async {
      await _pump(tester, HomePage(places: _places, dataNote: 'Data contoh.'));

      expect(find.text('Sela'), findsOneWidget);
      expect(find.text('Cari tempat buat fokus.'), findsOneWidget);
      expect(find.text('Ruang Arunika'), findsOneWidget);
      expect(find.text('Data contoh.'), findsOneWidget);
      expect(find.byType(PlaceCard), findsNWidgets(3));
    });

    testWidgets('kata kunci pencarian membuka daftar dengan hasil tersaring', (
      tester,
    ) async {
      await _pump(tester, HomePage(places: _places, dataNote: 'Data contoh.'));

      await tester.enterText(find.byType(TextField).first, 'kopi');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.byType(PlacesPage), findsOneWidget);
      expect(find.text('Kopi Teduh'), findsOneWidget);
      expect(find.text('Ruang Arunika'), findsNothing);
      expect(find.text('1 tempat ditemukan'), findsOneWidget);
    });

    testWidgets('chip kebutuhan membuka daftar dengan filter suasana', (
      tester,
    ) async {
      await _pump(tester, HomePage(places: _places, dataNote: 'Data contoh.'));

      await tester.tap(find.text('Diskusi kelompok').first);
      await tester.pumpAndSettle();

      expect(find.byType(PlacesPage), findsOneWidget);
      expect(find.text('2 tempat ditemukan'), findsOneWidget);
      expect(find.text('Ruang Arunika'), findsNothing);
    });

    testWidgets('tombol Lihat semua membuka daftar tanpa filter', (
      tester,
    ) async {
      await _pump(tester, HomePage(places: _places, dataNote: 'Data contoh.'));

      await tester.tap(find.text('Lihat semua'));
      await tester.pumpAndSettle();

      expect(find.byType(PlacesPage), findsOneWidget);
      expect(find.text('3 tempat ditemukan'), findsOneWidget);
    });
  });

  group('Halaman daftar', () {
    testWidgets('memilih kartu membuka detail tempat yang benar', (
      tester,
    ) async {
      await _pump(
        tester,
        PlacesPage(places: _places, dataNote: 'Data contoh.'),
      );

      await tester.tap(find.text('Kopi Teduh'));
      await tester.pumpAndSettle();

      expect(find.byType(PlaceDetailPage), findsOneWidget);
      expect(find.text('Jl. Sigura-gura No. 1'), findsOneWidget);
      expect(find.text('Deskripsi untuk Kopi Teduh.'), findsOneWidget);
    });

    testWidgets('kembali dari detail mempertahankan kata kunci dan filter', (
      tester,
    ) async {
      await _pump(
        tester,
        PlacesPage(places: _places, dataNote: 'Data contoh.'),
      );

      await tester.enterText(find.byType(TextField).first, 'kopi');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fokus sendiri'));
      await tester.pumpAndSettle();

      expect(find.text('1 tempat ditemukan'), findsOneWidget);

      await tester.tap(find.text('Kopi Teduh'));
      await tester.pumpAndSettle();
      expect(find.byType(PlaceDetailPage), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(PlacesPage), findsOneWidget);
      expect(find.text('1 tempat ditemukan'), findsOneWidget);
      expect(find.text('Kopi Teduh'), findsOneWidget);
      final field = tester.widget<TextField>(find.byType(TextField).first);
      expect(field.controller?.text, 'kopi');
    });

    testWidgets('hasil kosong menampilkan penjelasan dan tombol hapus filter', (
      tester,
    ) async {
      await _pump(
        tester,
        PlacesPage(places: _places, dataNote: 'Data contoh.'),
      );

      await tester.enterText(find.byType(TextField).first, 'tidak-ada');
      await tester.pumpAndSettle();

      expect(find.text('Belum ada tempat yang cocok'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Hapus filter'));
      await tester.pumpAndSettle();

      expect(find.text('3 tempat ditemukan'), findsOneWidget);
    });

    testWidgets('pengurutan biaya terendah mengubah urutan kartu', (
      tester,
    ) async {
      await _pump(
        tester,
        PlacesPage(places: _places, dataNote: 'Data contoh.'),
      );

      await tester.tap(find.text('Rekomendasi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Biaya terendah').last);
      await tester.pumpAndSettle();

      final cards = tester
          .widgetList<PlaceCard>(find.byType(PlaceCard))
          .toList();
      expect(cards.first.place.name, 'Ruang Arunika');
    });

    testWidgets(
      'memilih fasilitas menyaring hasil dan menghapus filter mengembalikannya',
      (tester) async {
        await _pump(
          tester,
          PlacesPage(places: _places, dataNote: 'Data contoh.'),
        );

        // Panel filter sudah terbuka ketika belum ada filter aktif.
        final mejaBesarChip = find.descendant(
          of: find.byType(FacilityChips),
          matching: find.text(Facility.byId('meja_besar')!.label),
        );
        await tester.tap(mejaBesarChip);
        await tester.pumpAndSettle();

        expect(find.text('1 tempat ditemukan'), findsOneWidget);
        expect(find.text('Studio Kolaborasi'), findsOneWidget);

        await tester.tap(find.text('Hapus filter'));
        await tester.pumpAndSettle();
        expect(find.text('3 tempat ditemukan'), findsOneWidget);
      },
    );
  });

  group('Halaman detail', () {
    testWidgets('menampilkan informasi lengkap tempat', (tester) async {
      await _pump(
        tester,
        PlaceDetailPage(place: _places[2], dataNote: 'Data contoh.'),
      );

      expect(find.text('Studio Kolaborasi'), findsOneWidget);
      expect(find.text('Soekarno Hatta'), findsOneWidget);
      expect(find.text('Rp20.000–45.000'), findsOneWidget);
      expect(find.text('Diskusi kelompok'), findsOneWidget);
      expect(find.text('Data contoh.'), findsOneWidget);
    });
  });

  group('Ketahanan tampilan', () {
    testWidgets('tidak overflow pada layar ponsel kecil dengan teks besar', (
      tester,
    ) async {
      await _pump(
        tester,
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            devicePixelRatio: 1.0,
            textScaler: TextScaler.linear(1.6),
          ),
          child: PlacesPage(
            places: _places,
            dataNote: 'Data contoh panjang untuk menguji pembungkusan teks pada layar sempit.',
          ),
        ),
        size: const Size(320, 568),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('tidak overflow pada layar lebar dengan teks besar', (
      tester,
    ) async {
      await _pump(
        tester,
        MediaQuery(
          data: const MediaQueryData(
            size: Size(1024, 768),
            devicePixelRatio: 1.0,
            textScaler: TextScaler.linear(1.3),
          ),
          child: HomePage(places: _places, dataNote: 'Data contoh.'),
        ),
        size: const Size(1024, 768),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('detail tetap terbaca pada layar sempit', (tester) async {
      await _pump(
        tester,
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            devicePixelRatio: 1.0,
            textScaler: TextScaler.linear(1.5),
          ),
          child: PlaceDetailPage(place: _places[1], dataNote: 'Data contoh.'),
        ),
        size: const Size(320, 568),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Kopi Teduh'), findsOneWidget);
    });

    testWidgets('beranda tidak overflow pada layar sempit dengan teks besar', (
      tester,
    ) async {
      await _pump(
        tester,
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 640),
            devicePixelRatio: 1.0,
            textScaler: TextScaler.linear(1.5),
          ),
          child: HomePage(places: _places, dataNote: 'Data contoh panjang.'),
        ),
        size: const Size(320, 640),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
