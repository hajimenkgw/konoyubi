import 'package:flutter/material.dart';
import 'package:konoyubi/ui/theme/constants.dart';

class StyledTextField extends StatelessWidget {
  const StyledTextField({
    Key? key,
    required this.controller,
    this.maxLines = 1,
  }) : super(key: key);

  final TextEditingController controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: const InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.orange,
            width: 2,
          ),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: accentColor),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
