import 'dart:async';

import 'package:flutter/material.dart';

import '../../controller/share_helper.dart';
import 'commanbannerwidget.dart';

class MangalvarVrat extends StatefulWidget {
  const MangalvarVrat({super.key});

  @override
  State<MangalvarVrat> createState() => _MangalvarVratState();
}

class _MangalvarVratState extends State<MangalvarVrat> {
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
        ShareHelper.shareContent(context, "मंगलवार व्रत कथा");
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
          _isEnglish ? 'Tuesday fast story' : "मंगलवार व्रत कथा",
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
                  imagePath: 'assets/sahitya_images/Mangalvar Vrat Katha.jpg',
                ),
                _buildSectionTitle(_isEnglish
                    ? "About Tuesday fast:"
                    : "मंगलवार व्रत के बारे में:"),
                _buildSectionContent(_isEnglish
                    ? "Tuesday fast is dedicated to Hanuman ji. Observing this fast brings blessings of Hanuman ji and gets rid of problems in life. Observing Tuesday fast increases respect, strength, and courage. This fast increases respect, strength, and courage. Tuesday fast is also considered very beneficial for getting promising and lucky children. Ghosts and black powers can be avoided by the effect of this fast. Apart from this, if Mars is weak in your horoscope and is not giving auspicious results, then you must fast on Tuesday."
                    : "मंगलवार का व्रत हनुमान जी को समर्पित है. इस व्रत को करने से हनुमान जी की कृपा मिलती है और जीवन में आने वाली समस्याओं से छुटकारा मिलता है. मंगलवार का व्रत करने से सम्मान, बल, और साहस बढ़ता है.ये व्रत सम्मान, बल और साहस को बढ़ाता है। होनहार और भाग्यशाली संतान प्राप्ति के लिए भी मंगलवार का व्रत बहुत लाभकारी माना जाता है। इस व्रत के प्रभाव से भूत-प्रेत और काली शक्तियों से बचा जा सकता है। इसके अलावा यदि आपकी कुंडली में मंगल कमजोर है और शुभ फल नहीं दे रहा है, तो मंगलवार के दिन जरूर व्रत करना चाहिए।"),
                _buildSectionTitle(_isEnglish
                    ? "Method of Tuesday fast:"
                    : "मंगलवार व्रत की विधि:"),
                _buildBulletPoint(_isEnglish
                    ? "Take a bath in the morning and wear red clothes."
                    : "सुबह स्नान करके लाल रंग के कपड़े पहनें."),
                _buildBulletPoint(_isEnglish
                    ? "For the worship of Hanuman ji, keep a chowki in the north-east corner of the house and install the idol or picture of Hanuman ji on it."
                    : "हनुमान जी की पूजा के लिए घर के ईशान कोण में चौकी रखें और उस पर हनुमान जी की मूर्ति या तस्वीर स्थापित करें."),
                _buildBulletPoint(_isEnglish
                    ? "Offer red flowers, coconut, jaggery, gram, betel leaf etc. to Hanuman ji."
                    : "हनुमान जी को लाल रंग के फूल, नारियल, गुड़, चना, पान का बीड़ा आदि अर्पित करें."),
                _buildBulletPoint(_isEnglish
                    ? "Offer jasmine oil in vermilion to Hanuman ji."
                    : "हनुमान जी को सिंदूर में चमेली का तेल चढ़ाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Offer boondi or gram flour laddus to Hanuman ji."
                    : "हनुमान जी को बूंदी या बेसन के लड्डू का भोग लगाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Recite Hanuman Chalisa and Sunderkand."
                    : "हनुमान चालीसा और सुंदरकांड का पाठ करें."),
                _buildBulletPoint(_isEnglish
                    ? "Perform Hanuman ji's aarti in the evening."
                    : "शाम को हनुमान जी की आरती करें."),
                _buildBulletPoint(_isEnglish
                    ? "Do not consume salt on the day of fasting."
                    : "व्रत वाले दिन नमक का सेवन न करें."),
                _buildBulletPoint(_isEnglish
                    ? "Do not consume meat, alcohol and non-vegetarian things on the day of fasting."
                    : "व्रत वाले दिन मांस-मदिरा और तामसिक चीज़ों का सेवन न करें."),
                _buildBulletPoint(_isEnglish
                    ? "Remember the name of Shri Sitaram on the day of fasting."
                    : "व्रत वाले दिन श्री सीताराम नाम का स्मरण करें."),
                _buildSectionTitle(_isEnglish ? "Story:" : "कथा:"),
                _buildSectionContent(
                  _isEnglish
                      ? "Once upon a time, a Brahmin couple did not have any child, due to which they were very sad. Once the Brahmin went to the forest to worship Hanuman ji. There he prayed to Mahavir ji and wished for a son. At home, his wife also used to fast on Tuesday to get a son. She used to eat only after offering food to Hanuman ji at the end of the fast on Tuesday.\n\n"
                          "Once on the day of fast, the Brahmini could neither cook food nor could offer food to Hanuman ji. She vowed that she would eat only after offering food to Hanuman ji on the next Tuesday. She remained hungry and thirsty for six days. She fainted on Tuesday. Hanuman ji was pleased to see her devotion and dedication. He blessed the Brahmin woman with a son and said that he will serve her a lot.\n\n"
                          "The Brahmin woman was very happy to get the child. She named the child Mangal. After some time, when the Brahmin came home, he saw the child and asked who he was? The wife said that Hanuman ji has given her this child after being pleased with the Tuesday fast. The Brahmin did not believe his wife. One day, seeing an opportunity, the Brahmin dropped the child in the well.\n\n"
                          "On returning home, the Brahmin woman asked 'Where is Mangal?' Then Mangal came smiling from behind. The Brahmin was surprised to see him back. At night, Hanuman ji appeared in his dream and told him that he has given him this son.\n\n"
                          "The Brahmin was very happy to know the truth. After this, the Brahmin couple started observing Tuesday fast. People who observe Tuesday fast become the recipient of Hanuman ji's grace and mercy."
                      : "एक समय की बात है एक ब्राह्मण दंपत्ति की कोई संतान नहीं थी जिस कारण वह बेहद दुखी थे। एक समय ब्राह्मण वन में हनुमान जी की पूजा के लिए गया। वहां उसने पूजा के साथ महावीर जी से एक पुत्र की कामना की। घर पर उसकी स्त्री भी पुत्र की प्राप्ति के लिए मंगलवार का व्रत करती थी। वह मंगलवार के दिन व्रत के अंत में हनुमान जी को भोग लगाकर ही भोजन करती थी।\n\n"
                          "एक बार व्रत के दिन ब्राह्मणी ना भोजन बना पाई और ना ही हनुमान जी को भोग लगा सकी। उसने प्रण किया कि वह अगले मंगलवार को हनुमान जी को भोग लगाकर ही भोजन करेगी। वह भूखी प्यासी छह दिन तक पड़ी रही। मंगलवार के दिन वह बेहोश हो गई। हनुमान जी उसकी निष्ठा और लगन को देखकर प्रसन्न हुए। उन्होंने आशीर्वाद स्वरूप ब्राह्मणी को एक पुत्र दिया और कहा कि यह तुम्हारी बहुत सेवा करेगा।\n\n"
                          "बालक को पाकर ब्राह्मणी अति प्रसन्न हुई। उसने बालक का नाम मंगल रखा। कुछ समय उपरांत जब ब्राह्मण घर आया, तो बालक को देख पूछा कि वह कौन है? पत्नी बोली कि मंगलवार व्रत से प्रसन्न होकर हनुमान जी ने उसे यह बालक दिया है। ब्राह्मण को अपनी पत्नी की बात पर विश्वास नहीं हुआ। एक दिन मौका देख ब्राह्मण ने बालक को कुएं में गिरा दिया।\n\n"
                          "घर पर लौटने पर ब्राह्मणी ने पूछा कि 'मंगल कहां है?' तभी पीछे से मंगल मुस्कुरा कर आ गया। उसे वापस देखकर ब्राह्मण आश्चर्यचकित रह गया। रात को हनुमानजी ने उसे सपने में दर्शन दिए और बताया कि यह पुत्र उसे उन्होंने ही दिया है।\n\n"
                          "ब्राह्मण सत्य जानकर बहुत खुश हुआ। इसके बाद ब्राह्मण दंपत्ति मंगलवार व्रत रखने लगे। मंगलवार का व्रत रखने वाले मनुष्य हनुमान जी की कृपा व दया का पात्र बनते हैं。",
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
