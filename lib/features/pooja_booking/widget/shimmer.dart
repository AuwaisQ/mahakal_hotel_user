import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerScreenPooja extends StatelessWidget {
  const ShimmerScreenPooja({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 10, // Number of items in the list
            itemBuilder: (BuildContext context, int index) {
              // itemBuilder function returns a widget for each item in the list
              return Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.orange.shade50,
                direction: ShimmerDirection.ttb,
                child: Container(
                  height: 250,
                  margin:
                      const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        "sau",
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Text(
                        " to ",
                        style: TextStyle(color: Colors.grey, letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
