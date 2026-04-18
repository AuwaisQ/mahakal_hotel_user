import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/tour_and_travells/view/vendores_tour.dart';
import 'package:mahakal/features/youtube_vedios/view/dynamic_tabview/grid_view/YoutubeGridView.dart';

import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../utill/app_constants.dart';
import '../../blogs_module/no_image_widget.dart';
import '../model/all_vendores_model.dart';

class VendorsPage extends StatefulWidget {
  bool isEngView;
  VendorsPage({super.key, required this.isEngView});

  @override
  State<VendorsPage> createState() => _VendorsPageState();
}

class _VendorsPageState extends State<VendorsPage> {
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAllVendores();
  }

  List<VendoresData> vendorsList = [];
  List<VendoresData> filteredVendorsList = [];

  Future<void> fetchAllVendores() async {
    setState(() {
      isLoading = true;
    });
    try {
      const url = AppConstants.tourAllVendorUrl;
      final res = await HttpService().getApi(url);

      if (res != null) {
        final allVendorList = AllVendoresModel.fromJson(res);

        setState(() {
          vendorsList = allVendorList.data ?? [];
          filteredVendorsList = vendorsList;
          isLoading = false;
        });

        print("${vendorsList.length}");
      } else {
        print("Response is null");
        setState(() {
          vendorsList = [];
          filteredVendorsList = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print("fetching new vendor $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterVendors(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredVendorsList = vendorsList;
      });
    } else {
      setState(() {
        filteredVendorsList = vendorsList
            .where((vendor) =>
                vendor.companyName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: Colors.orange,
            ))
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  color: Colors.deepOrange.shade50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),

                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(Icons.arrow_back_ios,
                                color: Colors.black),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.isEngView ? "ALL VENDORS" : "सभी विक्रेता",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        widget.isEngView
                            ? "Find your desired vendor and book your favourite tour"
                            : "अपना पसंदीदा विक्रेता खोजें और अपनी पसंदीदा यात्रा बुक करें",
                        style: const TextStyle(color: Colors.black54),
                      ),

                      const SizedBox(height: 12),

                      // Search bar
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: widget.isEngView
                                    ? "Search Vendor"
                                    : "विक्रेता खोजें",
                                hintStyle: const TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 12),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Colors.deepOrange, width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Colors.deepOrange, width: 2),
                                ),
                              ),
                              onChanged: (value) {
                                filterVendors(value);
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              filterVendors(searchController.text);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              widget.isEngView ? "Search" : "खोजें",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1, // 2 columns
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.8,
                    ),
                    itemCount: filteredVendorsList.length,
                    itemBuilder: (context, index) {
                      final store = filteredVendorsList[index];
                      return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => VendoresTour(
                                          tourId: store.tourId,
                                          isEngView: widget.isEngView,
                                        )));
                          },
                          child: _buildStoreCard(store));
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStoreCard(VendoresData store) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          bottom: BorderSide(
            color: Colors.deepOrange, // change color as needed
            width: 1.0, // thickness of the border
          ),
        ),
      ),
      child: Column(
        children: [
          // TOP IMAGE WITH STACK
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Background image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                    imageUrl:
                        "${store.banner}",
                    height: 80,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => placeholderImage(),
                    errorWidget: (context, url, error) => NoImageWidget()),
              ),

              // Circle icon overlapping (positioned)
              Positioned(
                bottom: -63, // overlap niche aayega
                left: 12,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.deepOrange.shade50,
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl:
                              "${store.image}",
                          fit: BoxFit.cover,
                          width: 80, // radius * 2
                          height: 80, // radius * 2
                          placeholder: (context, url) => placeholderImage(),
                          errorWidget: (context, url, error) => NoImageWidget(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            // widget.isEngView ? store.:
                            store.companyName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              ...List.generate(5, (index) {
                                double rating =
                                    double.tryParse(store.avgRating ?? "0") ??
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
                                "(${(double.tryParse(store.avgRating ?? "0") ?? 0.0).toStringAsFixed(1)})",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 65), // jaga circle avatar ke liye

          // Bottom info row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoBox("${store.reviewCount}", "रिव्यु"),
                _infoBox("${store.tourCount}", "Tours"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: value == "0" ? Colors.orange : Colors.deepOrange,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
