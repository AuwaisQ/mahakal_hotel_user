import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../utill/app_constants.dart';
import '../model/all_vendor_tours.dart';
import 'TourDetails.dart';

class VendoresTour extends StatefulWidget {
  dynamic tourId;
  bool isEngView;
  VendoresTour({super.key, required this.tourId, required this.isEngView});

  @override
  State<VendoresTour> createState() => _VendoresTourState();
}

class _VendoresTourState extends State<VendoresTour> {
  Widget TravelPackageCard(AllTourData package) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with discount badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  '${package.tourImage}',
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),

              // Discount badge
              if (package.percentageOff > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${package.percentageOff}% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              Positioned(
                bottom: 5,
                left: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Services
                    if (package.isIncludedPackage.isNotEmpty ?? false)
                      Wrap(
                        spacing: 8,
                        children:
                            (package.isIncludedPackage ?? []).map((service) {
                          String? imagePath;
                          if (service.toUpperCase() == "TRANSPORT") {
                            imagePath = 'assets/image/tour_vehicle.png';
                          } else if (service.toUpperCase() == "FOOD") {
                            imagePath = 'assets/image/tour_meal.png';
                          } else if (service.toUpperCase() == "HOTEL") {
                            imagePath = 'assets/image/tour_hotel.png';
                          }
                          return imagePath != null
                              ? Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Image.asset(
                                    imagePath,
                                    width: 20,
                                    height: 20,
                                    color: Colors.white,
                                  ),
                                )
                              : const SizedBox();
                        }).toList(),
                      ),
                  ],
                ),
              ),

              // lABLE Badge
              Positioned(
                top: 16, // thoda andar niche
                left: -40, // bahar nikal diya taki diagonal fit ho
                child: Transform.rotate(
                  angle: -0.785, // -45 degrees
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 45, vertical: 5),
                    color: getPlanTypeColor(
                        "${package.planTypeColor}"), // OR tour.planTypeColor
                    child: Text(
                      "${package.planTypeName.toUpperCase()}",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(11.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tour name
                Text(
                  widget.isEngView ? package.enTourName : package.hiTourName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),

                // Ratings
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      double rating =
                          double.tryParse(package.reviewAvgStar ?? "0") ?? 0.0;
                      //double rating = double.tryParse("3.0") ?? 0.0;

                      if (rating >= index + 1) {
                        return const Icon(Icons.star,
                            color: Colors.orange, size: 20);
                      } else if (rating > index && rating < index + 1) {
                        return const Icon(Icons.star_half,
                            color: Colors.orange, size: 20);
                      } else {
                        return const Icon(Icons.star_border,
                            color: Colors.orange, size: 20);
                      }
                    }),
                    const SizedBox(width: 6),
                    Text(
                      "(${(double.tryParse(package.reviewAvgStar ?? "0") ?? 0.0).toStringAsFixed(1)})",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // Price and Book Now button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //if (package['discount'] > 0)
                        Text(
                          '₹${package.offTotalPrice}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        Text(
                          '₹${package.minTotalPrice}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                    // Book Now button
                    Container(
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) =>
                                  TourDetails(productId: package.id.toString()),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2,
                          ),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchVendorTours();
  }

  AllVendorsTour? allVendorData;
  List<AllTourData> allVendorsTour = [];

  Future<void> fetchVendorTours() async {
    String url = AppConstants.allVendorTourUrl + "${widget.tourId}";
    setState(() {
      isLoading = true;
    });
    try {
      final res = await HttpService().getApi(url);
      if (res != null) {
        final allVendorList = AllVendorsTour.fromJson(res);

        setState(() {
          allVendorsTour = allVendorList.data ?? [];
          allVendorData = allVendorList;
          isLoading = false;
        });
        print("All Vendor Tour $allVendorsTour");
      }
    } catch (e) {
      print("Error in all vendor Tour $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Color getPlanTypeColor(String hexColor) {
    // Remove # if present
    hexColor = hexColor.replaceAll("#", "");

    // Parse hex to integer and add FF for full opacity
    return Color(int.parse("FF$hexColor", radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios)),
        title: Text("Vendores Tour"),
        centerTitle: true,
        backgroundColor: Colors.deepOrange.shade50,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: Colors.orange,
            ))
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  height: 80,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image:
                              NetworkImage("${allVendorData?.vendor?.banner}"),
                          fit: BoxFit.cover)),
                ),
                SizedBox(
                  height: 10,
                ),
                Card(
                  child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              image: DecorationImage(
                                  image: NetworkImage(
                                      "${allVendorData?.vendor?.image}"),
                                  fit: BoxFit.cover)),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${allVendorData?.vendor?.companyName}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Row(
                              children: [
                                ...List.generate(5, (index) {
                                  double rating = double.tryParse(
                                          allVendorData?.vendor?.avgRating ??
                                              "0") ??
                                      0.0;
                                  //double rating = double.tryParse("3.0") ?? 0.0;

                                  if (rating >= index + 1) {
                                    return const Icon(Icons.star,
                                        color: Colors.orange, size: 20);
                                  } else if (rating > index &&
                                      rating < index + 1) {
                                    return const Icon(Icons.star_half,
                                        color: Colors.orange, size: 20);
                                  } else {
                                    return const Icon(Icons.star_border,
                                        color: Colors.orange, size: 20);
                                  }
                                }),
                                const SizedBox(width: 6),
                                Text(
                                  "(${(double.tryParse(allVendorData?.vendor?.avgRating ?? "0") ?? 0.0).toStringAsFixed(1)})",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                const Text(
                                  "Ratings",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            "${allVendorData?.vendor?.tourCount} ",
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "Tours",
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Container(
                                  height: 15,
                                  width: 0.5,
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            "${allVendorData?.vendor?.reviewCount} ",
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "Reviews",
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),

                /// 🔹 Yaha Expanded use kiya

                allVendorsTour.isNotEmpty
                    ? Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 5,
                              childAspectRatio: 0.73,
                            ),
                            itemCount: allVendorsTour.length,
                            itemBuilder: (context, index) {
                              final package = allVendorsTour[index];
                              return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) => TourDetails(
                                            productId: package.id.toString()),
                                      ),
                                    );
                                  },
                                  child: TravelPackageCard(package));
                            },
                          ),
                        ),
                      )
                    : Center(child: Text("No Tours "))
              ],
            ),
    );
  }
}
