import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mahakal/features/self_drive/self_payment_screen.dart';
import 'package:provider/provider.dart';

import '../../data/datasource/remote/http/httpClient.dart';
import '../../main.dart';
import '../../utill/loading_datawidget.dart';
import '../profile/controllers/profile_contrroller.dart';
import 'model/car_details_model.dart';

class CarSelfDetails extends StatefulWidget {
  final String slug;
  final String type;
  final String location;
  final double totalHour;
  final String date;
  final String leadId;

  const CarSelfDetails({
    super.key,
    required this.slug,
    required this.type,
    required this.location,
    required this.totalHour,
    required this.date,
    required this.leadId,
  });

  @override
  State<CarSelfDetails> createState() => _CarSelfDetailsState();
}

class _CarSelfDetailsState extends State<CarSelfDetails> {
  CarDetailsModel? carDetails;
  final ScrollController _scrollController = ScrollController();
  bool _hideFab = false;
  String phone = '';

  int _selectedPickupPointIndex = 0;
  int _selectedInsuranceIndex = -1;
  int totalInsuranceAmount = 0;
  bool isAcSelected = true;

  int getBasePrice(CarDetail car) {
    int price;

    if (widget.type == 'self') {
      if (isAcSelected) {
        price = car.hourBasicPriceWithAc ?? 0;
        if (price == 0) {
          price = car.hourBasicPriceNonAc ?? 0;
        }
      } else {
        price = car.hourBasicPriceNonAc ?? 0;
        if (price == 0) {
          price = car.hourBasicPriceWithAc ?? 0;
        }
      }
    } else {
      if (isAcSelected) {
        price = car.kmBasicPriceWithAc ?? 0;
        if (price == 0) {
          price = car.kmBasicPriceNonAc ?? 0;
        }
      } else {
        price = car.kmBasicPriceNonAc ?? 0;
        if (price == 0) {
          price = car.kmBasicPriceWithAc ?? 0;
        }
      }
    }

    return price;
  }

