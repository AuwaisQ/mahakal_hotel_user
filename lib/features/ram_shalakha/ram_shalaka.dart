import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

import '../../utill/app_constants.dart';
import 'model/ram_shalaka_modal.dart'; // For shuffling

class RamShalaka extends StatefulWidget {
  const RamShalaka({super.key});

  @override
  _RamShalakaState createState() => _RamShalakaState();
}

class _RamShalakaState extends State<RamShalaka>
    with SingleTickerProviderStateMixin {
  final double _fontSize = 15.0; // Default font size
  bool _isLoading = true; // Loading state
  List<RamShalakhaData> _data = []; // List to store fetched data
  String _errorMessage = ''; // To handle errors
  List<RamShalakhaData> _shuffledData = []; // For shuffled data
  late TabController _tabController; // TabController for managing tabs
  String? _selectedLetter;
  bool isLoading = true;

  void isloded() {
    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  // State variable to keep track of the current image index
  int _currentImageIndex = 0;

  // List of image URLs
  final List<String> _images = [
    'assets/image/ram_shalkha_first.jpg', // Replace with your second image URL
    'assets/image/ram_shalakha_second.jpg', // Replace with your second image URL
  ];

  void _switchImage() {
    setState(() {
      // Toggle between 0 and 1
      _currentImageIndex = (_currentImageIndex + 1) % _images.length;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchRamShalakaData();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        // Index 1 is "Shuffle" Tab
        shuffleData();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose of the TabController
    super.dispose();
  }

  void showCustomBottomSheet(BuildContext context, RamShalakhaData item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.0)), // Rounded top corners
      ),
      backgroundColor: Colors.transparent, // Make the background transparent
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.orangeAccent
              ], // Gradient background
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title Section
                Row(
                  children: [
                    const Expanded(
                      flex: 1,
                      child: Text(
                        "अक्षर:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        item.letter,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black, // Highlight the letter
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.red, size: 24), // Close icon
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the bottom sheet
                      },
                    ),
                  ],
                ),
                Divider(
                    thickness: 2,
                    color: Colors.grey[300]), // Divider with thickness
                const SizedBox(height: 16),
                // Content Section
                _buildContentRow("चौपाई:", item.chaupai),
                const SizedBox(height: 10),
                _buildContentRow("अर्थ:", item.hiDescription),

                const SizedBox(height: 16),
                _buildContentRow("", item.description),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void showCustomDialog(BuildContext context, RamShalakhaData item) {
    showDialog(
      context: context,
      barrierDismissible:
          true, // Allows dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AnimatedRotation(
          duration: const Duration(seconds: 1),
          turns: 1, // Rotate 360 degrees
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0), // Rounded corners
            ),
            backgroundColor:
                Colors.transparent, // Make the background transparent
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.orangeAccent
                  ], // Gradient background
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title Section
                    Row(
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Text(
                            "अक्षर:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            item.letter,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black, // Highlight the letter
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.red, size: 24), // Close icon
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        ),
                      ],
                    ),
                    Divider(
                        thickness: 2,
                        color: Colors.grey[300]), // Divider with thickness
                    const SizedBox(height: 16),
                    // Content Section
                    _buildContentRow("चौपाई:", item.chaupai),
                    const SizedBox(height: 10),
                    _buildContentRow("अर्थ:", item.hiDescription),
                    const SizedBox(height: 16),
                    _buildContentRow("", item.description),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _fetchRamShalakaData() async {
    const url = AppConstants.baseUrl + AppConstants.ramshalakhaUrl;

    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final ramShalakaModal = ramShalakaModalFromJson(response.body);
        setState(() {
          _data = ramShalakaModal.data;
          _shuffledData = List.from(_data); // Initialize shuffled data
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to load data. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  void shuffleData() {
    setState(() {
      _shuffledData = List.from(_data)..shuffle();
      // Print the shuffled data to the console
      print(
          "Shuffled Data: ${_shuffledData.map((item) => item.letter).toList()}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Colors.deepOrange.shade200,
        title: const Text(
          "🔱 Ram Shalaka 🔱",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                _switchImage();
              },
              icon: const Icon(
                Icons.color_lens_outlined,
                color: Colors.black87,
              )),
        ],
        bottom: TabBar(
          indicatorColor: Colors.orangeAccent,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          splashFactory: NoSplash.splashFactory,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          unselectedLabelColor: Colors.black87,
          controller: _tabController,
          tabs: const [
            Tab(text: "Type: 1"),
            Tab(text: "Type: 2"),
            Tab(text: "Type: 3"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFirstTab(),
          _buildSecondTab(),
          _buildThirdTab(),
        ],
      ),
    );
  }

  Widget _buildFirstTab() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(_images[_currentImageIndex]),
          fit: BoxFit.cover, // Use cover to fill the container
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                color: Colors.orange,
              )) // Loading indicator
            : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage)) // Error message
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          shadowColor: Colors.orangeAccent.withOpacity(0.5),
                          child: Container(
                            // width: 300,
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFC8E6C9), Color(0xFFFFF9C4)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        " श्रीराम शलाका प्रश्नावली \n(Shri Ram Shalaka Prashnavali)",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: _fontSize),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.info_outline,
                                          color: Colors.black),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: SingleChildScrollView(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: Wrap(
                                                    crossAxisAlignment:
                                                        WrapCrossAlignment
                                                            .start,
                                                    children: [
                                                      const SizedBox(
                                                          height: 10),
                                                      Row(
                                                        children: [
                                                          const Expanded(
                                                            child: Text(
                                                              "Information",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(
                                                                Icons.close,
                                                                color:
                                                                    Colors.red,
                                                                size: 24),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                      const Divider(),
                                                      _buildBulletPoint(
                                                          "जिस शब्द पर आपने क्लिक किया है उससे हर नौ खानों में\nदिए गए शब्दों को जोड़कर एक चौपाई बनती है जो आपका समाधान है अब आप अपनी आँखे खोल दें आपकी आँखों के सामने आपके प्रश्न का उत्तर होगा।"),
                                                      _buildBulletPoint(
                                                        "हर व्यक्ति चाहता है कि उसका जीवन एक परी कथा की तरह हो, "
                                                        "उसे जीवन में हर सुख सुविधा मिले, सभी कार्य उसके अनुरूप हों। "
                                                        "लेकिन यह जीवन कोई परी कथा नहीं वरन इस जीवन में "
                                                        "हमें नित्य नयी चुनौतियों का सामना करना पड़ता है.",
                                                      ),
                                                      _buildBulletPoint(
                                                        "हम कार्य तो बहुत से करते हैं, सपने हमारे असीमित हैं लेकिन "
                                                        "बहुत से कार्य बहुत से सपने पूरे नहीं हो पाते हैं, कई बार दूसरे लोग "
                                                        "जिस कार्य में सफल हो रहे होते हैं हम असफल हो जाते हैं "
                                                        "या तमाम परिश्रम तमाम योजनाओं के बाद भी अपेक्षित परिणाम नहीं मिलते हैं.",
                                                      ),
                                                      _buildBulletPoint(
                                                        "हमारे धार्मिक साहित्य में इस अद्भुत पवित्र श्री राम शलाका(Ram Shalaka) "
                                                        "की बहुत मान्यता है, इसका उपयोग भी बहुत ही सरल है.",
                                                      ),
                                                      _buildBulletPoint(
                                                        "सर्वप्रथम प्रभु श्री राम का सच्चे ह्रदय से ध्यान करते हुए अपने मन "
                                                        "में अपना प्रश्न सोचें.",
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 6),
                                                        child: Text(
                                                          'जिस शब्द पर आपने क्लिक किया है, उससे हर नौ खानों में शब्दों को जोड़कर एक चौपाई बनती है।',
                                                          style: TextStyle(
                                                              fontSize:
                                                                  _fontSize),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFC8E6C9), Color(0xFFFFF9C4)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 15, // Number of columns
                                ),
                                itemCount: _data.length, // Use _data's length
                                itemBuilder: (context, index) {
                                  final item = _data[
                                      index]; // Get each Datum object from _data

                                  return GestureDetector(
                                    onTap: () {
                                      showCustomBottomSheet(
                                          context, item); // Show popup on tap
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.red),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(1.0),
                                        child: Text(
                                          item.letter, // Use the letter from Datum object
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildSecondTab() {
    shuffleData(); // Call shuffle whenever this widget is built
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(_images[_currentImageIndex]),
          fit: BoxFit.cover, // Use cover to fill the container
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator()) // Loading indicator
            : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage)) // Error message
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          shadowColor: Colors.orangeAccent.withOpacity(0.5),
                          child: Container(
                            // width: 300,
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFC8E6C9), Color(0xFFFFF9C4)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        " श्रीराम शलाका प्रश्नावली \n(Shri Ram Shalaka Prashnavali)",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: _fontSize),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.info_outline,
                                          color: Colors.black),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: SingleChildScrollView(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: Wrap(
                                                    crossAxisAlignment:
                                                        WrapCrossAlignment
                                                            .start,
                                                    children: [
                                                      const SizedBox(
                                                          height: 10),
                                                      Row(
                                                        children: [
                                                          const Expanded(
                                                            child: Text(
                                                              "Information",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(
                                                                Icons.close,
                                                                color:
                                                                    Colors.red,
                                                                size: 24),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                      const Divider(),
                                                      _buildBulletPoint(
                                                          "जिस शब्द पर आपने क्लिक किया है उससे हर नौ खानों में\nदिए गए शब्दों को जोड़कर एक चौपाई बनती है जो आपका समाधान है अब आप अपनी आँखे खोल दें आपकी आँखों के सामने आपके प्रश्न का उत्तर होगा।"),
                                                      _buildBulletPoint(
                                                        "हर व्यक्ति चाहता है कि उसका जीवन एक परी कथा की तरह हो, "
                                                        "उसे जीवन में हर सुख सुविधा मिले, सभी कार्य उसके अनुरूप हों। "
                                                        "लेकिन यह जीवन कोई परी कथा नहीं वरन इस जीवन में "
                                                        "हमें नित्य नयी चुनौतियों का सामना करना पड़ता है.",
                                                      ),
                                                      _buildBulletPoint(
                                                        "हम कार्य तो बहुत से करते हैं, सपने हमारे असीमित हैं लेकिन "
                                                        "बहुत से कार्य बहुत से सपने पूरे नहीं हो पाते हैं, कई बार दूसरे लोग "
                                                        "जिस कार्य में सफल हो रहे होते हैं हम असफल हो जाते हैं "
                                                        "या तमाम परिश्रम तमाम योजनाओं के बाद भी अपेक्षित परिणाम नहीं मिलते हैं.",
                                                      ),
                                                      _buildBulletPoint(
                                                        "हमारे धार्मिक साहित्य में इस अद्भुत पवित्र श्री राम शलाका(Ram Shalaka) "
                                                        "की बहुत मान्यता है, इसका उपयोग भी बहुत ही सरल है.",
                                                      ),
                                                      _buildBulletPoint(
                                                        "सर्वप्रथम प्रभु श्री राम का सच्चे ह्रदय से ध्यान करते हुए अपने मन "
                                                        "में अपना प्रश्न सोचें.",
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 6),
                                                        child: Text(
                                                          'जिस शब्द पर आपने क्लिक किया है, उससे हर नौ खानों में शब्दों को जोड़कर एक चौपाई बनती है।',
                                                          style: TextStyle(
                                                              fontSize:
                                                                  _fontSize),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFC8E6C9), Color(0xFFFFF9C4)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 15, // Number of columns
                                ),
                                // itemCount: _data.length, // Use _data's length
                                // itemBuilder: (context, index) {
                                //   final item = _data[index]; // Get each Datum object from _data
                                itemCount: _shuffledData.length,
                                itemBuilder: (context, index) {
                                  final item = _shuffledData[index];

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedLetter = item
                                            .letter; // Update the selected letter
                                      });
                                      showCustomBottomSheet(
                                          context, item); // Show popup on tap
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.red),
                                        // color: _selectedLetter == item.letter ? Colors.white : Colors.transparent, // Highlight if selected
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(1.0),
                                        child: Text(
                                          item.letter, // Use the letter from Datum object
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors
                                                .red, // Change to a visible color
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildThirdTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              shadowColor: Colors.orangeAccent.withOpacity(0.5),
              child: Container(
                // width: 300,
                padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFC8E6C9), Color(0xFFFFF9C4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            " श्रीराम शलाका प्रश्नावली \n(Shri Ram Shalaka Prashnavali)",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: _fontSize),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.info_outline,
                              color: Colors.black),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.start,
                                        children: [
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              const Expanded(
                                                child: Text(
                                                  "Information",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.close,
                                                    color: Colors.red,
                                                    size: 24),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          ),
                                          const Divider(),
                                          _buildBulletPoint(
                                              "जिस शब्द पर आपने क्लिक किया है उससे हर नौ खानों में\nदिए गए शब्दों को जोड़कर एक चौपाई बनती है जो आपका समाधान है अब आप अपनी आँखे खोल दें आपकी आँखों के सामने आपके प्रश्न का उत्तर होगा।"),
                                          _buildBulletPoint(
                                            "हर व्यक्ति चाहता है कि उसका जीवन एक परी कथा की तरह हो, "
                                            "उसे जीवन में हर सुख सुविधा मिले, सभी कार्य उसके अनुरूप हों। "
                                            "लेकिन यह जीवन कोई परी कथा नहीं वरन इस जीवन में "
                                            "हमें नित्य नयी चुनौतियों का सामना करना पड़ता है.",
                                          ),
                                          _buildBulletPoint(
                                            "हम कार्य तो बहुत से करते हैं, सपने हमारे असीमित हैं लेकिन "
                                            "बहुत से कार्य बहुत से सपने पूरे नहीं हो पाते हैं, कई बार दूसरे लोग "
                                            "जिस कार्य में सफल हो रहे होते हैं हम असफल हो जाते हैं "
                                            "या तमाम परिश्रम तमाम योजनाओं के बाद भी अपेक्षित परिणाम नहीं मिलते हैं.",
                                          ),
                                          _buildBulletPoint(
                                            "हमारे धार्मिक साहित्य में इस अद्भुत पवित्र श्री राम शलाका(Ram Shalaka) "
                                            "की बहुत मान्यता है, इसका उपयोग भी बहुत ही सरल है.",
                                          ),
                                          _buildBulletPoint(
                                            "सर्वप्रथम प्रभु श्री राम का सच्चे ह्रदय से ध्यान करते हुए अपने मन "
                                            "में अपना प्रश्न सोचें.",
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6),
                                            child: Text(
                                              'जिस शब्द पर आपने क्लिक किया है, उससे हर नौ खानों में शब्दों को जोड़कर एक चौपाई बनती है।',
                                              style: TextStyle(
                                                  fontSize: _fontSize),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator()) // Loading indicator
              : _errorMessage.isNotEmpty
                  ? Center(child: Text(_errorMessage)) // Error message
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                image: const DecorationImage(
                                  image: AssetImage(
                                      "assets/image/ram_shalakhaa_back.jpg"),
                                  fit: BoxFit
                                      .fill, // Use cover to fill the container
                                ),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFC8E6C9),
                                    Color(0xFFFFF9C4)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                color: Colors.white.withOpacity(1.00),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.0),
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 13),
                                    itemCount:
                                        _data.length, // Use _data's length
                                    itemBuilder: (context, index) {
                                      final item = _data[
                                          index]; // Get each Datum object from _data
                                      return GestureDetector(
                                        onTap: () {
                                          showCustomBottomSheet(context,
                                              item); // Show popup on tap
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.white
                                                  .withOpacity(0.00),
                                            ),
                                            color: Colors
                                                .transparent, // Make the background transparent
                                          ),
                                          child: Text(
                                            item.letter, // Use the letter from Datum object
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white
                                                  .withOpacity(0.00),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildContentRow(String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            content,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 20, right: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Text(
              "📌",
              style: TextStyle(fontSize: 18),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: _fontSize, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

// Other existing methods (like _buildContentRow, _buildBulletPoint, etc.) go here
}
