// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:mahakal/features/blogs_module/no_image_widget.dart';
// import '../../donation/controller/lanaguage_provider.dart';
// import '../../youtube_vedios/view/dynamic_tabview/grid_view/YoutubeGridView.dart';
// import '../model/subCategory_model.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'event_details.dart';
//
// class SeeScreen extends StatefulWidget {
//   List<SubData>? eventSubCategory;
//   String? eventType;
//
//   SeeScreen({super.key, this.eventSubCategory, this.eventType});
//
//   @override
//   State<SeeScreen> createState() => _SeeScreenState();
// }
//
// class _SeeScreenState extends State<SeeScreen> {
//
//   TextEditingController _searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     filteredSearch = widget.eventSubCategory!;
//   }
//
//   // Default values
//   String startDate = 'No Start Date';
//   String endDate = 'No End Date';
//   String fullDate = 'No Date';
//   String singleDate = 'No Single Date';
//   bool isSearchClicked = false;
//
//   List<SubData> filteredSearch = [];
//
//   void filterSearch(String query){
//     setState(() {
//       filteredSearch = widget.eventSubCategory!.where((item) => item.enEventName!.toLowerCase().contains(query.toLowerCase())).toList();
//     });
//   }
//
//   void dateFormatter(String startToEndDate) {
//     // String? startToEndDate = event.startToEndDate;
//
//     if (startToEndDate != null && startToEndDate.isNotEmpty) {
//       List<String> dates = startToEndDate.contains(" - ")
//           ? startToEndDate.split(" - ")
//           : [startToEndDate];
//
//       final inputFormat = DateFormat('yyyy-MM-dd');
//       final outputFormat = DateFormat('d MMMM yyyy'); // 10 March 2025 format
//
//       try {
//         // Start date format
//         startDate = outputFormat.format(inputFormat.parse(dates[0]));
//
//         if (dates.length > 1) {
//           // End date format (if range is given)
//           endDate = outputFormat.format(inputFormat.parse(dates[1]));
//           fullDate = "$startDate - $endDate";
//         } else {
//           // Single date case
//           singleDate = startDate;
//           fullDate = startDate;
//         }
//       } catch (e) {
//         print("Date Parsing Error: $e");
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var screenHeight = MediaQuery.of(context).size.height;
//     var screenWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.deepOrange,
//         leading: IconButton(onPressed: () {
//           Navigator.pop(context);
//         }, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
//         actions: [
//           IconButton(onPressed: () {
//             setState(() {
//               isSearchClicked = !isSearchClicked;
//             });
//           }, icon: Icon(Icons.search,color: Colors.white,)),
//           const SizedBox(
//             width: 15,
//           ),
//         ],
//         title: Text(
//           "${widget.eventType ?? "N/A"}",
//           style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: screenWidth * 0.06,
//               color: Colors.white),
//         ),
//         centerTitle: true,
//       ),
//       body: Padding(
//           padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
//           child: widget.eventSubCategory == null ||
//                   widget.eventSubCategory!.isEmpty
//               ? const Center(child: Text("No Data"))
//               : Column(
//                 children: [
//
//                   isSearchClicked ? Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Container(
//                       height: 45,
//                       child: TextFormField(
//                         controller: _searchController,
//                         onChanged: filterSearch,
//                         decoration: InputDecoration(
//                             hintText: 'Search by name...',
//                             hintStyle: const TextStyle(color: Colors.grey),
//                             suffixIcon: InkWell(
//                                 onTap: () {
//                                   setState(() {
//                                     _searchController.clear();
//                                   });
//                                 },
//                                 child: Icon(Icons.close)),
//                             prefixIcon: Icon(Icons.search),
//                             border: OutlineInputBorder(
//                               borderSide: BorderSide(color: Colors.grey, width: 2.0),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderSide: BorderSide(color: Colors.grey, width: 2.0),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderSide: BorderSide(color: Colors.orange, width: 2.0),
//                               borderRadius: BorderRadius.circular(10),
//                             )),
//                       ),
//                     ),
//                   ) : const SizedBox(),
//
//                   Expanded(
//                     child: GridView.builder(
//                         padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
//                         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 1,
//                           crossAxisSpacing: 10,
//                           mainAxisSpacing: 10,
//                           childAspectRatio: 0.90,
//                         ),
//                         itemCount: filteredSearch.length,
//                         itemBuilder: (context, index) {
//                           //  Date Formatter Value Store Kiya
//                           dateFormatter(
//                               widget.eventSubCategory![index].startToEndDate ?? "");
//                           var venueLength =
//                               widget.eventSubCategory![index].allVenueData?.length ??
//                                   0;
//                           var hasVenueData =
//                               widget.eventSubCategory![index].allVenueData != null &&
//                                   widget.eventSubCategory![index].allVenueData!
//                                       .isNotEmpty;
//                           var venueData = hasVenueData
//                               ? widget.eventSubCategory![index].allVenueData!.first
//                               : null;
//                           return GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 CupertinoPageRoute(
//                                     builder: (context) => EventDeatils(
//                                           eventId: widget.eventSubCategory![index].id,
//                                           eventSubCategory: widget.eventSubCategory,
//                                           enEventVenue: widget
//                                                   .eventSubCategory![index]
//                                                   .allVenueData![0]
//                                                   .enEventVenue ??
//                                               'N/A',
//                                           hiEventVenue: widget
//                                                   .eventSubCategory![index]
//                                                   .allVenueData![0]
//                                                   .enEventVenue ??
//                                               'N/A',
//                                         )),
//                               );
//                             },
//                             child: Consumer<LanguageProvider>(
//                               builder: (context, languageProvider, child) {
//                                 return Container(
//                                   padding: EdgeInsets.all(8),
//                                   decoration: BoxDecoration(
//                                     border: Border.all(color: const Color.fromRGBO(231, 231, 231, 1)),
//                                     borderRadius: BorderRadius.circular(12),
//                                     color: Colors.white,
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.05),
//                                         spreadRadius: 2,
//                                         blurRadius: 5,
//                                         offset: const Offset(0, 2),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       //  Image with Overlay
//                                       SizedBox(
//                                         width: double.infinity,
//                                         height: screenHeight * 0.24,
//                                         child: ClipRRect(
//                                           borderRadius: BorderRadius.circular(12),
//                                           child: Stack(
//                                             fit: StackFit.expand,
//                                             children: [
//                                               // Background Image
//                                               CachedNetworkImage(
//                                                 imageUrl: widget.eventSubCategory?[index].eventImage ?? "N/A",
//                                                 fit: BoxFit.fill,
//                                                 placeholder: (context, url) => placeholderImage(),
//                                                 errorWidget: (context, url, error) => NoImageWidget()
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                       SizedBox(height: screenHeight * 0.01),
//
//                                       //  Event Name
//                                       Flexible(
//                                         child: Text(
//                                           languageProvider.language == "english"
//                                               ? widget.eventSubCategory![index]
//                                                       .enEventName ??
//                                                   "N/A"
//                                               : widget.eventSubCategory![index]
//                                                       .hiEventName ??
//                                                   "N/A",
//                                           overflow: TextOverflow.ellipsis,
//                                           maxLines: 1,
//                                           style: TextStyle(
//                                               fontSize: screenWidth * 0.045,
//                                               fontWeight: FontWeight.w600,
//                                               color: Colors.black),
//                                         ),
//                                       ),
//                                       SizedBox(height: screenHeight * 0.005),
//
//                                       //  Event Date & Time
//                                       Consumer<LanguageProvider>(
//                                         builder: (context, languageProvider, child) {
//                                           return Text.rich(
//                                             maxLines: 4,
//                                             TextSpan(
//                                               children: [
//                                                 TextSpan(
//                                                   text: languageProvider.language ==
//                                                           "english"
//                                                       ? "Start Date: "
//                                                       : "आरंभ करने की तिथि: ",
//                                                   style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.blue,
//                                                     fontSize: screenWidth * 0.04,
//                                                   ),
//                                                 ),
//                                                 TextSpan(
//                                                   text: fullDate,
//                                                   style: const TextStyle(
//                                                       fontWeight: FontWeight.w400),
//                                                 ),
//                                                 TextSpan(
//                                                   text:
//                                                       "\n${languageProvider.language == "english" ? "Start Time: " : "समय: "}",
//                                                   style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.blue,
//                                                     fontSize: screenWidth * 0.04,
//                                                   ),
//                                                 ),
//                                                 TextSpan(
//                                                   text: hasVenueData &&
//                                                           venueData!.startTime != null
//                                                       ? venueData!.startTime
//                                                       : "No Time",
//                                                   style: const TextStyle(
//                                                       fontWeight: FontWeight.w400),
//                                                 ),
//                                                 TextSpan(
//                                                   text:
//                                                       "\n${languageProvider.language == "english" ? "Venue: " : "स्थान: "}",
//                                                   style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.blue,
//                                                     fontSize: screenWidth * 0.04,
//                                                   ),
//                                                 ),
//                                                 TextSpan(
//                                                   text: hasVenueData
//                                                       ? (languageProvider.language ==
//                                                               "english"
//                                                           ? venueData!.enEventVenue ??
//                                                               "No Venue"
//                                                           : venueData!.hiEventVenue ??
//                                                               "कोई स्थान नहीं")
//                                                       : "No Venue",
//                                                   style: const TextStyle(
//                                                       fontWeight: FontWeight.w400),
//                                                 ),
//                                                 venueLength > 1
//                                                     ? TextSpan(
//                                                         text: languageProvider
//                                                                     .language ==
//                                                                 "english"
//                                                             ? " + ${venueLength - 1} More Venues"
//                                                             : " + ${venueLength - 1} अधिक स्थान",
//                                                         style: const TextStyle(
//                                                             fontWeight:
//                                                                 FontWeight.w400),
//                                                       )
//                                                     : const TextSpan(),
//                                               ],
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                       SizedBox(height: screenHeight * 0.01),
//
//                                       widget.eventSubCategory![index].allVenueData!
//                                               .isNotEmpty
//                                           ? (widget
//                                                   .eventSubCategory![index]
//                                                   .allVenueData![0]
//                                                   .packageList!
//                                                   .isNotEmpty
//                                               ? Container(
//                                                   width: double.infinity,
//                                                   padding: const EdgeInsets.symmetric(
//                                                       horizontal: 20),
//                                                   decoration: BoxDecoration(
//                                                     borderRadius: BorderRadius.circular(10),
//                                                     color: Colors.deepOrange,
//                                                     boxShadow: [
//                                                       BoxShadow(
//                                                         color: Colors.black
//                                                             .withOpacity(0.2),
//                                                         spreadRadius: 2,
//                                                         blurRadius: 5,
//                                                         offset: const Offset(0, 3),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   child: Padding(
//                                                     padding: EdgeInsets.all(screenWidth * 0.02),
//                                                     child: Row(
//                                                       children: [
//                                                         Text(
//                                                           languageProvider.language ==
//                                                                   "english"
//                                                               ? "Rs : ${venueData!.packageList![0].priceNo ?? "N/A"}"
//                                                               : "₹ : ${venueData!.packageList![0].priceNo ?? "N/A"}",
//                                                           style: const TextStyle(
//                                                               fontWeight: FontWeight.bold,
//                                                           color: Colors.white,),
//                                                         ),
//                                                         const Spacer(),
//                                                         const Text('|',
//                                                             style: TextStyle(
//                                                                 color:
//                                                                     Colors.deepOrange,
//                                                                 fontWeight:
//                                                                     FontWeight.bold)),
//                                                         SizedBox(
//                                                             width:
//                                                             screenWidth * 0.02),
//                                                         // Display "Book now" button
//                                                         Text(
//                                                           languageProvider.language ==
//                                                                   "english"
//                                                               ? "Book now"
//                                                               : "अभी बुक करें",
//                                                           style: const TextStyle(
//                                                               fontWeight: FontWeight.bold,
//                                                               color: Colors.white,
//                                                               fontSize: 16),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 )
//                                               : Container(
//                                                   width: double.infinity,
//                                                   padding: EdgeInsets.all(screenWidth * 0.02),
//                                                   decoration: BoxDecoration(
//                                                     borderRadius: BorderRadius.circular(10),
//                                                     color: Colors.deepOrange,
//                                                     boxShadow: [
//                                                       BoxShadow(
//                                                         color: Colors.black
//                                                             .withOpacity(0.2),
//                                                         spreadRadius: 2,
//                                                         blurRadius: 5,
//                                                         offset: const Offset(0, 3),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   child: Row(
//                                                     children: [
//                                                       Text(
//                                                         languageProvider.language ==
//                                                                 "english"
//                                                             ? "Know about the Event"
//                                                             : "जानिए इवेंट के बारे में",
//                                                         style: const TextStyle(
//                                                             fontWeight: FontWeight.bold,
//                                                             color: Colors.white,
//                                                             fontSize: 16),
//                                                       ),
//                                                       Spacer(),
//                                                       Icon(Icons.arrow_circle_right_outlined,color: Colors.white,)
//                                                     ],
//                                                   ),
//                                                 ))
//                                           : Container(
//                                               width: double.infinity,
//                                               padding: EdgeInsets.all(screenWidth * 0.02),
//                                               decoration: BoxDecoration(
//                                                 borderRadius:
//                                                     BorderRadius.circular(10),
//                                                 color: Colors.deepOrange,
//                                                 boxShadow: [
//                                                   BoxShadow(
//                                                     color:
//                                                         Colors.black.withOpacity(0.2),
//                                                     spreadRadius: 2,
//                                                     blurRadius: 5,
//                                                     offset: const Offset(0, 3),
//                                                   ),
//                                                 ],
//                                               ),
//                                               child: Row(
//                                                 children: [
//                                                   Text(
//                                                     languageProvider.language ==
//                                                             "english"
//                                                         ? "Know about the Event"
//                                                         : "जानिए इवेंट के बारे में",
//                                                     style: const TextStyle(
//                                                         fontWeight: FontWeight.bold,
//                                                         color: Colors.white,
//                                                         fontSize: 16),
//                                                   ),
//                                                   Spacer(),
//                                                   Icon(Icons.arrow_circle_right_outlined,color: Colors.white,)
//                                                 ],
//                                               ),
//                                             )
//                                     ],
//                                   ),
//                                 );
//                               },
//                             ),
//                           );
//                         },
//                       ),
//                   ),
//                 ],
//               )),
//     );
//   }
// }
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../tour_and_travells/Controller/lanaguage_provider.dart';
import '../model/subCategory_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'event_details.dart';

