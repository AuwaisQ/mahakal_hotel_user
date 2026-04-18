import 'dart:async';
import 'package:flutter/material.dart';

import '../../controller/share_helper.dart';
import 'commanbannerwidget.dart';

class HoliVrat extends StatefulWidget {
  const HoliVrat({super.key});

  @override
  State<HoliVrat> createState() => _HoliVratState();
}

class _HoliVratState extends State<HoliVrat> {
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
        ShareHelper.shareContent(context, "होली व्रत कथा");
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
          _isEnglish ? 'Holi Vrat Katha' : "होली की व्रत कथा",
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
                  imagePath: 'assets/sahitya_images/holi vrat katha.jpg',
                ),

                _buildSectionTitle(
                    _isEnglish ? "About Holi Vrat:" : "होली व्रत के बारे में:"),
                _buildSectionContent(_isEnglish
                    ? "Holi is an important Indian and Nepalese festival celebrated in the spring season. This festival is celebrated on the full moon day of the month of Phalguna according to the Hindu calendar.\n\n"
                        "Holi, also known as the Festival of Colors, is a vibrant Hindu festival that marks the end of winter and the welcome of spring. Holi, celebrated on the last full moon day of the Hindu lunar calendar, is a time of merriment, symbolizing new beginnings and the victory of good over evil.\n\n"
                        "For the demoness appearing in Ramayana, see Singhika. Holika (Sanskrit: हौलाका, IAST: Holika), also known as Singhika, is an Asuri in Hinduism. She is the sister of the demon-kings Hiranyakashipu and Hiranyaksha, and the aunt of Prahlad."
                    : "होली वसंत ऋतु में मनाया जाने वाला एक महत्वपूर्ण भारतीय और नेपाली लोगों का त्यौहार है। यह पर्व हिंदू पंचांग के अनुसार फाल्गुन मास की पूर्णिमा को मनाया जाता है।\n\n"
                        "होली, जिसे रंगों का त्यौहार भी कहा जाता है, एक जीवंत हिंदू उत्सव है जो सर्दियों के अंत और वसंत के स्वागत का प्रतीक है। हिंदू चंद्र कैलेंडर के अंतिम पूर्णिमा के दिन मनाया जाने वाला होली हर्षोल्लास का समय है, जो नई शुरुआत और बुराई पर अच्छाई की जीत का प्रतीक है।\n\n"
                        "रामायण में दिखाई देने वाली राक्षसी के लिए, सिंहिका देखें। होलिका ( संस्कृत : होलिका , IAST : होलिका ), जिसे सिंहिका के नाम से भी जाना जाता है, हिंदू धर्म में एक असुरी है। वह असुर-राजा हिरण्यकश्यप और हिरण्याक्ष की बहन और प्रह्लाद की मौसी है।"),

                _buildSectionTitle(_isEnglish
                    ? "Holika Dahan Puja Vidhi and Samagri:"
                    : "होलिका दहन की पूजा विधि और सामग्री :"),
                _buildBulletPoint(_isEnglish
                    ? "For the Holika Dahan Puja, sanctify the place of worship with Gangajal."
                    : "होलिका दहन की पूजा के लिए, पूजा स्थल को गंगाजल से पवित्र करें."),
                _buildBulletPoint(_isEnglish
                    ? "For worship, sit facing north or east."
                    : "पूजा के लिए, उत्तर या पूर्व दिशा की ओर मुंह करके बैठें."),
                _buildBulletPoint(_isEnglish
                    ? "Make idols of Holika and Prahlad from cow dung."
                    : "होलिका और प्रह्लाद की मूर्तियां गाय के गोबर से बनाएं."),

                _buildSectionTitle(
                    _isEnglish ? "Puja material:" : "पूजा सामग्री :"),
                _buildBulletPoint(_isEnglish ? "Roli" : "रोली"),
                _buildBulletPoint(_isEnglish ? "Flowers" : "फूल"),
                _buildBulletPoint(_isEnglish ? "Mung" : "मूंग"),
                _buildBulletPoint(_isEnglish ? "Coconut" : "नारियल"),
                _buildBulletPoint(_isEnglish ? "Akshat" : "अक्षत"),
                _buildBulletPoint(
                    _isEnglish ? "Whole turmeric" : "साबुत हल्दी"),
                _buildBulletPoint(_isEnglish ? "Batashas" : "बताशे"),
                _buildBulletPoint(_isEnglish ? "Raw thread" : "कच्चा सूत"),
                _buildBulletPoint(_isEnglish ? "Fruits" : "फल"),
                _buildBulletPoint(
                    _isEnglish ? "Water in Kalash" : "कलश में पानी"),
                const SizedBox(height: 16.0), // Add some space
                _buildBulletPoint(_isEnglish
                    ? "For Holika Dahan, circle around Holika three or seven times with raw thread."
                    : "होलिका दहन के लिए कच्चे सूत से होलिका के चारों ओर तीन या सात बार परिक्रमा करें."),
                _buildBulletPoint(_isEnglish
                    ? "Offer pure water from a pot and other worship material to Holika."
                    : "लोटे से शुद्ध जल और अन्य पूजा सामग्री को होलिका को अर्पित करें."),
                _buildBulletPoint(_isEnglish
                    ? "After Holika Dahan, it is considered auspicious to bring the burnt ashes home the next morning."
                    : "होलिका दहन के बाद जली हुई राख को अगले दिन सुबह घर लाना शुभ माना जाता है."),
                _buildBulletPoint(_isEnglish
                    ? "By filling the ashes of Holika Dahan in a bundle and keeping it in the safe of the house, wealth and grains increase."
                    : "होलिका दहन की राख को पोटली में भरकर घर की तिजोरी में रखने से धन-धान्य में वृद्धि होती है."),
                _buildBulletPoint(_isEnglish
                    ? "Mixing a little mustard and salt in the ashes of Holika Dahan and keeping it in the house removes negative energy."
                    : "होलिका दहन की राख में थोड़ी सी राई और नमक मिलाकर घर में रखने से नकारात्मक ऊर्जा दूर होती है."),

                _buildSectionTitle(_isEnglish ? "Story:" : "कथा:"),
                _buildSectionContent(
                  _isEnglish
                      ? "The story of Holi is related to Shri Hari Vishnu Ji. According to Narada Purana, in ancient times there was a demon named Hiranyakashyap. The demon king considered himself greater than God. He wanted people to worship only him. But his own son Prahlad was a great Vishnu devotee. He had inherited devotion from his mother.\n\n"
                          "It was a matter of great concern for Hiranyakashyap that how did his own son become a Vishnu devotee? And how should he remove him from the path of devotion? According to the story of Holi (Holi ki Katha), when Hiranyakashyap asked his son to give up Vishnu devotion, but even after tireless efforts he could not succeed.\n\n"
                          "When Prahlad did not agree even after explaining many times, Hiranyakashyap thought of killing his own son. Even after many attempts, he failed to kill Prahlad. Hiranyakashyap became furious after failing with repeated attempts.\n\n"
                          "After this he took help from his sister Holika who had received a sheet from Lord Shiva which if covered with, the fire could not burn her. It was decided that Prahlad would be made to sit with Holika and burnt in the fire.\n\n"
                          "Holika covered herself with her sheet and sat on the pyre with Prahlad in her lap. But due to the miracle of Vishnu ji that sheet flew and fell on Prahlad, saving Prahlad's life and Holika was burnt. Since then, Holika Dahan is organized by lighting a fire on the evening of Holi."
                      : "होली की कहानी का संबंद्ध श्री हरि विष्णु जी से है। नारद पुराण के अनुसार आदिकाल में हिरण्यकश्यप नामक एक राक्षस हुआ था। दैत्यराज खुद को ईश्वर से भी बड़ा समझता था। वह चाहता था कि लोग केवल उसकी पूजा करें। लेकिन उसका खुद का पुत्र प्रह्लाद परम विष्णु भक्त था। भक्ति उसे उसकी मां से विरासत के रूप में मिली थी।\n\n"
                          "हिरण्यकश्यप के लिए यह बड़ी चिंता की बात थी कि उसका स्वयं का पुत्र विष्णु भक्त कैसे हो गया? और वह कैसे उसे भक्ति मार्ग से हटाए। होली की कथा (Holi ki Katha) के अनुसार जब हिरण्यकश्यप ने अपने पुत्र को विष्णु भक्ति छोड़ने के लिए कहा परंतु अथक प्रयासों के बाद भी वह सफल नहीं हो सका।\n\n"
                          "कई बार समझाने के बाद भी जब प्रह्लाद नहीं माना तो हिरण्यकश्यप ने अपने ही बेटे को जान से मारने का विचार किया। कई कोशिशों के बाद भी वह प्रह्लाद को जान से मारने में नाकाम रहा। बार-बार की कोशिशों से नाकाम होकर हिरण्यकश्यप आग बबूला हो उठा।\n\n"
                          "इसके बाद उसने अपनी बहन होलिका से मदद ली जिसे भगवान शंकर से ऐसा चादर मिला था जिसे ओढ़ने पर अग्नि उसे जला नहीं सकती थी। तय हुआ कि प्रह्लाद को होलिका के साथ बैठाकर अग्नि में स्वाहा कर दिया जाएगा।\n\n"
                          "होलिका अपनी चादर को ओढ़कर प्रह्लाद को गोद में लेकर चिता पर बैठ गई। लेकिन विष्णु जी के चमत्कार से वह चादर उड़कर प्रह्लाद पर आ गई जिससे प्रह्लाद की जान बच गई और होलिका जल गई। इसी के बाद से होली की संध्या को अग्नि जलाकर होलिका दहन का आयोजन किया जाता है।",
                ),
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
