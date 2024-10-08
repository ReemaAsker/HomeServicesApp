import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../logic/authLogic.dart';

class DisplayRating extends StatelessWidget {
  final String userId;

  DisplayRating({Key? key, required this.userId}) : super(key: key);

  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream:
          _auth.ratingOfCurrentProvider(userId), // Use Stream instead of Future
      builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show loading indicator
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Handle error state
        } else {
          // When the data is available, display the RatingBarIndicator
          return RatingBarIndicator(
            rating: snapshot.data ?? 0.0, // Use the fetched rating
            itemBuilder: (context, index) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            itemCount: 5,
            itemSize: 30.0,
            direction: Axis.horizontal,
          );
        }
      },
    );
  }
}
