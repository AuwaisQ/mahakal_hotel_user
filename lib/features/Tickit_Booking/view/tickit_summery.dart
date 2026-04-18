import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mahakal/features/Tickit_Booking/view/tickit_payment_summery.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:mahakal/features/Tickit_Booking/view/tickit_selection_layout.dart';
import 'package:mahakal/features/Tickit_Booking/controller/tickit_summery_controller.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../main.dart';
import '../../../utill/app_constants.dart';
import '../../profile/controllers/profile_contrroller.dart';
import '../../tour_and_travells/Controller/fetch_wallet_controller.dart';
import '../controller/activities_genlead_controller.dart';
import '../controller/tickit_availablity_controller.dart';
import '../model/tickit_availiblity_model.dart' hide Row;
import '../model/tickit_summery_model.dart';

class TickitSummery extends StatefulWidget {
  final String slug;
  final String venue;
  final String adventureName;
  final int adharStatus;
  final int venueId;
  final int eventId;

  const TickitSummery({
    Key? key,
    required this.slug,
    required this.venue,
    required this.adventureName,
    required this.adharStatus,
    required this.venueId,
    required this.eventId,
  }) : super(key: key);

  @override
  _TickitSummeryState createState() => _TickitSummeryState();
}

class _TickitSummeryState extends State<TickitSummery> {

  double walletPay = 0;
  int? _selectedPackageIndex;
  DateTime? _selectedDate;
  String? _selectedTime;
  int _personCount = 1;
  String userId = "";
  List<Map<String, String>> _verifiedUsers = [];
  List<Map<String, String>> _nonVerifiedUsers = [];

  // Track description expansion for each package
  Map<int, bool> _packageDescriptionExpanded = {};

  List<Map<String, String>> devotees = [];
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController phoneController2 = TextEditingController();
  TextEditingController aadharController = TextEditingController();
  TextEditingController aadharController2 = TextEditingController();

  bool isverify = false;

  void _resetSelectionOnDateChange() {
    setState(() {
      _selectedTime = null;
      _selectedPackageIndex = null;
      //devotees.clear();
    });
    context.read<TickitAvailablityController>().resetAvailability();
  }

  final walletController = Provider.of<FetchWalletController>(Get.context!, listen: false);

