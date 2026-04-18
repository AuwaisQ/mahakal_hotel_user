import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class AboutTemple extends StatefulWidget {
  String data;
  AboutTemple({super.key, required this.data});

  @override
  State<AboutTemple> createState() => _AboutTempleState();
}

class _AboutTempleState extends State<AboutTemple> {
  final bool _showMore = true;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 20,
                width: 3,
                color: Colors.orange,
              ),
              const SizedBox(width: 8),
              const Text(
                "Temples Details",
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    color: Colors.black),
              )
            ],
          ),
          Html(data: widget.data),
        ],
      ),
    );
  }
}
