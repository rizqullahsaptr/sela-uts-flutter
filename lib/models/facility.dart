import 'package:flutter/material.dart';

/// Kebutuhan belajar yang dipakai sebagai filter suasana.
enum StudyMode {
  focus('fokus', 'Fokus sendiri', Icons.person_outline),
  group('diskusi', 'Diskusi kelompok', Icons.groups_outlined);

  const StudyMode(this.jsonValue, this.label, this.icon);

  final String jsonValue;
  final String label;
  final IconData icon;

  static StudyMode? fromJson(String value) {
    for (final mode in StudyMode.values) {
      if (mode.jsonValue == value) return mode;
    }
    return null;
  }
}

/// Fasilitas yang ditampilkan di kartu dan halaman detail.
/// Label dan ikon disimpan di sini agar data JSON tetap ringkas dan ikon konsisten.
class Facility {
  const Facility({required this.id, required this.label, required this.icon});

  final String id;
  final String label;
  final IconData icon;

  static const Map<String, Facility> catalog = {
    'wifi': Facility(id: 'wifi', label: 'Wi-Fi', icon: Icons.wifi),
    'stopkontak': Facility(
      id: 'stopkontak',
      label: 'Stopkontak',
      icon: Icons.power_outlined,
    ),
    'ac': Facility(id: 'ac', label: 'AC', icon: Icons.ac_unit_outlined),
    'ruang_tenang': Facility(
      id: 'ruang_tenang',
      label: 'Ruang tenang',
      icon: Icons.volume_off_outlined,
    ),
    'meja_besar': Facility(
      id: 'meja_besar',
      label: 'Meja besar',
      icon: Icons.table_bar_outlined,
    ),
    'kopi': Facility(
      id: 'kopi',
      label: 'Kopi & camilan',
      icon: Icons.local_cafe_outlined,
    ),
    'parkir': Facility(
      id: 'parkir',
      label: 'Parkir',
      icon: Icons.local_parking_outlined,
    ),
  };

  /// Fasilitas yang boleh dipilih sebagai filter. Dibatasi empat agar mudah dipindai.
  static const List<String> filterable = [
    'wifi',
    'stopkontak',
    'ruang_tenang',
    'meja_besar',
  ];

  static Facility? byId(String id) => catalog[id];
}
