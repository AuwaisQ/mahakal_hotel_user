import 'package:flutter/material.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  bool _showMore = false;
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                title: const Text(
                  "Progress",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Roboto',
                      color: Colors.orange),
                ),
                centerTitle: true,
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05),
                        child: SizedBox(
                          width: screenWidth * 0.8,
                          child: const Text(
                              "Booking  ID - OD126070343499261000",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Roboto',
                                  fontSize: 12,
                                  color: Colors.grey,
                                  overflow: TextOverflow.ellipsis)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: screenWidth * 0.05, top: screenWidth * 0.03),
                        child: SizedBox(
                          width: screenWidth * 0.8,
                          child: const Text.rich(TextSpan(children: <TextSpan>[
                            TextSpan(
                                text: "Vishnu Pad Temple",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Roboto',
                                    fontSize: 12,
                                    color: Colors.grey)),
                            TextSpan(
                                text: "Rs 851",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Roboto',
                                    fontSize: 12,
                                    color: Color.fromRGBO(0, 71, 255, 1)))
                          ])),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: screenWidth * 0.03),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Container(
                                      height: 15,
                                      width: 15,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Container(
                                      height: screenHeight * 0.1,
                                      margin: EdgeInsets.only(
                                          left: screenWidth * 0.08),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.04,
                                          vertical: screenWidth * 0.002),
                                      decoration: const BoxDecoration(
                                          border: Border(
                                              left: BorderSide(
                                        color: Colors.green,
                                      ))),
                                    ),
                                    Container(
                                      height: 15,
                                      width: 15,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Container(
                                      height: screenWidth * 0.7,
                                      decoration: const BoxDecoration(
                                          border: Border(
                                              left: BorderSide(
                                        color: Colors.green,
                                      ))),
                                    ),
                                    Container(
                                      height: 15,
                                      width: 15,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),

                                // SizedBox(width: screenWidth * 0.2),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                                width: screenWidth * 0.5,
                                                child: const Text(
                                                  "Navgrah shanti Puja",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily: 'Roboto',
                                                      color: Colors.black,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                )),
                                            SizedBox(
                                                width: screenWidth * 0.5,
                                                child: const Text(
                                                  "Ujjain Madhya Pradesh",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily: 'Roboto',
                                                      color: Colors.grey,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                )),
                                            SizedBox(
                                              width: screenWidth * 0.5,
                                              child: const Text(
                                                "xyz",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Roboto',
                                                    color: Colors.grey,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              ),
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              height: screenHeight * 0.1,
                                              width: screenWidth * 0.2,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.grey),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: screenWidth * 0.02,
                                    ),
                                    Container(
                                      width: screenWidth * 0.7,
                                      height: screenHeight * 0.001,
                                      color: Colors.black,
                                    ),
                                    SizedBox(height: screenWidth * 0.02),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                            width: screenWidth * 0.8,
                                            child: const Text(
                                              "1 june , 2024",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: 'Roboto',
                                                  color: Colors.black,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            )),
                                        SizedBox(
                                            width: screenWidth * 0.8,
                                            child: const Text(
                                              "Booked Puja on Mahakal ",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: 'Roboto',
                                                  color: Colors.grey,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            )),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: screenWidth * 0.03,
                                              horizontal: screenWidth * 0.01),
                                          child: Container(
                                              height: screenHeight * 0.2,
                                              width: screenWidth * 0.7,
                                              color: Colors.grey),
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {},
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: Colors.orange),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical:
                                                          screenWidth * 0.02,
                                                      horizontal:
                                                          screenWidth * 0.04),
                                                  child: const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "Download",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Roboto',
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Icon(
                                                        Icons
                                                            .file_download_outlined,
                                                        color: Colors.white,
                                                        size: 25,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color: Colors.orange)),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        screenWidth * 0.05,
                                                    vertical:
                                                        screenWidth * 0.02),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal:
                                                                  screenWidth *
                                                                      0.04),
                                                      child: const Text(
                                                        "Share",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Roboto',
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                    Container(
                                                      height:
                                                          screenHeight * 0.03,
                                                      width: screenWidth * 0.05,
                                                      decoration: const BoxDecoration(
                                                          image: DecorationImage(
                                                              image: NetworkImage(
                                                                  "https://s3-alpha-sig.figma.com/img/7ffe/2ead/b9d4ea9adb840676bcecff2319aff2e2?Expires=1721606400&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=OOtvRVn1gmRioKKxq-sTBUqyRPH~YgmeN7BsBvrWkU7KkPQQz3SKJzwaMVNSVFizYpP4etVt8GHYphiOY7TJOqaOvX66zkssCFz44ZuPLE2QXNHaLmfSCaLSty-fwkChdubIyyI~0IUB4La9w~x5JpreD0jBy0SzI-FJLKI~GL7gsv6AQLUMn~ebioQaCV8oXQs4R-gMapqUXVKtPzidZ4RTbSZmTkix6Mq2Yx35YNEM7Hs~twD5g6Rbq-YvGMJZZZTeN9XmOOfsgNxxonbJZByw0PDlw~KaFAN-JwPvbHVNlf2ws1wNhjIQCG0u6hN9Z45KekYC5UMi00yhG5B6pg__"),
                                                              fit: BoxFit
                                                                  .cover)),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenWidth * 0.01),
                                    Container(
                                      width: screenWidth * 0.7,
                                      height: screenWidth * 0.002,
                                      color: Colors.black,
                                    ),
                                    SizedBox(
                                      height: screenWidth * 0.05,
                                    ),
                                    SizedBox(
                                        width: screenWidth * 0.7,
                                        height: screenWidth * 0.2,
                                        child: const Text(
                                          "Video will be Shared 2 - 3 Days after the\nchadhava is done",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'Roboto',
                                              color: Colors.black),
                                        ))
                                  ],
                                ),
                              ])),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: screenWidth * 0.001,
                            horizontal: screenWidth * 0.05),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey),
                              color: Colors.transparent),
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.02),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Bill details",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black),
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      child: ImageIcon(
                                          _showMore
                                              ? const AssetImage(
                                                  "assets/image/down.png")
                                              : const AssetImage(
                                                  "assets/image/up.png"),
                                          color: Colors.orange),
                                      onTap: () {
                                        setState(() {
                                          _showMore = !_showMore;
                                        });
                                      },
                                    )
                                  ],
                                ),
                                // _showText
                                _showMore
                                    ? Column(
                                        children: [
                                          SizedBox(
                                            height: screenWidth * 0.02,
                                          ),
                                          Row(
                                            children: [
                                              const Text(
                                                "Puja Total",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Roboto',
                                                    color: Colors.black),
                                              ),
                                              SizedBox(
                                                width: screenWidth * 0.4,
                                              ),
                                              SizedBox(
                                                  width: screenWidth * 0.2,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: screenWidth *
                                                            0.002),
                                                    child: const Text(
                                                      "Rs 851.0",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily: 'Roboto',
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ))
                                            ],
                                          ),
                                          SizedBox(height: screenWidth * 0.02),
                                          Row(
                                            children: [
                                              const Text(
                                                "Convenience Fee",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Roboto',
                                                    color: Colors.black),
                                              ),
                                              SizedBox(
                                                  width: screenWidth * 0.3),
                                              const Row(
                                                children: [
                                                  Text(
                                                    "Rs 25.0",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily: 'Roboto',
                                                        color: Colors.grey,
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        decorationColor:
                                                            Colors.grey,
                                                        decorationThickness: 2),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    "Free",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily: 'Roboto',
                                                        color: Colors.grey),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                          SizedBox(height: screenWidth * 0.02),
                                          Row(
                                            children: [
                                              const Text(
                                                "Pandit Fee",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Roboto',
                                                    color: Colors.black),
                                              ),
                                              SizedBox(
                                                  width: screenWidth * 0.4),
                                              const Row(
                                                children: [
                                                  Text(
                                                    "Rs 150.0",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily: 'Roboto',
                                                        color: Colors.grey,
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        decorationColor:
                                                            Colors.grey,
                                                        decorationThickness: 2),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    "Free",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily: 'Roboto',
                                                        color: Colors.grey),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                          SizedBox(height: screenWidth * 0.02),
                                          Row(
                                            children: [
                                              const Text(
                                                "Photo & video recording fee",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Roboto',
                                                    color: Colors.black),
                                              ),
                                              SizedBox(
                                                  width: screenWidth * 0.1),
                                              const Row(
                                                children: [
                                                  Text(
                                                    "Rs 500.0",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily: 'Roboto',
                                                        color: Colors.grey,
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        decorationColor:
                                                            Colors.grey,
                                                        decorationThickness: 2),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    "Free",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily: 'Roboto',
                                                        color: Colors.grey),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                          SizedBox(height: screenWidth * 0.02),
                                          const Divider(),
                                          SizedBox(height: screenWidth * 0.02),
                                          Row(
                                            children: [
                                              const Text(
                                                "Special Discount",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Roboto',
                                                    color: Colors.black),
                                              ),
                                              SizedBox(
                                                  width: screenWidth * 0.4),
                                              const Text(
                                                "- Rs 0.0",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Roboto',
                                                    color: Colors.grey),
                                              )
                                            ],
                                          ),
                                          SizedBox(height: screenWidth * 0.02),
                                          const Divider(),
                                          SizedBox(height: screenWidth * 0.02),
                                          const Row(
                                            children: [
                                              Text(
                                                "Total Amount",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: 'Roboto',
                                                    color: Colors.black),
                                              ),
                                              SizedBox(width: 160),
                                              Text(
                                                "Rs 851.0",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    fontFamily: 'Roboto',
                                                    color: Colors.green),
                                              )
                                            ],
                                          ),
                                        ],
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.only(),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                                height: screenWidth * 0.02),
                                            const Divider(),
                                            SizedBox(
                                                height: screenWidth * 0.02),
                                            Row(
                                              children: [
                                                const Text(
                                                  "Puja Total",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily: 'Roboto',
                                                      color: Colors.black),
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.5),
                                                const Text(
                                                  "Rs 851.0",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily: 'Roboto',
                                                      color: Colors.grey),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                //     : Container(
                                //     color: Color.fromRGBO(231, 231, 231, 1)
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
