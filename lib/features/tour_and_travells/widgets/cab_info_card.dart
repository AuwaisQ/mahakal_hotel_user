import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class CabInfoCard extends StatefulWidget {
  final String imageUrl;
  final String cabName;
  final String seatsText;
  final String unitPrice;
  final String totalLabel;
  final String totalPrice;
  final int quantity;
  final bool isEnglish;
  final bool personInCab;
  final VoidCallback onInfoTap;
  final VoidCallback onAddTap;
  final VoidCallback onIncreaseTap;
  final VoidCallback onDecreaseTap;
  final bool isSelected;
  final VoidCallback? onSelect; // Made optional
  final VoidCallback? onClearTap;
  final int? selectedIndex;
  final int? widgetIndex;
  final bool isPersonWise;
  final int? includedStatus;

  const CabInfoCard({
    super.key,
    required this.imageUrl,
    required this.cabName,
    required this.seatsText,
    required this.unitPrice,
    required this.totalLabel,
    required this.totalPrice,
    required this.quantity,
    required this.isEnglish,
    required this.onInfoTap,
    required this.onAddTap,
    required this.onIncreaseTap,
    required this.onDecreaseTap,
    required this.personInCab,
    this.isSelected = false,
    this.onSelect,
    this.selectedIndex,
    this.widgetIndex,
    this.onClearTap,
    this.isPersonWise = false,
    this.includedStatus,
  });

  @override
  State<CabInfoCard> createState() => _CabInfoCardState();
}

