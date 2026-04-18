import 'package:flutter/material.dart';

class ProgressView extends StatefulWidget {
  const ProgressView({super.key});

  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Progress',
          style: TextStyle(color: Colors.orange),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('Booking ID - ',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    Text('OD126070343499261000',
                        style: TextStyle(fontSize: 14, color: Colors.blue)),
                  ],
                ),
                const Row(
                  children: [
                    Text('Vishnu Pad Temple  - ',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    Text('\$1200',
                        style: TextStyle(fontSize: 14, color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 10),
                Theme(
                  data: ThemeData(
                    colorScheme: const ColorScheme.light(
                      primary: Colors.green, // Stepper icon and connector color
                    ),
                  ),
                  child: Stepper(
                    controlsBuilder:
                        (BuildContext context, ControlsDetails details) {
                      return Container();
                    },
                    steps: <Step>[
                      Step(
                        title: const SizedBox(),
                        subtitle: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Column(
                              children: [
                                Text('Vishnu Pad Temple'),
                                Text('Gaya Bihar Mohit'),
                              ],
                            ),
                            const Spacer(),
                            SizedBox(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  'https://economictimes.indiatimes.com/thumb/msid-100966456,width-1200,height-1200,resizemode-4,imgsize-63314/why-become-a-product-manager.jpg?from=mdr', // Replace with your image asset
                                  height: 70,
                                  width: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                        content: const SizedBox(),
                        isActive: true,
                        state: StepState.complete,
                      ),
                      Step(
                        title: const SizedBox(),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(
                              color: Colors.grey,
                            ),
                            const Text(
                              '8 May, 2024',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              'Booked Cadahva on Mahakal',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              color: Colors.grey[300],
                              height: 160,
                              width: double.infinity,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 45,
                                    decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius:
                                            BorderRadius.circular(8.0)),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Download",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Icon(
                                          Icons.download_outlined,
                                          color: Colors.white,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Container(
                                    height: 45,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        border: Border.all(
                                            color: Colors.orange, width: 1.5)),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Share",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        Icon(
                                          Icons.share,
                                          color: Colors.black,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        content: const SizedBox(),
                        isActive: true,
                        state: StepState.complete,
                      ),
                      const Step(
                        content: SizedBox(),
                        title: SizedBox(),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text(
                                'Video will be Shared 2 - 3 Days after the chadhava is done'),
                            SizedBox(height: 20),
                          ],
                        ),
                        isActive: true,
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0)),
                  child: ExpansionTile(
                    leading: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(4.0)),
                    ),
                    iconColor: Colors.orange,
                    collapsedIconColor: Colors.orange,
                    initiallyExpanded: true,
                    title: const Text('Bill details'),
                    subtitle: const Text(
                      "1 Item \$1.0'",
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                    children: const <Widget>[
                      Divider(
                        color: Colors.grey,
                      ),
                      ListTile(
                        title: Center(
                            child: Text(
                          'SOON',
                          style: TextStyle(color: Colors.blue),
                        )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
