import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sela/data/place_repository.dart';
import 'package:sela/models/facility.dart';
import 'package:sela/models/place.dart';

/// Bundle palsu yang mengembalikan isi tertentu tanpa membaca aset nyata.
class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this.payload);

  final String payload;
  int loadCount = 0;

  @override
  Future<ByteData> load(String key) async {
    loadCount++;
    final bytes = utf8.encode(payload);
    return ByteData.view(Uint8List.fromList(bytes).buffer);
  }
}

class _ThrowingBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async => throw Exception('aset hilang');
}

Place _place({
  required String id,
  required String name,
  String area = 'Lowokwaru',
  List<String> modes = const ['fokus'],
  List<String> facilities = const ['wifi'],
  int priceMin = 10000,
}) {
  return Place.fromJson({
    'id': id,
    'name': name,
    'area': area,
    'address': 'Jl. $area',
    'description': 'Deskripsi.',
    'atmosphere': 'Tenang',
    'studyModes': modes,
    'modeNotes': const {},
    'facilities': facilities,
    'priceMin': priceMin,
    'priceMax': priceMin + 5000,
    'openingHours': '08.00–20.00',
    'imageAsset': 'assets/images/reading_room.jpg',
  });
}

void main() {
  group('PlaceRepository', () {
    test('membaca JSON dan mengubahnya menjadi Place', () async {
      final payload = jsonEncode({
        'dataNote': 'Data contoh.',
        'places': [
          {
            'id': 'a',
            'name': 'Tempat A',
            'area': 'Dinoyo',
            'address': 'Jl. A',
            'description': 'D',
            'atmosphere': 'Tenang',
            'studyModes': ['fokus'],
            'facilities': ['wifi'],
            'priceMin': 0,
            'priceMax': 5000,
            'openingHours': '08.00–17.00',
            'imageAsset': 'assets/images/reading_room.jpg',
          },
        ],
      });
      final data = await PlaceRepository(bundle: _FakeBundle(payload)).load();
      expect(data.places, hasLength(1));
      expect(data.places.first.name, 'Tempat A');
      expect(data.note, 'Data contoh.');
    });

    test(
      'memberi pesan yang dapat ditampilkan saat aset gagal dibaca',
      () async {
        await expectLater(
          PlaceRepository(bundle: _ThrowingBundle()).load(),
          throwsA(isA<PlaceDataException>()),
        );
      },
    );

    test('menolak JSON yang rusak', () async {
      await expectLater(
        PlaceRepository(bundle: _FakeBundle('{bukan json')).load(),
        throwsA(isA<PlaceDataException>()),
      );
    });

    test('menolak struktur tanpa daftar places', () async {
      await expectLater(
        PlaceRepository(bundle: _FakeBundle('{"places": {}}')).load(),
        throwsA(isA<PlaceDataException>()),
      );
    });

    test('menolak daftar places yang kosong', () async {
      await expectLater(
        PlaceRepository(bundle: _FakeBundle('{"places": []}')).load(),
        throwsA(isA<PlaceDataException>()),
      );
    });
  });

  group('PlaceQuery.apply', () {
    final places = [
      _place(id: '1', name: 'Arunika', area: 'Lowokwaru', priceMin: 0),
      _place(
        id: '2',
        name: 'Kopi Teduh',
        area: 'Sigura-gura',
        modes: ['fokus', 'diskusi'],
        facilities: ['wifi', 'stopkontak', 'kopi'],
        priceMin: 15000,
      ),
      _place(
        id: '3',
        name: 'Studio Kolaborasi',
        area: 'Soekarno Hatta',
        modes: ['diskusi'],
        facilities: ['wifi', 'meja_besar'],
        priceMin: 20000,
      ),
    ];

    List<String> ids(List<Place> result) => result.map((p) => p.id).toList();

    test('tanpa filter mengembalikan semua tempat', () {
      expect(const PlaceQuery().apply(places), hasLength(3));
    });

    test('pencarian menyaring berdasarkan nama dan area', () {
      expect(ids(const PlaceQuery(keyword: 'kopi').apply(places)), ['2']);
      expect(ids(const PlaceQuery(keyword: 'dinoyo').apply(places)), isEmpty);
    });

    test('filter suasana tunggal', () {
      expect(ids(const PlaceQuery(modes: {StudyMode.group}).apply(places)), [
        '2',
        '3',
      ]);
    });

    test('dua suasana sekaligus memakai logika DAN', () {
      expect(
        ids(
          const PlaceQuery(modes: {StudyMode.focus, StudyMode.group})
              .apply(places),
        ),
        ['2'],
      );
    });

    test('dua fasilitas sekaligus memakai logika DAN', () {
      expect(
        ids(const PlaceQuery(facilities: {'wifi', 'meja_besar'}).apply(places)),
        ['3'],
      );
    });

    test('kombinasi kata kunci, suasana, dan fasilitas', () {
      final query = PlaceQuery(
        keyword: 'studio',
        modes: {StudyMode.group},
        facilities: {'meja_besar'},
      );
      expect(ids(query.apply(places)), ['3']);
    });

    test('pengurutan nama A–Z', () {
      expect(ids(const PlaceQuery(sort: PlaceSort.nameAsc).apply(places)), [
        '1',
        '2',
        '3',
      ]);
    });

    test('pengurutan biaya terendah menempatkan tempat gratis lebih dulu', () {
      expect(ids(const PlaceQuery(sort: PlaceSort.priceAsc).apply(places)), [
        '1',
        '2',
        '3',
      ]);
    });

    test('rekomendasi mendahulukan tempat dengan lebih banyak suasana', () {
      expect(const PlaceQuery().apply(places).first.id, '2');
    });

    test('hasil kosong ketika tidak ada yang cocok', () {
      expect(const PlaceQuery(keyword: 'tidak-ada').apply(places), isEmpty);
    });

    test('reset filter mempertahankan pilihan pengurutan', () {
      final query = const PlaceQuery(
        keyword: 'kopi',
        modes: {StudyMode.group},
        sort: PlaceSort.priceAsc,
      );
      final cleared = query.cleared();
      expect(cleared.keyword, isEmpty);
      expect(cleared.modes, isEmpty);
      expect(cleared.facilities, isEmpty);
      expect(cleared.sort, PlaceSort.priceAsc);
      expect(cleared.hasFilters, isFalse);
    });

    test('toggle suasana menambah lalu menghapus pilihan', () {
      final once = const PlaceQuery().toggledMode(StudyMode.group);
      expect(once.modes, {StudyMode.group});
      final twice = once.toggledMode(StudyMode.group);
      expect(twice.modes, isEmpty);
    });

    test('toggle fasilitas menambah lalu menghapus pilihan', () {
      final once = const PlaceQuery().toggledFacility('wifi');
      expect(once.facilities, {'wifi'});
      expect(once.toggledFacility('wifi').facilities, isEmpty);
    });
  });

  group('Katalog fasilitas', () {
    test('filter fasilitas memakai id yang dikenal', () {
      for (final id in Facility.filterable) {
        expect(Facility.byId(id)?.label, isNotEmpty);
      }
    });
  });
}
