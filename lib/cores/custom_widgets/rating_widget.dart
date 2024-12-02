import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:home_services_app/cores/logic/firebaseLogic.dart';

import '../logic/firebaseLogic.dart';

class DisplayRating extends StatelessWidget {
  final String userId;

  DisplayRating({Key? key, required this.userId}) : super(key: key);

  final _auth = FirebaseServices();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: _auth.ratingOfCurrentProvider(userId),
      builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return RatingBarIndicator(
            rating: snapshot.data ?? 0.0,
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
