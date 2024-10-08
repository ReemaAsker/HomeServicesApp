import 'package:flutter/material.dart';

class My_snackBar extends StatelessWidget {
  const My_snackBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  static void showSnackBar(BuildContext context, String message, Color color) {
    var snackBar = SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.right,
      ),
      backgroundColor: color,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
