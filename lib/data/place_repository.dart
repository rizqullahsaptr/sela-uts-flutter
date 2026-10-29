import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../models/facility.dart';
import '../models/place.dart';

/// Hasil pemuatan data: daftar tempat beserta catatan sumber data.
class PlaceData {
  const PlaceData({required this.places, required this.note});

  final List<Place> places;
  final String note;
}

/// Kesalahan yang bisa ditampilkan ke pengguna saat aset data gagal dibaca.
class PlaceDataException implements Exception {
  const PlaceDataException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Lapisan tunggal antara data dan UI.
///
/// Saat ini membaca aset JSON lokal. Bila nanti memakai API, cukup ganti isi
/// [load] dan seluruh halaman tetap bekerja karena hanya mengenal [Place].
class PlaceRepository {
  const PlaceRepository({
    this.assetPath = 'assets/data/places.json',
    this.bundle,
  });

  final String assetPath;
  final AssetBundle? bundle;

  AssetBundle get _assetBundle => bundle ?? rootBundle;

  Future<PlaceData> load() async {
    final String raw;
    try {
      raw = await _assetBundle.loadString(assetPath);
    } catch (_) {
      throw const PlaceDataException(
        'Data tempat tidak dapat dibaca. Pastikan berkas assets/data/places.json '
        'terdaftar pada pubspec.yaml.',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      throw const PlaceDataException('Format data tempat tidak valid.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const PlaceDataException('Struktur data tempat tidak sesuai.');
    }

    final rawPlaces = decoded['places'];
    if (rawPlaces is! List) {
      throw const PlaceDataException(
        'Daftar tempat tidak ditemukan pada data.',
      );
    }

    final places = <Place>[];
    for (final item in rawPlaces) {
      if (item is Map<String, dynamic>) places.add(Place.fromJson(item));
    }

    if (places.isEmpty) {
      throw const PlaceDataException('Data tempat masih kosong.');
    }

    final note = decoded['dataNote'];
    return PlaceData(
      places: List.unmodifiable(places),
      note: note is String && note.trim().isNotEmpty
          ? note.trim()
          : 'Data tempat dan harga merupakan contoh untuk praktikum.',
    );
  }
}

/// Kriteria penyaringan dan pengurutan yang dipakai halaman daftar.
///
/// Objek ini bersifat immutable supaya keadaan filter mudah dibandingkan,
/// disalin, dan diuji tanpa efek samping.
class PlaceQuery {
  const PlaceQuery({
    this.keyword = '',
    this.modes = const <StudyMode>{},
    this.facilities = const <String>{},
    this.sort = PlaceSort.recommended,
  });

  final String keyword;
  final Set<StudyMode> modes;
  final Set<String> facilities;
  final PlaceSort sort;

  bool get hasFilters =>
      keyword.trim().isNotEmpty || modes.isNotEmpty || facilities.isNotEmpty;

  int get activeFilterCount => modes.length + facilities.length;

  PlaceQuery copyWith({
    String? keyword,
    Set<StudyMode>? modes,
    Set<String>? facilities,
    PlaceSort? sort,
  }) {
    return PlaceQuery(
      keyword: keyword ?? this.keyword,
      modes: modes ?? this.modes,
      facilities: facilities ?? this.facilities,
      sort: sort ?? this.sort,
    );
  }

  PlaceQuery cleared() => PlaceQuery(sort: sort);

  PlaceQuery toggledMode(StudyMode mode) {
    final next = Set<StudyMode>.of(modes);
    if (!next.remove(mode)) next.add(mode);
    return copyWith(modes: next);
  }

  PlaceQuery toggledFacility(String id) {
    final next = Set<String>.of(facilities);
    if (!next.remove(id)) next.add(id);
    return copyWith(facilities: next);
  }

  /// Terapkan pencarian, filter, lalu pengurutan.
  ///
  /// Filter antar-kategori digabung dengan logika DAN: tempat harus memenuhi
  /// semua suasana terpilih dan memiliki semua fasilitas terpilih. Ini membuat
  /// hasil makin sempit ketika pengguna menambah kriteria.
  List<Place> apply(List<Place> source) {
    final filtered = source.where((place) {
      if (!place.matchesQuery(keyword)) return false;
      if (modes.isNotEmpty && !modes.every(place.supports)) return false;
      if (facilities.isNotEmpty &&
          !facilities.every(place.facilities.contains)) {
        return false;
      }
      return true;
    }).toList();

    filtered.sort((a, b) {
      switch (sort) {
        case PlaceSort.nameAsc:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case PlaceSort.priceAsc:
          final byPrice = a.priceForSorting.compareTo(b.priceForSorting);
          return byPrice != 0
              ? byPrice
              : a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case PlaceSort.recommended:
          // Tempat yang cocok dengan lebih banyak suasana dan lebih murah tampil lebih dulu.
          final byMode = b.studyModes.length.compareTo(a.studyModes.length);
          if (byMode != 0) return byMode;
          return a.priceForSorting.compareTo(b.priceForSorting);
      }
    });
    return filtered;
  }
}

enum PlaceSort {
  recommended('Rekomendasi'),
  nameAsc('Nama A–Z'),
  priceAsc('Biaya terendah');

  const PlaceSort(this.label);

  final String label;
}
