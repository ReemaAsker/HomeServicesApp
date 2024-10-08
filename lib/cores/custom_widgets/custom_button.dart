import 'package:flutter/material.dart';

import '../app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text; // Text on the button
  final VoidCallback onTap; // Callback for the button tap
  final double padding; // Padding for the button (optional)
  const CustomButton({
    Key? key,
    required this.text, // Required text
    required this.onTap, // Required onTap callback
    this.padding = 14.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Executes the passed callback when tapped
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                AppColors.primaryColor,
                AppColors.lightPrimaryColor,
              ]),
        ),
        child: Center(
          child: Text(
            text, // Button text
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
