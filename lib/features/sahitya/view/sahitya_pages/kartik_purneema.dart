import 'dart:async';

import 'package:flutter/material.dart';

import '../../controller/share_helper.dart';
import 'commanbannerwidget.dart';

class KartikPurnima extends StatefulWidget {
  const KartikPurnima({super.key});

  @override
  State<KartikPurnima> createState() => _KartikPurnimaState();
}

class _KartikPurnimaState extends State<KartikPurnima> {
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
  Color _themeColor = Colors.lightBlueAccent; // Default theme color

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
        ShareHelper.shareContent(context, "कार्तिक पूर्णिमा व्रत कथा");
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
          _isEnglish ? 'Kartik Purnima Vrat' : "कार्तिक पूर्णिमा व्रत",
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
                      'assets/sahitya_images/Kartik Purnima Vrat Katha.jpg',
                ),
                _buildSectionTitle(_isEnglish
                    ? "About Kartik Purnima:"
                    : "कार्तिक पूर्णिमा के बारे में:"),
                _buildSectionContent(_isEnglish
                    ? "Kartik Purnima is also known as Dev Deepawali in many places. Keeping a fast on this day is considered very auspicious and virtuous work. Kartik Purnima is also known as Tripuri Purnima. It was on the day of Kartik Purnima that Lord Shiva ended the demon named Tripurasura. This day is considered the best for the worship of Lord Vishnu and the Moon.\n\n"
                        "On the day of Kartik Purnima, Lord Vishnu was born in the form of Matsya Avatar, which is associated with the story of the destruction and re-creation of the creation. Matsya Avatar is considered to be the first incarnation of Lord Vishnu among the ten incarnations. It is a religious belief that Lord Vishnu took the form of Matsya on the day of Kartik Purnima to protect the Vedas during the deluge."
                    : "कार्तिक पूर्णिमा को कई जगह देव दीपावली के नाम से भी जाना जाता है। इस दिन व्रत रखना बेहद शुभ और पुण्य का काम माना जाता है। कार्तिक पूर्णिमा को त्रिपुरी पूर्णिमा  के नाम से भी जाना जाता है। कार्तिक पूर्णिमा के दिन ही भगवान शिव ने त्रिपुरासुर नामक राक्षस का अंत किया था। यह दिन भगवान विष्णु और चंद्रमा की पूजा के लिए सबसे अच्छा माना जाता है\n\n"
                        "कार्तिक पूर्णिमा के दिन भगवान विष्णु के रूप में मत्स्य अवतार का जन्म हुआ था, जो सृष्टि के विनाश और पुनर्सृजन की कथा से जुड़ा है। भगवान विष्णु के दस अवतारों में पहला अवतार मत्स्य अवतार माना जाता है। धार्मिक मान्यता है कि भगवान विष्णु ने प्रलय काल में वेदों की रक्षा के लिए कार्तिक पूर्णिमा के दिन मत्स्य रूप धारण किया था।"),
                _buildSectionTitle(_isEnglish
                    ? "Kartik Purnima Vrat Method and Ingredients:"
                    : "कार्तिक पूर्णिमा व्रत  विधि और सामग्री:"),
                _buildBulletPoint(_isEnglish
                    ? "Get up early in the morning on the day of Kartik Purnima and take a vow to fast."
                    : "कार्तिक पूर्णिमा के दिन सुबह जल्दी उठकर व्रत का संकल्प लें."),
                _buildBulletPoint(_isEnglish
                    ? "Clean the house and offer arghya to the Sun God."
                    : "घर की साफ़-सफ़ाई करें और सूर्य देव को अर्घ्य दें."),
                _buildBulletPoint(_isEnglish
                    ? "Worship Lord Vishnu and Mother Lakshmi."
                    : "भगवान विष्णु और मां लक्ष्मी की पूजा करें."),
                _buildBulletPoint(_isEnglish
                    ? "Offer fragrance, flowers, fruits, clothes to Lord Vishnu."
                    : "भगवान विष्णु को गंध, फूल, फल, वस्त्र अर्पित करें."),
                _buildBulletPoint(_isEnglish
                    ? "Light a lamp of desi ghee and perform aarti and chant Vishnu ji's mantras."
                    : "देसी घी का दीपक जलाकर आरती करें और विष्णु जी के मंत्रों का जप करें."),
                _buildBulletPoint(_isEnglish
                    ? "Offer fruits and sweets."
                    : "फल और मिठाई का भोग लगाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Recite the Vrat Katha."
                    : "व्रत कथा का पाठ करें."),
                _buildBulletPoint(_isEnglish
                    ? "Donate to poor people."
                    : "गरीब लोगों में दान करें."),
                _buildBulletPoint(_isEnglish
                    ? "In the evening, fill water in a copper or steel pot."
                    : "शाम के समय तांबे या स्टील के लोटे में जल भरें."),
                _buildBulletPoint(_isEnglish
                    ? "Add milk to that water and tie a Kalawa on the pot."
                    : "उस जल में दूध मिलाएं और लोटे के ऊपर कलावा बांध दें."),
                _buildBulletPoint(_isEnglish
                    ? "After the moon rises, offer Arghya and chant the mantras of the moon."
                    : "चंद्रमा के उदय होने के बाद अर्घ्य दें और चंद्रमा के मंत्रों का जाप करें."),
                _buildBulletPoint(_isEnglish
                    ? "Offer Deepdaan on the Tulsi plant."
                    : "तुलसी के पौधे पर दीपदान करें."),
                _buildBulletPoint(_isEnglish
                    ? "Light a lamp inside and outside the house."
                    : "घर में और बाहर दीपक जलाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Donate cow, milk, bananas, dates, guava, rice, sesame and gooseberry."
                    : "गाय का दान, दूध, केले, खजूर, अमरूद, चावल, तिल और आंवले का दान करें."),
                _buildBulletPoint(_isEnglish
                    ? "Offer water mixed with milk and honey on the Peepal tree and light a lamp."
                    : "पीपल के पेड़ पर जल में दूध और शहद मिलाकर चढ़ाएं और दीपक जलाएं."),
                _buildSectionTitle(_isEnglish ? "Story:" : "कथा:"),
                _buildSectionContent(_isEnglish
                    ? "On Kartik Purnima, Lord Shiva killed the demons named Tripurasurs and Lord Vishnu took his Matsya avatar on this day. Guru Nanak Dev ji was also born on this day. Therefore, this day is also celebrated as Prakash Parv and Guru Parv. Kartik Purnima is one of the most auspicious days of the year. It is said that by donating lamps and taking a bath in the Ganges on this day, all the sins of a person are destroyed. Also, on this day, 6 Krittikas are worshipped.\n\n"
                        "There was a demon named Tarakasur. He had three sons Tarakaksh, Kamalaksh and Vidyunmali. When Lord Shiva's son Kartikeya killed Tarakasur, his three sons were very sad. They did severe penance of Brahma ji to take revenge from the gods for their father's death. Brahma ji, pleased with their penance, appeared before them and asked them to ask for a boon. All three asked Brahma ji to be immortal, but Brahma ji said that you should ask for some other boon apart from this.\n\n"
                        "After this, all three asked for the construction of three cities, in which the three of them can sit and travel the entire earth and sky and when we meet at one place after a thousand years, all three cities should unite and whichever god or goddess has the power to destroy these three cities with one arrow, only he can kill us.\n\n"
                        "Brahma Ji fulfilled the wish of Tarakasur's three sons. Brahma Ji built three cities. A city of gold was built for Tarakaksh, a city of silver for Kamalaksh and a city of iron for Vidyunmali. After getting the boon, all three created terror everywhere and tried to establish their authority over heaven as well, due to which Indradev got scared and took refuge in Lord Shiva. Listening to Indradev, Mahadev built a divine chariot and destroyed all the three cities with a single arrow and killed Tripurasurs. It is said that after this Lord Shiva was called Tripurari."
                    : "कार्तिक पूर्णिमा पर भगवान शिव ने त्रिपुरासुरों नामक राक्षसों का वध किया था और वहीं भगवान विष्णु ने इस दिन अपना मत्स्यावतार लिया था। वहीं इस दिन गुरु नानक देव जी का भी जन्म हुआ था। इसलिए इस दिन को प्रकाश पर्व और गुरु पर्व के रूप में भी मनाया जाता है। कार्तिक पूर्णिमा साल में आने वाले सबसे शुभ दिनों में से एक है। कहते हैं इस दिन दीप दान और गंगा स्नान करने से व्यक्ति के सारे पाप नष्ट हो जाते हैं। साथ ही इस दिन 6 कृतिकाओं का भी पूजन होता है।\n\n"
                        "तारकासुर नाम का एक राक्षस था। जिसके तीन पुत्र थे तारकाक्ष, कमलाक्ष और विद्युन्माली। जब भगवान शिव के पुत्र कार्तिकेय जी ने तारकासुर का वध कर दिया तो उसके तीनों पुत्र बेहद दुखी हुए थे। उन्होंने अपने पिता की मृत्यु का देवताओं से बदला लेने के लिए ब्रह्मा जी की घोर तपस्या की। ब्रह्मा जी ने उनकी तपस्या से प्रसन्न होकर उन्हें साक्षात दर्शन दिए और वरदान मांगने के लिए कहा। तीनों ने ब्रह्मा जी से अमर होने का वरदान मांगा, लेकिन ब्रह्मा जी ने कहा कि आप इसके अलावा कुछ अलग वरदान मांग लो।\n\n"
                        "इसके बाद तीनों ने तीन नगर का निर्माण करवाने के लिए कहा, जिसमें बैठकर वह तीनों पूरे पृथ्वी और आकाश का भ्रमण कर सकें और जब एक हजार वर्ष बाद हम एक जगह पर मिलें तो तीनों नगर मिलकर एक हो जाएं और जो भी देवी-देवता अपने एक बाण से इन तीनों नगरों को नष्ट करने की ताकत रखता हो वही हमारा वध कर सके।\n\n"
                        "ब्रह्मा जी ने तारकासुर के तीनों पुत्रों की ये मनोकामना पूरी कर दी। ब्रह्मा जी ने तीन नगरों का निर्माण करवाया। तारकाक्ष के लिए सोने का, कमलाक्ष के लिए चांदी का और विद्युन्माली के लिए लोहे का नगर बनवाया गया। वरदान प्राप्त करने के बाद तीनों ने हर जगह अपना आतंक मचा दिया और स्वर्ग पर भी अपना अधिकार स्थापित करने की कोशिश की जिससे इंद्रदेव भयभीत हुए और भगवान शिव की शरण में पहुंचे। इंद्रदेव की बात सुन महादेव ने एक दिव्य रथ का निर्माण किया और एक ही बाण से तीनों नगरों को नष्ट कर त्रिपुरासुरों का वध कर दिया। कहते हैं इसके बाद से ही भगवान शिव त्रिपुरारी कहलाए।"),
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
