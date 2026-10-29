import 'package:flutter/material.dart';

import '../models/facility.dart';
import '../models/place.dart';
import '../theme/app_theme.dart';
import '../widgets/filter_chips.dart';
import '../widgets/place_card.dart';

/// Halaman detail satu tempat: foto, informasi lengkap, dan kecocokan aktivitas.
class PlaceDetailPage extends StatelessWidget {
  const PlaceDetailPage({
    super.key,
    required this.place,
    required this.dataNote,
  });

  final Place place;
  final String dataNote;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 720;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              'Detail tempat',
              style: AppText.label.copyWith(fontSize: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: wide ? AppSpace.xxl : AppSpace.lg,
                      ),
                      child: AspectRatio(
                        aspectRatio: 16 / 10,
                        child: PlaceImage(
                          place: place,
                          borderRadius: AppRadius.card,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        wide ? AppSpace.xxl : AppSpace.lg,
                        AppSpace.xl,
                        wide ? AppSpace.xxl : AppSpace.lg,
                        AppSpace.xxxl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place.name,
                            style: AppText.title.copyWith(fontSize: 30),
                          ),
                          const SizedBox(height: AppSpace.md),
                          _MetaRow(
                            icon: Icons.place_outlined,
                            text: place.area,
                          ),
                          const SizedBox(height: AppSpace.sm),
                          _MetaRow(
                            icon: Icons.home_work_outlined,
                            text: place.address,
                          ),
                          const SizedBox(height: AppSpace.sm),
                          _MetaRow(
                            icon: Icons.schedule,
                            text: place.openingHours,
                          ),
                          const SizedBox(height: AppSpace.sm),
                          _MetaRow(
                            icon: Icons.payments_outlined,
                            text: place.priceLabel,
                          ),
                          const SizedBox(height: AppSpace.xl),
                          _AtmosphereCard(atmosphere: place.atmosphere),
                          const SizedBox(height: AppSpace.xl),
                          Text(
                            'Tentang tempat ini',
                            style: AppText.sectionTitle,
                          ),
                          const SizedBox(height: AppSpace.md),
                          Text(place.description, style: AppText.bodyText),
                          const SizedBox(height: AppSpace.xl),
                          Text('Cocok untuk', style: AppText.sectionTitle),
                          const SizedBox(height: AppSpace.md),
                          _SuitabilityList(place: place),
                          const SizedBox(height: AppSpace.xl),
                          Text('Fasilitas', style: AppText.sectionTitle),
                          const SizedBox(height: AppSpace.md),
                          _FacilityGrid(facilities: place.facilityObjects),
                          const SizedBox(height: AppSpace.xl),
                          DemoDataNote(note: dataNote, compact: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: AppColors.inkMuted),
        const SizedBox(width: AppSpace.md),
        Expanded(
          child: Text(text, style: AppText.bodyMuted.copyWith(fontSize: 14)),
        ),
      ],
    );
  }
}

class _AtmosphereCard extends StatelessWidget {
  const _AtmosphereCard({required this.atmosphere});

  final String atmosphere;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpace.lg),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suasana',
            style: AppText.caption.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            atmosphere,
            style: AppText.label.copyWith(
              color: AppColors.primary,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

/// Menjelaskan untuk aktivitas apa tempat ini cocok, diambil dari data tempat.
class _SuitabilityList extends StatelessWidget {
  const _SuitabilityList({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    if (place.studyModes.isEmpty) {
      return Text(
        'Belum ada catatan kecocokan aktivitas untuk tempat ini.',
        style: AppText.bodyMuted,
      );
    }
    return Column(
      children: [
        for (final mode in place.studyModes)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(mode.icon, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mode.label, style: AppText.label),
                      const SizedBox(height: 2),
                      Text(
                        place.noteFor(mode) ??
                            'Termasuk tempat yang sesuai untuk aktivitas ini.',
                        style: AppText.bodyMuted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _FacilityGrid extends StatelessWidget {
  const _FacilityGrid({required this.facilities});

  final List<Facility> facilities;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 520 ? 2 : 1;
        final gap = AppSpace.sm;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final facility in facilities)
              SizedBox(
                width: width,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpace.md,
                    vertical: AppSpace.md,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(facility.icon, size: 18, color: AppColors.primary),
                      const SizedBox(width: AppSpace.md),
                      Expanded(
                        child: Text(
                          facility.label,
                          style: AppText.bodyMuted.copyWith(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
