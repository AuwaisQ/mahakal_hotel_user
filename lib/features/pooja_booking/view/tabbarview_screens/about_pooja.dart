import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class AboutPooja extends StatefulWidget {
  String data;
  AboutPooja({super.key, required this.data});

  @override
  State<AboutPooja> createState() => _AboutPoojaState();
}

class _AboutPoojaState extends State<AboutPooja> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(children: [
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Container(
                height: 20,
                width: 3,
                color: Colors.orange,
              ),
              const SizedBox(width: 8),
              const Text(
                "About Puja",
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    color: Colors.black),
              )
            ],
          ),
          Html(data: widget.data),
        ]),
      ),
    );
    //);
  }
}
