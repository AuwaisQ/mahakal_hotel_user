import 'dart:async';
import 'package:flutter/material.dart';

import '../../controller/share_helper.dart';
import 'commanbannerwidget.dart';

class Narasimha extends StatefulWidget {
  const Narasimha({super.key});

  @override
  State<Narasimha> createState() => _NarasimhaState();
}

class _NarasimhaState extends State<Narasimha> {
  int _currentIndex = 0;
  bool _isBlackBackground = false;
  final double _scaleIncrement = 0.1;
  bool _isAutoScrolling = false;
  double _scrollSpeed = 2.0;
  late Timer _scrollTimer;
  final ScrollController _scrollController = ScrollController();

  final bool _isSliderVisible =
      false; // State variable to track visibility of the slider button
  double _textScaleFactor = 15.0; // Default font size
  bool _isEnglish = false; // State variable to track language
  Color _themeColor = Colors.orangeAccent; // Default theme color

  @override
  void dispose() {
    _scrollTimer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  // Method to show a SnackBar and copy content to clipboard
  void _showCopyMessage() {
    const snackBar = SnackBar(
      content: Text('Content copied!'),
      duration: Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _toggleAutoScroll() {
    setState(() {
      _isAutoScrolling = !_isAutoScrolling;

      if (_isAutoScrolling) {
        _scrollTimer =
            Timer.periodic(const Duration(milliseconds: 100), (timer) {
          if (_scrollController.position.pixels <
              _scrollController.position.maxScrollExtent) {
            _scrollController.animateTo(
              _scrollController.position.pixels + _scrollSpeed,
              duration: const Duration(milliseconds: 100),
              curve: Curves.linear,
            );
          } else {
            _scrollController.jumpTo(0);
          }
        });
      } else {
        _scrollTimer.cancel();
      }
    });
  }

  void _onBottomNavTap(int index) {
    if (index != 5) {
      if (_isAutoScrolling) {
        _toggleAutoScroll();
      }
    }

    setState(() {
      _currentIndex = index;

      if (index == 0) {
        _isBlackBackground = !_isBlackBackground;
      } else if (index == 1) {
        _textScaleFactor += _scaleIncrement;
      } else if (index == 2) {
        _textScaleFactor -= _scaleIncrement;
        if (_textScaleFactor < 0.1) {
          _textScaleFactor = 0.1;
        }
      } else if (index == 3) {
        ShareHelper.shareContent(context, "नरसिंह जयंती व्रत कथा");
      } else if (index == 4) {
        _showCopyMessage();
      } else if (index == 5) {
        _toggleAutoScroll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isBlackBackground ? Colors.black : Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: _isBlackBackground ? Colors.black : _themeColor,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          _isEnglish ? 'Narasimha Jayanti Vrat' : "नृसिंह जयंती व्रत",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate, color: Colors.white),
            onPressed: () {
              setState(() {
                _isEnglish = !_isEnglish; // Toggle language
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.color_lens, color: Colors.white),
            onPressed: () {
              _showColorSelectionDialog(); // Show color selection dialog
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isBlackBackground
                    ? [Colors.black, Colors.grey]
                    : [_themeColor.withOpacity(0.5), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 1),
                const CommanBannerWidget(
                  imagePath:
                      'assets/sahitya_images/Narsingh Jayanti Vrat Katha.jpg',
                ),

                _buildSectionTitle(_isEnglish
                    ? "About Narasimha Jayanti:"
                    : "नरसिंह जयंती के बारे में:"),
                _buildSectionContent(_isEnglish
                    ? "According to the Hindu calendar, the fast of Narasimha Jayanti is observed on the Chaturthi Tithi of the Shukla Paksha of the month of Vaishakh. According to the stories mentioned in the Agni Purana, on this holy day, Lord Vishnu took the form of Narasimha to protect the devotee Prahlad. Due to which this day is celebrated with great pomp and gaiety as the Jayanti of Lord Narasimha."
                    : "हिन्दू पंचांग के अनुसार नृसिंह जयंती का व्रत वैशाख माह के शुक्ल पक्ष की चतुर्थी तिथि को मनाया जाता है. अग्नि पुराण में वर्णित कथाओं के अनुसार इसी पावन दिवस को भक्त प्रहलाद की रक्षा करने के लिए भगवान विष्णु ने नृसिंह रूप में अवतार लिया था. जिस कारणवश यह दिन भगवान नृसिंह के जयंती रूप में बड़े ही धूमधाम और हर्सोल्लास के साथ मनाया जाता है."),

                _buildSectionTitle(_isEnglish
                    ? "Method of fasting on the day of Narasimha Jayanti:"
                    : "नरसिंह जयंती के दिन व्रत रखने की विधि:"),
                // Section for Narasimha Puja celebration instructions in English
                _buildBulletPoint(_isEnglish
                    ? "Get up in the morning and take a bath and wear clean clothes."
                    : "सुबह उठकर स्नान करें और साफ़ कपड़े पहनें."),
                _buildBulletPoint(_isEnglish
                    ? "Offer water to Lord Surya."
                    : "भगवान सूर्य को जल अर्पित करें."),
                _buildBulletPoint(_isEnglish
                    ? "Clean the temple and sprinkle Gangajal."
                    : "मंदिर को साफ़ करें और गंगाजल छिड़कें."),
                _buildBulletPoint(_isEnglish
                    ? "Install the idol of Lord Narasimha on a pedestal."
                    : "एक चौकी पर भगवान नरसिंह की मूर्ति स्थापित करें."),
                _buildBulletPoint(
                    _isEnglish ? "Take a vow to fast." : "व्रत का संकल्प लें."),
                _buildBulletPoint(_isEnglish
                    ? "Offer flowers, garlands, fruits, sweets, saffron, kumkum to Lord Narasimha."
                    : "भगवान नरसिंह को फूल, माला, फल, मिठाई, केसर, कुमकुम चढ़ाएं."),
                _buildBulletPoint(
                    _isEnglish ? "Light a ghee lamp." : "घी का दीपक जलाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Chant the mantras of Lord Narasimha."
                    : "भगवान नरसिंह के मंत्रों का जाप करें."),
                _buildBulletPoint(_isEnglish
                    ? "Recite Narasimha Stotra."
                    : "नरसिंह स्तोत्र का पाठ करें."),
                _buildBulletPoint(_isEnglish ? "Perform Aarti." : "आरती करें."),
                _buildBulletPoint(_isEnglish
                    ? "Offer Bhog and distribute Prasad."
                    : "भोग लगाएं और प्रसाद बांटें."),
                _buildBulletPoint(_isEnglish
                    ? "According to your faith, donate food and clothes to the poor."
                    : "अपनी श्रद्धा के मुताबिक, गरीबों को भोजन और कपड़े दान करें."),
                _buildBulletPoint(_isEnglish
                    ? "End the fast according to the auspicious time."
                    : "व्रत का पारण मुहूर्त के मुताबिक करें."),

                _buildSectionTitle(_isEnglish
                    ? "Story of Narasimha Jayanti:"
                    : "नरसिंह जयंती व्रत कथा:"),
                _buildSectionContent(_isEnglish
                    ? "According to the mythological story, when Hiranyaksha was killed, his brother, the demon king Hiranyakashyap was very sad. To avenge his brother's death, Hiranyakashyap performed severe penance. The demon king pleased Brahmaji and Shivaji and got the boon of not dying from humans, gods, birds, animals etc. After getting the boon, Hiranyakashyap started punishing the worshippers of God and made them worship him. He started giving various kinds of tortures and troubles to his subjects and due to this the subjects remained very unhappy. Pleased with the praise of the gods, Lord Vishnu assured the killing of Hiranyakashyap.\n\n"
                        "During these days, Hiranyakashyap's wife Kayadhu gave birth to a son, who was named Prahlad. Even after being born in a demon clan, Prahlad started worshipping Lord Narayana since childhood. He also used to preach religion to the children of the palace. Hiranyakashyap made several failed attempts to remove Prahlad's mind from devotion to God, but he could not succeed. Once he tried to burn him in fire with the help of his sister Holika, but due to God's immense grace on Prahlad, he was disappointed. One day, an angry Hiranyakashyap called Prahlad to the court and scolded him saying that you acted against me on someone's orders. Then Prahlad said that Lord Narayana is everywhere and he has created the whole universe. You should leave this feeling of yours and concentrate on the feet of Shri Hari.\n\n"
                        "On hearing Prahlad's words, Hiranyakashyap said that if your God is everywhere then why is he not seen in this pillar. Saying this, Hiranyakashyap, fuming with anger, tried to kill him with a sword himself, and jumped on the throne and punched the pillar hard. Then Lord Narasimha appeared from within the pillar, he had half human body and half lion body. He took Hiranyakashyap on his thighs and tore his chest with his nails on the door frame and saved his devotee."
                    : "पौराणिक कथा के अनुसार, जब हिरण्याक्ष का वध हुआ था तो उसका भाई राक्षसराज हिरण्यकश्यप बहुत दुख हुआ था। अपने भाई की मृत्यु का बदला लेने के लिए हिरण्यकश्यप ने कठोर तप किया। राक्षसराज ने ब्रह्माजी व शिवजी को प्रसन्न कर उनसे मनुष्य, देवता, पक्षी, पशु आदि से ना मरने का वरदान प्राप्त कर लिया था। वरदान पाकर हिरण्यकश्यप ने भगवान की पूजा करने वालों को कठोर दंड देना शुरू कर दिया और उन सभी से अपनी पूजा करवाता था। वह अपनी प्रजा को तरह तरह की यातनाएं और कष्ट देने लगा और इस कारण प्रजा अत्यंत दुखी रहती थी। देवताओं की स्तुति से प्रसन्न होकर भगवान विष्णु ने हिरण्यकश्यप के वध का आश्वासन दिया।\n\n"
                        "इन्हीं दिनों हिरण्यकश्यप की पत्नी कयाधु ने एक पुत्र को जन्म दिया, जिसका नाम प्रहलाद रखा गया। राक्षस कुल में जन्म लेने के बाद भी बचपन से ही प्रहलाद भगवान नारायण की भक्ति करने लगा। वह महल के बच्चों को भी धर्म का उपदेश देते थे। हिरण्यकश्यप ने प्रहलाद का मन भगवान की भक्ति से हटाने के लिए कई असफल प्रयास किए, लेकिन वह सफल नहीं हो सका।एक बार उसने अपनी बहन होलिका की सहायता से उसे अग्नि में जलाने के प्रयास किया, परन्तु प्रहलाद पर भगवान की असीम कृपा होने के कारण उसे मायूसी ही हाथ लगी. एक दिन क्रोधित हिरण्यकश्यप ने प्रहलाद को दरबार में बुलाया और डांटते हुए कहा कि तुने किसी की आज्ञा से मेरे विरुद्ध काम किया। तब प्रह्लाद ने कहा कि भगवान नारायण हर जगह है और उन्होंने पूरे ब्रह्मांड की रचना की है। आप अपना यह भाव छोड़कर श्रीहरि के चरणों में मन लगाइए।\n\n"
                        "प्रह्लाद की बात सुनकर हिरण्यकश्यप ने कहा कि अगर तेरा भगवान हर जगह है तो इस खंभे में क्यों नहीं दिखता। यह कहकर हिरण्यकश्यप क्रोध से तमतमाया हुआ, स्वयं तलवार लेकर  मारने का प्रयास किया, और सिंहासन पर कूद पड़ा और जोर से खंभे पर घूंसा मारा। तभी खंभे के भीतर से नृसिंह भगवान प्रकट हुए, उनका आधा शरीर मनुष्य और आधा शरीर सिंह समान था। उन्‍होंने हिरण्‍यकश्‍यप को अपने जांघों पर लेते हुए चौखट पर उसके सीने को अपने नाखूनों से फाड़ दिया और अपने भक्त की रक्षा की।"),

                // _buildSectionContent(_isEnglish ?"" :"" ),
                // _buildSectionContent(_isEnglish
                //     ?""
                //     :""
                // ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_currentIndex == 5)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  Text(
                    "Adjust Scroll Speed",
                    style: TextStyle(
                        color: _isBlackBackground ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                  Slider(
                    value: _scrollSpeed,
                    activeColor:
                        _isBlackBackground ? Colors.white : _themeColor,
                    inactiveColor: Colors.black.withOpacity(0.5),
                    min: 1.0,
                    max: 10.0,
                    divisions: 10,
                    label: _scrollSpeed.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _scrollSpeed = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onBottomNavTap,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.sunny,
                    color: _isBlackBackground ? Colors.black : _themeColor),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.text_increase_outlined,
                    color: _isBlackBackground ? Colors.black : _themeColor),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.text_decrease,
                    color: _isBlackBackground ? Colors.black : _themeColor),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.share_outlined,
                    color: _isBlackBackground ? Colors.black : _themeColor),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.save,
                    color: _isBlackBackground ? Colors.black : _themeColor),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.slideshow,
                    color: _isBlackBackground ? Colors.black : _themeColor),
                label: '',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showColorSelectionDialog() {
    Map<Color, String> colorMap = {
      Colors.red: "Red",
      Colors.green: "Green",
      Colors.blue: "Blue",
      Colors.yellow: "Yellow",
      Colors.purple: "Purple",
      Colors.deepOrange: "Orange",
      Colors.teal: "Teal",
      Colors.brown: "Brown",
      Colors.cyan: "Cyan",
      Colors.indigo: "Indigo",
      Colors.amber: "Amber",
      Colors.lime: "Lime",
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Theme Color"),
          content: SizedBox(
            height: 400,
            width: double.maxFinite,
            child: GridView.count(
              crossAxisCount: 3,
              children: colorMap.entries.map((entry) {
                return _colorOption(entry.key, entry.value);
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget _colorOption(Color color, String colorName) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _themeColor = color; // Update the theme color
        });
        Navigator.of(context).pop(); // Close the dialog
      },
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            colorName,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 15, left: 15, top: 20, bottom: 5),
      child: Text(
        title,
        style: TextStyle(
          fontSize: _textScaleFactor,
          fontWeight: FontWeight.bold,
          color: _isBlackBackground ? Colors.white : _themeColor,
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Card(
      elevation: 4,
      color: _isBlackBackground ? Colors.black : Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Text(
          content,
          style: TextStyle(
            fontSize: _textScaleFactor,
            color: _isBlackBackground ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.check_circle,
                color: _isBlackBackground ? Colors.white : _themeColor,
                size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                    fontSize: _textScaleFactor,
                    color: _isBlackBackground ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
