import 'package:flutter_test/flutter_test.dart';
import 'package:sela/models/facility.dart';
import 'package:sela/models/place.dart';

Map<String, dynamic> _json({
  String id = 'x1',
  String name = 'Ruang Uji',
  String area = 'Lowokwaru',
  String address = 'Jl. Uji 1',
  List<String> modes = const ['fokus'],
  List<String> facilities = const ['wifi', 'stopkontak'],
  int priceMin = 10000,
  int priceMax = 20000,
}) {
  return {
    'id': id,
    'name': name,
    'area': area,
    'address': address,
    'description': 'Deskripsi uji.',
    'atmosphere': 'Tenang',
    'studyModes': modes,
    'modeNotes': {'fokus': 'Meja dekat jendela.'},
    'facilities': facilities,
    'priceMin': priceMin,
    'priceMax': priceMax,
    'openingHours': '08.00–20.00 (contoh)',
    'imageAsset': 'assets/images/reading_room.jpg',
  };
}

void main() {
  group('Place.fromJson', () {
    test('membaca seluruh field inti', () {
      final place = Place.fromJson(_json());
      expect(place.id, 'x1');
      expect(place.name, 'Ruang Uji');
      expect(place.area, 'Lowokwaru');
      expect(place.studyModes, [StudyMode.focus]);
      expect(place.facilities, ['wifi', 'stopkontak']);
      expect(place.priceMin, 10000);
      expect(place.priceMax, 20000);
    });

    test('mengabaikan suasana dan fasilitas yang tidak dikenal', () {
      final place = Place.fromJson(
        _json(modes: ['fokus', 'karaoke'], facilities: ['wifi', 'kolam']),
      );
      expect(place.studyModes, [StudyMode.focus]);
      expect(place.facilities, ['wifi']);
    });

    test('memakai nilai aman ketika field hilang atau bertipe salah', () {
      final place = Place.fromJson({
        'id': 7,
        'priceMin': 'gratis',
        'studyModes': 'fokus',
      });
      expect(place.name, 'Tanpa nama');
      expect(place.priceMin, 0);
      expect(place.studyModes, isEmpty);
      expect(place.facilities, isEmpty);
    });

    test('membaca angka desimal sebagai bilangan bulat', () {
      final place = Place.fromJson({
        'id': 'x9',
        'priceMin': 5000.4,
        'priceMax': 9000.6,
      });
      expect(place.priceMin, 5000);
      expect(place.priceMax, 9001);
    });
  });

  group('Format biaya', () {
    test('gratis ketika batas bawah nol', () {
      final place = Place.fromJson(_json(priceMin: 0, priceMax: 0));
      expect(place.priceLabel, 'Gratis');
    });

    test('menampilkan rentang dengan pemisah ribuan', () {
      final place = Place.fromJson(_json(priceMin: 15000, priceMax: 35000));
      expect(place.priceLabel, 'Rp15.000–35.000');
    });

    test('menampilkan satu nilai ketika batas sama', () {
      final place = Place.fromJson(_json(priceMin: 12000, priceMax: 12000));
      expect(place.priceLabel, 'Rp12.000');
    });
  });

  group('Pencarian', () {
    test('cocok pada nama, area, dan alamat tanpa membedakan huruf besar', () {
      final place = Place.fromJson(_json());
      expect(place.matchesQuery('ruang'), isTrue);
      expect(place.matchesQuery('LOWOKWARU'), isTrue);
      expect(place.matchesQuery('jl. uji'), isTrue);
      expect(place.matchesQuery('dinoyo'), isFalse);
    });

    test('kata kunci kosong dianggap cocok', () {
      expect(Place.fromJson(_json()).matchesQuery('   '), isTrue);
    });
  });

  group('Alasan rekomendasi', () {
    test('diambil dari atribut tempat, bukan teks tetap', () {
      final place = Place.fromJson(
        _json(facilities: ['wifi', 'stopkontak', 'ruang_tenang']),
      );
      expect(place.reason, 'Area tenang, tersedia stopkontak.');
    });

    test('memakai suasana ketika fasilitas tenang tidak tersedia', () {
      final place = Place.fromJson(_json(facilities: ['wifi']));
      expect(place.reason, 'Tenang.');
    });
  });

  group('Katalog fasilitas', () {
    test('setiap fasilitas yang boleh difilter ada di katalog', () {
      for (final id in Facility.filterable) {
        expect(
          Facility.byId(id),
          isNotNull,
          reason: 'fasilitas $id tidak ada di katalog',
        );
      }
    });
  });
}
