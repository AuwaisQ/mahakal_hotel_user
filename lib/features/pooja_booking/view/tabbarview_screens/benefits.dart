import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class Benifits extends StatefulWidget {
  String data;
  Benifits({super.key, required this.data});

  @override
  State<Benifits> createState() => _BenifitsState();
}

class _BenifitsState extends State<Benifits> {
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
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
                "Benifits of pooja",
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    color: Colors.black),
              )
            ],
          ),

          Html(
            data: widget.data,
          ),
          // Text("${widget.data?.service?.benefits}",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w400,fontFamily: 'Roboto',color: Color.fromRGBO(0, 0, 0, 1)),),
        ],
      ),
    );
  }
}
