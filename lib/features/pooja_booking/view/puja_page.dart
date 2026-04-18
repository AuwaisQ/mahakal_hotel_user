import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/pooja_booking/view/progress_page.dart';

class PujaPage extends StatefulWidget {
  const PujaPage({super.key});

  @override
  State<PujaPage> createState() => _PujaPageState();
}

class _PujaPageState extends State<PujaPage> {
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
            vertical: screenWidth * 0.03, horizontal: screenWidth * 0.06),
        child: Column(
          children: [
            Center(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange)),
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: screenWidth * 0.3,
                            width: screenWidth * 0.3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.02),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    width: screenWidth * 0.4,
                                    child: const Text(
                                      "Navgrah shanti Puja",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Roboto',
                                          color: Colors.black,
                                          overflow: TextOverflow.ellipsis),
                                    )),
                                SizedBox(
                                    width: screenWidth * 0.4,
                                    child: const Text(
                                      "XYZ",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Roboto',
                                          color: Colors.black,
                                          overflow: TextOverflow.ellipsis),
                                    )),
                                SizedBox(
                                    width: screenWidth * 0.4,
                                    child: const Text(
                                      "1 June 2024 Saturday",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Roboto',
                                          color: Colors.black,
                                          overflow: TextOverflow.ellipsis),
                                    )),
                              ],
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.001,
                            vertical: screenWidth * 0.03),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                                width: screenWidth * 0.3,
                                child: const Text(
                                  "Navgrah shanti puja",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                      overflow: TextOverflow.ellipsis),
                                )),
                            const Spacer(),
                            SizedBox(
                                width: screenWidth * 0.4,
                                child: const Text(
                                  "Video is being Processed",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                )),
                            SizedBox(
                                height: screenWidth * 0.05,
                                child: const Icon(
                                  Icons.history,
                                  size: 15,
                                  color: Colors.black,
                                ))
                          ],
                        ),
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => const ProgressPage(),
                                ));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.orange),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: screenWidth * 0.03),
                                child: const Text("Track Progress",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Roboto',
                                      color: Colors.white,
                                    )),
                              ),
                            ),
                          ))
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
