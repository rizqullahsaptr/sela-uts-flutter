import 'package:flutter/material.dart';

import '../models/facility.dart';
import '../models/place.dart';
import '../theme/app_theme.dart';

/// Gambar tempat dengan penanganan aset yang gagal dimuat.
class PlaceImage extends StatelessWidget {
  const PlaceImage({
    super.key,
    required this.place,
    this.height,
    this.width,
    this.borderRadius = AppRadius.card,
  });

  final Place place;
  final double? height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        place.imageAsset,
        height: height,
        width: width,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
        errorBuilder: (context, error, stackTrace) => Container(
          height: height,
          width: width,
          color: AppColors.imageFallback,
          alignment: Alignment.center,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.inkMuted,
                size: 24,
              ),
              SizedBox(height: AppSpace.xs),
              Text('Foto tidak tersedia', style: AppText.caption),
            ],
          ),
        ),
      ),
    );
  }
}

/// Label kecil berikon untuk satu fasilitas.
class FacilityTag extends StatelessWidget {
  const FacilityTag({super.key, required this.facility, this.dense = false});

  final Facility facility;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(facility.icon, size: dense ? 14 : 16, color: AppColors.inkMuted),
        const SizedBox(width: AppSpace.xs),
        Flexible(
          child: Text(
            facility.label,
            style: dense
                ? AppText.caption
                : AppText.bodyMuted.copyWith(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

enum PlaceCardLayout { horizontal, vertical }

/// Kartu tempat untuk halaman daftar dan rekomendasi beranda.
class PlaceCard extends StatelessWidget {
  const PlaceCard({
    super.key,
    required this.place,
    required this.onTap,
    this.layout = PlaceCardLayout.horizontal,
    this.showReason = false,
  });

  final Place place;
  final VoidCallback onTap;
  final PlaceCardLayout layout;
  final bool showReason;

  @override
  Widget build(BuildContext context) {
    final content = layout == PlaceCardLayout.horizontal
        ? _horizontal(context)
        : _vertical(context);

    return Semantics(
      button: true,
      label: '${place.name}, ${place.area}, ${place.priceLabel}',
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(onTap: onTap, child: content),
      ),
    );
  }

  Widget _horizontal(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpace.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlaceImage(place: place, height: 96, width: 96, borderRadius: 10),
          const SizedBox(width: AppSpace.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: AppText.cardTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpace.xs),
                _areaLine(),
                const SizedBox(height: AppSpace.sm),
                _priceLine(),
                if (showReason) ...[
                  const SizedBox(height: AppSpace.sm),
                  Text(
                    place.reason,
                    style: AppText.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: AppSpace.md),
                _facilityRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _vertical(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: PlaceImage(place: place, borderRadius: 0),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place.name,
                style: AppText.cardTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpace.xs),
              _areaLine(),
              const SizedBox(height: AppSpace.sm),
              _priceLine(),
              if (showReason) ...[
                const SizedBox(height: AppSpace.sm),
                Text(
                  place.reason,
                  style: AppText.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: AppSpace.md),
              _facilityRow(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _areaLine() {
    return Row(
      children: [
        const Icon(Icons.place_outlined, size: 15, color: AppColors.inkMuted),
        const SizedBox(width: AppSpace.xs),
        Flexible(
          child: Text(
            place.area,
            style: AppText.bodyMuted,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _priceLine() {
    return Text(
      place.priceLabel,
      style: AppText.label.copyWith(color: AppColors.primary),
    );
  }

  Widget _facilityRow() {
    final facilities = place.facilityObjects.take(3).toList();
    return Wrap(
      spacing: AppSpace.md,
      runSpacing: AppSpace.sm,
      children: [
        for (final facility in facilities)
          FacilityTag(facility: facility, dense: true),
      ],
    );
  }
}
