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
        // For display purposes, we need to check if the option's description
        // is in the selected values list
        bool isSelected = false;
        
        // This is a workaround since we're now storing IDs but displaying descriptions
        // The actual selection logic is handled in the parent widget
        for (var value in selectedValues) {
          if (value == option) {
            isSelected = true;
            break;
          }
        }
        
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (_) => onTap(option)
        );
      }).toList(),
    );
  }
}