class _CabInfoCardState extends State<CabInfoCard>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return widget.personInCab
        ? _buildPersonInCabDesign()
        : _buildVehicleDesign();
  }

  /// Personwise
  Widget _buildPersonInCabDesign() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300)),
      child: widget.includedStatus == 1
          ? Column(
              children: [
                Row(
                  children: [
                    // Left side: Text info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.cabName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.seatsText,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),

                    // Right side: Image + ADD/Quantity button over it
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: widget.imageUrl,
                              height: 100,
                              width: 150,
                              fit: BoxFit.fill,
                              placeholder: (context, url) => Container(
                                height: 120,
                                width: 150,
                                color: Colors.grey.shade200,
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.image),
                            ),
                          ),
                        ),

                        // Info Icon (Top Right)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: InkWell(
                            onTap: widget.onInfoTap,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        // Floating Add/Quantity Button (Bottom center, half outside)
                        widget.includedStatus == 1
                            ? Positioned(
                                bottom: -15,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    width: 125,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.blue,
                                      border: Border.all(color: Colors.blue),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Included",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 17),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Positioned(
                                bottom: -15,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    width: 120,
                                    height: 33,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: widget.quantity == 0
                                          ? Colors.white
                                          : Colors.blue,
                                      border: Border.all(
                                          color: widget.quantity == 0
                                              ? Colors.blue
                                              : Colors.grey.shade300),
                                    ),
                                    child: widget.quantity == 0
                                        ? InkWell(
                                            onTap: widget.onAddTap,
                                            child: const Center(
                                              child: Text(
                                                "ADD +",
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              IconButton(
                                                onPressed: widget.onDecreaseTap,
                                                icon: const Icon(Icons.remove,
                                                    size: 16,
                                                    color: Colors.white),
                                                splashRadius: 16,
                                              ),
                                              Text(
                                                "${widget.quantity}",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              ),
                                              IconButton(
                                                onPressed: widget.onIncreaseTap,
                                                icon: const Icon(Icons.add,
                                                    size: 16,
                                                    color: Colors.white),
                                                splashRadius: 16,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 5),
              ],
            )
          : Column(
              children: [
                Row(
                  children: [
                    // Left side: Text info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.cabName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${widget.seatsText}",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹' + NumberFormat('#,###').format(int.parse("${widget.unitPrice}")),
                            //formatIndianCurrency(widget.unitPrice),
                           // "₹${widget.unitPrice}",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                "${widget.totalLabel}: ",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '₹' + NumberFormat('#,###').format(int.parse("${widget.totalPrice}")),
                                //formatIndianCurrency(widget.totalPrice),
                               // widget.totalPrice,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: widget.quantity == 0
                                      ? Colors.grey
                                      : Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Right side: Image + ADD/Quantity button over it
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: widget.imageUrl,
                              height: 100,
                              width: 150,
                              fit: BoxFit.fill,
                              placeholder: (context, url) => Container(
                                height: 120,
                                width: 150,
                                color: Colors.grey.shade200,
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.image),
                            ),
                          ),
                        ),

                        // Info Icon (Top Right)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: InkWell(
                            onTap: widget.onInfoTap,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: -15,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 125,
                              height: 38,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: widget.quantity == 0
                                    ? Colors.white
                                    : Colors.blue,
                                border: Border.all(
                                    color: widget.quantity == 0
                                        ? Colors.blue
                                        : Colors.grey.shade300),
                              ),
                              child: widget.quantity == 0
                                  ? InkWell(
                                      onTap: widget.onAddTap,
                                      child: const Center(
                                        child: Text(
                                          "ADD +",
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          onPressed: widget.onDecreaseTap,
                                          icon: const Icon(Icons.remove,
                                              size: 16, color: Colors.white),
                                          splashRadius: 16,
                                        ),
                                        Text(
                                          "${widget.quantity}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 16),
                                        ),
                                        IconButton(
                                          onPressed: widget.onIncreaseTap,
                                          icon: const Icon(Icons.add,
                                              size: 16, color: Colors.white),
                                          splashRadius: 16,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 5),
              ],
            ),
    );
  }

  /// CabWise
  Widget _buildVehicleDesign() {

    bool shouldBlur = widget.selectedIndex != -1 && widget.selectedIndex != widget.widgetIndex;

    return Opacity(
      opacity: shouldBlur ? 0.2 : 1.0,
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              if(widget.quantity > 0){
                widget.onClearTap!();
              }
              else{
                widget.onSelect?.call();
                widget.onAddTap.call();
                print("Condition Working");
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: widget.quantity > 0
                          ? Colors.transparent
                          : Colors.blue.shade100)),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 15),
                    decoration: BoxDecoration(
                      color: widget.quantity > 0
                          ? Colors.blue.shade50
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Text section
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.cabName,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.seatsText,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                      '₹' + NumberFormat('#,###').format(int.parse("${widget.unitPrice}")),
                                      //formatIndianCurrency(widget.unitPrice),
                                     // "₹${widget.unitPrice}",
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.isPersonWise
                                        ? (widget.isEnglish
                                            ? "No. of Person"
                                            : "व्यक्ति की संख्या")
                                        : (widget.isEnglish
                                            ? "No. of Vehicle"
                                            : "वाहन की संख्या"),
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text("${widget.totalLabel}: ",
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black)),
                                      Text(
                                          '₹' + NumberFormat('#,###').format(int.parse("${widget.totalPrice}")), // yahan commas add ho jaayenge
                                          // widget.totalPrice,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: widget.quantity == 0
                                                  ? Colors.grey
                                                  : Colors.blue)),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Image + Info + Add
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: widget.quantity > 0
                                            ? Colors.blue
                                            : Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.imageUrl,
                                      height: 100,
                                      width: 150,
                                      fit: BoxFit.fill,
                                      placeholder: (context, url) =>
                                          Container(
                                        height: 120,
                                        width: 150,
                                        color: Colors.grey.shade200,
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.image),
                                    ),
                                  ),
                                ),

                                // Info icon
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: InkWell(
                                    onTap: widget.onInfoTap,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.info_outline,
                                          size: 16, color: Colors.white),
                                    ),
                                  ),
                                ),

                                // ADD button
                                if (widget.quantity == 0)
                                  Positioned(
                                    bottom: -15,
                                    left: 20,
                                    right: 20,
                                    child: InkWell(
                                      onTap: () {
                                        widget.onSelect?.call();
                                        widget.onAddTap.call();
                                      },
                                      child: Container(
                                        width: 120,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.white,
                                          border: Border.all(
                                              color: Colors.blue),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            "ADD +",
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Quantity box
                  if (widget.isSelected && widget.quantity > 0)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      height: 60, // Increased height for better touch targets
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16), // Increased border radius
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.blue.withOpacity(0.2)),
                          gradient: const LinearGradient(
                            colors: [
                              Colors.amber,
                              Colors.blue,
                              Colors.amber,
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Decrease Button
                            InkWell(
                              onTap: widget.onDecreaseTap,
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.green,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.remove,
                                  size: 20,
                                  color: Colors.green,
                                ),
                              ),
                            ),

                            // Quantity Display
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.1),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    widget.isPersonWise
                                        ? (widget.isEnglish
                                        ? "No. of Person"
                                        : "व्यक्ति की संख्या")
                                        : (widget.isEnglish
                                        ? "No. of Vehicle"
                                        : "वाहन की संख्या"),
                                    // "Total Vehicle:",
                                    style: TextStyle(
                                      fontSize: 14, // Increased font size
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(width: 5,),
                                  Text(
                                    "${widget.quantity}",
                                    style: TextStyle(
                                      fontSize: 18, // Increased font size
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Increase Button
                            InkWell(
                              onTap: widget.onIncreaseTap,
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
          widget.quantity > 0
              ? Positioned(
                  right: 5,
                  top: -5,
                  child: InkWell(
                    onTap: () {
                      // Single tap to completely clear
                      widget.onClearTap!();
                    },
                    child: Container(
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                            color: Colors.black12, shape: BoxShape.circle),
                        child: const Icon(
                          Icons.close,
                          size: 24,
                          color: Colors.red,
                        )),
                  ))
              : const SizedBox()
        ],
      ),
    );
  }
}
