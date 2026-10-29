import 'package:flutter/material.dart';

import '../models/facility.dart';
import '../theme/app_theme.dart';

/// Baris chip untuk memilih suasana belajar.
class StudyModeChips extends StatelessWidget {
  const StudyModeChips({
    super.key,
    required this.selected,
    required this.onToggle,
    this.includeAll = false,
    this.allSelected = true,
    this.onSelectAll,
  });

  final Set<StudyMode> selected;
  final ValueChanged<StudyMode> onToggle;
  final bool includeAll;
  final bool allSelected;
  final VoidCallback? onSelectAll;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpace.sm,
      runSpacing: AppSpace.sm,
      children: [
        if (includeAll)
          _Chip(
            label: 'Semua',
            icon: Icons.apps_outlined,
            selected: allSelected,
            onTap: onSelectAll,
          ),
        for (final mode in StudyMode.values)
          _Chip(
            label: mode.label,
            icon: mode.icon,
            selected: selected.contains(mode),
            onTap: () => onToggle(mode),
          ),
      ],
    );
  }
}

/// Baris chip fasilitas yang boleh dipakai sebagai filter.
class FacilityChips extends StatelessWidget {
  const FacilityChips({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpace.sm,
      runSpacing: AppSpace.sm,
      children: [
        for (final id in Facility.filterable)
          if (Facility.byId(id) case final facility?)
            _Chip(
              label: facility.label,
              icon: facility.icon,
              selected: selected.contains(id),
              onTap: () => onToggle(id),
            ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : AppColors.ink;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.primary : AppColors.surface,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.lg,
              vertical: 10,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: foreground),
                const SizedBox(width: AppSpace.sm),
                Flexible(
                  child: Text(
                    label,
                    style: AppText.label.copyWith(color: foreground),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu catatan bahwa seluruh data adalah contoh praktikum.
class DemoDataNote extends StatelessWidget {
  const DemoDataNote({super.key, required this.note, this.compact = false});

  final String note;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? AppSpace.md : AppSpace.lg),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Text(
              note,
              style: AppText.caption.copyWith(
                color: AppColors.primary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Keadaan data yang gagal dimuat, dengan tombol coba lagi.
class DataErrorView extends StatelessWidget {
  const DataErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 32,
                color: AppColors.inkMuted,
              ),
              const SizedBox(height: AppSpace.lg),
              Text(
                'Data belum bisa dimuat',
                style: AppText.sectionTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpace.sm),
              Text(
                message,
                style: AppText.bodyMuted,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpace.xl),
              FilledButton(onPressed: onRetry, child: const Text('Coba lagi')),
            ],
          ),
        ),
      ),
    );
  }
}
