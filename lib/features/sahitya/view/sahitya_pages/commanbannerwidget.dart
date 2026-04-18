import 'package:flutter/cupertino.dart';

class CommanBannerWidget extends StatelessWidget {
  final String imagePath;
  const CommanBannerWidget({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image:
              DecorationImage(image: AssetImage(imagePath), fit: BoxFit.fill)),
    );
  }
}
