import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints; // Optional with default `null`
  final bool obscureText; // Optional with default `false`
  final Widget? suffixIcon; // Optional with default `InputDecoration()`
  final TextStyle? style;
  const CustomTextField({
    Key? key,
    required this.controller, // Required parameter
    required this.labelText, // Required parameter
    this.validator, // Optional parameter with no default
    this.autofillHints, // Optional parameter, defaults to null
    this.obscureText = false, // Optional, defaults to `false`
    this.suffixIcon,
    this.style,
    // Optional, defaults to empty `InputDecoration`
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // RTL for the whole text field
      child: TextFormField(
        autofillHints: autofillHints,
        obscureText: obscureText,
        controller: controller,
        validator: validator, // Uses the passed validator function
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          label: Text(
            labelText,
            // textAlign: TextAlign.center, // Aligns the label text to the right
            style: style ?? TextStyle(fontSize: 14),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.black,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
