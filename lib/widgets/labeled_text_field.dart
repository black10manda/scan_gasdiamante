import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LabeledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final bool isNumber;
  final FocusNode? focusNode;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    this.enabled = true,
    this.isNumber = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '$label:',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          enabled: enabled,
          focusNode: focusNode,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          inputFormatters: isNumber
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          decoration: InputDecoration(
            hintText: label,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
