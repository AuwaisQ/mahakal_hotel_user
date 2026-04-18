import 'dart:async';
import 'package:flutter/material.dart';

import '../../controller/share_helper.dart';
import 'commanbannerwidget.dart';

class GovardhanPuja extends StatefulWidget {
  const GovardhanPuja({super.key});

  @override
  State<GovardhanPuja> createState() => _GovardhanPujaState();
}

class _GovardhanPujaState extends State<GovardhanPuja> {
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
  Color _themeColor = Colors.amber; // Default theme color

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
        ShareHelper.shareContent(context, "गोवर्धन पूजा व्रत कथा");
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
          _isEnglish ? 'Govardhan Puja Vrat' : "गोवर्धन पूजा व्रत",
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
                      'assets/sahitya_images/Govardhan Puja Vrat Katha.jpg',
                ),
                _buildSectionTitle(_isEnglish
                    ? "About Govardhan Puja:"
                    : "गोवर्धन पूजा के बारे में:"),
                _buildSectionContent(_isEnglish
                    ? "Goverdhan Puja is performed on the day of Kartik Shukla Paksha Pratipada. According to Hindu belief, Lord Krishna worshipped Govardhan mountain on this day during the Mahabharata period. Since then this tradition has been maintained. When Krishna kept Govardhan mountain on his smallest finger for seven days to save the people of Braj from torrential rain and the Gopas and Gopikas lived happily in its shade. On the seventh day, the Lord put Govardhan down and ordered to celebrate Annakoot festival by worshipping Govardhan every year. Since then this festival started being celebrated in the name of Annakoot.\n\n"
                        "This festival is celebrated on the second day of Diwali and reminds of the wonderful story of Lord Krishna lifting Govardhan mountain. It is believed that on this day, Lord Krishna saved the people of Braj from the wrath of Indra Dev by lifting Govardhan mountain on his little finger. There is a law to worship Govardhan on this day."
                    : "कार्तिक शुक्ल पक्ष प्रतिपदा के दिन गोर्वधन पूजा की जाती है। हिन्दू मान्यतानुसार महाभारत काल में इसी दिन भगवान कृष्ण ने गोवर्धन पर्वत की पूजा की थी। तभी से यह परंपरा कायम है। जब कृष्ण ने ब्रजवासियों को मूसलधार वर्षा से बचाने के लिए सात दिन तक गोवर्धन पर्वत को अपनी सबसे छोटी उँगली पर उठाकर रखा और गोप-गोपिकाएँ उसकी छाया में सुखपूर्वक रहे। सातवें दिन भगवान ने गोवर्धन को नीचे रखा और प्रतिवर्ष गोवर्धन पूजा करके अन्नकूट उत्सव मनाने की आज्ञा दी। तभी से यह उत्सव अन्नकूट के नाम से मनाया जाने लगा।\n\n"
                        "यह त्योहार दीपावली के दूसरे दिन मनाया जाता है और भगवान कृष्ण के गोवर्धन पर्वत को उठाने के अद्भुत किस्से की याद दिलाता है. मान्यता है कि इस दिन, भगवान श्रीकृष्ण ने गोवर्धन पर्वत को अपनी छोटी उंगली पर उठाकर ब्रजवासियों को इंद्र देव के प्रकोप से बचाया था. इस दिन गोवर्धन की पूजा अर्चना करने का विधान है."),
                _buildSectionTitle(_isEnglish
                    ? "Materials required for Govardhan Puja:"
                    : "गोवर्धन पूजा के लिए ज़रूरी सामग्री:"),
                _buildBulletPoint(_isEnglish
                    ? "Make the shape of Lord Govardhan by smearing it with cow dung."
                    : "गोबर से लीपकर गोवर्धन भगवान की आकृति बनाना."),
                _buildBulletPoint(_isEnglish
                    ? "Make small shapes of cow and bull."
                    : "गाय और बैल की छोटी-छोटी आकृतियां बनाना."),
                _buildBulletPoint(_isEnglish
                    ? "Roli, rice, batasha, betel leaf, kheer, water, milk, flowers."
                    : "रोली, चावल, बताशे, पान, खीर, जल, दूध, फूल."),
                _buildBulletPoint(_isEnglish ? "Lamp." : "दीपक."),
                _buildBulletPoint(_isEnglish ? "Thali." : "थाली."),
                _buildBulletPoint(_isEnglish ? "Akshat." : "अक्षत."),
                _buildBulletPoint(_isEnglish ? "Saffron." : "केसर."),
                _buildBulletPoint(_isEnglish ? "Naivedya." : "नैवेद्य."),
                _buildBulletPoint(_isEnglish ? "Sweets." : "मिठाई."),
                _buildBulletPoint(_isEnglish ? "Gangajal." : "गंगाजल."),
                _buildBulletPoint(_isEnglish ? "Honey." : "शहद."),
                _buildBulletPoint(
                    _isEnglish ? "Flower garland." : "फूल की माला."),
                _buildBulletPoint(
                    _isEnglish ? "Mustard oil lamp." : "सरसों के तेल का दीपक."),
                _buildBulletPoint(_isEnglish
                    ? "Photo of Govardhan mountain."
                    : "गोवर्धन पर्वत की फ़ोटो."),
                _buildBulletPoint(_isEnglish
                    ? "Statue or picture of Shri Krishna."
                    : "श्रीकृष्ण की प्रतिमा या तस्वीर."),
                _buildBulletPoint(_isEnglish
                    ? "Book of Govardhan Puja story."
                    : "गोवर्धन पूजा की कथा की किताब."),
                _buildSectionTitle(_isEnglish
                    ? "Method of Govardhan Puja:"
                    : "गोवर्धन पूजा की विधि:"),
                _buildBulletPoint(_isEnglish
                    ? "Make the shape of Lord Govardhan by smearing it with cow dung near the courtyard or main door of the house."
                    : "घर के आंगन या मुख्य दरवाज़े के पास गोबर से लीपकर गोवर्धन भगवान की आकृति बनाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Offer the Puja material."
                    : "पूजा सामग्री अर्पित करें."),
                _buildBulletPoint(
                    _isEnglish ? "Light the lamp." : "दीपक जलाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Round the path of Lord Govardhan."
                    : "गोवर्धन भगवान की परिक्रमा करें."),
                _buildSectionTitle(_isEnglish ? "story:" : "कथा:"),
                _buildSectionContent(_isEnglish
                    ? "Once upon a time, Indra became proud of his powers. Then Lord Krishna created a leela to shatter his pride. In this, he saw all the Brajvasis and his mother preparing for a puja, so he asked Yashoda Maa, Mother, whose puja are you all preparing for? Then the mother told him that she was preparing for the worship of Indradev.\n\n"
                        "Then Lord Krishna asked, Mother, why do we all worship Indra? Then the mother told that Indra rains and from that we get food and grass for our cow. Hearing this, Krishna ji immediately said, Mother, our cow grazes on the Govardhan mountain, so he should be worshiped by us. Indra Dev is arrogant, he never gives darshan.\n\n"
                        "Following Krishna's advice, all the Brajvasis worshipped Govardhan mountain instead of Indradev. Angered by this, Lord Indra started torrential rain. Seeing the rain taking the form of flood, all the residents of Braj started cursing Lord Krishna. Then Krishna ji lifted the Govardhan mountain on his little finger to protect the people from the rain.\n\n"
                        "After this, everyone was asked to take shelter under the mountain along with their cows. This made Indra Dev even more angry and he increased the speed of rain. To break Indra's pride, Shri Krishna then asked Sudarshan Chakra to stay on top of the mountain and control the speed of rain and asked Sheshnag to make a bund and stop the water from coming towards the mountain.\n\n"
                        "Indra Dev kept raining heavily day and night. After a long time, he realized that Krishna was not an ordinary human being. Then he went to Brahma ji and he came to know that Shri Krishna was none other than the incarnation of Shri Hari Vishnu himself. On hearing this, he went to Shri Krishna and started apologizing to him. After this, Devraj Indra worshipped Krishna and offered him food. Since then the tradition of Govardhan Puja has been maintained. It is believed that Lord Krishna is pleased by worshipping Govardhan mountain and cows on this day."
                    : "एक बार की बात है इंद्र को अपनी शक्तियों पर घमंड हो गया। तब भगवान कृष्ण ने उनके घमंड को चूर करने के लिए एक लीला रची। इसमें उन्होंने सभी ब्रजवासियों और अपनी माता को एक पूजा की तैयारी करते हुए देखा तो, यशोदा मां से पूछने लगे, मईया आप सब किसकी पूजा की तैयारी कर रहे हैं? तब माता ने उन्हें बताया कि वह इन्द्रदेव की पूजा की तैयारी कर रही हैं।\n\n"
                        "फिर भगवान कृष्ण ने पूछा मैइया हम सब इंद्र की पूजा क्यों करते है? तब मईया ने बताया कि इंद्र वर्षा करते हैं और उसी से हमें अन्न और हमारी गाय के घास मिलता है। यह सुनकर कृष्ण जी ने तुरंत कहा मैइया हमारी गाय तो अन्न गोवर्धन पर्वत पर चरती है, तो हमारे लिए वही पूजनीय होना चाहिए। इंद्र देव तो घमंडी हैं वह कभी दर्शन नहीं देते हैं।\n\n"
                        "कृष्ण की बात मानते हुए सभी ब्रजवासियों ने इन्द्रदेव के स्थान पर गोवर्धन पर्वत की पूजा की। इस पर क्रोधित होकर भगवान इंद्र ने मूसलाधार बारिश शुरू कर दी। वर्षा को बाढ़ का रूप लेते देख सभी  ब्रज के निवासी भगवान कृष्ण को कोसने लगें। तब कृष्ण जी ने वर्षा से लोगों की रक्षा करने के लिए गोवर्धन पर्वत को अपनी कानी उंगली पर उठा लिया।\n\n"
                        "इसके बाद सब को अपने गाय सहित पर्वत के नीचे शरण लेने को कहा। इससे इंद्र देव और अधिक क्रोधित हो गए तथा वर्षा की गति और तेज कर दी। इन्द्र का अभिमान चूर करने के लिए तब श्री कृष्ण ने सुदर्शन चक्र से कहा कि आप पर्वत के ऊपर रहकर वर्षा की गति को नियंत्रित करने को और शेषनाग से मेंड़ बनाकर पर्वत की ओर पानी आने से रोकने को कहा।\n\n"
                        "इंद्र देव लगातार रात- दिन मूसलाधार वर्षा करते रहे। काफी समय बीत जाने के बाद उन्हें एहसास हुआ कि कृष्ण कोई साधारण मनुष्य नहीं हैं। तब वह ब्रह्मा जी के पास गए तब उन्हें ज्ञात हुआ की श्रीकृष्ण कोई और नहीं स्वयं श्री हरि विष्णु के अवतार हैं। इतना सुनते ही वह श्री कृष्ण के पास जाकर उनसे क्षमा याचना करने लगें। इसके बाद देवराज इन्द्र ने कृष्ण की पूजा की और उन्हें भोग लगाया। तभी से गोवर्धन पूजा की परंपरा कायम है। मान्यता है कि इस दिन गोवर्धन पर्वत और गायों की पूजा करने से भगवान कृष्ण प्रसन्न होते हैं।"),
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
