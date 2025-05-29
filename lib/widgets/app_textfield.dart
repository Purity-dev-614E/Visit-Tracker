import 'package:flutter/material.dart';

class AppTextfield extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final prefixIcon;
  final String hintText;

  const AppTextfield({
    Key? key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.prefixIcon,
    this.hintText = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(labelText: label, filled:  true),
      controller: controller,
      maxLines: maxLines,
    );
  }
}