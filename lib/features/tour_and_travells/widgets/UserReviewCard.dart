import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import '../model/tour_reviews_model.dart';
import 'PRatingBarIndicater.dart';

class UserReviewCard extends StatelessWidget {
  final TourReviewList comment;

  const UserReviewCard({super.key, required this.comment});

  String formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat("d MMMM yyyy").format(parsedDate); // 1 March 2025
    } catch (e) {
      print("Date Parsing Error: $e");
      return "Invalid Date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with profile and name
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage("${comment.userImage}"),
                ),
                const SizedBox(width: 10),
                Text(
                  comment.userName ?? "Anonymous",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            // IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
          ],
        ),

        const SizedBox(height: 5),

        // Rating and date
        Row(
          children: [
            PRatingBarIndicater(rating: comment.star!.toDouble()),
            const SizedBox(width: 10),
            Text(
              formatDate("${comment.createdAt ?? ""}"),
              //comment.date ?? "", // Optionally format with intl
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Review Text
        ReadMoreText(
          comment.comment ?? "",
          trimLines: 2,
          trimMode: TrimMode.Line,
          trimExpandedText: "Show less",
          trimCollapsedText: "Show more",
          moreStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange),
          lessStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange),
        ),

        const SizedBox(height: 10),
      ],
    );
  }
}
