import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import '../../../main.dart';
import '../../../utill/app_constants.dart';
import '../../auth/controllers/auth_controller.dart';
import '../model/jaapmodel.dart';
import '../model/ramlekhan_model.dart';

class History extends StatefulWidget {
  final int product;
  final List data;
  final List pressCounts;
  final int index;
  final int counter;
  final String currentTime;
  final String selectedItem;

  History({
    super.key,
    required this.product,
    required this.data,
    required this.index,
    required this.counter,
    required this.pressCounts,
    required this.selectedItem,
    required this.currentTime,
  });

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> with TickerProviderStateMixin {
  int _counter = 0;
  String userToken = "";
  String totalListCount = "";
  String totalListCountRam = "";
  final List<int> _savedCounts = [];

  late TabController _tabController;
  int? totalCount;
  int? totalCounts;

  List<Jaap> jaapModelList = <Jaap>[];
  List<Ramlekhan> ramlekhanModelList = <Ramlekhan>[];

  // Mantra list for Sankalp Details tab
  final List<Map<String, String>> mantraList = [
    {
      'title': 'Gayatri Mantra',
      'description': 'The Gayatri Mantra is a highly revered mantra from the Rig Veda. It is addressed to the solar deity Savitr and is considered one of the most sacred mantras in Hinduism.',
      'sanskrit': 'ॐ भूर्भुवः स्वः तत्सवितुर्वरेण्यं भर्गो देवस्य धीमहि धियो यो नः प्रचोदयात्'
    },
    {
      'title': 'Mahamrityunjaya Mantra',
      'description': 'The Mahamrityunjaya Mantra is a verse from the Rig Veda. It is a mantra for healing, rejuvenation, and overcoming fear of death.',
      'sanskrit': 'ॐ त्र्यम्बकं यजामहे सुगन्धिं पुष्टिवर्धनम् उर्वारुकमिव बन्धनान् मृत्योर्मुक्षीय मामृतात्'
    },
    {
      'title': 'Om Namah Shivaya',
      'description': 'One of the most popular Hindu mantras, dedicated to Lord Shiva. It means "I bow to Shiva" and is considered both a bija (seed) mantra and a salutation.',
      'sanskrit': 'ॐ नमः शिवाय'
    },
    {
      'title': 'Shri Ram Jai Ram',
      'description': 'A powerful mantra dedicated to Lord Rama. Chanting this mantra is believed to bring peace, prosperity, and protection.',
      'sanskrit': 'श्री राम जय राम जय जय राम'
    },
    {
      'title': 'Shanti Mantra',
      'description': 'The Shanti Mantra is chanted for peace at three levels - Adhi-daivikam (divine disturbances), Adhi-bhautikam (external disturbances), and Adhyatmikam (internal disturbances).',
      'sanskrit': 'ॐ सह नाववतु सह नौ भुनक्तु सह वीर्यं करवावहै तेजस्वि नावधीतमस्तु मा विद्विषावहै ॐ शान्तिः शान्तिः शान्तिः'
    },
  ];

  @override
  void initState() {
    super.initState();
    // Initialize tab controller BEFORE accessing context
    _tabController = TabController(
        length: 3,
        vsync: this,
        initialIndex: widget.index
    );

    // Get user token after controller initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = Provider.of<AuthController>(context, listen: false);
      userToken = authController.getUserToken();
      getJaapData();
      getRamlekhanData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> getJaapData() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.baseUrl + AppConstants.japCountUrl),
        headers: {
          'Authorization': 'Bearer $userToken',
          'Content-Type': 'application/json',
        },
      );
      print("Api response jaap list ${response.body}");
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          totalListCount = data['total_count'].toString();
          jaapModelList.clear();
          List jaapList = data['data'];
          jaapModelList.addAll(jaapList.map((e) => Jaap.fromJson(e)));
        });
      }
    } catch (e) {
      print("Error in getJaapData: $e");
    }
  }

  Future<void> getRamlekhanData() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.baseUrl + AppConstants.ramLekhanUrl),
        headers: {
          'Authorization': 'Bearer $userToken',
          'Content-Type': 'application/json',
        },
      );
      print("Api response ramlekhan list ${response.body}");
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          totalListCountRam = data['total_count'].toString();
          ramlekhanModelList.clear();
          List ramlekhanList = data['data'];
          ramlekhanModelList
              .addAll(ramlekhanList.map((e) => Ramlekhan.fromJson(e)));
        });
      }
    } catch (e) {
      print("Error in getRamlekhanData: $e");
    }
  }

  Future<void> deleteJaapCount(int id) async {
    final url = Uri.parse(
        AppConstants.baseUrl + AppConstants.deleteJapCountUrl + id.toString());

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        print("Delete successful!");
        getJaapData(); // Refresh data
      } else {
        print("Failed to delete. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> deleteRamCount(int id) async {
    final url = Uri.parse(AppConstants.baseUrl +
        AppConstants.deleteramLekhanCountUrl +
        id.toString());
    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        print("Delete successful!");
        getRamlekhanData(); // Refresh data
      } else {
        print("Failed to delete. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // Function to show sankalp details popup
  void _showSankalpDetails(BuildContext context, Map<String, String> mantra) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Get color based on mantra
        Color getMantraColor() {
          switch (mantra['title']) {
            case 'Gayatri Mantra':
              return Color(0xFF4A6FA5); // Deep blue
            case 'Mahamrityunjaya Mantra':
              return Color(0xFF6A0572); // Purple
            case 'Om Namah Shivaya':
              return Color(0xFF2C5530); // Deep green
            case 'Shri Ram Jai Ram':
              return Color(0xFFD35400); // Orange
            case 'Shanti Mantra':
              return Color(0xFF2980B9); // Sky blue
            default:
              return Color(0xFFE67E22); // Orange fallback
          }
        }

        final mantraColor = getMantraColor();

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          backgroundColor: Colors.white,
          elevation: 20,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gradient Header
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        mantraColor.withOpacity(0.9),
                        mantraColor.withOpacity(0.7),
                        mantraColor.withOpacity(0.5),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: mantraColor.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Decorative elements
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 30,
                        left: 20,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                      ),

                      // Content
                      Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title Row
                              Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '📿',
                                        style: TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          mantra['title']!,
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black26,
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Divine Chant',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white.withOpacity(0.9),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              // Mantra in Sanskrit
                              Text(
                                mantra['sanskrit']!,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mantra Details Card
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                mantraColor.withOpacity(0.1),
                                mantraColor.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: mantraColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.volume_up_rounded, color: mantraColor, size: 22),
                                  SizedBox(width: 8),
                                  Text(
                                    'Full Mantra',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: mantraColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Text(
                                mantra['sanskrit']!,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade800,
                                  fontStyle: FontStyle.italic,
                                  height: 1.6,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: mantraColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.repeat, size: 14, color: mantraColor),
                                        SizedBox(width: 6),
                                        Text(
                                          '108 Times Daily',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: mantraColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Benefits Section
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF27AE60).withOpacity(0.1),
                                Color(0xFF2ECC71).withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Color(0xFF27AE60).withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.spa_rounded, color: Color(0xFF27AE60), size: 22),
                                  SizedBox(width: 8),
                                  Text(
                                    'Spiritual Benefits',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF27AE60),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              // Benefits List with icons
                              _buildBenefitItem("✨ Enhances spiritual awareness", mantraColor),
                              _buildBenefitItem("🧘 Brings inner peace & calmness", mantraColor),
                              _buildBenefitItem("🌟 Removes negative energies", mantraColor),
                              _buildBenefitItem("💫 Promotes healing & well-being", mantraColor),
                              _buildBenefitItem("🙏 Deepens devotion & connection", mantraColor),
                            ],
                          ),
                        ),

                        // Timing & Practice Tips
                        Row(
                          children: [
                            // Best Time
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Color(0xFF3498DB).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Color(0xFF3498DB).withOpacity(0.2),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.wb_sunny_rounded, color: Color(0xFF3498DB), size: 18),
                                        SizedBox(width: 6),
                                        Text(
                                          'Best Time',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF3498DB),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '4-6 AM\n(Brahma Muhurta)',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 12),

                            // Ideal Count
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Color(0xFF9B59B6).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Color(0xFF9B59B6).withOpacity(0.2),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.filter_none_rounded, color: Color(0xFF9B59B6), size: 18),
                                        SizedBox(width: 6),
                                        Text(
                                          'Ideal Count',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF9B59B6),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '108 times\nwith Mala',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Bottom Action Buttons
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Close Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: mantraColor,
                            side: BorderSide(color: mantraColor, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.close, size: 18),
                              SizedBox(width: 6),
                              Text('Close'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 12),

                      // Save Button with gradient
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.favorite, color: Colors.white),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${mantra['title']} saved to favorites',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: mantraColor,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mantraColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            elevation: 3,
                            shadowColor: mantraColor.withOpacity(0.3),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.favorite_border, size: 18),
                              SizedBox(width: 6),
                              Text('Save Mantra'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Helper method for benefit items
  Widget _buildBenefitItem(String text, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.check_circle,
                size: 12,
                color: color,
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }



// Helper method for different colors for each mantra
  Color _getMantraColor(int index) {
    List<Color> colors = [
      Colors.orange,
      Colors.deepPurple,
      Colors.green,
      Colors.blue,
      Colors.red,
    ];
    return colors[index % colors.length];
  }


  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          top: false, // Top SafeArea disable karein
          child: Column(
            children: [
              // Tab Bar
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorWeight: 3,
                  indicatorColor: Colors.orange,
                  tabs: [
                    Tab(
                      child: Container(
                        child: Center(
                          child: Text(
                            "Jaap",
                            style: TextStyle(fontSize: screenwidth * 0.04),
                          ),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        child: Center(
                          child: Text(
                            "Ram Lekhan",
                            style: TextStyle(fontSize: screenwidth * 0.039),
                          ),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        child: Center(
                          child: Text(
                            "Sankalp Details",
                            style: TextStyle(fontSize: screenwidth * 0.032),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      // Container(
                      //   color: Colors.white,
                      //   child: Padding(
                      //     padding: const EdgeInsets.only(left: 35,right: 35,top: 10),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //       children: [
                      //         Text("मंत्र",style: TextStyle(fontSize: screenwidth * 0.043,fontWeight: FontWeight.bold),),
                      //         Padding(
                      //           padding: EdgeInsets.only(left: 20),
                      //           child: Text("गढ़ना",style: TextStyle(fontSize: screenwidth * 0.043,fontWeight: FontWeight.bold),),
                      //         ),
                      //         Text("दिनांक / समय",style: TextStyle(fontSize: screenwidth * 0.039,fontWeight: FontWeight.bold),),
                      //       ],
                      //     ),
                      //   ),
                      // ),

                      Stack(
                        children: [
                          Container(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 35, right: 35, top: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "मंत्र",
                                    style: TextStyle(
                                        fontSize: screenwidth * 0.043,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(
                                      "गढ़ना",
                                      style: TextStyle(
                                          fontSize: screenwidth * 0.043,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    "दिनांक / समय",
                                    style: TextStyle(
                                        fontSize: screenwidth * 0.039,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          jaapModelList.isEmpty
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: 6,
                                  itemBuilder: (context, index) {
                                    return Shimmer.fromColors(
                                      baseColor: Theme.of(context).cardColor,
                                      highlightColor: Colors.grey[300]!,
                                      enabled: true,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 5),
                                        margin: const EdgeInsets.all(10),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade100,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                  0.2), // Shadow color
                                              spreadRadius:
                                                  1, // Shadow spread radius
                                              blurRadius:
                                                  9, // Shadow blur radius
                                              offset: const Offset(
                                                  0, 3), // Shadow offset
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            const Expanded(
                                              child: Text(
                                                "jaap",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              ),
                                            ),
                                            // जाप
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            const Text(
                                              "20",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 26),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            const Text(
                                              "date",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                            const SizedBox(
                                              width: 6,
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                showCupertinoDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      CupertinoAlertDialog(
                                                    title: const Text(
                                                        'Delete Item'),
                                                    //content: Text('Are you sure you want to delete this item?'),
                                                    actions: [
                                                      CupertinoDialogAction(
                                                        child: const Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .blueAccent),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                      CupertinoDialogAction(
                                                        child: const Text(
                                                          'Delete',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                        onPressed: () {
                                                          deleteJaapCount(
                                                              jaapModelList[
                                                                      index]
                                                                  .id);
                                                          getJaapData();
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                                size: 25,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: jaapModelList.length,
                                  itemBuilder: (context, index) {
                                    DateTime dateString =
                                        jaapModelList[index].createdAt;
                                    String parsedDate = DateFormat('dd-MM-yyyy')
                                        .format(dateString);
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                                      margin: const EdgeInsets.all(10),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.shade50,
                                            Colors.lightBlueAccent.shade100,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blue.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: Colors.blue.shade100,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade400,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              jaapModelList[index].name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                color: Colors.blue.shade900,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade100,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              "${jaapModelList[index].count}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18,
                                                color: Colors.blue.shade800,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            parsedDate,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                              color: Colors.blue.shade600,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Container(
                                            width: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              onPressed: () {
                                                showCupertinoDialog(
                                                  context: context,
                                                  builder: (context) => CupertinoAlertDialog(
                                                    title: const Text('Delete Item'),
                                                    content: const Text('Are you sure?'),
                                                    actions: [
                                                      CupertinoDialogAction(
                                                        child: const Text('Cancel'),
                                                        onPressed: () => Navigator.of(context).pop(),
                                                      ),
                                                      CupertinoDialogAction(
                                                        child: const Text('Delete',
                                                            style: TextStyle(color: Colors.red)),
                                                        onPressed: () {
                                                          deleteJaapCount(jaapModelList[index].id);
                                                          getJaapData();
                                                          Navigator.of(context).pop();
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              icon: Icon(
                                                Icons.delete_outline,
                                                color: Colors.red.shade400,
                                                size: 20,
                                              ),
                                              padding: const EdgeInsets.all(6),
                                              constraints: const BoxConstraints(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 19),
                        child: Row(
                          children: [
                            Text(
                              'Total Count: $totalListCount',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                showCupertinoDialog(
                                  context: context,
                                  builder: (context) => CupertinoAlertDialog(
                                    title: const Text(
                                      'Reset',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 20),
                                    ),
                                    //content: Text('Are you sure you want to reset the data?'),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                              color: Colors.blueAccent),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      CupertinoDialogAction(
                                        child: const Text(
                                          'Reset',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onPressed: () {
                                          setState(() {});
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Container(
                                width: 70,
                                height: 43,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.orange,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Center(
                                  child: Text(
                                    "reset",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                //-----------------------------------JAAP HISTORY ENDS-------------------------------------

                //-------------------------------RAM LEKHAN HISTORY STARTS-----------------------------
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      // Container(
                      //   color: Colors.white,
                      //   child: Padding(
                      //     padding: const EdgeInsets.only(left: 35,right: 35,top: 10),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //       children: [
                      //         Text("मंत्र",style: TextStyle(fontSize: screenwidth * 0.043,fontWeight: FontWeight.bold),),
                      //         Padding(
                      //           padding: EdgeInsets.only(left: 20),
                      //           child: Text("गढ़ना",style: TextStyle(fontSize: screenwidth * 0.043,fontWeight: FontWeight.bold),),
                      //         ),
                      //         Text("दिनांक / समय",style: TextStyle(fontSize: screenwidth * 0.039,fontWeight: FontWeight.bold),),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      Stack(
                        children: [
                          Container(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 35, right: 35, top: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "मंत्र",
                                    style: TextStyle(
                                        fontSize: screenwidth * 0.043,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(
                                      "गढ़ना",
                                      style: TextStyle(
                                          fontSize: screenwidth * 0.043,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    "दिनांक / समय",
                                    style: TextStyle(
                                        fontSize: screenwidth * 0.039,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ramlekhanModelList.isEmpty
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: 6,
                                  itemBuilder: (context, index) {
                                    return Shimmer.fromColors(
                                      baseColor: Theme.of(context).cardColor,
                                      highlightColor: Colors.grey[300]!,
                                      enabled: true,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 5),
                                        margin: const EdgeInsets.all(10),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade100,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                  0.2), // Shadow color
                                              spreadRadius:
                                                  1, // Shadow spread radius
                                              blurRadius:
                                                  9, // Shadow blur radius
                                              offset: const Offset(
                                                  0, 3), // Shadow offset
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            const Expanded(
                                              child: Text(
                                                "jaap",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              ),
                                            ),
                                            // जाप
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            const Text(
                                              "20",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 26),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            const Text(
                                              "date",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                            const SizedBox(
                                              width: 6,
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                showCupertinoDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      CupertinoAlertDialog(
                                                    title: const Text(
                                                        'Delete Item'),
                                                    //content: Text('Are you sure you want to delete this item?'),
                                                    actions: [
                                                      CupertinoDialogAction(
                                                        child: const Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .blueAccent),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                      CupertinoDialogAction(
                                                        child: const Text(
                                                          'Delete',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                        onPressed: () {
                                                          deleteJaapCount(
                                                              jaapModelList[
                                                                      index]
                                                                  .id);
                                                          getJaapData();
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                                size: 25,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: ramlekhanModelList.length,
                                  itemBuilder: (context, index) {
                                    DateTime dateString =
                                        ramlekhanModelList[index].createdAt;
                                    String parsedDate = DateFormat('dd-MM-yyyy')
                                        .format(dateString);
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 5),
                                      margin: const EdgeInsets.all(10),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                                0.2), // Shadow color
                                            spreadRadius:
                                                1, // Shadow spread radius
                                            blurRadius: 9, // Shadow blur radius
                                            offset: const Offset(
                                                0, 3), // Shadow offset
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Text(
                                              ramlekhanModelList[index].name,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ),
                                          ),
                                          // जाप
                                          const SizedBox(
                                            width: 30,
                                          ),
                                          Text(
                                            ramlekhanModelList[index].count,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 26),
                                          ),
                                          const SizedBox(
                                            width: 30,
                                          ),
                                          Text(
                                            parsedDate,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              showCupertinoDialog(
                                                context: context,
                                                builder: (context) =>
                                                    CupertinoAlertDialog(
                                                  title:
                                                      const Text('Delete Item'),
                                                  //content: Text('Are you sure you want to delete this item?'),
                                                  actions: [
                                                    CupertinoDialogAction(
                                                      child: const Text(
                                                        'Cancel',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .blueAccent),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    CupertinoDialogAction(
                                                      child: const Text(
                                                        'Delete',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                      onPressed: () {
                                                        deleteRamCount(
                                                            ramlekhanModelList[
                                                                    index]
                                                                .id);
                                                        getRamlekhanData();
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 25,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 19),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Count: $totalListCountRam',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            GestureDetector(
                              onTap: () {
                                showCupertinoDialog(
                                  context: context,
                                  builder: (context) => CupertinoAlertDialog(
                                    title: const Text(
                                      'Reset',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 20),
                                    ),
                                    //content: Text('Are you sure you want to reset the counts?'),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                              color: Colors.blueAccent),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      CupertinoDialogAction(
                                        child: const Text(
                                          'Reset',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onPressed: () {
                                          setState(() {});
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Container(
                                width: 70,
                                height: 43,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.orange,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Center(
                                  child: Text(
                                    "reset",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                //-------------------------------RAM LEKHAN HISTORY ENDS-----------------------------

      // Third Tab: Sankalp Details - Beautiful List
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.orange.shade50,
            ],
          ),
        ),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: mantraList.length,
          itemBuilder: (context, index) {
            final mantra = mantraList[index];
            final mantraColor = getMantraColorForIndex(index);

            return Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    mantraColor.withOpacity(0.1),
                    mantraColor.withOpacity(0.05),
                  ],
                ),
                border: Border.all(
                  color: mantraColor.withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _showSankalpDetails(context, mantra);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Number Badge
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                mantraColor.withOpacity(0.9),
                                mantraColor.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: mantraColor.withOpacity(0.3),
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),

                        // Mantra Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mantra['title']!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: mantraColor,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                mantra['sanskrit']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Arrow Icon
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: mantraColor,
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
            ),
          )
        ],
      ),
    ));
  }
  // Helper function to get color based on index
  Color getMantraColorForIndex(int index) {
    List<Color> colors = [
      Color(0xFF4A6FA5), // Deep blue
      Color(0xFF6A0572), // Purple
      Color(0xFF2C5530), // Deep green
      Color(0xFFD35400), // Orange
      Color(0xFF2980B9), // Sky blue
      Color(0xFFC0392B), // Red
      Color(0xFF8E44AD), // Violet
      Color(0xFF16A085), // Teal
    ];
    return colors[index % colors.length];
  }
}




//
// // Inside your TabBarView, add this for the Leaderboard tab:
// SingleChildScrollView(
// child: Container(
// padding: const EdgeInsets.all(16),
// child: Column(
// children: [
// // Header Section
// Container(
// padding: const EdgeInsets.all(20),
// decoration: BoxDecoration(
// gradient: LinearGradient(
// colors: [Colors.orange.shade700, Colors.orange.shade400],
// begin: Alignment.topLeft,
// end: Alignment.bottomRight,
// ),
// borderRadius: BorderRadius.circular(20),
// boxShadow: [
// BoxShadow(
// color: Colors.orange.withOpacity(0.3),
// blurRadius: 10,
// offset: const Offset(0, 4),
// ),
// ],
// ),
// child: Row(
// children: [
// const Icon(Icons.leaderboard, color: Colors.white, size: 30),
// const SizedBox(width: 10),
// Expanded(
// child: Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// const Text(
// 'Jaap Leaderboard',
// style: TextStyle(
// color: Colors.white,
// fontSize: 20,
// fontWeight: FontWeight.bold,
// ),
// ),
// const SizedBox(height: 5),
// Text(
// _getTimeFilterSubtitle(),
// style: TextStyle(
// color: Colors.white.withOpacity(0.9),
// fontSize: 14,
// ),
// ),
// ],
// ),
// ),
// ],
// ),
// ),
//
// const SizedBox(height: 20),
//
// // Time Filter Tabs
// Container(
// decoration: BoxDecoration(
// color: Colors.grey.shade50,
// borderRadius: BorderRadius.circular(12),
// border: Border.all(color: Colors.grey.shade200),
// ),
// child: Row(
// children: [
// _buildTimeTab('Daily', 0),
// _buildTimeTab('Weekly', 1),
// _buildTimeTab('Monthly', 2),
// _buildTimeTab('All Time', 3),
// ],
// ),
// ),
//
// const SizedBox(height: 10),
//
// // Top 3 Winners
// Text(
// 'Top Performers',
// style: TextStyle(
// fontSize: 18,
// fontWeight: FontWeight.bold,
// color: Colors.orange.shade800,
// ),
// ),
// const SizedBox(height: 35),
// Row(
// mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// children: _buildTopThreeWinners(),
// ),
//
// const SizedBox(height: 30),
//
// // Leaderboard List
// Container(
// decoration: BoxDecoration(
// color: Colors.white,
// borderRadius: BorderRadius.circular(15),
// boxShadow: [
// BoxShadow(
// color: Colors.grey.withOpacity(0.1),
// blurRadius: 10,
// offset: const Offset(0, 2),
// ),
// ],
// ),
// child: Column(
// children: [
// // List Header
// Container(
// padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// decoration: BoxDecoration(
// color: Colors.orange.shade50,
// borderRadius: const BorderRadius.only(
// topLeft: Radius.circular(15),
// topRight: Radius.circular(15),
// ),
// ),
// child: Row(
// children: [
// Text('Rank', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
// const SizedBox(width: 20),
// Expanded(child: Text('Devotee', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800))),
// Text('Jaap Count', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
// ],
// ),
// ),
//
// // Leaderboard Items
// ..._buildLeaderboardList(),
// ],
// ),
// ),
//
// const SizedBox(height: 20),
//
// // Current User Stats
// Container(
// padding: const EdgeInsets.all(16),
// decoration: BoxDecoration(
// gradient: LinearGradient(
// colors: [Colors.deepOrange.shade50, Colors.orange.shade50],
// begin: Alignment.topLeft,
// end: Alignment.bottomRight,
// ),
// borderRadius: BorderRadius.circular(15),
// border: Border.all(color: Colors.orange.shade200),
// ),
// child: Row(
// children: [
// Container(
// padding: const EdgeInsets.all(10),
// decoration: BoxDecoration(
// color: Colors.orange.shade100,
// shape: BoxShape.circle,
// ),
// child: Icon(Icons.person, color: Colors.orange.shade700),
// ),
// const SizedBox(width: 15),
// Expanded(
// child: Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// Text(
// 'Your Position',
// style: TextStyle(
// color: Colors.orange.shade800,
// fontWeight: FontWeight.bold,
// ),
// ),
// Text(
// "Rank #${_getUserStats()['rank']} • ${_getUserStats()['count']} Jaaps",
// style: TextStyle(
// color: Colors.orange.shade600,
// fontSize: 16,
// ),
// ),
// ],
// ),
// ),
// Container(
// padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// decoration: BoxDecoration(
// color: Colors.orange.shade100,
// borderRadius: BorderRadius.circular(20),
// ),
// child: Text(
// _getUserStats()['progress'],
// style: TextStyle(
// color: Colors.orange.shade700,
// fontWeight: FontWeight.bold,
// fontSize: 12,
// ),
// ),
// ),
// ],
// ),
// ),
//
// const SizedBox(height: 20),
//
// // Motivational Quote
// Container(
// padding: const EdgeInsets.all(16),
// decoration: BoxDecoration(
// color: Colors.orange.shade50,
// borderRadius: BorderRadius.circular(12),
// border: Border.all(color: Colors.orange.shade100),
// ),
// child: Row(
// children: [
// Icon(Icons.lightbulb_outline, color: Colors.orange.shade600),
// const SizedBox(width: 10),
// Expanded(
// child: Text(
// _getMotivationalQuote(),
// style: TextStyle(
// color: Colors.orange.shade700,
// fontStyle: FontStyle.italic,
// ),
// ),
// ),
// ],
// ),
// ),
// ],
// ),
// ),
// ),
