import 'package:flutter/material.dart';
import 'package:mahakal/data/datasource/remote/http/httpClient.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';

import '../../main.dart';
import '../profile/controllers/profile_contrroller.dart';

class NumerologyView extends StatefulWidget {
  final String name;
  final String date;
  final String time;
  final String country;
  final String city;
  final String lati;
  final String longi;
  const NumerologyView(
      {super.key,
      required this.name,
      required this.date,
      required this.time,
      required this.country,
      required this.city,
      required this.lati,
      required this.longi});

  @override
  State<NumerologyView> createState() => _NumerologyViewState();
}

class _NumerologyViewState extends State<NumerologyView> {
  @override
  void initState() {
    super.initState();
    userId = Provider.of<ProfileController>(Get.context!, listen: false).userID;
    getNumerology();
  }

  //

  int selectedIndex = 0;
  String translateEn = 'hi';
  bool fontSizeChange = true;
  double fontSizeDefault = 16.0;
  bool gridList = false;
  // String name = "";
  String date = "";
  String userId = "";
  String destiny = "";
  String redical = "";
  String nameNumber = "";
  String evilNum = "";
  String favColor = "";
  String favDay = "";
  String favGod = "";
  String favManta = "";
  String favMetal = "";
  String favStone = "";
  String favSubStone = "";
  String friendlyNum = "";
  String neutralNum = "";
  String redicalNum = "";
  String redicalRuler = "";
  String numeroTitle = "";
  String numeroReport = "";
  bool isLoading = false;

