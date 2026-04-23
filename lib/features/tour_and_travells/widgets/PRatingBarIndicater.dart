import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class PRatingBarIndicater extends StatelessWidget {
  const PRatingBarIndicater({
    super.key,
    required this.rating,
  });

  final double rating;
  @override
  Widget build(BuildContext context) {
    return RatingBarIndicator(
        rating: rating,
        itemSize: 20,
        unratedColor: Colors.grey,
        itemBuilder: (_, __) => const Icon(
              Icons.star,
              color: Colors.blue,
            ));
  }
}
