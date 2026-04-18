import 'package:flutter/material.dart';

import 'PRatingProgressIndicater.dart';

class OverAllProductRating extends StatelessWidget {
  final Map<int, int> starCounts;
  final double avgRating;

  const OverAllProductRating({
    super.key,
    required this.starCounts,
    required this.avgRating,
  });

  @override
  Widget build(BuildContext context) {
    int total = starCounts.values.fold(0, (a, b) => a + b);

    double getRatio(int star) {
      if (total == 0) return 0;
      return starCounts[star]! / total;
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            avgRating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ),
        Expanded(
          flex: 7,
          child: Column(
            children: List.generate(5, (index) {
              int star = 5 - index;
              return PRatingProgressIndicater(
                text: '$star',
                value: getRatio(star),
              );
            }),
          ),
        ),
      ],
    );
  }
}