  @override
  void initState() {
    super.initState();
    userId = Provider.of<ProfileController>(Get.context!, listen: false).userID;

    WidgetsBinding.instance.addPostFrameCallback((_) async{
      context.read<TickitSummeryController>().getTickitSummery(widget.slug, widget.venue,);
      context.read<LeadGenerateController>().createLead(userId: userId, eventId: widget.eventId.toString(), venueId: widget.venueId.toString());
      // Fetch wallet balance
      await walletController.fetchWallet();
      setState(() {
        walletPay = walletController.walletPay;
      });

      //  Availability controller ko RESET karo
      context.read<TickitAvailablityController>().resetAvailability();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TickitSummeryController>();
    final data = controller.tickitSummeryModel?.data;
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepOrange.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.deepOrange),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'Booking Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildBottomActionButton(),
      body: controller.loading
          ? _buildLoadingState()
          : data == null
          ? _buildErrorState()
          : _buildContent(data),
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // 1. Header (Pura box)
            _buildShimmerBox(height: 85, marginLeft: 16, marginRight: 16, radius: 24),

            const SizedBox(height: 24),

            // 2. Date Section Title
            _buildShimmerBox(height: 20, width: 120, marginLeft: 16, radius: 4),
            const SizedBox(height: 16),

            // Horizontal Dates Shimmer
            SizedBox(
              height: 85,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                padding: const EdgeInsets.only(left: 16),
                itemBuilder: (_, __) => _buildShimmerBox(height: 85, width: 55, marginRight: 10, radius: 16),
              ),
            ),

            const SizedBox(height: 24),

            // 3. Package Section Title
            _buildShimmerBox(height: 20, width: 150, marginLeft: 16, radius: 4),
            const SizedBox(height: 16),

            // Horizontal Packages Shimmer
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                padding: const EdgeInsets.only(left: 16),
                itemBuilder: (_, __) => _buildShimmerBox(height: 140, width: 165, marginRight: 12, radius: 20),
              ),
            ),

            const SizedBox(height: 20),

            // 1. Header (Pura box)
            _buildShimmerBox(height: 85, marginLeft: 16, marginRight: 16, radius: 24),

            const SizedBox(height: 24),

            // 2. Date Section Title
            _buildShimmerBox(height: 20, width: 120, marginLeft: 16, radius: 4),
            const SizedBox(height: 16),

            // Horizontal Dates Shimmer
            SizedBox(
              height: 85,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                padding: const EdgeInsets.only(left: 16),
                itemBuilder: (_, __) => _buildShimmerBox(height: 85, width: 55, marginRight: 10, radius: 16),
              ),
            ),

            const SizedBox(height: 24),

            // 3. Package Section Title
            _buildShimmerBox(height: 20, width: 150, marginLeft: 16, radius: 4),
            const SizedBox(height: 16),

            // Horizontal Packages Shimmer
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                padding: const EdgeInsets.only(left: 16),
                itemBuilder: (_, __) => _buildShimmerBox(height: 140, width: 165, marginRight: 12, radius: 20),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildShimmerBox({
    double height = 20,
    double width = double.infinity,
    double marginLeft = 0,
    double marginRight = 0,
    double radius = 12,
  }) {
    return Container(
      height: height,
      width: width,
      margin: EdgeInsets.only(left: marginLeft, right: marginRight),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, size: 45, color: Colors.red),
          ),
          SizedBox(height: 20),
          Text(
            'No data available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey.shade800),
          ),
          SizedBox(height: 10),
          Text(
            'Please try again later',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          SizedBox(height: 25),
          ElevatedButton(
            onPressed: () => context.read<TickitSummeryController>().getTickitSummery(widget.slug, widget.venue),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: Text(
              'Retry',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(TickitData data) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

           // Header Card
           _buildHeaderSection(),
           SizedBox(height: 10),

          // Date Selection
          _buildDateSection(data),
          SizedBox(height: 10),

          //  Package Selection - ONLY show AFTER checking availability
          if(data.auditorium == 0)
          Column(
            children: [
              Consumer<TickitAvailablityController>(
                builder: (BuildContext context, tickitAvailablityController, Widget? child) {

                  if (!tickitAvailablityController.hasCheckedAvailability) {
                    return SizedBox.shrink();
                  }

                  final isLoading = tickitAvailablityController.isLoading;
                  if (isLoading) {
                    return buildPackageSectionShimmer();
                  }

                  final packages = tickitAvailablityController
                      .tickitAvailiblityModel
                      ?.data
                      ?.packageList;

                  if (packages == null || packages.isEmpty) {
                    return buildEmptyPackageWidget();
                  }
                  return _buildPackageSection(packages);
                },
              ),
              SizedBox(height: 10),
            ],
          ),

          _buildPersonSection(data.requiredAadharStatus),
          SizedBox(height: 80),

        ],
      ),
    );
  }

  Widget buildPackageSectionShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// 🔹 Header Shimmer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              _shimmerBox(width: 120, height: 16),
              const SizedBox(width: 8),
              _shimmerBox(width: 25, height: 16, radius: 6),
            ],
          ),
        ),

        /// 🔹 Horizontal Cards Shimmer
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3, // fake shimmer items
            padding: const EdgeInsets.only(left: 16, right: 8),
            itemBuilder: (context, index) {
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12, bottom: 8, top: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _shimmerBox(width: 60, height: 20),
                    _shimmerBox(width: 120, height: 14),
                    _shimmerBox(width: 80, height: 10),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        /// 🔹 Detail Section Shimmer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shimmerBox(width: 150, height: 16),
              const SizedBox(height: 10),
              _shimmerBox(width: double.infinity, height: 12),
              const SizedBox(height: 6),
              _shimmerBox(width: double.infinity, height: 12),
              const SizedBox(height: 6),
              _shimmerBox(width: 200, height: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildEmptyPackageWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F2F6)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// 🔹 Icon
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.deepOrange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: Colors.deepOrange,
                size: 28,
              ),
            ),

            const SizedBox(height: 16),

            /// 🔹 Title
            const Text(
              "No Packages Available",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D3436),
              ),
            ),

            const SizedBox(height: 6),

            /// 🔹 Subtitle
            Text(
              "Currently there are no packages available for this activity.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    double radius = 8,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16), // Padding thodi kam kar di compact karne ke liye
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Compact Icon Container
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F2F6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.explore_rounded, // Adventure feel icon
              color: Color(0xFF4361EE),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Text Section - Adventure & Venue
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Jitni zaroorat utni hi height
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.adventureName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.venue,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Subtle Forward Arrow (Optional, looks professional)
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildPackageSection(List<ActivityPackageList> packages) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Small & Sharp
          _buildSectionHeader(
            title: 'Select Package',
            icon: Icons.card_giftcard,
          ),
          SizedBox(height: 10,),

          SizedBox(
            height: 170, // Slightly increased height for better breathing room
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: packages.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final package = packages[index];
                final bool isAvailable = package.available == true;
                final bool isSelected = _selectedPackageIndex == index;

                return GestureDetector(
                  onTap: isAvailable ? () => setState(() => _selectedPackageIndex = index) : null,
                  child: AnimatedScale(
                    scale: isSelected ? 1.02 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 170,
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        color: isSelected && isAvailable ? Colors.orange : Colors.white,
                        //     ? const LinearGradient(
                        //   colors: [Color(0xFF2D3436), Color(0xFF000000)], // Premium Dark Theme
                        //   begin: Alignment.topLeft,
                        //   end: Alignment.bottomRight,
                        // )
                        //     : const LinearGradient(
                        //   colors: [Colors.white, Color(0xFFF8F9FA)],
                        //   begin: Alignment.topLeft,
                        //   end: Alignment.bottomRight,
                        // ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? Colors.black.withOpacity(0.15)
                                : Colors.grey.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(
                          color: isSelected ? Colors.transparent : Colors.grey.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: Opacity(
                        opacity: isAvailable ? 1.0 : 0.6,
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Row: Type Tag
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.white24 : Colors.deepOrange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        package.type.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                          color: isSelected ? Colors.white : Colors.deepOrange,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                // Price
                                Text(
                                  '₹${package.price}',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: isSelected ? Colors.white : const Color(0xFF2D3436),
                                  ),
                                ),
                                // Package Name
                                Text(
                                  package.enPackageName,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected ? Colors.white70 : Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Bottom Row: Seats Info
                                Row(
                                  children: [
                                    Icon(
                                      Icons.bolt, // Changed to a more "action" oriented icon
                                      size: 14,
                                      color: isSelected ? Colors.orangeAccent : Colors.deepOrange,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      package.remainingSeats == "0" ? "Full" : "${package.remainingSeats} left",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : Colors.grey.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Sold Out Overlay - More subtle
                            if (!isAvailable)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                      ),
                                      child: const Text(
                                        "SOLD OUT",
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Integrated Detail Area: Small & Clean
          if (packages.isNotEmpty && _selectedPackageIndex != null)
            _buildIntegratedDetails(packages[_selectedPackageIndex!]),
        ],
      ),
    );
  }

  Widget _buildIntegratedDetails(ActivityPackageList package) {

    final cleanDescription = _cleanHtmlText(package.enPackageDetails);
    final isExpanded = _packageDescriptionExpanded[_selectedPackageIndex] ?? false;
    final canExpand = cleanDescription.length > 100;

    return Container(
      key: ValueKey(package.packageId),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F2F6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.description_outlined, size: 16, color: Colors.blue),
              ),
              const SizedBox(width: 10),
              const Text(
                "Package Description",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Full Description Text
          Text(
            cleanDescription,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5, // Line height for better readability
              fontWeight: FontWeight.w500,
            ),
            maxLines: isExpanded ? null : 4,
            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),

          // View More / View Less Button
          if (canExpand)
            GestureDetector(
              onTap: () {
                setState(() {
                  _packageDescriptionExpanded[_selectedPackageIndex!] = !isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Text(
                      isExpanded ? "Show Less" : "Read Full Description",
                      style: TextStyle(
                        color: Colors.deepOrange.shade400,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: Colors.deepOrange.shade400,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),

          // Agar Hindi data bhi dikhana hai toh yahan aa jayega
          if (isExpanded && package.hiPackageDetails.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            const Text(
              "विवरण (Hindi):",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _cleanHtmlText(package.hiPackageDetails),
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  String _cleanHtmlText(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    Widget? trailing, // Agar right side mein "More" ya kuch aur dikhana ho
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8), // Thoda breathing room badha diya
              decoration: BoxDecoration(
                color: Colors.deepOrange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.deepOrange,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildDateSection(TickitData data) {
    List<String> availableWeekdays = data.weekly ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// ================= HEADER =================
          _buildSectionHeader(
            title: 'Choose Date',
            icon: Icons.calendar_today_rounded,
          ),
          const SizedBox(height: 20),

          /// ================= QUICK DATE SELECTOR =================
          SizedBox(
            height: 90,
            child: Builder(
              builder: (context) {

                ///  Only 4 dates
                List<DateTime> quickDates = [];
                for (int i = 0; i < 3; i++) {
                  quickDates.add(DateTime.now().add(Duration(days: i)));
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: quickDates.length + 1, // +1 for calendar
                  itemBuilder: (context, index) {

                    ///  Last item = Calendar Button
                    if (index == quickDates.length) {
                      return _buildCalendarButton();
                    }

                    DateTime date = quickDates[index];

                    String weekday =
                    DateFormat('EEE').format(date).toLowerCase();

                    bool isAvailable =
                    availableWeekdays.contains(weekday);

                    bool isSelected = _selectedDate != null &&
                        DateUtils.isSameDay(_selectedDate, date);

                    return _buildQuickDateTile(
                      date: date,
                      isAvailable: isAvailable,
                      isSelected: isSelected,
                      onTap: () {
                        if (isAvailable) {
                          if (!DateUtils.isSameDay(_selectedDate, date)) {
                            setState(() {
                              _selectedDate = date;
                              _resetSelectionOnDateChange();
                            });
                          }
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),

          /// ================= SELECTED DATE INFO =================
          if (_selectedDate != null) ...[
            const SizedBox(height: 20),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month,
                      size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Booking for: ${DateFormat('d MMM').format(_selectedDate!)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2D3436),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          /// ================= TIME SECTION =================
          _buildTimeSection(data),

          const SizedBox(height: 24),

          /// ================= CHECK AVAILABILITY BUTTON =================
          // if (data.auditorium == 0)Consumer<TickitAvailablityController>(
          //     builder: (context, controller, child) {
          //
          //       final isEnabled = _selectedDate != null &&
          //           _selectedTime != null &&
          //           !controller.isLoading;
          //
          //       return AnimatedScale(
          //         scale: isEnabled ? 1.0 : 0.98,
          //         duration: const Duration(milliseconds: 300),
          //         child: AnimatedContainer(
          //           duration: const Duration(milliseconds: 300),
          //           width: double.infinity,
          //           height: 50,
          //           decoration: BoxDecoration(
          //             borderRadius: BorderRadius.circular(16),
          //             gradient: isEnabled
          //                 ? const LinearGradient(
          //               colors: [
          //                 Color(0xFF00B09B),
          //                 Color(0xFF96C93D)
          //               ],
          //               begin: Alignment.centerLeft,
          //               end: Alignment.centerRight,
          //             )
          //                 : LinearGradient(
          //               colors: [
          //                 Colors.grey.shade300,
          //                 Colors.grey.shade300
          //               ],
          //             ),
          //             boxShadow: [
          //               if (isEnabled)
          //                 BoxShadow(
          //                   color: const Color(0xFF00B09B)
          //                       .withOpacity(0.3),
          //                   blurRadius: 15,
          //                   offset: const Offset(0, 8),
          //                 ),
          //             ],
          //           ),
          //           child: ElevatedButton(
          //             onPressed: isEnabled
          //                 ? () async {
          //               final formattedDate =
          //               DateFormat('yyyy-MM-dd')
          //                   .format(_selectedDate!);
          //
          //               int? selectedTimeId;
          //
          //               for (var slot in data.date) {
          //                 if ('${slot.startTime} - ${slot.endTime}' ==
          //                     _selectedTime) {
          //                   selectedTimeId = slot.id;
          //                   break;
          //                 }
          //               }
          //
          //               await controller.getTickitAvailiblity(
          //                 widget.slug,
          //                 formattedDate,
          //                 selectedTimeId?.toString() ?? '1',
          //               );
          //             }
          //                 : null,
          //             style: ElevatedButton.styleFrom(
          //               backgroundColor: Colors.transparent,
          //               shadowColor: Colors.transparent,
          //               shape: RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.circular(20),
          //               ),
          //             ),
          //             child: controller.isLoading
          //                 ? const SizedBox(
          //               height: 24,
          //               width: 24,
          //               child: CircularProgressIndicator(
          //                 strokeWidth: 3,
          //                 color: Colors.white,
          //               ),
          //             )
          //                 : Row(
          //               mainAxisAlignment:
          //               MainAxisAlignment.center,
          //               children: [
          //                 Text(
          //                   'Check Availability',
          //                   style: TextStyle(
          //                     fontSize: 17,
          //                     fontWeight: FontWeight.w900,
          //                     letterSpacing: 0.5,
          //                     color: isEnabled
          //                         ? Colors.white
          //                         : Colors.grey.shade500,
          //                   ),
          //                 ),
          //                 const SizedBox(width: 12),
          //                 if (isEnabled)
          //                   const Icon(
          //                     Icons.verified_user_rounded,
          //                     size: 18,
          //                     color: Colors.white,
          //                   ),
          //               ],
          //             ),
          //           ),
          //         ),
          //       );
          //     },
          //   ),
        ],
      ),
    );
  }

  Widget _buildQuickDateTile({required DateTime date, required bool isAvailable, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade100,
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: Colors.orange.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5))
          ] : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              DateFormat('EEE').format(date).toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: isSelected ? Colors.white60 : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 6),

            Text(
              DateFormat('d').format(date),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.white : (isAvailable ? const Color(0xFF1A1A1A) : Colors.grey.shade300),
              ),
            ),
            const SizedBox(height: 4),

            // Status Dot
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : (isAvailable ? Colors.green : Colors.transparent),
                shape: BoxShape.circle,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarButton() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        width: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Icon(Icons.calendar_today_outlined, color: Color(0xFF1A1A1A), size: 20),
      ),
    );
  }

  Widget _buildTimeSection(TickitData data) {
    List<Date> timeSlots = data.date;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Section with a refined touch
        _buildSectionHeader(
          title: 'Select Time Slot',
          icon: Icons.schedule_rounded,
        ),
        const SizedBox(height: 16),

        if (timeSlots.isEmpty)
          buildEmptyState()
        else
          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: timeSlots.length,
              itemBuilder: (context, index) {
                final slot = timeSlots[index];
                final timeText = '${slot.startTime} - ${slot.endTime}';
                final isSelected = _selectedTime == timeText;

                return Padding(
                  padding: const EdgeInsets.only(right: 12, bottom: 4),
                  child: GestureDetector(
                    onTap: () async {
                      setState(() {
                        _selectedTime = timeText;
                      });

                      if (data.auditorium == 0 && _selectedDate != null) {

                        final formattedDate =
                        DateFormat('yyyy-MM-dd').format(_selectedDate!);

                        int selectedTimeId = slot.id;

                        await context
                            .read<TickitAvailablityController>()
                            .getTickitAvailiblity(
                          widget.slug,
                          formattedDate,
                          selectedTimeId.toString(),
                        );
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.orange : Colors.white,
                        borderRadius: BorderRadius.circular(14), //
                        border: Border.all(
                          color: isSelected ? Colors.orange : Colors.grey.shade200,
                          width: 1.5,
                        ),
                        // boxShadow: [
                        //   if (isSelected)
                        //     BoxShadow(
                        //       color: Colors.deepOrange.withOpacity(0.3),
                        //       blurRadius: 12,
                        //       offset: const Offset(0, 6), // Soft orange glow
                        //     )
                        //   else
                        //     BoxShadow(
                        //       color: Colors.black.withOpacity(0.04),
                        //       blurRadius: 4,
                        //       offset: const Offset(0, 2),
                        //     ),
                        // ],
                      ),
                      child: Center(
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time_filled_rounded,
                              size: 16,
                              color: isSelected ? Colors.white : Colors.deepOrange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              slot.startTime ?? "",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isSelected ? Colors.white : const Color(0xFF2D3436),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                "-",
                                style: TextStyle(
                                  color: isSelected ? Colors.white70 : Colors.grey.shade400,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              slot.endTime ?? "",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isSelected ? Colors.white : const Color(0xFF2D3436),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // Empty State Widget
  Widget buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Colors.grey.shade400),
            const SizedBox(width: 10),
            Text(
              'No time slots available',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonSection(int aadharRequired) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.people_alt_rounded,
                  color: Colors.orange.shade700,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Number of Persons',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          if (aadharRequired == 1)
            _addMemberCard(screenWidth, screenHeight, aadharRequired)
          else
            _buildSimpleCounterSection(),
          SizedBox(height: 16),

          // Devotees List
          if (devotees.isNotEmpty) ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: devotees.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.grey.shade100,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name Row (Compact)
                        Row(
                          children: [
                            Icon(Icons.person,
                                size: 18,
                                color: Colors.deepOrange
                                    .withOpacity(0.8)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "${devotees[index]['name']}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                            if (index > 0)
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(Icons.delete,
                                    size: 20,
                                    color: Colors.red.shade400),
                                onPressed: () {
                                  setState(() {
                                    devotees.removeAt(index);
                                    //sumTotal();
                                  });
                                },
                              )
                          ],
                        ),

                        // Phone (if exists)
                        if (devotees[index]['phone']?.isNotEmpty ??
                            false) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.phone,
                                  size: 16,
                                  color: Colors.green.shade600),
                              const SizedBox(width: 8),
                              Text(
                                "+91 ${devotees[index]['phone']}",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],

                        // Aadhar
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.credit_card,
                                size: 16,
                                color: Colors.blue.shade600),
                            const SizedBox(width: 8),
                            Text(
                              _formatAadhar(
                                  "${devotees[index]['aadhar']}"),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),

                        // Primary Devotee Badge (if index=0)
                        if (index == 0) ...[
                          const SizedBox(height: 6),
                          Text(
                            '( Primary Devotee)',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  String _formatAadhar(String aadhar) {
    if (aadhar == "N/A") return aadhar;

    // Remove existing hyphens/spaces (if any)
    String cleaned = aadhar.replaceAll(RegExp(r'[-\s]'), '');

    // Add hyphen every 4 digits
    String formatted = '';
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) formatted += '-';
      formatted += cleaned[i];
    }

    return formatted;
  }

  void getAadhar(String aadharNumber, BuildContext context, StateSetter modalSetter) async {
    var res = await HttpService().postApi(AppConstants.sendAadharOtp, {
      "aadhaar_number": aadharNumber,
    });
    print("Api response data place order $res");
    if (res["status"] == 1) {
      Navigator.pop(context);
      String id = res["data"]["request_id"].toString();
      Fluttertoast.showToast(
          msg: "Send OTP",
          backgroundColor: Colors.green,
          textColor: Colors.white);
      showOtpVerificationDialog(context, id);
    }
    if (res["status"] == 2) {
      // Navigator.pop(context);
      String name = res["data"]["name"];
      String aadhar = res["data"]["aadhar"].toString();
      setState(() {
        devotees.add({
          'name': name,
          'phone': phoneController2.text.trim(),
          'aadhar': aadhar,
          'aadhar_verify': "1",
        });
      });
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: "Success",
          backgroundColor: Colors.green,
          textColor: Colors.white);
      phoneController2.clear();
      aadharController2.clear();
      // billAmount = double.parse(widget.billAmount) * devotees.length;
      // walletMinusAmount = max(walletPay - billAmount, 0);
      // finalAmount = (walletPay - billAmount).abs();
    }
    if (res["status"] == 0) {
      Fluttertoast.showToast(
          msg: "Invalid Aadhaar Number",
          backgroundColor: Colors.red,
          textColor: Colors.white);
      modalSetter(() {
        isverify = false;
      });
    }
    print("${res['data']['message']} ${res['status']} Print status");
  }

  Future<void> verifyOtp(
      String otp,
      String id,
      BuildContext context,
      ) async {
    print("Verify OTP Called");

    var res = await HttpService().postApi(
      AppConstants.sendAadharOtpVerify,
      {"otp": otp, "request_id": id},
    );

    print("Api response data verify otp $res");

    if (res["status"] == 1) {
      String name = res["data"]["data"]["full_name"];
      String aadhar = res["data"]["data"]["aadhaar_number"];

      Navigator.pop(context);

      setState(() {
        devotees.add({
          'name': name,
          'phone': phoneController2.text.trim(),
          'aadhar': aadhar,
          'aadhar_verify': "1",
        });
      });

      Fluttertoast.showToast(
        msg: "Success",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      phoneController2.clear();
      aadharController2.clear();
    } else {
      Fluttertoast.showToast(
        msg: "Invalid request",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _showAddDevoteeDialog(BuildContext context, int aadharRequired) {
    int _verificationStatus = 1;

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter modalSetter) {
              return Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dialog Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Add New Devotee',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 24),
                              onPressed: () {
                                modalSetter(() {
                                  isverify = false;
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                        Divider(
                          color: Colors.grey.shade300,
                        ),


                        Row(
                          children: [
                            aadharRequired == 1 ?
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: _verificationStatus == 1
                                      ? Colors.deepOrange.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _verificationStatus == 1
                                        ? Colors.deepOrange
                                        : Colors.grey.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: RadioListTile<int>(
                                  dense: true,
                                  contentPadding:
                                  EdgeInsets.symmetric(horizontal: 8),
                                  activeColor: Colors.deepOrange,
                                  title: Text(
                                    "Verified Aadhaar",
                                    style: TextStyle(
                                      fontWeight: _verificationStatus == 1
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  value: 1,
                                  groupValue: _verificationStatus,
                                  onChanged: (int? value) {
                                    modalSetter(() {
                                      _verificationStatus = value!;
                                    });
                                  },
                                ),
                              ),
                            ) :
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: _verificationStatus == 0
                                      ? Colors.deepOrange.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _verificationStatus == 0
                                        ? Colors.deepOrange
                                        : Colors.grey.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: RadioListTile<int>(
                                  dense: true,
                                  contentPadding:
                                  EdgeInsets.symmetric(horizontal: 8),
                                  activeColor: Colors.deepOrange,
                                  title: Text(
                                    "Non-Verified Aadhaar",
                                    style: TextStyle(
                                      fontWeight: _verificationStatus == 0
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  value: 0,
                                  groupValue: _verificationStatus,
                                  onChanged: (int? value) {
                                    modalSetter(() {
                                      _verificationStatus = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        if (aadharRequired == 1) ...[
                          Text(
                            'Phone Number',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: phoneController2,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              hintText: ' Enter phone number',
                              prefixIcon: const Icon(
                                Icons.phone_rounded,
                                color: Colors.deepOrange,
                              ),
                              counterText: '',
                            ),
                            maxLength: 10,
                          ),
                          const SizedBox(height: 16),

                          Text(
                            'Aadhar Number',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: aadharController2,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              hintText: ' Enter 12-digit Aadhar',
                              prefixIcon: const Icon(
                                Icons.credit_card,
                                color: Colors.deepOrange,
                              ),
                              counterText: '',
                            ),
                            maxLength: 12,
                          ),
                          const SizedBox(height: 24),
                          // verify btn
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                String phone = phoneController2.text.trim();
                                String aadhar = aadharController2.text.trim();

                                // Phone validation
                                if (phone.isEmpty) {
                                  Fluttertoast.showToast(
                                    msg: "Phone number is required",
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                  );
                                  return;
                                }

                                // Allow either 10 digits OR +91 followed by 10 digits
                                final phoneRegex =
                                RegExp(r'^(?:\+91)?[0-9]{10}$');

                                if (!phoneRegex.hasMatch(phone)) {
                                  Fluttertoast.showToast(
                                    msg:
                                    "Enter a valid phone number (10 digits or +91XXXXXXXXXX)",
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                  );
                                  return;
                                }

                                // Aadhar validation
                                if (aadhar.isEmpty) {
                                  Fluttertoast.showToast(
                                    msg: "Aadhar number is required",
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                  );
                                  return;
                                } else if (aadhar.length != 12 ||
                                    !RegExp(r'^[0-9]+$').hasMatch(aadhar)) {
                                  Fluttertoast.showToast(
                                    msg: "Enter a valid 12-digit Aadhar number",
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                  );
                                  return;
                                }

                                // Check if Aadhar already exists
                                bool exists = devotees.any(
                                        (devotee) => devotee['aadhar'] == aadhar);
                                if (exists) {
                                  Fluttertoast.showToast(
                                    msg: "This Aadhar number is already added",
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                  );
                                  return;
                                }

                                // If everything is valid
                                modalSetter(() {
                                  isverify = true;
                                });

                                getAadhar(aadhar, context, modalSetter);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                padding:
                                const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: isverify
                                  ? const CircularProgressIndicator(
                                  color: Colors.white)
                                  : const Text(
                                'Verify',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],

                        if (aadharRequired == 0) ...[
                          // Name Field (Always shown)
                          Text(
                            'Full Name',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              hintText: 'Enter full name',
                              prefixIcon: const Icon(
                                Icons.person,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Phone Field (Only shown if devotees list is not empty)
                          if (devotees.isEmpty) ...[
                            Text(
                              'Phone Number',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                hintText: 'Enter phone number',
                                prefixIcon: const Icon(
                                  Icons.phone,
                                  color: Colors.deepOrange,
                                ),
                                counterText: '',
                              ),
                              maxLength: 10,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Aadhar Field (Always shown)
                          Text(
                            'Aadhar Number',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: aadharController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              hintText: 'Enter 12-digit Aadhar',
                              prefixIcon: const Icon(
                                Icons.credit_card,
                                color: Colors.deepOrange,
                              ),
                              counterText: '',
                            ),
                            maxLength: 12,
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                String name = nameController.text.trim();
                                String phone = phoneController.text.trim();
                                String aadhar = aadharController.text.trim();

                                // Validation rules
                                final phoneRegex = RegExp(
                                    r'^[0-9]{10}$'); // Only 10 digits (no +91)
                                final aadharRegex =
                                RegExp(r'^[0-9]{12}$'); // 12 digits only

                                // Name validation
                                if (name.isEmpty) {
                                  Fluttertoast.showToast(
                                    msg: "Full name is required",
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                  );
                                  return;
                                }

                                // If devotees list is empty → phone is required
                                if (devotees.isEmpty) {
                                  if (phone.isEmpty) {
                                    Fluttertoast.showToast(
                                      msg: "Phone number is required",
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                    );
                                    return;
                                  }

                                  if (!phoneRegex.hasMatch(phone)) {
                                    Fluttertoast.showToast(
                                      msg:
                                      "Enter a valid 10-digit phone number (without +91)",
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                    );
                                    return;
                                  }
                                }

                                // Aadhaar validation
                                if (aadhar.isEmpty) {
                                  Fluttertoast.showToast(
                                    msg: "Aadhar number is required",
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                  );
                                  return;
                                }

                                if (!aadharRegex.hasMatch(aadhar)) {
                                  Fluttertoast.showToast(
                                    msg: "Enter a valid 12-digit Aadhar number",
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                  );
                                  return;
                                }

                                // Check if Aadhaar already exists
                                bool exists = devotees.any(
                                        (devotee) => devotee['aadhar'] == aadhar);
                                if (exists) {
                                  Fluttertoast.showToast(
                                    msg: "This Aadhar number is already added",
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                  );
                                  return;
                                }

                                // ✅ If all validations pass
                                Navigator.pop(context);
                                setState(() {
                                  devotees.add({
                                    'name': name,
                                    'phone': devotees.isEmpty ? phone : '',
                                    'aadhar': aadhar,
                                    'aadhar_verify': "0",
                                  });
                                });

                                Fluttertoast.showToast(
                                  msg: "Devotee added successfully",
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                );

                                print("Devotee list item: $devotees");

                                // Clear fields after success
                                nameController.clear();
                                phoneController.clear();
                                aadharController.clear();

                                //sumTotal();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                padding:
                                const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Add Devotee',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }).then((value) {
      setState(() {
        isverify = false;
      });
    });
  }

  Widget _addMemberCard(double screenWidth, double screenHeight, int aadharRequired) {
    return GestureDetector(
      onTap:
      // int.tryParse("${widget.seatNumber}") == devotees.length
      //     ? null //  Disable click when seats full
      //     :
          () => _showAddDevoteeDialog(context,aadharRequired), //  Open dialog only if seats available
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.shade200.withOpacity(0.9),
              Colors.amber.shade50.withOpacity(0.9),
            ],
          ),
          border: Border.all(
            color: Colors.deepOrange.shade700.withOpacity(0.7),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.deepOrange.withOpacity(0.15),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepOrange,
              ),
              child: const Icon(
                Icons.group_add_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            /// ---- Text Change Based on Seats ----
            Expanded(
              child: Text(
                // devotees.isEmpty
                //     ? "Add Members"
                //     : int.tryParse("${widget.seatNumber}") == devotees.length
                //     ? "Members (${devotees.length}) • No more seats now"
                //     :
                "Add Members (${devotees.length})",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepOrange,
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            /// ---- Show Button Only If Seats Available ----
            ///  if (int.tryParse("${widget.seatNumber}") != devotees.length)
            //if (int.tryParse("${widget.seatNumber}") != devotees.length) ...[
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ElevatedButton(
                  onPressed: () => _showAddDevoteeDialog(context,aadharRequired),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: Colors.deepOrange.shade600,
                        width: 1.5,
                      ),
                    ),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Text(
                        "ADD",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.add_circle_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            //]
          ],
        ),
      ),
    );

    // Add Devotee Button
    // Container(
    //   height: 60, // Slightly taller for better touch targets
    //   padding: const EdgeInsets.symmetric(horizontal: 18),
    //   decoration: BoxDecoration(
    //     borderRadius: BorderRadius.circular(14), // Smoother corners
    //     gradient: LinearGradient(
    //       begin: Alignment.topLeft,
    //       end: Alignment.bottomRight,
    //       colors: [
    //         Colors.orange.shade200.withOpacity(0.9),
    //         Colors.amber.shade50.withOpacity(0.9),
    //       ],
    //     ),
    //     border: Border.all(
    //       color: Colors.deepOrange.shade700.withOpacity(0.7),
    //       width: 1.2,
    //     ),
    //     boxShadow: [
    //       BoxShadow(
    //         color: Colors.deepOrange.withOpacity(0.15),
    //         blurRadius: 10,
    //         spreadRadius: 1,
    //         offset: const Offset(0, 3),
    //       ),
    //     ],
    //   ),
    //   child: Row(
    //     children: [
    //       AnimatedContainer(
    //         duration: const Duration(milliseconds: 200),
    //         padding: const EdgeInsets.all(6),
    //         decoration: BoxDecoration(
    //           shape: BoxShape.circle,
    //           color: Colors.deepOrange,
    //         ),
    //         child: Icon(
    //           Icons.group_add_rounded, // More relevant icon
    //           color: Colors.white,
    //           size: 22,
    //         ),
    //       ),
    //       const SizedBox(width: 12),
    //       Text(
    //         devotees.isEmpty
    //             ? "Add Members" // More engaging text
    //             : "Add Members (${devotees.length})",
    //         style: GoogleFonts.poppins(
    //           // Using a custom font (add google_fonts package)
    //           fontSize: 17,
    //           fontWeight: FontWeight.w600,
    //           color: Colors.deepOrange,
    //           letterSpacing: 0.2,
    //         ),
    //       ),
    //       const Spacer(),
    //       MouseRegion(
    //         // Adds hover effect (if on web/desktop)
    //         cursor: SystemMouseCursors.click,
    //         child: AnimatedContainer(
    //           duration: const Duration(milliseconds: 150),
    //           child: ElevatedButton(
    //             onPressed: () => _showAddDevoteeDialog(context),
    //             style: ElevatedButton.styleFrom(
    //               backgroundColor: Colors.deepOrange,
    //               foregroundColor: Colors.deepOrange.shade300,
    //               shape: RoundedRectangleBorder(
    //                 borderRadius: BorderRadius.circular(18),
    //                 side: BorderSide(
    //                   color: Colors.deepOrange.shade600,
    //                   width: 1.5,
    //                 ),
    //               ),
    //               padding:
    //               const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    //               elevation: 0,
    //               shadowColor: Colors.transparent,
    //             ),
    //             onHover: (isHovered) {
    //               // Optional: Add hover animation logic
    //             },
    //             child: Row(
    //               children: [
    //                 Text(
    //                   "ADD", // More action-oriented
    //                   style: GoogleFonts.poppins(
    //                       fontSize: 13,
    //                       fontWeight: FontWeight.bold,
    //                       letterSpacing: 0.5,
    //                       color: Colors.white),
    //                 ),
    //                 const SizedBox(width: 6),
    //                 Icon(
    //                   Icons.add_circle_rounded,
    //                   size: 18,
    //                   color: Colors.white,
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }

  void showOtpVerificationDialog(BuildContext context, String requestId) {
    final otpController = TextEditingController();
    bool isButtonEnabled = false;
    bool isVerifying = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetter) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// HEADER
                  Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.verified_user_rounded,
                          size: 48,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  /// TITLE
                  Text(
                    'OTP Verification',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  /// SUBTITLE
                  Text(
                    'Enter the 6-digit code sent to your mobile',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  /// OTP FIELD
                  PinCodeTextField(
                    controller: otpController,
                    length: 6,
                    appContext: context,
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.fade,
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: true,
                    cursorColor: Theme.of(context).primaryColor,
                    textStyle: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(12),
                      fieldHeight: 55,
                      fieldWidth: 45,
                      activeFillColor: Colors.white,
                      selectedFillColor: Colors.white,
                      inactiveFillColor: Colors.grey.shade100,

                      activeColor: Theme.of(context).primaryColor,
                      selectedColor: Theme.of(context).primaryColor,
                      inactiveColor: Colors.grey.shade300,
                    ),
                    boxShadows: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    onChanged: (value) {
                      modalSetter(() {
                        isButtonEnabled = value.length == 6;
                      });
                    },
                    beforeTextPaste: (text) => text?.length == 6,
                  ),
                  const SizedBox(height: 24),

                  /// BUTTON ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// RESEND OTP
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('OTP resent successfully'),
                            ),
                          );

                          getAadhar(
                              aadharController2.text, context, modalSetter);
                        },
                        child: Text(
                          'Resend OTP',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),

                      /// VERIFY BUTTON
                      ElevatedButton(
                        onPressed: isButtonEnabled && !isVerifying
                            ? () async {
                          modalSetter(() {
                            isVerifying = true;
                          });

                          await verifyOtp(
                            otpController.text,
                            requestId,
                            context,
                          );

                          modalSetter(() {
                            isVerifying = false;
                          });
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: isVerifying
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          'Verify',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAadharRequiredSection() {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _showAadharBottomSheet,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.orange.shade100, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person_add_alt_1_rounded,
                      color: Colors.orange,
                      size: 22,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Persons (Aadhar Required)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tap to add persons with Aadhar verification',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      '$_personCount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        if (_verifiedUsers.isNotEmpty || _nonVerifiedUsers.isNotEmpty) ...[
          SizedBox(height: 16),
          Divider(color: Colors.grey.shade200, height: 1),
          SizedBox(height: 12),
          Text(
            'Added Persons',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              if (_verifiedUsers.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade200, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified, size: 14, color: Colors.green),
                      SizedBox(width: 6),
                      Text(
                        '${_verifiedUsers.length} verified',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(width: 10),
              if (_nonVerifiedUsers.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.shade200, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.pending, size: 14, color: Colors.orange),
                      SizedBox(width: 6),
                      Text(
                        '${_nonVerifiedUsers.length} pending',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSimpleCounterSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text(
              //   'Number of Attendees',
              //   style: TextStyle(
              //     fontSize: 12,
              //     fontWeight: FontWeight.w700,
              //     color: Color(0xFF1A1A2E),
              //   ),
              // ),
              // SizedBox(height: 4),
              Text(
                'Select total number of persons',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 3,),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_rounded, size: 18),
                        onPressed: _personCount > 1 ? () => setState(() => _personCount--) : null,
                        color: Colors.grey.shade600,
                      ),
                      Container(
                        width: 40,
                        child: Center(
                          child: Text(
                            '$_personCount',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_rounded, size: 18),
                        onPressed: () => setState(() => _personCount++),
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }

  Widget _buildBottomActionButton() {
    return Consumer<TickitAvailablityController>(
      builder: (context, controller, child) {
        final summeryController = context.read<TickitSummeryController>();
        final tickitData = summeryController.tickitSummeryModel?.data;

        final isDateSelected = _selectedDate != null;
        final isTimeSelected = _selectedTime != null;

        final aadharRequired = tickitData?.requiredAadharStatus ?? 0;
        final isPersonValid = aadharRequired == 1
            ? devotees.isNotEmpty
            : _personCount > 0;

        final hasCheckedAvailability = controller.hasCheckedAvailability;
        final packages =
            controller.tickitAvailiblityModel?.data?.packageList;
        final isPackageAvailable =
            packages != null && packages.isNotEmpty;

        final auditoriumStatus = tickitData?.auditorium ?? 0;
        final shouldCheckAvailability = auditoriumStatus == 1;

        /// 🔹 Basic conditions
        bool areBasicConditionsMet =
            isDateSelected && isTimeSelected && isPersonValid;

        /// 🔹 Final Enable Condition
        bool isEnabled = areBasicConditionsMet &&
            (auditoriumStatus == 1 || _selectedPackageIndex != null);

        String buttonText = "Complete Selection";
        VoidCallback? onPressed;
        bool showLoading = false;

        if (!areBasicConditionsMet) {
          if (aadharRequired == 1 && devotees.isEmpty) {
            buttonText = 'Proceed to Payment';
          } else if (!isDateSelected || !isTimeSelected) {
            buttonText = 'Select Date & Time';
          } else {
            buttonText = 'Add Persons';
          }
          onPressed = null;
        } else if (shouldCheckAvailability && !hasCheckedAvailability) {
          buttonText = 'Choose Your Seats';
          onPressed = () => _checkAvailability(context);
        } else if (shouldCheckAvailability && controller.isLoading) {
          buttonText = 'Choose Your Seats...';
          showLoading = true;
          onPressed = null;
        } else if (shouldCheckAvailability && !isPackageAvailable) {
          buttonText = 'No Packages Available';
          onPressed = null;
        } else {
          if (auditoriumStatus == 1) {
            buttonText = 'Choose Your Seat';
          } else {
            if (packages != null &&
                packages.isNotEmpty &&
                _selectedPackageIndex != null) {
              final selectedPackage =
              packages[_selectedPackageIndex!];

              final personCount = aadharRequired == 1
                  ? devotees.length
                  : _personCount;

              final totalAmount =
                  int.parse(selectedPackage.price) * personCount;

              buttonText = 'Proceed to Payment - ₹$totalAmount';
            } else {
              buttonText = 'Proceed to Payment';
            }
          }

          onPressed = () => _proceedToNextStep(context);
        }

        return Container(
          height: 75,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: isEnabled
                ? const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: isEnabled ? null : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isEnabled
                ? [
              BoxShadow(
                color:
                const Color(0xFF667EEA).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: showLoading
                  ? null
                  : () {

                if (!isDateSelected) {
                  _showWarning(context, "Please select date");
                  return;
                }

                if (!isTimeSelected) {
                  _showWarning(context, "Please select time");
                  return;
                }

                if (aadharRequired == 1 && devotees.isEmpty) {
                  _showWarning(context, "Please add devotees");
                  return;
                }

                if (aadharRequired != 1 && _personCount <= 0) {
                  _showWarning(context, "Please add persons");
                  return;
                }

                if (auditoriumStatus != 1 && _selectedPackageIndex == null) {
                  _showWarning(context, "Please select package");
                  return;
                }

                //  All good → call original function
                if (onPressed != null) {
                  onPressed();
                }
              },
              // onTap: isEnabled && !showLoading
              //     ? onPressed
              //     : null,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: showLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
                    : Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(
                            isEnabled ? 0.2 : 0.1),
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                      child: Icon(
                        auditoriumStatus == 1
                            ? Icons.chair_alt_rounded
                            : Icons.payment_rounded,
                        color: Colors.white.withOpacity(
                            isEnabled ? 1 : 0.6),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Text(
                            buttonText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (aadharRequired == 1 &&
                              isEnabled)
                            Text(
                              '${devotees.length} Aadhar verified person${devotees.length > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white
                                    .withOpacity(0.9),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (isEnabled && !showLoading)
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _checkAvailability(BuildContext context) async {
    // Format date properly
    final formattedDate = _selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
        : '';

    // Get selected time slot ID
    int? selectedTimeId;
    final tickitData = context.read<TickitSummeryController>().tickitSummeryModel?.data;
    if (_selectedTime != null && tickitData?.date != null && tickitData!.date.isNotEmpty) {
      for (var slot in tickitData.date) {
        final timeText = '${slot.startTime} - ${slot.endTime}';
        if (timeText == _selectedTime) {
          selectedTimeId = slot.id;
          break;
        }
      }
    }

    // Call availability API
    await context.read<TickitAvailablityController>().getTickitAvailiblity(
      widget.slug,
      formattedDate,
      selectedTimeId?.toString() ?? '1',
    );
    _proceedToNextStep(context);
  }

  void _proceedToNextStep(BuildContext context) {
    final controller = context.read<TickitAvailablityController>();
    final leadController = context.read<LeadGenerateController>();
    final summeryController = context.read<TickitSummeryController>();
    final tickitData = summeryController.tickitSummeryModel?.data;

    final auditoriumStatus = tickitData?.auditorium ?? 0;
    final aadharRequired = tickitData?.requiredAadharStatus ?? 0;

    final personCount =
    aadharRequired == 1 ? devotees.length : _personCount;

    //  CASE 1 → Auditorium 1 (Seat Selection Flow)
    if (auditoriumStatus == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeatSelectionScreen(
            ticketData: controller.tickitAvailiblityModel!,
            personCount: personCount,
            venueId: widget.venueId,
            eventId: widget.eventId,
            leadId: leadController.leadId ?? 0, // Lead ID
            packageId: 0,
            eventName: "${widget.adventureName}", // Event name
            eventDate: DateFormat('d MMM yyyy').format(_selectedDate!),
            eventTime: "${_selectedTime}", // Event time
            eventVenue: "${widget.venue}", devotees: devotees, walletPay: walletPay,
          ),
        ),
      );
      return;
    }

    //  CASE 2 → Auditorium 0 (Package Required Flow)

    final packages = controller.tickitAvailiblityModel?.data?.packageList;

    if (packages == null ||
        packages.isEmpty ||
        _selectedPackageIndex == null) {
      return; // Safety
    }

    final selectedPackage = packages[_selectedPackageIndex!];
    final totalAmount = int.parse(selectedPackage.price) * personCount;

    print('Navigate to Payment Screen');
    print('Total Amount: ₹$totalAmount');
    print('Persons: $personCount');

    // Navigate to payment
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketPaymentSummary(
          packageName: "${selectedPackage.enPackageName}", // Selected package name
          eventName: "${widget.adventureName}", // Event name
          eventDate: DateFormat('d MMM yyyy').format(_selectedDate!),
          eventTime: "${_selectedTime}", // Event time
          eventVenue: "${widget.venue}", // Venue
          personCount: personCount, // Number of persons
          seatNumbers: [],
          totalAmount: double.parse(totalAmount.toString()), // Total amount
          eventId: widget.eventId.toString(), // Event ID
          venueId: widget.venueId.toString(), // Venue ID
          leadId: leadController.leadId.toString(), // Lead ID
          packageId: selectedPackage.packageId.toString(),
          devotees: devotees,
          amount: double.parse(selectedPackage.price), walletPay: walletPay, // Package ID
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _buildCustomCalendarSheet();
      },
    );
  }

  void _showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildCustomCalendarSheet() {
    DateTime focusedDate = _selectedDate ?? DateTime.now();
    DateTime firstDate = DateTime.now();
    DateTime lastDate = DateTime.now().add(const Duration(days: 60));

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.80,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
          ),
          child: Column(
            children: [

              /// ===== Drag Indicator =====
              const SizedBox(height: 14),
              Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.orange.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 20),

              /// ===== Custom Header =====
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      "Select Your Date",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// ===== Calendar =====
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Colors.deepOrange,      // Selected circle
                      onPrimary: Colors.white,         // Selected text
                      surface: Colors.white,
                      onSurface: Colors.black87,
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.deepOrange,
                      ),
                    ),
                  ),
                  child: CalendarDatePicker(
                    initialDate: focusedDate,
                    firstDate: firstDate,
                    lastDate: lastDate,
                    onDateChanged: (picked) {
                      setModalState(() {
                        focusedDate = picked;
                      });
                    },
                  ),
                ),
              ),

              /// ===== Selected Date Preview =====
              if (focusedDate != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.deepOrange.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_available,
                          color: Colors.deepOrange, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('EEEE, d MMM yyyy')
                            .format(focusedDate),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              /// ===== Confirm Button =====
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 15),
                child: ElevatedButton(
                  onPressed: () {
                    if (!DateUtils.isSameDay(_selectedDate, focusedDate)) {
                      setState(() {
                        _selectedDate = focusedDate;
                      });

                      _resetSelectionOnDateChange();
                    }

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    elevation: 8,
                    shadowColor: Colors.deepOrange.withOpacity(0.4),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    "Confirm Date",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAadharBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AadharBottomSheet(
        onAddVerified: (user) {
          setState(() {
            _verifiedUsers.add(user);
            _personCount = _verifiedUsers.length + _nonVerifiedUsers.length + 1;
          });
        },
        onAddNonVerified: (aadhar) {
          setState(() {
            _nonVerifiedUsers.add({
              'name': 'User ${_nonVerifiedUsers.length + 1}',
              'aadhar': aadhar,
              'status': 'pending',
            });
            _personCount = _verifiedUsers.length + _nonVerifiedUsers.length + 1;
          });
        },
        verifiedUsers: _verifiedUsers,
        nonVerifiedUsers: _nonVerifiedUsers,
      ),
    );
  }
}

class _AadharBottomSheet extends StatefulWidget {
  final Function(Map<String, String>) onAddVerified;
  final Function(String) onAddNonVerified;
  final List<Map<String, String>> verifiedUsers;
  final List<Map<String, String>> nonVerifiedUsers;

  const _AadharBottomSheet({
    Key? key,
    required this.onAddVerified,
    required this.onAddNonVerified,
    required this.verifiedUsers,
    required this.nonVerifiedUsers,
  }) : super(key: key);

  @override
  __AadharBottomSheetState createState() => __AadharBottomSheetState();
}

class __AadharBottomSheetState extends State<_AadharBottomSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController _aadharController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _aadharController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Persons',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.deepOrange,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: TextStyle(fontWeight: FontWeight.w700),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.deepOrange.withOpacity(0.1),
              ),
              tabs: [
                Tab(text: 'Non-Verified'),
                Tab(text: 'Verified'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNonVerifiedTab(),
                _buildVerifiedTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNonVerifiedTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Input Form
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _aadharController,
                  keyboardType: TextInputType.number,
                  maxLength: 12,
                  decoration: InputDecoration(
                    labelText: 'Aadhar Number',
                    prefixIcon: Icon(Icons.credit_card),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange, Colors.deepOrange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        if (_aadharController.text.length == 12 && _nameController.text.isNotEmpty) {
                          widget.onAddNonVerified(_aadharController.text);
                          _aadharController.clear();
                          _nameController.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Person added successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      child: Center(
                        child: Text(
                          'Add Person',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (widget.nonVerifiedUsers.isNotEmpty) ...[
            SizedBox(height: 20),
            Text(
              'Pending Verification (${widget.nonVerifiedUsers.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 12),
            ...widget.nonVerifiedUsers.map((user) => _buildUserCard(user, false)),
          ],
        ],
      ),
    );
  }

  Widget _buildVerifiedTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: widget.verifiedUsers.isEmpty
          ? Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_user_rounded,
              size: 50,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'No Verified Users',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      )
          : Column(
        children: [
          Text(
            'Verified Users (${widget.verifiedUsers.length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          SizedBox(height: 16),
          ...widget.verifiedUsers.map((user) => _buildUserCard(user, true)),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, String> user, bool isVerified) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isVerified ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVerified ? Colors.green.shade200 : Colors.orange.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isVerified ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isVerified ? Icons.verified : Icons.pending,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Aadhar: ${user['aadhar']}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            isVerified ? 'Verified' : 'Pending',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isVerified ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}