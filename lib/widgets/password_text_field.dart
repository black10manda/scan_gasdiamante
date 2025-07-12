import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;

  const PasswordTextField({
    super.key,
    required this.controller,
    this.label = 'Contraseña',
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '${widget.label}:',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
          ),
        ),
        const SizedBox(height: 2),
        TextField(
          controller: widget.controller,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: widget.label,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