  void getNumerology() async {
    isLoading = true;
    var res = await HttpService().postApi(AppConstants.kundliURL, {
      "user_id": userId,
      "device_id": "123",
      "name": widget.name,
      "date": widget.date,
      "time": widget.time,
      "country": widget.country,
      "city": widget.city,
      "latitude": widget.lati,
      "longitude": widget.longi,
      "timezone": "5.5",
      "language": translateEn,
      "planet_name": "saturn",
      "tab": "numero"
    });
    print(res);
    if (res['status'] == 200) {
      setState(() {
        // name = res['numerology']['name'].toString();
        date = res['numerology']['date'].toString();
        destiny = res['numerology']['destiny_number'].toString();
        redical = res['numerology']['radical_number'].toString();
        nameNumber = res['numerology']['name_number'].toString();
        evilNum = res['numerology']['evil_num'].toString();
        favColor = res['numerology']['fav_color'].toString();
        favDay = res['numerology']['fav_day'].toString();
        favGod = res['numerology']['fav_god'].toString();
        favManta = res['numerology']['fav_mantra'].toString();
        favMetal = res['numerology']['fav_metal'].toString();
        favStone = res['numerology']['fav_stone'].toString();
        favSubStone = res['numerology']['fav_substone'].toString();
        friendlyNum = res['numerology']['friendly_num'].toString();
        neutralNum = res['numerology']['neutral_num'].toString();
        redicalNum = res['numerology']['radical_num'].toString();
        redicalRuler = res['numerology']['radical_ruler'].toString();

        numeroTitle = res['numerologyReport']['title'].toString();
        numeroReport = res['numerologyReport']['description'].toString();
      });
    } else if (res['status'] == 500) {
      final snackBar = SnackBar(
        content: const Text('This is a SnackBar with an action!'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Code to execute when the action is pressed.
            print('Undo action pressed!');
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print("Api response failled");
    }

    isLoading = false;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget FirstTab() {
      // double numeroload = double.parse("${destiny}0");
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              // Container(
              //   decoration: BoxDecoration(
              //     color: Colors.red.shade100,
              //     borderRadius: BorderRadius.circular(16)
              //   ),
              //   child: Row(
              //     children: [
              //       SizedBox(
              //         width: 280,
              //         child: FAProgressBar(
              //           borderRadius: BorderRadius.circular(16),
              //           size: 100,
              //         currentValue: numeroload,
              //           displayText: '%\n Lucky Number',
              //         ),
              //       ),
              //       Padding(
              //         padding: const EdgeInsets.all(10.0),
              //         child: Center(
              //             child: Text(
              //               destiny,
              //               style: TextStyle(
              //                 fontSize: 40,
              //               ),
              //             )),
              //       ),
              //     ],
              //   ),
              // ),

              const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border:
                        Border.all(color: Colors.grey.shade400, width: 1.5)),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: 80,
                      decoration: BoxDecoration(
                          color: Colors.orange.shade400,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: const [
                            BoxShadow(
                                spreadRadius: 4,
                                blurRadius: 5,
                                color: Colors.white)
                          ]),
                      child: const Center(
                          child: Text(
                        " Lucky Number ",
                        style: TextStyle(color: Colors.black, fontSize: 22),
                      )),
                    ),
                    const Spacer(),
                    Container(
                      margin: const EdgeInsets.all(6),
                      height: 80,
                      width: 80,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.orange.shade400,
                          boxShadow: const [
                            BoxShadow(
                                spreadRadius: 4,
                                blurRadius: 5,
                                color: Colors.white)
                          ]),
                      child: Center(
                          child: Text(
                        destiny,
                        style:
                            const TextStyle(fontSize: 32, color: Colors.black),
                      )),
                    ),
                    const Spacer()
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.cyan.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border:
                        Border.all(color: Colors.grey.shade400, width: 1.5)),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: 80,
                      decoration: BoxDecoration(
                          color: Colors.cyan.shade400,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: const [
                            BoxShadow(
                                spreadRadius: 4,
                                blurRadius: 5,
                                color: Colors.white)
                          ]),
                      child: const Center(
                          child: Text(
                        "Original Number",
                        style: TextStyle(color: Colors.black, fontSize: 22),
                      )),
                    ),
                    const Spacer(),
                    Container(
                      margin: const EdgeInsets.all(6),
                      height: 80,
                      width: 80,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.cyan.shade400,
                          boxShadow: const [
                            BoxShadow(
                                spreadRadius: 4,
                                blurRadius: 5,
                                color: Colors.white)
                          ]),
                      child: Center(
                          child: Text(
                        redical,
                        style:
                            const TextStyle(fontSize: 32, color: Colors.black),
                      )),
                    ),
                    const Spacer()
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border:
                        Border.all(color: Colors.grey.shade400, width: 1.5)),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: 80,
                      decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: const [
                            BoxShadow(
                                spreadRadius: 4,
                                blurRadius: 5,
                                color: Colors.white)
                          ]),
                      child: const Center(
                          child: Text(
                        "Original Number",
                        style: TextStyle(color: Colors.black, fontSize: 22),
                      )),
                    ),
                    const Spacer(),
                    Container(
                      margin: const EdgeInsets.all(6),
                      height: 80,
                      width: 80,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.red.shade400,
                          boxShadow: const [
                            BoxShadow(
                                spreadRadius: 4,
                                blurRadius: 5,
                                color: Colors.white)
                          ]),
                      child: Center(
                          child: Text(
                        nameNumber,
                        style:
                            const TextStyle(fontSize: 32, color: Colors.black),
                      )),
                    ),
                    const Spacer()
                  ],
                ),
              ),

              const SizedBox(
                height: 10,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                child: Row(
                  children: [
                    Container(
                      color: Colors.orange,
                      height: 20,
                      width: 4,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Numerology Table",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.report_gmailerrorred,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                margin: const EdgeInsets.all(4.0),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.cyan.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey.shade300)),
                child: Row(
                  children: [
                    const Expanded(child: Text("Name :")),
                    Expanded(
                        child: Text(
                      widget.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                margin: const EdgeInsets.all(4.0),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey.shade300)),
                child: Row(
                  children: [
                    const Expanded(child: Text("Date of Birth :")),
                    Expanded(
                        child: Text(
                      date,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                margin: const EdgeInsets.all(4.0),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.cyan.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey.shade300)),
                child: Row(
                  children: [
                    const Expanded(child: Text("Radix number :")),
                    Expanded(
                        child: Text(
                      redicalNum,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                margin: const EdgeInsets.all(4.0),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey.shade300)),
                child: Row(
                  children: [
                    const Expanded(child: Text("Radix Owner :")),
                    Expanded(
                        child: Text(
                      redicalRuler,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                margin: const EdgeInsets.all(4.0),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.cyan.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey.shade300)),
                child: Row(
                  children: [
                    const Expanded(child: Text("Friend Number :")),
                    Expanded(
                        child: Text(
                      friendlyNum,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                margin: const EdgeInsets.all(4.0),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey.shade300)),
                child: Row(
                  children: [
                    const Expanded(child: Text("Even Number :")),
                    Expanded(
                        child: Text(
                      neutralNum,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                margin: const EdgeInsets.all(4.0),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.cyan.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey.shade300)),
                child: Row(
                  children: [
                    const Expanded(child: Text("Enemy Points :")),
                    Expanded(
                        child: Text(
                      evilNum,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                margin: const EdgeInsets.all(4.0),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey.shade300)),
                child: Row(
                  children: [
                    const Expanded(child: Text("Auspicious Day :")),
                    Expanded(
                        child: Text(
                      favDay,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis),
                    )),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                margin: const EdgeInsets.all(4.0),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.cyan.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey.shade300)),
                child: Row(
                  children: [
                    const Expanded(child: Text("Favorable Gem :")),
                    Expanded(
                        child: Text(
                      favStone,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                margin: const EdgeInsets.all(4.0),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey.shade300)),
                child: Row(
                  children: [
                    const Expanded(child: Text("Favorable sub-stone :")),
                    Expanded(
                        child: Text(
                      favSubStone,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis),
                    )),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                margin: const EdgeInsets.all(4.0),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.cyan.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey.shade300)),
                child: Row(
                  children: [
                    const Expanded(child: Text("Favorable god :")),
                    Expanded(
                        child: Text(
                      favGod,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                margin: const EdgeInsets.all(4.0),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey.shade300)),
                child: Row(
                  children: [
                    const Expanded(child: Text("Compatible Metal :")),
                    Expanded(
                        child: Text(
                      favMetal,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                margin: const EdgeInsets.all(4.0),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.cyan.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey.shade300)),
                child: Row(
                  children: [
                    const Expanded(child: Text("Compatible color :")),
                    Expanded(
                        child: Text(
                      favColor,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                margin: const EdgeInsets.all(4.0),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey.shade300)),
                child: Row(
                  children: [
                    const Expanded(child: Text("Favorable Mantra :")),
                    Expanded(
                        child: Text(
                      favManta,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget SecondTab() {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    color: Colors.orange,
                    height: 20,
                    width: 4,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Numerology Result",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.report_gmailerrorred,
                    color: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                numeroTitle,
                style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              Text(
                numeroReport,
                style: TextStyle(fontSize: fontSizeDefault),
              ),
              const SizedBox(
                height: 30,
              )
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: selectedIndex == 1
            ? Row(
                children: [
                  const Spacer(),
                  fontSizeChange
                      ? const SizedBox()
                      : Container(
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.transparent,
                          ),
                          height: 40,
                          width: MediaQuery.of(context).size.width * 0.75,
                          child: Slider(
                            inactiveColor: Colors.grey,
                            activeColor: Colors.orange,
                            label: "$fontSizeDefault",
                            value: fontSizeDefault,
                            min: 12.0,
                            max: 32.0,
                            onChanged: (double value) {
                              setState(() {
                                fontSizeDefault = value;
                              });
                            },
                          ),
                        ),
                  FloatingActionButton.small(
                    backgroundColor: Colors.orange,
                    onPressed: () {
                      setState(() {
                        fontSizeChange = !fontSizeChange;
                      });
                    },
                    child: Icon(
                      fontSizeChange ? Icons.text_fields : Icons.cancel,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              )
            : const SizedBox(),
        appBar: AppBar(
          actions: [
            BouncingWidgetInOut(
              onPressed: () {
                setState(() {
                  gridList = !gridList;
                  translateEn = gridList ? 'en' : 'hi';
                });
                getNumerology();
              },
              bouncingType: BouncingType.bounceInAndOut,
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.0),
                    color: gridList ? Colors.orange : Colors.white,
                    border: Border.all(color: Colors.orange, width: 2)),
                child: Center(
                  child: Icon(Icons.translate,
                      color: gridList ? Colors.white : Colors.orange),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            )
          ],
          title: const Text(
            "Numerology",
            style: TextStyle(color: Colors.orange),
          ),
          centerTitle: true,
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.orange,
                ),
              )
            : Column(
                children: <Widget>[
                  Material(
                    child: TabBar(
                      tabs: const [
                        Tab(
                          child: Text(
                            "Numerology Table",
                          ),
                        ),
                        Tab(
                          child: Text(
                            "Numerology Result",
                          ),
                        ),
                      ],
                      indicatorColor: Colors.orange,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      onTap: (index) {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      indicatorWeight: 3,
                      dividerColor: Colors.transparent,
                      labelStyle: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Roboto-Regular',
                          letterSpacing: 0.28),
                      unselectedLabelStyle: const TextStyle(
                          fontSize: 15.0,
                          fontFamily: 'Roboto-Regular',
                          letterSpacing: 0.28),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        FirstTab(),
                        SecondTab(),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
