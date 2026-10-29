import 'package:flutter/material.dart';

import '../data/place_repository.dart';
import '../models/place.dart';
import '../theme/app_theme.dart';
import '../widgets/filter_chips.dart';
import '../widgets/place_card.dart';
import '../widgets/search_field.dart';
import 'place_detail_page.dart';

/// Halaman daftar tempat: pencarian, filter, pengurutan, dan hasil.
///
/// Keadaan filter disimpan pada State halaman ini sehingga tetap utuh ketika
/// pengguna membuka detail lalu kembali.
class PlacesPage extends StatefulWidget {
  const PlacesPage({
    super.key,
    required this.places,
    required this.dataNote,
    this.initialQuery = const PlaceQuery(),
  });

  final List<Place> places;
  final String dataNote;
  final PlaceQuery initialQuery;

  @override
  State<PlacesPage> createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage> {
  late final TextEditingController _searchController;
  late PlaceQuery _query;
  bool _filtersExpanded = true;

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery;
    _searchController = TextEditingController(text: _query.keyword);
    _filtersExpanded = _query.modes.isEmpty && _query.facilities.isEmpty;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _update(PlaceQuery next) => setState(() => _query = next);

  void _resetFilters() {
    _searchController.clear();
    _update(_query.cleared());
  }

  void _openDetail(Place place) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            PlaceDetailPage(place: place, dataNote: widget.dataNote),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _query.apply(widget.places);
    final wide = MediaQuery.sizeOf(context).width >= 720;
    final padding = wide ? AppSpace.xxl : AppSpace.lg;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(
          'Daftar tempat',
          style: AppText.label.copyWith(fontSize: 16),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                padding,
                AppSpace.sm,
                padding,
                AppSpace.xxl,
              ),
              children: [
                SearchField(
                  controller: _searchController,
                  hintText: 'Cari nama atau area',
                  onChanged: (value) =>
                      _update(_query.copyWith(keyword: value)),
                  onSubmitted: (value) =>
                      _update(_query.copyWith(keyword: value)),
                ),
                const SizedBox(height: AppSpace.md),
                _FilterSummaryBar(
                  query: _query,
                  expanded: _filtersExpanded,
                  onToggleExpanded: () =>
                      setState(() => _filtersExpanded = !_filtersExpanded),
                  onReset: _query.hasFilters ? _resetFilters : null,
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 180),
                  crossFadeState: _filtersExpanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Padding(
                    padding: const EdgeInsets.only(top: AppSpace.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kebutuhan', style: AppText.caption),
                        const SizedBox(height: AppSpace.sm),
                        StudyModeChips(
                          selected: _query.modes,
                          onToggle: (mode) => _update(_query.toggledMode(mode)),
                        ),
                        const SizedBox(height: AppSpace.lg),
                        Text('Fasilitas', style: AppText.caption),
                        const SizedBox(height: AppSpace.sm),
                        FacilityChips(
                          selected: _query.facilities,
                          onToggle: (id) => _update(_query.toggledFacility(id)),
                        ),
                      ],
                    ),
                  ),
                  secondChild: const SizedBox(width: double.infinity),
                ),
                const SizedBox(height: AppSpace.lg),
                _ResultHeader(
                  count: results.length,
                  sort: _query.sort,
                  onSortChanged: (sort) => _update(_query.copyWith(sort: sort)),
                ),
                const SizedBox(height: AppSpace.md),
                if (results.isEmpty)
                  _EmptyResults(onReset: _resetFilters)
                else
                  _ResultsGrid(
                    places: results,
                    wide: wide,
                    onOpen: _openDetail,
                  ),
                const SizedBox(height: AppSpace.xl),
                DemoDataNote(note: widget.dataNote, compact: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterSummaryBar extends StatelessWidget {
  const _FilterSummaryBar({
    required this.query,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onReset,
  });

  final PlaceQuery query;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton.icon(
          onPressed: onToggleExpanded,
          icon: Icon(expanded ? Icons.tune : Icons.tune_outlined, size: 18),
          label: Text(
            query.activeFilterCount == 0
                ? 'Filter'
                : 'Filter (${query.activeFilterCount})',
          ),
        ),
        const Spacer(),
        if (onReset != null)
          TextButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Hapus filter'),
          ),
      ],
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({
    required this.count,
    required this.sort,
    required this.onSortChanged,
  });

  final int count;
  final PlaceSort sort;
  final ValueChanged<PlaceSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            count == 0 ? 'Tidak ada hasil' : '$count tempat ditemukan',
            style: AppText.label,
          ),
        ),
        PopupMenuButton<PlaceSort>(
          tooltip: 'Urutkan hasil',
          initialValue: sort,
          onSelected: onSortChanged,
          itemBuilder: (context) => [
            for (final option in PlaceSort.values)
              PopupMenuItem<PlaceSort>(
                value: option,
                child: Row(
                  children: [
                    Icon(
                      option == sort ? Icons.check : Icons.sort,
                      size: 18,
                      color: option == sort
                          ? AppColors.primary
                          : AppColors.inkMuted,
                    ),
                    const SizedBox(width: AppSpace.md),
                    Text(option.label, style: AppText.bodyText),
                  ],
                ),
              ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.md,
              vertical: AppSpace.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.swap_vert,
                  size: 16,
                  color: AppColors.inkMuted,
                ),
                const SizedBox(width: AppSpace.xs),
                Text(sort.label, style: AppText.label),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultsGrid extends StatelessWidget {
  const _ResultsGrid({
    required this.places,
    required this.wide,
    required this.onOpen,
  });

  final List<Place> places;
  final bool wide;
  final ValueChanged<Place> onOpen;

  @override
  Widget build(BuildContext context) {
    if (!wide) {
      return Column(
        children: [
          for (final place in places) ...[
            PlaceCard(place: place, onTap: () => onOpen(place)),
            const SizedBox(height: AppSpace.md),
          ],
        ],
      );
    }

    // Lebar besar memakai grid dua kolom dengan kartu bergambar di atas.
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 2 : 1;
        final gap = AppSpace.lg;
        final itemWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final place in places)
              SizedBox(
                width: itemWidth,
                child: PlaceCard(
                  place: place,
                  layout: PlaceCardLayout.vertical,
                  onTap: () => onOpen(place),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpace.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_outlined,
            size: 30,
            color: AppColors.inkMuted,
          ),
          const SizedBox(height: AppSpace.md),
          Text(
            'Belum ada tempat yang cocok',
            style: AppText.cardTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            'Coba kata kunci lain, kurangi fasilitas yang dipilih, atau hapus semua filter.',
            style: AppText.bodyMuted,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpace.lg),
          FilledButton(onPressed: onReset, child: const Text('Hapus filter')),
        ],
      ),
    );
  }
}