class SeeScreen extends StatefulWidget {
  final List<SubData>? eventSubCategory;
  final String? eventType;

  const SeeScreen({super.key, this.eventSubCategory, this.eventType});

  @override
  State<SeeScreen> createState() => _SeeScreenState();
}

class _SeeScreenState extends State<SeeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SubData> filteredSearch = [];

  String startDate = 'No Start Date';
  String endDate = 'No End Date';
  String fullDate = 'No Date';
  String singleDate = 'No Single Date';
  bool isSearchClicked = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    filteredSearch = widget.eventSubCategory ?? [];
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void filterSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final lowerQuery = query.toLowerCase();
      setState(() {
        if (lowerQuery.isEmpty) {
          filteredSearch = widget.eventSubCategory!;
        } else {
          filteredSearch = widget.eventSubCategory!.where((item) {
            final name = item.enEventName.toLowerCase() ?? '';
            return name.contains(lowerQuery);
          }).toList();
        }
      });
    });
  }

  String formatDateString(String rawDate) {
    try {
      // Fix double dashes if present
      String fixedDate = rawDate.replaceAll('--', '-');

      // Parse the fixed string into DateTime
      DateTime parsedDate = DateTime.parse(fixedDate);

      // Format it as you want - here: Jan 06, 2025
      return DateFormat('MMM dd, yyyy').format(parsedDate);
    } catch (e) {
      // In case of error, just return the raw input or empty string
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
        actions: [
          IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                setState(() {
                  isSearchClicked = !isSearchClicked;
                  if (!isSearchClicked) {
                    _searchController.clear();
                    filterSearch('');
                  }
                });
              }),
          const SizedBox(width: 15),
        ],
        title: Text(
          widget.eventType ?? "N/A",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.06,
              color: Colors.white),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
        child: widget.eventSubCategory == null ||
                widget.eventSubCategory!.isEmpty
            ? const Center(child: Text("No Data"))
            : Column(
                children: [
                  if (isSearchClicked)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _searchController,
                        onChanged: filterSearch,
                        onFieldSubmitted: filterSearch,
                        decoration: InputDecoration(
                          hintText: 'Search events...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _searchController.clear();
                                    filterSearch('');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.orange),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  filteredSearch.isEmpty
                      ? Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off,
                                    size: 80, color: Colors.grey[400]),
                                const SizedBox(height: 10),
                                Text(
                                  "No events found.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Expanded(
                          child: GridView.builder(
                            padding: EdgeInsets.symmetric(
                                vertical: screenWidth * 0.03),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.90,
                            ),
                            itemCount: filteredSearch.length,
                            itemBuilder: (context, index) {
                              final event = filteredSearch[index];
                              final venueList = event.allVenueData ?? [];
                              final hasVenue = venueList.isNotEmpty;
                              final venueData =
                                  hasVenue ? venueList.first : null;

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => EventDeatils(
                                        eventId: event.id,
                                      ),
                                    ),
                                  );
                                },
                                child: Consumer<LanguageProvider>(
                                  builder: (context, langProvider, child) {
                                    return Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: const Color(0xFFE7E7E7)),
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.05),
                                            spreadRadius: 2,
                                            blurRadius: 5,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Image
                                          SizedBox(
                                            width: double.infinity,
                                            height: screenHeight * 0.24,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    event.eventImage ?? "N/A",
                                                fit: BoxFit.fill,
                                                placeholder: (context, url) =>
                                                    CircularProgressIndicator(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const CircularProgressIndicator(),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: screenHeight * 0.01),

                                          // Title
                                          Text(
                                            langProvider.language == "english"
                                                ? event.enEventName ?? "N/A"
                                                : event.hiEventName ?? "N/A",
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontSize: screenWidth * 0.045,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black),
                                          ),
                                          SizedBox(
                                              height: screenHeight * 0.005),

                                          // Info
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: langProvider.language ==
                                                          "english"
                                                      ? "Start Date: "
                                                      : "आरंभ तिथि: ",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue,
                                                    fontSize:
                                                        screenWidth * 0.04,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: formatDateString(
                                                      "${event.allVenueData[0].date}"),
                                                ),
                                                TextSpan(
                                                  text:
                                                      "\n${langProvider.language == "english" ? "Time: " : "समय: "}",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue,
                                                    fontSize:
                                                        screenWidth * 0.04,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: venueData?.startTime ??
                                                      "No Time",
                                                ),
                                                TextSpan(
                                                  text:
                                                      "\n${langProvider.language == "english" ? "Venue: " : "स्थान: "}",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue,
                                                    fontSize:
                                                        screenWidth * 0.04,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: hasVenue
                                                      ? (langProvider
                                                                  .language ==
                                                              "english"
                                                          ? venueData!
                                                                  .enEventVenue ??
                                                              "No Venue"
                                                          : venueData!
                                                                  .hiEventVenue ??
                                                              "कोई स्थान नहीं")
                                                      : "No Venue",
                                                ),
                                                if (venueList.length > 1)
                                                  TextSpan(
                                                    text: langProvider
                                                                .language ==
                                                            "english"
                                                        ? " + ${venueList.length - 1} More"
                                                        : " + ${venueList.length - 1} अधिक",
                                                  )
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: screenHeight * 0.01),

                                          // Book now or Info
                                          Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.all(
                                                screenWidth * 0.02),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.deepOrange,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  spreadRadius: 2,
                                                  blurRadius: 5,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    hasVenue &&
                                                            venueData!
                                                                .packageList
                                                                .isNotEmpty
                                                        ? (langProvider
                                                                    .language ==
                                                                "english"
                                                            ? "Rs: ${venueData.packageList[0].priceNo}"
                                                            : "₹: ${venueData.packageList[0].priceNo}")
                                                        : (langProvider
                                                                    .language ==
                                                                "english"
                                                            ? "Know about the Event"
                                                            : "जानिए इवेंट के बारे में"),
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                        fontSize: 16),
                                                  ),
                                                ),
                                                const Icon(
                                                    Icons.arrow_forward_ios,
                                                    color: Colors.white,
                                                    size: 18)
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
      ),
    );
  }
}
