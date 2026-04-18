import 'dart:async';
import 'package:flutter/material.dart';
import '../../controller/share_helper.dart';
import 'commanbannerwidget.dart';

class BhaiDooj extends StatefulWidget {
  const BhaiDooj({super.key});

  @override
  State<BhaiDooj> createState() => _BhaiDoojState();
}

class _BhaiDoojState extends State<BhaiDooj> {
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
  Color _themeColor = Colors.lime; // Default theme color

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
        ShareHelper.shareContent(context, "भाई दूज व्रत कथा");
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
          _isEnglish ? 'Bhai Dooj Vrat' : "भाई दूज व्रत",
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
                  imagePath: 'assets/sahitya_images/Bhai dooj Vrat Katha.jpg',
                ),

                _buildSectionTitle(
                    _isEnglish ? "About Bhai Dooj:" : "भाई दूज के बारे में:"),
                _buildSectionContent(_isEnglish
                    ? "The festival of Bhai Dooj is celebrated on the second day of Kartik Shukla Paksha, two days after Diwali. On this day, brothers go to their sister's house and get Tilak done. Sisters feed their brother food prepared by their own hands. On this day, a square is made in the courtyard of the house and worship is done and the story of Bhai Dooj is recited. On this auspicious occasion, sisters worship Yamraj, so that their brother gets success in life and his life is long. Also, they apply Tilak to the brother in the auspicious time."
                    : "भाई दूज का पर्व दीपावली के दो दिन बाद कार्तिक शुक्‍ल पक्ष की द्वितीया को मनाया जाता है। इस दिन भाई बहन के घर जाकर तिलक करवाते हैं। बहनें भाई को अपने हाथ से बना भोजन करवाती हैं। इस दिन घर के आंगन में चौक बनाकर पूजा की जाती है और भाई दूज की कथा का पाठ किया जाता है। इस शुभ अवसर पर बहनें यमराज की पूजा करती हैं, ताकि उनके भाई को जीवन में सफलता मिले और उनकी उम्र लंबी हो। साथ ही शुभ मुहूर्त में भाई का तिलक करती हैं।"),

                _buildSectionTitle(_isEnglish
                    ? "Bhai Dooj Vrat Puja Vidhi and Materials:"
                    : "भाई दूज के व्रत की पूजा विधि और सामग्री:"),
                // Section for Bhai Dooj celebration instructions in English
                _buildBulletPoint(_isEnglish
                    ? "On the day of Bhai Dooj, wake up early in the morning and take a bath."
                    : "भाई दूज के दिन सुबह जल्दी उठकर स्नान करें."),
                _buildBulletPoint(_isEnglish
                    ? "Light a ghee lamp in the temple of the house and worship God."
                    : "घर के मंदिर में घी का दीपक जलाकर ईश्वर की पूजा करें."),
                _buildBulletPoint(_isEnglish
                    ? "Worship Yamraj, Yamuna, Lord Ganesha, and Lord Vishnu."
                    : "यमराज, यमुना, भगवान गणेश, और भगवान विष्णु की पूजा करें."),
                _buildBulletPoint(_isEnglish
                    ? "Make a square with ground rice."
                    : "पिसे चावल से चौक बनाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Apply Tilak to the brother."
                    : "भाई को तिलक लगाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Perform the Aarti of the brother."
                    : "भाई की आरती उतारें."),
                _buildBulletPoint(_isEnglish
                    ? "Tie Kalawa to the brother."
                    : "भाई को कलावा बांधें."),
                _buildBulletPoint(_isEnglish
                    ? "Feed sweets to the brother."
                    : "भाई को मिठाई खिलाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Give coconut to the brother."
                    : "भाई को नारियल दें."),
                _buildBulletPoint(
                    _isEnglish ? "Feed your brother." : "भाई को भोजन कराएं."),
                _buildBulletPoint(_isEnglish
                    ? "Brothers and sisters should give gifts to each other."
                    : "भाई-बहन एक-दूसरे को उपहार दें."),
                _buildBulletPoint(_isEnglish
                    ? "Brothers and sisters should touch each other's feet and seek blessings."
                    : "भाई-बहन चरण स्पर्श करके आशीर्वाद लें."),

                _buildSectionTitle(_isEnglish
                    ? "Bhai Dooj Puja Samagri:"
                    : "भाई दूज की पूजा सामग्री:"),
                // Section for items needed for Bhai Dooj in English
                _buildBulletPoint(_isEnglish ? "Kumkum" : "कुमकुम"),
                _buildBulletPoint(_isEnglish ? "Sindoor" : "सिंदूर"),
                _buildBulletPoint(_isEnglish ? "Chandan" : "चंदन"),
                _buildBulletPoint(_isEnglish ? "Flowers" : "फूल"),
                _buildBulletPoint(_isEnglish ? "Fruits" : "फल"),
                _buildBulletPoint(_isEnglish ? "Sweets" : "मिठाई"),
                _buildBulletPoint(_isEnglish ? "Betel Nut" : "सुपारी"),
                _buildBulletPoint(_isEnglish ? "Akshat" : "अक्षत"),
                _buildBulletPoint(_isEnglish ? "Red Kalawa" : "लाल कलावा"),
                _buildBulletPoint(
                    _isEnglish ? "Silver Coin" : "चांदी का सिक्का"),

                _buildSectionTitle(_isEnglish ? "Story:" : "कथा:"),
                _buildSectionContent(_isEnglish
                    ? "Sun God's wife's name was Sangya Devi. They had two children, son was Yamraj and daughter was Yamuna. Queen Sangya could not bear the scorching rays of her husband Surya and started living as a shadow in the North Pole region. Tapti river and Shani were born from that shadow. It is said that Ashwini Kumars were also born from this shadow who are considered to be the physicians of the gods. Here, Chhaya's behavior with Yamraj and Yamuna started getting bad. Displeased with this, Yam established a new city Yampuri. Seeing his brother punishing sinners in Yampuri, Yamunaji went to Golok. He sent messengers to search for Yamuna, but could not find her. Then he himself went to Golok where he met Yamunaji at Vishram Ghat. On seeing her brother, Yamuna was overjoyed and welcomed him with hospitality and served him food.\n\n"
                        "Pleased with this, Yam asked him to ask for a boon. Yamuna said- 'O brother! I want to ask you for a boon that the men and women who bathe in my water should not go to Yampuri? The question was very difficult. If Yam gave such a boon, the existence of Yampuri would end. So, seeing her brother in a dilemma, Yamuna said- Don't worry, give me this boon that those who eat at their sister's place today and bathe at Vishram Ghat in this Mathura city should not go to your world.' Yamraj accepted this and said that on this day, those gentlemen who do not eat at their sister's house, I will tie them up and take them to Yampuri and those who bathe in your water will attain heaven. Since then, this festival of brother-sister relationship started being celebrated."
                    : "सूर्य भगवान की पत्‍नी का नाम संज्ञादेवी था, इनकी दो संतानें, पुत्र यमराज था कन्या यमुना थी। संज्ञा रानी पति सूर्य की उद्दीप्त किरणों को न सह सकने के कारण उत्तरी ध्रुव प्रदेश में छाया बनकर रहने लगी। उसी छाया से ताप्ती नदी तथा शनिश्चर का जन्म हुआ। इसी छाया से अश्विनी कुमारों का भी जन्म बताया जाता है जो देवताओं के वैद्य (भेषज) माने जाते हैं। इधर छाया का यम तथा यमुना से व्यवहार खराब होने लगा। इससे खिन्न होकर यम ने अपनी एक नई नगरी यमपुरी बसाई, यमपुरी में पापियों को दण्ड देने का काम संपादित करते भाई को देखकर यमुनाजी गौ लोक चली आई तो उन्होंने दूतों को भेजकर यमुना को बहुत खोजवाया, मगर मिल न सकीं। फिर स्वयं ही गोलोक गए जहां विश्राम घाट पर यमुनाजी से भेंट हुई। भाई को देखते ही यमुना ने हर्ष विभोर हो स्वागत सत्कार के साथ भोजन करवाया।\n\n"
                        "इससे प्रसन्न हो यम ने वर मांगने को कहा। यमुना ने कहा- 'हे भैया! मैं आपसे यह वरदान मांगना चाहती हूं कि मेरे जल में स्नान करने वाले नर-नारी यमपुरी न जाएं? प्रश्न बड़ा कठिन था यम के ऐसा वर देने से यमपुरी का अस्तित्व ही समाप्त जाता अतः भाई को असमंजस में देखकर यमुना बोली- आप चिन्ता न करें मुझे यह वरदान दें कि जो लोग आज के दिन बहन के यहां भोजन करके, इस मथुरा नगरी स्थित विश्राम घाट पर स्नान करें वह तुम्हारे लोक न जाएं।' इसे यमराज ने स्वीकार कर लिया इस तिथि को जो सज्जन बहन के घर भोजन नहीं करेंगे उन्हें मैं बांधकर यमपुरी को ले जाऊंगा और तुम्हारे जल में स्नान करने वालों को स्वर्ग प्राप्त होगा। तभी से भाई-बहन के रिश्‍ते का यह त्‍योहार मनाया जाने लगा।"),
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
