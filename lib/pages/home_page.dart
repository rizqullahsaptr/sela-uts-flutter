import 'package:flutter/material.dart';

import '../data/place_repository.dart';
import '../models/facility.dart';
import '../models/place.dart';
import '../theme/app_theme.dart';
import '../widgets/filter_chips.dart';
import '../widgets/place_card.dart';
import '../widgets/search_field.dart';
import 'place_detail_page.dart';
import 'places_page.dart';

/// Halaman beranda: pengantar singkat, pencarian, pilihan kebutuhan,
/// dan beberapa rekomendasi dari data lokal.
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.places, required this.dataNote});

  final List<Place> places;
  final String dataNote;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openPlaces(PlaceQuery query) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlacesPage(
          places: widget.places,
          dataNote: widget.dataNote,
          initialQuery: query,
        ),
      ),
    );
  }

  void _submitSearch(String value) {
    if (value.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    _openPlaces(PlaceQuery(keyword: value.trim()));
  }

  void _openMode(StudyMode mode) {
    _openPlaces(PlaceQuery(modes: {mode}));
  }

  List<Place> get _recommendations {
    final sorted = List<Place>.of(widget.places)
      ..sort((a, b) {
        final byMode = b.studyModes.length.compareTo(a.studyModes.length);
        return byMode != 0
            ? byMode
            : a.priceForSorting.compareTo(b.priceForSorting);
      });
    return sorted.take(3).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 720;
    final horizontalPadding = wide ? AppSpace.xxl : AppSpace.lg;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            AppSpace.lg,
            horizontalPadding,
            AppSpace.xxl,
          ),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BrandBar(
                      onBrowseAll: () => _openPlaces(const PlaceQuery()),
                    ),
                    const SizedBox(height: AppSpace.xxl),
                    Text('Cari tempat buat fokus.', style: AppText.title),
                    const SizedBox(height: AppSpace.md),
                    Text(
                      'Sela membantu memilih tempat belajar sesuai suasana, fasilitas, dan kisaran biaya.',
                      style: AppText.bodyMuted.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: AppSpace.xl),
                    SearchField(
                      controller: _searchController,
                      hintText: 'Cari nama tempat atau area',
                      onSubmitted: _submitSearch,
                    ),
                    const SizedBox(height: AppSpace.xl),
                    Text('Mau belajar seperti apa?', style: AppText.label),
                    const SizedBox(height: AppSpace.md),
                    StudyModeChips(
                      selected: const <StudyMode>{},
                      includeAll: true,
                      allSelected: false,
                      onSelectAll: () => _openPlaces(const PlaceQuery()),
                      onToggle: _openMode,
                    ),
                    const SizedBox(height: AppSpace.xxl),
                    _SectionHeader(
                      title: 'Rekomendasi untuk kamu',
                      actionLabel: 'Lihat semua',
                      onAction: () => _openPlaces(const PlaceQuery()),
                    ),
                    const SizedBox(height: AppSpace.lg),
                    for (final place in _recommendations) ...[
                      PlaceCard(
                        place: place,
                        showReason: true,
                        onTap: () => _openDetail(place),
                      ),
                      const SizedBox(height: AppSpace.md),
                    ],
                    const SizedBox(height: AppSpace.md),
                    DemoDataNote(note: widget.dataNote),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(Place place) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            PlaceDetailPage(place: place, dataNote: widget.dataNote),
      ),
    );
  }
}

class _BrandBar extends StatelessWidget {
  const _BrandBar({required this.onBrowseAll});

  final VoidCallback onBrowseAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: const Text(
            'S',
            style: TextStyle(
              fontFamily: AppText.display,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: AppSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sela', style: AppText.label.copyWith(fontSize: 16)),
              Text('Panduan tempat belajar', style: AppText.caption),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: onBrowseAll,
          icon: const Icon(Icons.list_alt_outlined, size: 18),
          label: const Text('Daftar'),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: Text(title, style: AppText.sectionTitle)),
        TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}
