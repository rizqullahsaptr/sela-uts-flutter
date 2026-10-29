import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Kolom pencarian dengan tombol hapus yang hanya muncul saat ada isi.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.onChanged,
    this.hintText = 'Cari nama atau area',
    this.autofocus = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextField(
          controller: controller,
          autofocus: autofocus,
          textInputAction: TextInputAction.search,
          onSubmitted: onSubmitted,
          onChanged: onChanged,
          style: AppText.bodyText,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.inkMuted,
              size: 22,
            ),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Hapus kata kunci',
                    icon: const Icon(
                      Icons.close,
                      size: 20,
                      color: AppColors.inkMuted,
                    ),
                    onPressed: () {
                      controller.clear();
                      onChanged?.call('');
                      onSubmitted('');
                    },
                  ),
          ),
        );
      },
    );
  }
}
