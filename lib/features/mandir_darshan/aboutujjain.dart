// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'model/templenearby_model.dart';
//
// class AboutDetailsView extends StatefulWidget {
//   final String name;
//   final String details;
//   final String femousDetails;
//   final List<Data> templeModelList;
//   const AboutDetailsView({super.key, required this.name, required this.details, required this.templeModelList, required this.femousDetails});
//
//   @override
//   State<AboutDetailsView> createState() => _SearchScreenState();
// }
//
// class _SearchScreenState extends State<AboutDetailsView> {
//
//   @override
//   Widget build(BuildContext context) {
//     final double screenHeight = MediaQuery.of(context).size.height;
//     final double screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Container(
//           decoration: const BoxDecoration(
//             image: DecorationImage(
//               image: NetworkImage(
//                   'https://img.jagrantv.com/webstories/ws2111/1665482998-ujjain--1-.jpg'), // Replace with your image asset
//               fit: BoxFit.cover,
//             ),
//           ),
//           child: BackdropFilter(
//             filter: ImageFilter.blur(
//                 sigmaX: 14.0,
//                 sigmaY: 20.0), // Adjust the blur intensity as needed
//             child: Column(children: [
//               SizedBox(
//                 height: 30,
//               ),
//               Row(
//                 children: [
//                   IconButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     icon: const Icon(
//                       Icons.arrow_back,
//                       size: 30,
//                       color: Colors.white,
//                     ),
//                   ),
//                   Spacer(),
//                   const Icon(
//                     Icons.send,
//                     color: Colors.white,
//                     size: 25,
//                   ),
//                   IconButton(
//                     onPressed: () {},
//                     icon: const Icon(
//                       Icons.more_vert,
//                       size: 30,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//
//               Text(
//                 'About ${widget.name}',
//                 style: TextStyle(
//                     fontSize: 30,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Text(
//                   "${widget.details}",
//                   style: TextStyle(fontSize: 20, color: Colors.white),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Text(widget.femousDetails,
//                   style: TextStyle(fontSize: 20, color: Colors.white),
//                 ),
//               ),
//               Container(
//                 margin: EdgeInsets.all(10),
//                 height: 200,
//                 color: Colors.white70,
//                 child: Center(child: Text("MAP"))
//               ),
//
//               Container(
//                 margin: EdgeInsets.all(10),
//                 padding: EdgeInsets.symmetric(horizontal: 10,vertical: 6),
//                 color: Colors.black.withOpacity(0.3),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Language(s)',
//                       style: TextStyle(
//                         color: Colors.grey,
//                         fontSize: 12,
//                       ),
//                     ),
//                     const Text(
//                       'Hindi',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 10,),
//                     const Text(
//                       'Currency',
//                       style: TextStyle(
//                         color: Colors.grey,
//                         fontSize: 12,
//                       ),
//                     ),
//                     const Text(
//                       'Indian Rupees',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const Text(
//                       'INR=1.00INR',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 14,
//                       ),
//                     ),
//                     SizedBox(height: 10,),
//                     const Text(
//                       'Best time to visit',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         const Icon(
//                           Icons.circle,
//                           color: Colors.red,
//                           size: 15,
//                         ),
//                         SizedBox(width: 6.0,),
//                         const Text(
//                           'OCT - MAR (Good Weather)',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         )
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: List.generate(
//                       widget.templeModelList.length,
//                           (index) => GestureDetector(
//                         onTap: () {
//                           // Navigator.push(
//                           //   context,
//                           //   CupertinoPageRoute(
//                           //     builder: (context) => const mandir(),
//                           //   ),
//                           // );
//                         },
//                         child: Stack(
//                           children: [
//                             Container(
//                               margin: EdgeInsets.all(4.0),
//                               height: 220,
//                               width: 150,
//                               child: ClipRRect(
//                                 borderRadius: const BorderRadius.only(
//                                   topLeft: Radius.circular(10.0),
//                                   topRight: Radius.circular(10.0),
//                                   bottomRight: Radius.circular(10.0),
//                                   bottomLeft: Radius.circular(10.0),
//                                 ),
//                                 child: Image.network(
//                                   widget.templeModelList[index].image.toString(),
//                                   fit: BoxFit.fill,
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               padding: EdgeInsets.all(10),
//                               margin: EdgeInsets.all(4.0),
//                               decoration: BoxDecoration(
//                                   color: Colors.black.withOpacity(0.3),
//                                   borderRadius: BorderRadius.circular(10)
//                               ),
//                               height: 220,
//                               width: 150,
//                               child:  Center(
//                                 child: Text("${widget.templeModelList[index].enName}",
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: screenWidth * 0.043,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ),
//
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'model/templenearby_model.dart';

