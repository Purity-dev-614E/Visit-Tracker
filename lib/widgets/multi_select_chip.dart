import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MultiSelectChip extends StatelessWidget {
  final List<String> options;
  final List<String> selectedValues;
  final void Function(String) onTap;

  const MultiSelectChip({
    super.key,
    required this.options,
    required this.selectedValues,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
        children: options.map((option) {
          final isSelected = selectedValues.contains(option);
          return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected : (_) => onTap(option)
          );
        }).toList(),
    );
  }
}
