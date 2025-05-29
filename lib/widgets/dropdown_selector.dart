import 'package:flutter/material.dart';

class DropdownSelector <T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;

  const DropdownSelector({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(labelText: label, filled: true),
      value: value,
      items: items,
      onChanged: onChanged,
      isExpanded: true,
    );
  }
}