import 'package:flutter/material.dart';
import 'package:mahakal/features/pooja_booking/view/puja_page.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: Size(screenWidth * 0.01, screenWidth * 0.15),
              child: AppBar(
                automaticallyImplyLeading: false,
                bottom: TabBar(
                    indicatorPadding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                    unselectedLabelColor: Colors.black,
                    labelColor: Colors.black,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorColor: Colors.orange,
                    labelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Roboto',
                        color: Colors.black),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(
                        text: "Chadava",
                      ),
                      Tab(
                        text: "Puja",
                      ),
                      Tab(
                        text: "Consultation",
                      ),
                    ]),
              ),
            ),
            body: const Flexible(
                child: TabBarView(
              children: [
                Center(child: Text("Chadava Tab")),
                PujaPage(),
                Center(child: Text("Consultation Tab")),
              ],
            ))),
      ),
    );
  }
}
