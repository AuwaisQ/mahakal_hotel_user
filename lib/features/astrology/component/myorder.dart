import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/astrology/component/progresspage.dart';

class MyOrderView extends StatelessWidget {
  final int tabIndex;
  final int subTabIndex;
  const MyOrderView(
      {super.key, required this.tabIndex, required this.subTabIndex});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      initialIndex: tabIndex,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Order',
            style: TextStyle(color: Colors.orange),
          ),
          centerTitle: true,
          bottom: TabBar(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            dividerColor: Colors.white,
            labelColor: Colors.white,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelColor: Colors.black,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(
                    6.0) // Set the background color of the indicator
                ),
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Products'),
              Tab(text: 'Service'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FirstTab(),
            SecondTab(),
            ThirdTab(),
          ],
        ),
      ),
    );
  }

  Widget FirstTab() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: 10,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey.shade400, width: 2)),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: SizedBox(
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                "https://www.brightpearl.com/wp-content/uploads/2021/03/image1-1.jpg",
                                height: 100,
                                fit: BoxFit.cover,
                              )),
                        )),
                    const SizedBox(
                      width: 10,
                    ),
                    const Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Education Yog",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange),
                            ),
                            Text(
                              "XYZXYZ",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            Text(
                              "8 May 2024 Wednasday",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            Text(
                              "₹2200",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          ],
                        )),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget SecondTab() {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Column(
        children: [
          const TabBar(
            padding: EdgeInsets.all(10),
            dividerColor: Colors.white,
            labelColor: Colors.orange,
            indicatorColor: Colors.orange,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: 'Running'),
              Tab(text: 'Delivered'),
              Tab(text: 'Canceled'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // First tab
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                                color: Colors.grey.shade400, width: 2)),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: SizedBox(
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.network(
                                            "https://cdn.businessday.ng/wp-content/uploads/2023/12/Education-1.png",
                                            height: 100,
                                            fit: BoxFit.cover,
                                          )),
                                    )),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Education Yog",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange),
                                        ),
                                        Text(
                                          "XYZXYZ",
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                        Text(
                                          "8 May 2024 Wednasday",
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                        Text(
                                          "₹2200",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue),
                                        ),
                                      ],
                                    )),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Center(child: Text("SOON")),
                const Center(child: Text("SOON")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget ThirdTab() {
    return DefaultTabController(
      length: 3,
      initialIndex: subTabIndex,
      // Number of tabs
      child: Column(
        children: [
          const TabBar(
            padding: EdgeInsets.all(10),
            dividerColor: Colors.white,
            labelColor: Colors.orange,
            indicatorColor: Colors.orange,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: 'Chadava'),
              Tab(text: 'Puja'),
              Tab(text: 'Consultation'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                                color: Colors.grey.shade400, width: 2)),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: SizedBox(
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.network(
                                            "https://shippingchimp.com/blog/wp-content/uploads/2020/07/Advantage-of-real-time-parcel-tracking-01.png",
                                            height: 100,
                                            fit: BoxFit.cover,
                                          )),
                                    )),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Vishnu Pad Temple",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange),
                                        ),
                                        Text(
                                          "XYZXYZ",
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                        Text(
                                          "8 May 2024 Wednasday",
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Row(
                              children: [
                                Text(
                                  "1 x Tulsi Patta",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                                Spacer(),
                                Text(
                                  "Video is being Processed",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Icon(
                                  Icons.history,
                                  size: 18,
                                  color: Colors.blue,
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) =>
                                            const ProgressView()));
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: const Center(
                                    child: Text(
                                  "Track Order",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                )),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 2,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                                color: Colors.grey.shade400, width: 2)),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: SizedBox(
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.network(
                                            "https://shippingchimp.com/blog/wp-content/uploads/2020/07/Advantage-of-real-time-parcel-tracking-01.png",
                                            height: 100,
                                            fit: BoxFit.cover,
                                          )),
                                    )),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Vishnu Pad Temple",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange),
                                        ),
                                        Text(
                                          "XYZXYZ",
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                        Text(
                                          "8 May 2024 Wednasday",
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Row(
                              children: [
                                Text(
                                  "1 x Tulsi Patta",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                                Spacer(),
                                Text(
                                  "Video is being Processed",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Icon(
                                  Icons.history,
                                  size: 18,
                                  color: Colors.blue,
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) =>
                                            const ProgressView()));
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: const Center(
                                    child: Text(
                                  "Track Order",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                )),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Center(child: Text("SOON")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