class AboutDetailsView extends StatefulWidget {
  final String name;
  final String details;
  final String femousDetails;
  final List<Data> templeModelList;
  final LatLng
      templeLocation; // Add this parameter for temple location coordinates

  const AboutDetailsView({
    super.key,
    required this.name,
    required this.details,
    required this.templeModelList,
    required this.femousDetails,
    required this.templeLocation, // Initialize this in constructor
  });

  @override
  State<AboutDetailsView> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<AboutDetailsView> {
  late GoogleMapController mapController;
  bool isFullScreen = false;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _addMarker();
  }

  void _addMarker() {
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId("temple_location"),
          position: widget.templeLocation,
          infoWindow: InfoWindow(title: widget.name),
        ),
      );
    });
  }

  void _toggleFullScreen() {
    setState(() {
      isFullScreen = !isFullScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    // Return full screen map if in full screen mode
    if (isFullScreen) {
      return Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.templeLocation,
                zoom: 15,
              ),
              markers: _markers,
              onMapCreated: (controller) {
                setState(() {
                  mapController = controller;
                });
              },
            ),
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                onPressed: _toggleFullScreen,
              ),
            ),
          ],
        ),
      );
    }

    // Original screen with map container
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  'https://img.jagrantv.com/webstories/ws2111/1665482998-ujjain--1-.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14.0, sigmaY: 20.0),
            child: Column(children: [
              const SizedBox(height: 30),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back,
                        size: 30, color: Colors.white),
                  ),
                  const Spacer(),
                  const Icon(Icons.send, color: Colors.white, size: 25),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert,
                        size: 30, color: Colors.white),
                  ),
                ],
              ),
              Text(
                'About ${widget.name}',
                style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  widget.details,
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  widget.femousDetails,
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              // Replaced the MAP container with Google Maps widget
              Container(
                margin: const EdgeInsets.all(10),
                height: 200,
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: widget.templeLocation,
                        zoom: 15,
                      ),
                      markers: _markers,
                      onMapCreated: (controller) {
                        setState(() {
                          mapController = controller;
                        });
                      },
                      zoomControlsEnabled: false,
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: FloatingActionButton(
                        mini: true,
                        onPressed: _toggleFullScreen,
                        child: const Icon(Icons.fullscreen),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                color: Colors.black.withOpacity(0.3),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Language(s)',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Hindi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Currency',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Indian Rupees',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'INR=1.00INR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Best time to visit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color: Colors.red,
                          size: 15,
                        ),
                        SizedBox(width: 6.0),
                        Text(
                          'OCT - MAR (Good Weather)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      widget.templeModelList.length,
                      (index) => GestureDetector(
                        onTap: () {
                          // Navigation logic
                        },
                        child: Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(4.0),
                              height: 220,
                              width: 150,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  topRight: Radius.circular(10.0),
                                  bottomRight: Radius.circular(10.0),
                                  bottomLeft: Radius.circular(10.0),
                                ),
                                child: Image.network(
                                  widget.templeModelList[index].image
                                      .toString(),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(10)),
                              height: 220,
                              width: 150,
                              child: Center(
                                child: Text(
                                  widget.templeModelList[index].enName
                                      .toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.043,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