  void fetchCarDetails() async {
    String slug = widget.slug;
    var res = await HttpService().getApi('/api/v1/self-vehicle/getbyid/$slug');
    if (res['status'] == 1) {
      carDetails = CarDetailsModel.fromJson(res);
      print('Api response data $carDetails');
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchCarDetails();
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      final position = _scrollController.position;

      if (position.pixels >= position.maxScrollExtent - 20) {
        if (!_hideFab) {
          setState(() => _hideFab = true);
        }
      } else {
        if (_hideFab) {
          setState(() => _hideFab = false);
        }
      }
    });
    phone =
        Provider.of<ProfileController>(Get.context!, listen: false).userPHONE;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final car = carDetails?.carDetail;
    if (car == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.deepOrange,
          ),
        ),
      );
    }

    String unitType = widget.type == 'self' ? 'hour' : 'km';
    // int? basePrice = widget.type == 'self'
    //     ? (car.hourStatus == 1 ? car.hourBasicPriceWithAc : car.hourBasicPriceNonAc)
    //     : (car.kmStatus == 1 ? car.kmBasicPriceWithAc : car.kmBasicPriceNonAc);
    int? minimum = widget.type == 'self' ? car.hourMinimum : car.kmMinimum;
    int? extraCharge =
        widget.type == 'self' ? car.hourExtraChargesHour : car.kmExtraChargesKm;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar with Images Slider
          SliverAppBar(
            backgroundColor: Colors.white,
            expandedHeight: 240,
            pinned: true,
            centerTitle: true,
            title: Text(
              car.enCabName ?? '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: buildImageCarousel(car.images ?? []),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {},
              ),
            ],
          ),

          // Main Content
          SliverList(
            delegate: SliverChildListDelegate([
              // Basic Info Card
              buildCarDetailCard(
                car,
                unitType,
              ),

              // Important Note Card
              buildImportantNoteCard(car, unitType, minimum!, extraCharge!),

              // Inclusion Section
              buildInclusionSection(car),

              // Features Section (Cab About)
              buildFeaturesSection(car),

              // Insurance Policy Options
              // buildInsurancePolicySection(),

              // Pickup Points
              // if (widget.type == 'self' && car.pickPoint!.isNotEmpty)
              //   buildPickupPointsSection(car.pickPoint!),

              // Driving Policies
              buildDrivingPoliciesSection(car.drivingPolicy!),

              // Driver Requirements
              buildDriverRequirementsSection(car),

              // Cancellation Policy
              buildCancellationPolicySection(car.cancelPolicy!),

              // About Traveller
              buildTravellerInfoSection(car),

              // Bottom Booking Card
              widget.totalHour < minimum
                  ? const SizedBox.shrink()
                  : buildBottomBookingCard(car, unitType),
            ]),
          ),
        ],
      ),

      // Floating Action Button for Quick Booking
      floatingActionButton: widget.totalHour < minimum
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.deepOrange.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Colors.deepOrange,
                  ),
                  const SizedBox(width: 6),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      children: [
                        const TextSpan(text: 'Minimum '),
                        TextSpan(
                          text: '$minimum $unitType',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                        const TextSpan(text: ' booking required'),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              offset: _hideFab ? const Offset(0, 1.8) : Offset.zero,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                opacity: _hideFab ? 0 : 1,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingConfirmationPage(
                          type: widget.type,
                          carName: car.enCabName ?? '',
                          location: widget.location,
                          hour: widget.totalHour,
                          pickupDate: widget.date,
                          price: '${getBasePrice(car)}',
                          insAmount: totalInsuranceAmount,
                          vehicleId: '${car.id}',
                          leadId: widget.leadId,
                        ),
                      ),
                    );
                  },
                  backgroundColor: Colors.deepOrange,
                  elevation: 6,
                  icon: const Icon(
                    Icons.directions_car_filled,
                    color: Colors.white,
                  ),
                  label: Row(
                    children: [
                      const Text(
                        'Book Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      if (getBasePrice(car) > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '₹${getBasePrice(car)}/$unitType',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget buildImageCarousel(List<String> images) {
    if (images.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(
            Icons.directions_car,
            size: 60,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(20),
      ),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 260,
          viewportFraction: 1,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 3),
          enlargeCenterPage: false,
        ),
        items: images.map((img) {
          return CachedNetworkImage(
            imageUrl: img,
            width: double.infinity,
            fit: BoxFit.fill,
            placeholder: (_, __) => Container(
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.deepOrange,
              ),
            ),
            errorWidget: (_, __, ___) => const Icon(
              Icons.directions_car,
              size: 60,
              color: Colors.grey,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildCarDetailCard(CarDetail car, String unitType) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// PRICE + AC STATUS

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '₹${getBasePrice(car)}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      TextSpan(
                        text: '/$unitType',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if ((widget.type == 'self' && car.hourStatus == 1) ||
                    (widget.type != 'self' && car.kmStatus == 1))
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.ac_unit, size: 14, color: Colors.blue),
                        SizedBox(width: 4),
                        Text(
                          'AC',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if(widget.type == 'self')...[
              car.hourBasicPriceNonAc == 0 || car.hourBasicPriceWithAc == 0 ? SizedBox() :
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isAcSelected = true;
                      });
                    },
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isAcSelected
                            ? Colors.deepOrange
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "AC",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isAcSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isAcSelected = false;
                      });
                    },
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: !isAcSelected
                            ? Colors.deepOrange
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Non AC",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: !isAcSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
            ],

            if(widget.type != 'self')...[
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isAcSelected = true;
                      });
                    },
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isAcSelected
                            ? Colors.deepOrange
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "AC",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isAcSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isAcSelected = false;
                      });
                    },
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: !isAcSelected
                            ? Colors.deepOrange
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Non AC",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: !isAcSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
            ],


            /// CAB NAME
            Row(
              children: [
                Expanded(
                  child: Text(
                    car.enCabName ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    car.hiCabName ?? '',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// CAR TYPE + FUEL TYPE + DURATION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.directions_car,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      car.carType ?? '',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.local_gas_station,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      car.fuelType ?? '',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.timer_outlined,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.totalHour.toStringAsFixed(2)} $unitType',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade300),

            /// CATEGORY + SEATS + FUEL
            Row(
              children: [
                _specItem(
                  icon: Icons.category_outlined,
                  title: car.enCategoryName ?? '',
                  subtitle: car.hiCategoryName ?? '',
                ),
                _verticalDivider(),
                _specItem(
                  icon: Icons.people_alt_outlined,
                  title: 'Seats',
                  subtitle: '${car.cabSeats} Persons',
                ),
                _verticalDivider(),
                _specItem(
                  icon: Icons.local_gas_station_outlined,
                  title: 'Fuel',
                  subtitle: car.fuelType ?? '',
                ),
              ],
            ),

            if (car.securityAmount != null && car.securityAmount! > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security, color: Colors.amber[800], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Security Amount: ₹${car.securityAmount} (Refundable)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildImportantNoteCard(
      CarDetail car, String unitType, int minimum, int extraCharge) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.deepOrange.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.deepOrange.withOpacity(0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADLINE
          Row(
            children: const [
              Icon(
                Icons.info_outline,
                size: 18,
                color: Colors.deepOrange,
              ),
              SizedBox(width: 6),
              Text(
                'Important Note',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.deepOrange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// MINIMUM BOOKING MESSAGE
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              children: [
                const TextSpan(text: 'Minimum booking of '),
                TextSpan(
                  text: '$minimum $unitType',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                    fontSize: 16,
                  ),
                ),
                const TextSpan(text: ' is required.'),
              ],
            ),
          ),

          const SizedBox(height: 6),

          /// EXTRA CHARGE MESSAGE
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              children: unitType == 'km'
                  ? [
                      const TextSpan(
                        text: 'If distance exceeds the included limit, ',
                      ),
                      TextSpan(
                        text: '₹$extraCharge/km',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                          fontSize: 16,
                        ),
                      ),
                      const TextSpan(
                        text: ' will be charged for every extra kilometer.',
                      ),
                    ]
                  : [
                      const TextSpan(
                        text: 'If usage exceeds the booked time, ',
                      ),
                      TextSpan(
                        text: '₹$extraCharge/hour',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                          fontSize: 16,
                        ),
                      ),
                      const TextSpan(
                        text: ' will be charged for every extra hour.',
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInclusionSection(CarDetail car) {
    if (car.inclusion == null || car.inclusion!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What\'s Included',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.withOpacity(0.2)),
            ),
            padding: const EdgeInsets.all(16),
            child: _buildHtmlContent(car.inclusion!, Colors.green),
          ),
        ],
      ),
    );
  }

  Widget buildFeaturesSection(CarDetail car) {
    if (car.cabAbout!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Features & Benefits',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: car.cabAbout!.length,
              separatorBuilder: (_, __) => Divider(
                height: 16,
                color: Colors.grey.shade200,
              ),
              itemBuilder: (context, index) {
                final feature = car.cabAbout![index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feature.enName ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            feature.enDetails ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget buildInsurancePolicySection() {
  //   final policies = carDetails?.carDetail?.policyInfo;
  //   if (policies == null || policies.isEmpty) {
  //     return const SizedBox.shrink();
  //   }
  //
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           'Choose Insurance Policy',
  //           style: TextStyle(
  //             fontSize: 18,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         const SizedBox(height: 12),
  //
  //         /// HORIZONTAL RADIO STYLE CARDS
  //         SizedBox(
  //           height: 60,
  //           child: ListView.separated(
  //             scrollDirection: Axis.horizontal,
  //             itemCount: policies.length,
  //             separatorBuilder: (_, __) => const SizedBox(width: 12),
  //             itemBuilder: (context, index) {
  //               final policy = policies[index];
  //               final isSelected = _selectedInsuranceIndex == index;
  //
  //               return GestureDetector(
  //                 onTap: () {
  //                   setState(() {
  //                     if (isSelected) {
  //                       _selectedInsuranceIndex = -1;
  //                       totalInsuranceAmount = 0;
  //                     } else {
  //                       _selectedInsuranceIndex = index;
  //                       totalInsuranceAmount = int.parse('${policy.price}');
  //                     }
  //                   });
  //                 },
  //                 child: AnimatedContainer(
  //                   duration: const Duration(milliseconds: 200),
  //                   padding: const EdgeInsets.symmetric(
  //                       horizontal: 20, vertical: 5),
  //                   decoration: BoxDecoration(
  //                     color: isSelected ? Colors.deepOrange : Colors.white,
  //                     borderRadius: BorderRadius.circular(16),
  //                     border: Border.all(
  //                       color: isSelected
  //                           ? Colors.deepOrange
  //                           : Colors.grey.shade300,
  //                       width: 1.5,
  //                     ),
  //                     boxShadow: [
  //                       BoxShadow(
  //                         color: Colors.black.withOpacity(0.05),
  //                         blurRadius: 6,
  //                         offset: const Offset(0, 3),
  //                       ),
  //                     ],
  //                   ),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       Row(
  //                         children: [
  //                           Container(
  //                             width: 16,
  //                             height: 16,
  //                             decoration: BoxDecoration(
  //                               shape: BoxShape.circle,
  //                               border: Border.all(
  //                                   color: isSelected
  //                                       ? Colors.white
  //                                       : Colors.deepOrange,
  //                                   width: 2),
  //                             ),
  //                             child: isSelected
  //                                 ? Center(
  //                               child: Container(
  //                                 width: 8,
  //                                 height: 8,
  //                                 decoration: const BoxDecoration(
  //                                   shape: BoxShape.circle,
  //                                   color: Colors.white,
  //                                 ),
  //                               ),
  //                             )
  //                                 : null,
  //                           ),
  //                           const SizedBox(width: 6),
  //                           Text(
  //                             '₹${policy.price}',
  //                             style: TextStyle(
  //                               fontSize: 14,
  //                               fontWeight: FontWeight.bold,
  //                               color: isSelected
  //                                   ? Colors.white
  //                                   : Colors.deepOrange,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       const SizedBox(height: 6),
  //                       Text(
  //                         policy.enName ?? '',
  //                         maxLines: 2,
  //                         overflow: TextOverflow.ellipsis,
  //                         style: TextStyle(
  //                           fontSize: 12,
  //                           fontWeight: FontWeight.w600,
  //                           color: isSelected
  //                               ? Colors.white
  //                               : Colors.grey[800],
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //
  //         /// SELECTED POLICY DETAILS
  //         // if (_selectedInsuranceIndex != -1) ...[
  //         //   const SizedBox(height: 10),
  //         //   _buildSelectedPolicyDetails(policies[_selectedInsuranceIndex]),
  //         // ],
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildSelectedPolicyDetails(PolicyInfo policy) {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(14),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [
  //           Colors.deepOrange.withOpacity(0.06),
  //           Colors.deepOrange.withOpacity(0.12),
  //         ],
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       ),
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(
  //         color: Colors.deepOrange.withOpacity(0.25),
  //       ),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.04),
  //           blurRadius: 6,
  //           offset: const Offset(0, 3),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Container(
  //               padding: const EdgeInsets.all(6),
  //               decoration: BoxDecoration(
  //                 color: Colors.deepOrange.withOpacity(0.15),
  //                 shape: BoxShape.circle,
  //               ),
  //               child: const Icon(
  //                 Icons.verified,
  //                 size: 14,
  //                 color: Colors.deepOrange,
  //               ),
  //             ),
  //             const SizedBox(width: 8),
  //             Expanded(
  //               child: Text(
  //                 policy.enName ?? '',
  //                 style: const TextStyle(
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.w700,
  //                   color: Colors.deepOrange,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 10),
  //         ...policy.policy?.take(3).map(
  //               (item) => Padding(
  //             padding: const EdgeInsets.only(bottom: 6),
  //             child: Row(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 const Icon(
  //                   Icons.check_circle,
  //                   color: Colors.green,
  //                   size: 14,
  //                 ),
  //                 const SizedBox(width: 6),
  //                 Expanded(
  //                   child: Text(
  //                     item.enName ?? '',
  //                     maxLines: 2,
  //                     overflow: TextOverflow.ellipsis,
  //                     style: const TextStyle(
  //                       fontSize: 12,
  //                       color: Colors.black87,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         )
  //             .toList(),
  //         if (policy.policy != null && policy.policy!.length > 3)
  //           const Text(
  //             '+ more benefits',
  //             style: TextStyle(
  //               fontSize: 11,
  //               color: Colors.black54,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }

  Widget buildDrivingPoliciesSection(List<DrivingPolicy> policies) {
    if (policies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Driving Policies',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...policies.map((policy) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  childrenPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: Colors.deepOrange,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    policy.enPolicyName ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    policy.enTitle ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  children: [
                    _buildHtmlContent(policy.enMessage ?? '', Colors.black87),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget buildDriverRequirementsSection(CarDetail car) {
    bool hasAgeDetails =
        car.enDriversAgeDetails != null && car.enDriversAgeDetails!.isNotEmpty;
    bool hasLocalResident =
        car.enLocalResident != null && car.enLocalResident!.isNotEmpty;
    bool hasNotLocalResident =
        car.enNotLocalResident != null && car.enNotLocalResident!.isNotEmpty;

    if (!hasAgeDetails && !hasLocalResident && !hasNotLocalResident) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Driver Requirements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            if (hasAgeDetails)
              _driverRequirementTile(
                context,
                icon: Icons.cake_outlined,
                title: 'Age Requirements',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHtmlContent(
                        car.enDriversAgeDetails ?? '', Colors.black87),
                  ],
                ),
              ),
            if (hasNotLocalResident)
              _driverRequirementTile(
                context,
                icon: Icons.description_outlined,
                title: 'For Non-Local Residents',
                child:
                    _buildHtmlContent(car.enNotLocalResident!, Colors.black87),
              ),
            if (hasLocalResident)
              _driverRequirementTile(
                context,
                icon: Icons.description_outlined,
                title: 'For Local Residents',
                child: _buildHtmlContent(car.enLocalResident!, Colors.black87),
              ),
          ],
        ),
      ),
    );
  }

  Widget _driverRequirementTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepOrange.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.deepOrange, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [child],
      ),
    );
  }

  Widget buildCancellationPolicySection(List<CancelPolicy> policies) {
    if (policies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cancellation Policy',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...policies.map((policy) {
            return GestureDetector(
              onTap: () => _showCancellationDetails(policy),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withOpacity(0.25)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cancel_outlined,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            policy.enTitle ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _stripHtmlTags(policy.enMessage ?? ''),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[500],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget buildTravellerInfoSection(CarDetail car) {
    bool hasTravellerInfo =
        (car.travellerName != null && car.travellerName!.isNotEmpty) ||
            (car.travellerCompanyName != null &&
                car.travellerCompanyName!.isNotEmpty) ||
            (car.travellerImage != null && car.travellerImage!.isNotEmpty);

    if (!hasTravellerInfo) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.deepOrange.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: (car.travellerImage != null &&
                            car.travellerImage!.isNotEmpty)
                        ? NetworkImage(car.travellerImage!)
                        : null,
                    child: (car.travellerImage == null ||
                            car.travellerImage!.isEmpty)
                        ? const Icon(Icons.person, size: 30, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        car.travellerName ?? 'Service Provider',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        car.travellerCompanyName ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Verified Partner',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            /// BANNER
            if (car.travellerBanner != null && car.travellerBanner!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    car.travellerBanner!,
                    height: 80,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        height: 80,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) {
                      return Container(
                        height: 80,
                        color: Colors.grey[100],
                        child: const Center(
                          child: Icon(Icons.image_not_supported,
                              color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildBottomBookingCard(CarDetail car, String unitType) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// PRICE ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Price',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Excluding taxes & additional charges',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${getBasePrice(car)}/$unitType',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                  if (totalInsuranceAmount > 0)
                    Text(
                      '+ ₹$totalInsuranceAmount (Insurance)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// CTA BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingConfirmationPage(
                      type: widget.type,
                      carName: car.enCabName ?? '',
                      location: widget.location,
                      hour: widget.totalHour,
                      pickupDate: widget.date,
                      price: '${getBasePrice(car)}',
                      insAmount: totalInsuranceAmount,
                      vehicleId: '${car.id}',
                      leadId: widget.leadId,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'BOOK NOW',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHtmlContent(String htmlString, Color textColor) {
    // Simple HTML tag stripper
    String plainText = _stripHtmlTags(htmlString);

    // Check if it contains list items
    if (htmlString.contains('<li>')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: plainText
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: Text(
                          line.trim(),
                          style: TextStyle(
                            fontSize: 13,
                            color: textColor,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      );
    }

    // Regular text
    return Text(
      plainText,
      style: TextStyle(
        fontSize: 13,
        height: 1.5,
        color: textColor,
      ),
    );
  }

  Widget _specItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepOrange.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: Colors.deepOrange),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                overflow: TextOverflow.ellipsis),
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 50,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.grey[300],
    );
  }

  String _stripHtmlTags(String htmlString) {
    return htmlString
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&rsquo;', "'")
        .replaceAll('&lsquo;', "'")
        .replaceAll('&rdquo;', '"')
        .replaceAll('&ldquo;', '"')
        .replaceAll(RegExp(r'\n+'), '\n')
        .trim();
  }

  void _showCancellationDetails(CancelPolicy policy) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                policy.enTitle ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _buildHtmlContent(policy.enMessage ?? '', Colors.grey[700]!),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
