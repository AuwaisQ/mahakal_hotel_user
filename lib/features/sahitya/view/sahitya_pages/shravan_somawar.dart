import 'dart:async';
import 'package:flutter/material.dart';

import '../../controller/share_helper.dart';
import 'commanbannerwidget.dart';

class Shravan extends StatefulWidget {
  const Shravan({super.key});

  @override
  State<Shravan> createState() => _ShravanState();
}

class _ShravanState extends State<Shravan> {
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
        ShareHelper.shareContent(context, "सावन सोमवार व्रत कथा");
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
          _isEnglish
              ? 'Shravan (Sawan) Monday Fast'
              : "श्रावण (सावन) सोमवार व्रत",
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
                      'assets/sahitya_images/Shravan (sawan) Somvar Vrat Katha.jpg',
                ),

                _buildSectionTitle(_isEnglish
                    ? "About Shravan (Sawan) Monday:"
                    : "श्रावण (सावन) सोमवार के बारे में: "),
                // Section for Shravan Month and Shravan Monday information in English
                _buildSectionContent(_isEnglish
                    ? "According to the Indian Hindu calendar, the fifth month is Shravan. In common parlance, many people also call it Sawan. This month is considered special and sacred for Hindus. It is believed that Sawan is the favorite month of Lord Shiva. The sixteen Monday fast is started from the month of Sawan. Fasting on Monday of Sawan month is considered very fruitful and auspicious.\n\n"
                        "Shravan Monday is called the Monday that comes in the month of Sawan. On this day Lord Shiva and Mother Parvati are worshiped. By observing the fast of Sawan Monday, wishes are fulfilled and defects are removed from the horoscope. The method of Monday fast is the same in all fasts. It is considered auspicious to start this fast in the month of Shravan. Lord Shiva and Goddess Parvati are worshiped in the fast of Shravan Monday. Shravan Monday fast is observed from sunrise till the third quarter.\n\n"
                        "In the scriptures, Monday is considered very important for freedom from sins and attainment of auspicious results. It is believed that by worshiping and praying to Lord Shiva on Monday of the month of Sawan, a person gets the special blessings of Shankar ji and all the troubles of his life are resolved. It is said that Goddess Parvati did rigorous penance to get Lord Shiva as her husband. She kept a fast on Monday in the month of Sawan and pleased with her penance, Lord Shiva gave her a boon and he became her husband."
                    : "भारतीय हिन्दू कैलेंडर के अनुसार पांचवां मास श्रावण का होता है। आम बोलचाल की भाषा में इसे कई लोग सावन भी कहते हैं। यह महीना हिंदुओं के लिए विशेष और पवित्र माना जाता है। मान्यता है कि सावन भगवान शिव का पसंदीदा मास होता है। सावन मास से सोलह सोमवार व्रत की शुरूआत की जाती है। सावन मास के सोमवार को व्रत रखना बेहद फलदायी और शुभ माना जाता है।\n\n"
                        "श्रावण सोमवार, सावन महीने में आने वाले सोमवार को कहते हैं। इस दिन भगवान शिव और माता पार्वती की पूजा की जाती है। सावन सोमवार का व्रत करने से मनोकामनाएं पूरी होती हैं और कुंडली से दोष दूर होते हैं। सोमवार व्रत की विधि सभी व्रतों में समान होती है। इस व्रत को श्रावण माह में आरंभ करना शुभ माना जाता है। श्रावण सोमवार के व्रत में भगवान शिव और देवी पार्वती की पूजा की जाती है। श्रावण सोमवार व्रत सूर्योदय से प्रारंभ कर तीसरे पहर तक किया जाता है।\n\n"
                        "शास्त्रों में सोमवार के दिन को पापों से मुक्ति और शुभ फलों की प्राप्ति के लिए भी बहुत ही महत्वपूर्ण माना गया है। मान्यता है कि सावन माह के सोमवार को भगवान शिव की आराधना और उपासना करने से व्यक्ति को शंकर जी की विशेष कृपा प्राप्त होती है और उसके जीवन के सभी कष्टों का निवारण होता है। कहा जाता है कि देवी पार्वती ने भगवान शिव को पति रूप में पाने के लिए कठोर तपस्या की थी। उन्होंने सावन के महीने में सोमवार का व्रत रखा और उनकी तपस्या से प्रसन्न होकर भगवान शिव ने उन्हें वरदान दिया और वे उनके पति बने।"),

                _buildSectionTitle(_isEnglish
                    ? "Sawan Monday Vrat Puja Vidhi and Material:"
                    : "सावन सोमवार व्रत की पूजा विधि और सामग्री:"),
                // Section for Sawan Monday celebration instructions in English
                _buildBulletPoint(_isEnglish
                    ? "On Sawan Monday, get up early in the morning and take a bath."
                    : "सावन सोमवार के दिन सुबह जल्दी उठकर स्नान करें."),
                _buildBulletPoint(
                    _isEnglish ? "Wear clean clothes." : "साफ़ कपड़े पहनें."),
                _buildBulletPoint(_isEnglish
                    ? "Clean the puja room or temple."
                    : "पूजा घर या मंदिर की साफ़-सफ़ाई करें."),
                _buildBulletPoint(_isEnglish
                    ? "Perform Abhishek by adding Ganga water to the water on the Shivling."
                    : "शिवलिंग पर जल में गंगाजल डालकर अभिषेक करें."),
                _buildBulletPoint(_isEnglish
                    ? "Apply white sandalwood to Lord Shiva."
                    : "भगवान शिव को सफ़ेद चंदन लगाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Offer milk, Ganga water, honey, ghee, Akshat, Belpatra, Bhang, Dhatura, Ankda, Betel Nut etc. to Lord Shiva."
                    : "भगवान शिव को दूध, गंगाजल, शहद, घी, अक्षत, बेलपत्र, भांग, धतूरा, आंकड़ा, सुपारी आदि चढ़ाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Worship Lord Shiva."
                    : "भगवान शिव की पूजा करें."),
                _buildBulletPoint(_isEnglish
                    ? "Chant the Beej Mantra of Lord Shiva 'Om Namah Shivaya'."
                    : "भगवान शिव के बीज मंत्र 'ॐ नमः शिवाय' का जाप करें."),
                _buildBulletPoint(_isEnglish
                    ? "Do the Aarti of Lord Shiva."
                    : "भगवान शिव की आरती करें."),
                _buildBulletPoint(_isEnglish
                    ? "Listen to the story of Sawan Monday fast."
                    : "सावन सोमवार व्रत की कथा सुनें."),
                _buildBulletPoint(_isEnglish ? "Offer Bhog." : "भोग लगाएं."),

                _buildSectionTitle(
                    _isEnglish ? "Sawan Puja Vidhi:" : "सावन पूजा-विधि:"),
                _buildSectionContent(_isEnglish
                    ? "If you want to keep a fast, then take holy water, flowers and Akshat in your hand and take a pledge to keep the fast. Light a lamp in the temple of your house. Then do the Abhishek of Lord Shiva in the Shiva temple or at home and do the proper worship of the Shiva family."
                    : "अगर व्रत रखना है तो हाथ में पवित्र जल, फूल और अक्षत लेकर व्रत रखने का संकल्प लें। घर के मंदिर में में दीपक जलाएं। फिर शिव मंदिर या घर में भगवान शिव का अभिषेक करें और शिव परिवार की विधिवत पूजा-अर्चना करें।"),

                _buildSectionTitle(_isEnglish
                    ? "Shravan (Sawan) Monday Fast Story:"
                    : "श्रावण (सावन) सोमवार व्रत कथा:"),
                _buildSectionContent(_isEnglish
                    ? "According to Skanda Purana, when Sanat Kumar asked Lord Shiva that why do you like the month of Shravan so much? Then Lord Shiva told that Goddess Sati had vowed to get Lord Shiva as her husband in every birth. But due to her father Daksha Prajapati insulting Lord Shiva, Goddess Sati left her body with the power of yoga. After this, she was born in the second birth with the name Parvati in the house of King Himalaya and Queen Naina. In her youth, she pleased Lord Shiva by observing a strict fast without food in the month of Shravan and married him.\n\nFasting to get desired life partner is believed that fasting for Lord Shiva without eating anything in Shravan month helps in getting desired life partner. Unmarried girls and boys especially fasting in this month helps ingetting married. Also, by fasting in Shravan month, Lord Shiva takes away all the troubles of life."
                    : "स्कंद पुराण के अनुसार जब सनत कुमार ने भगवान शिव से पूछा कि आपको श्रावण मास इतना प्रिय क्यों है? तब शिवजी ने बताया कि देवी सती ने भगवान शिव को हर जन्म में अपने पति के रूप में पाने का प्रण लिया था। लेकिन अपने पिता दक्ष प्रजापति के भगवान शिव को अपमानित करने के कारण देवी सती ने योगशक्ति से शरीर त्याग दिया। इसके पश्चात उन्होंने दूसरे जन्म में पार्वती नाम से राजा हिमालय और रानी नैना के घर जन्म लिया। उन्होंने युवावस्था में श्रावण महीने में ही निराहार रहकर कठोर व्रत द्वारा भगवान शिव को प्रसन्न कर उनसे विवाह किया।\n\nमनचाहा जीवनसाथी पाने के लिए व्रत इसीलिए मान्यता है कि श्रावण में निराहार रह भगवान शिव का व्रत रखने से मनचाहा जीवनसाथी मिलता है। कुंआरी लड़कियों और लड़कों को इस महीने विशेष रूप से व्रत करने से शादी के योग बनते हैं। साथ ही श्रावण मास में व्रत रखने से भगवान शिव जीवन के सभी कष्टों का निवारण करते हैं।"),

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
