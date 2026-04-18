import 'dart:async';
import 'package:flutter/material.dart';

import '../../controller/share_helper.dart';
import 'commanbannerwidget.dart';

class SharadPurnima extends StatefulWidget {
  const SharadPurnima({super.key});

  @override
  State<SharadPurnima> createState() => _SharadPurnimaState();
}

class _SharadPurnimaState extends State<SharadPurnima> {
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
  Color _themeColor = Colors.deepPurpleAccent; // Default theme color

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
        ShareHelper.shareContent(context, "शरद पूर्णिमा व्रत कथा");
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
          _isEnglish ? 'Sharad Purnima Vrat' : "शरद पूर्णिमा व्रत",
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
                      'assets/sahitya_images/Sharad Purnima Vrat Katha.jpg',
                ),

                _buildSectionTitle(_isEnglish
                    ? "About Sharad Purnima:"
                    : "शरद पूर्णिमा के बारे में:"),
                _buildSectionContent(_isEnglish
                    ? "Sharad Purnima, according to the Hindu calendar, is celebrated on the full moon day of the month of Ashwin. This day is also called Kojagari Purnima and Raas Purnima. On the day of Sharad Purnima, the moon is full of 16 arts. Goddess Lakshmi and Lord Vishnu are worshipped on this day.\n\n"
                        "It is believed that on the night of Sharad Purnima, Lord Krishna performed Maharas with the gopis, so it is called Raas Purnima. At the same time, on the night of Sharad Purnima, Mother Lakshmi roams on the earth, which is known as Kojagar Purnima. Kheer is kept under the open sky on the night of Sharad Purnima."
                    : "शरद पूर्णिमा, हिंदू पंचांग के मुताबिक, आश्विन महीने की पूर्णिमा को मनाई जाती है. इस दिन को कोजागरी पूर्णिमा और रास पूर्णिमा भी कहते हैं. शरद पूर्णिमा के दिन चंद्रमा 16 कलाओं से परिपूर्ण होता है. इस दिन देवी लक्ष्मी और भगवान विष्णु की पूजा की जाती है.\n\n"
                        "मान्यता है कि शरद पूर्णिमा की रात भगवान श्रीकृष्ण ने गोपियों के संग महारास रचाया था, इसलिए इसे रास पूर्णिमा कहते हैं। वहीं, शरद पूर्णिमा की रात माता लक्ष्मी पृथ्वी पर विचरण करती हैं, जिसे कोजागर पूर्णिमा के नाम से जानते हैं। शरद पूर्णिमा की रात में खुले आसमान के नीचे खीर रखते हैं।"),

                _buildSectionTitle(_isEnglish
                    ? "Method of Sharad Purnima Vrat Puja:"
                    : "शरद पूर्णिमा व्रत पूजा की विधि :"),
                // Section for Lakshmi Puja celebration instructions in English
                _buildBulletPoint(_isEnglish
                    ? "Get up in the morning, take a bath and take a vow to fast."
                    : "सुबह उठकर स्नान करें और व्रत का संकल्प लें."),
                _buildBulletPoint(_isEnglish
                    ? "Keep fast for the whole day."
                    : "पूरे दिन व्रत रखें."),
                _buildBulletPoint(_isEnglish
                    ? "First worship the Ishta Dev."
                    : "सबसे पहले इष्ट देव की पूजा करें."),
                _buildBulletPoint(_isEnglish
                    ? "Then worship Lord Vishnu and Mother Lakshmi."
                    : "फिर भगवान विष्णु और माता लक्ष्मी की पूजा करें."),
                _buildBulletPoint(_isEnglish
                    ? "Offer red sandalwood, red flowers, and makeup items to Mother Lakshmi."
                    : "माता लक्ष्मी को लाल चंदन, लाल फूल, और श्रृंगार का सामान अर्पित करें."),
                _buildBulletPoint(
                    _isEnglish ? "Light a ghee lamp." : "घी का दीपक जलाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Read Lakshmi Chalisa and chant Lakshmi ji's mantra."
                    : "लक्ष्मी चालीसा पढ़ें और लक्ष्मी जी के मंत्र जपें."),
                _buildBulletPoint(_isEnglish ? "Sing Aarti." : "आरती गाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Feed kheer to Brahmins and give them donations."
                    : "ब्राह्मणों को खीर का भोजन कराएं और उन्हें दान-दक्षिणा दें."),
                _buildBulletPoint(_isEnglish
                    ? "Worship Goddess Lakshmi and Lord Vishnu in the evening."
                    : "शाम को मां लक्ष्मी और भगवान विष्णु की पूजा करें."),
                _buildBulletPoint(_isEnglish
                    ? "Offer Arghya to the moon."
                    : "चंद्रमा को अर्घ्य दें."),
                _buildBulletPoint(_isEnglish
                    ? "Keep the vessel filled with kheer in the moonlight at night."
                    : "रात में खीर से भरे बर्तन को चंद्रमा की रोशनी में रखें."),
                _buildBulletPoint(_isEnglish
                    ? "Eat kheer as prasad the next morning."
                    : "अगले दिन सुबह प्रसाद के रूप में खीर खाएं."),

                _buildSectionTitle(
                    _isEnglish ? "Sharad Purnima Katha:" : "शरद पूर्णिमा कथा:"),
                _buildSectionContent(_isEnglish
                    ? "A moneylender had two daughters. Both daughters used to observe the Purnima fast, but the elder daughter used to observe the full fast properly while the younger daughter used to observe an incomplete fast. As a result, the children of the moneylender's younger daughter used to die as soon as they were born. When she asked the Pandits the reason for the death of her children, they told that earlier you used to observe an incomplete fast on Purnima, due to which all your children die as soon as they are born. Then the younger daughter asked the Pandits the solution to this, then they told that if you observe the Purnima fast properly, then your children can survive.\n\n"
                        "On the advice of those gentlemen, the younger daughter of the moneylender completed the Purnima fast properly. As a result, she got a son but he died soon. Then the younger daughter made the boy lie down on the stool and covered him with cloth. Then she called her elder sister and gave her the same stool to sit on.\n\n"
                        "When the elder sister started sitting on the stool, her skirt touched the dead child, the child started crying as soon as the skirt touched. The elder sister said- you wanted to defame me. If I had sat on it, your child would have died. Then the younger sister said- sister, you don't know, he was already dead, it is because of your luck that he has become alive again. He has become alive because of your good deeds. After this incident, she made a public announcement in the city to observe the fast of the full moon."
                    : "एक साहूकार के दो पुत्रियां थी। दोनों पुत्रियां पूर्णिमा का व्रत रखती थी, परन्तु बड़ी पुत्री विधिपूर्वक पूरा व्रत करती थी जबकि छोटी पुत्री अधूरा व्रत ही किया करती थी। परिणामस्वरूप साहूकार के छोटी पुत्री की संतान पैदा होते ही मर जाती थी। उसने पंडितों से अपने संतानों के मरने का कारण पूछा तो उन्होंने बताया कि पहले समय में तुम पूर्णिमा का अधूरा व्रत किया करती थी, जिस कारणवश तुम्हारी सभी संतानें पैदा होते ही मर जाती है। फिर छोटी पुत्री ने पंडितों से इसका उपाय पूछा तो उन्होंने बताया कि यदि तुम विधिपूर्वक पूर्णिमा का व्रत करोगी, तब तुम्हारे संतान जीवित रह सकते हैं।\n\n"
                        "साहूकार की छोटी कन्या ने उन भद्रजनों की सलाह पर पूर्णिमा का व्रत विधिपूर्वक संपन्न किया। फलस्वरूप उसे पुत्र रत्न की प्राप्ति हुई परन्तु वह शीघ्र ही मृत्यु को प्राप्त हो गया। तब छोटी पुत्री ने उस लड़के को पीढ़ा पर लिटाकर ऊपर से पकड़ा ढंक दिया। फिर अपनी बड़ी बहन को बुलाकर ले आई और उसे बैठने के लिए वही पीढ़ा दे दिया।\n\n"
                        "बड़ी बहन जब पीढ़े पर बैठने लगी तो उसका घाघरा उस मृत बच्चे को छू गया, बच्चा घाघरा छूते ही रोने लगा। बड़ी बहन बोली- तुम तो मुझे कलंक लगाना चाहती थी। मेरे बैठने से तो तुम्हारा यह बच्चा यह मर जाता। तब छोटी बहन बोली- बहन तुम नहीं जानती, यह तो पहले से ही मरा हुआ था, तुम्हारे भाग्य से ही फिर से जीवित हो गया है। तेरे पुण्य से ही यह जीवित हुआ है। इस घटना के उपरान्त ही नगर में उसने पूर्णिमा का व्रत करने का ढिंढोरा पिटवा दिया।"),

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
