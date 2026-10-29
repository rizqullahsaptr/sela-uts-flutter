import 'facility.dart';

/// Model satu tempat belajar.
///
/// Bentuk field mengikuti `assets/data/places.json` sehingga penggantian sumber
/// data lokal menjadi API hanya perlu menyesuaikan lapisan repository.
class Place {
  const Place({
    required this.id,
    required this.name,
    required this.area,
    required this.address,
    required this.description,
    required this.atmosphere,
    required this.studyModes,
    required this.modeNotes,
    required this.facilities,
    required this.priceMin,
    required this.priceMax,
    required this.openingHours,
    required this.imageAsset,
  });

  final String id;
  final String name;
  final String area;
  final String address;
  final String description;
  final String atmosphere;
  final List<StudyMode> studyModes;

  /// Catatan kecocokan per aktivitas, misalnya untuk "fokus" atau "diskusi".
  final Map<StudyMode, String> modeNotes;

  final List<String> facilities;
  final int priceMin;
  final int priceMax;
  final String openingHours;
  final String imageAsset;

  factory Place.fromJson(Map<String, dynamic> json) {
    final modes = <StudyMode>[];
    final rawModes = json['studyModes'];
    if (rawModes is List) {
      for (final value in rawModes) {
        if (value is! String) continue;
        final mode = StudyMode.fromJson(value);
        if (mode != null) modes.add(mode);
      }
    }

    final notes = <StudyMode, String>{};
    final rawNotes = json['modeNotes'];
    if (rawNotes is Map) {
      rawNotes.forEach((key, value) {
        final mode = key is String ? StudyMode.fromJson(key) : null;
        if (mode != null && value is String) notes[mode] = value;
      });
    }

    final facilityIds = <String>[];
    final rawFacilities = json['facilities'];
    if (rawFacilities is List) {
      for (final value in rawFacilities) {
        if (value is String && Facility.byId(value) != null) {
          facilityIds.add(value);
        }
      }
    }

    return Place(
      id: _string(json['id'], ''),
      name: _string(json['name'], 'Tanpa nama'),
      area: _string(json['area'], ''),
      address: _string(json['address'], ''),
      description: _string(json['description'], ''),
      atmosphere: _string(json['atmosphere'], ''),
      studyModes: modes,
      modeNotes: notes,
      facilities: facilityIds,
      priceMin: _int(json['priceMin']),
      priceMax: _int(json['priceMax']),
      openingHours: _string(json['openingHours'], ''),
      imageAsset: _string(json['imageAsset'], ''),
    );
  }

  static String _string(Object? value, String fallback) =>
      value is String && value.trim().isNotEmpty ? value.trim() : fallback;

  static int _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Ringkasan biaya, misalnya "Gratis" atau "Rp15.000–35.000".
  String get priceLabel {
    if (priceMin <= 0 && priceMax <= 0) return 'Gratis';
    if (priceMin <= 0) return 'Gratis–${_rupiah(priceMax)}';
    if (priceMin == priceMax) return _rupiah(priceMin);
    return '${_rupiah(priceMin)}–${_rupiah(priceMax, withPrefix: false)}';
  }

  /// Nilai biaya untuk pengurutan termurah. Tempat gratis mendapat nilai 0.
  int get priceForSorting => priceMin <= 0 ? 0 : priceMin;

  List<Facility> get facilityObjects => facilities
      .map(Facility.byId)
      .whereType<Facility>()
      .toList(growable: false);

  bool supports(StudyMode mode) => studyModes.contains(mode);

  String? noteFor(StudyMode mode) => modeNotes[mode];

  /// Kata kunci pencarian mencakup nama, area, dan alamat contoh.
  bool matchesQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) ||
        area.toLowerCase().contains(q) ||
        address.toLowerCase().contains(q);
  }

  /// Alasan singkat yang benar-benar berasal dari atribut tempat, bukan karangan.
  String get reason {
    final parts = <String>[];
    if (facilities.contains('ruang_tenang')) {
      parts.add('area tenang');
    } else if (atmosphere.isNotEmpty) {
      parts.add(atmosphere.toLowerCase());
    }
    if (facilities.contains('stopkontak')) parts.add('tersedia stopkontak');
    if (parts.isEmpty && facilities.isNotEmpty) {
      parts.add('fasilitas ${facilityObjects.first.label.toLowerCase()}');
    }
    if (parts.isEmpty) return priceLabel;
    final sentence = parts.join(', ');
    return '${sentence[0].toUpperCase()}${sentence.substring(1)}.';
  }

  static String _rupiah(int value, {bool withPrefix = true}) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return withPrefix ? 'Rp$buffer' : buffer.toString();
  }
}
