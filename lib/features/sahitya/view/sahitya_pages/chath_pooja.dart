import 'dart:async';

import 'package:flutter/material.dart';

import '../../controller/share_helper.dart';
import 'commanbannerwidget.dart';

class ChhathPuja extends StatefulWidget {
  const ChhathPuja({super.key});

  @override
  State<ChhathPuja> createState() => _ChhathPujaState();
}

class _ChhathPujaState extends State<ChhathPuja> {
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
        ShareHelper.shareContent(context, "छठ पूजा व्रत कथा");
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
          _isEnglish ? 'Chhath Puja Vrat' : "छठ पूजा व्रत",
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
                  imagePath: 'assets/sahitya_images/Chhath puja Katha.jpg',
                ),

                _buildSectionTitle(
                    _isEnglish ? "About Chhath Puja:" : "छठ पूजा के बारे में:"),
                // Section for the Chhath Vrat information in English
                _buildSectionContent(_isEnglish
                    ? "Chhath Vrat is a special festival dedicated to Lord Suryadev. In many parts of India, especially in UP and Bihar, it is considered a great festival. This festival, celebrated with purity, cleanliness and sanctity, has been celebrated since ancient times. Chhathi Mata is worshipped in Chhath Vrat and a boon is sought from her for the protection of children.\n\n"
                        "The Chhath Vrat, which is celebrated on the Shashthi Tithi of Shukla Paksha of Kartik month, is described in the Bhavishya Purana as Surya Shashthi. However, according to folk beliefs, Surya Shashthi or Chhath Vrat started from the Ramayana period. This fast was also observed by Draupadi in the Dwapar era along with Sita Mata.\n\n"
                        "In Treta Yuga, Mother Sita and in Dwapar Yuga, Draupadi also kept the Chhath fast. According to the story of Ramayana, when Ram ji returned to Ayodhya with Goddess Sita and Lakshman ji after killing Ravana, then Mother Sita kept a fast on Shashthi of Shukla Paksha of Kartik month and worshipped Goddess Shashthi and Sun God for the peace and happiness of the family."
                    : "छठ व्रत भगवान सूर्यदेव को समर्पित एक विशेष पर्व है। भारत के कई हिस्सों में खासकर यूपी और बिहार में तो इसे महापर्व माना जाता है। शुद्धता, स्वच्छता और पवित्रता के साथ मनाया जाने वाला यह पर्व आदिकाल से मनाया जा रहा है। छठ व्रत में छठी माता की पूजा होती है और उनसे संतान की रक्षा का वर मांगा जाता है।\n\n"
                        "कार्तिक माह के शुक्ल पक्ष की षष्ठी तिथि को मनाए जाने वाले छठ व्रत का वर्णन भविष्य पुराण में सूर्य षष्ठी के रूप में है। हालांकि लोक मान्यताओं के अनुसार सूर्य षष्ठी या छठ व्रत की शुरुआत रामायण काल से हुई थी। इस व्रत को सीता माता समेत द्वापर युग में द्रौपदी ने भी किया था।\n\n"
                        "त्रेतायुग में माता सीता और द्वापर युग में द्रौपदी ने भी रखा था छठ का व्रत। रामायण की कहानी के अनुसार जब रावण का वध करके राम जी देवी सीता और लक्ष्मण जी के साथ अयोध्या वापस लौटे थे, तो माता सीता ने कार्तिक मास की शुक्ल पक्ष की षष्ठी को व्रत रखकर कुल की सुख-शांति के लिए षष्ठी देवी और सूर्यदेव की आराधना की थी."),

                _buildSectionTitle(
                    _isEnglish ? "Chhath Puja Method:" : "छठ पूजा की विधि :"),
                // Section for the Arghya offering instructions in English
                _buildBulletPoint(_isEnglish
                    ? "Arghya is offered to Sun God in the evening on Kartik Shukla Shashthi."
                    : "कार्तिक शुक्ल षष्ठी को शाम को सूर्य देव को अर्घ्य दिया जाता है."),
                _buildBulletPoint(_isEnglish
                    ? "To offer Arghya, a soup is prepared in a bamboo basket with fruits, Thekua, rice laddus etc."
                    : "अर्घ्य देने के लिए बांस की टोकरी में फलों, ठेकुआ, चावल के लड्डू वगैरह से सूप तैयार किया जाता है."),
                _buildBulletPoint(_isEnglish
                    ? "Arghya is offered to the setting sun."
                    : "डूबते हुए सूर्य को अर्घ्य दिया जाता है."),
                _buildBulletPoint(_isEnglish
                    ? "At the time of Arghya, water and milk are offered to Sun God."
                    : "अर्घ्य के समय सूर्य देव को जल और दूध चढ़ाया जाता है."),
                _buildBulletPoint(_isEnglish
                    ? "Chhathi Maiya is worshipped with a soup filled with Prasad."
                    : "प्रसाद से भरे सूप से छठी मैया की पूजा की जाती है."),
                _buildBulletPoint(_isEnglish
                    ? "At night, songs of Chhathi Maiya are sung and the Vrat Katha is heard."
                    : "रात में छठी मैया के गीत गाए जाते हैं और व्रत कथा सुनी जाती है."),
                _buildBulletPoint(_isEnglish
                    ? "The fast of Chhath Puja lasts for three days."
                    : "छठ पूजा का व्रत तीन दिनों तक चलता है."),

                _buildSectionTitle(_isEnglish
                    ? "Chhath Puja Materials:"
                    : "छठ पूजा की सामग्री :"),
                // Section for the items needed for Chhath Puja in English
                _buildBulletPoint(_isEnglish ? "New Saree" : "नई साड़ी"),
                _buildBulletPoint(
                    _isEnglish ? "Two bamboo baskets" : "बांस की दो टोकरियां"),
                _buildBulletPoint(_isEnglish
                    ? "Glass and tumbler for milk and water"
                    : "दूध और पानी के लिए गिलास और लोटा"),
                _buildBulletPoint(
                    _isEnglish ? "Thali and spoon" : "थाली और चम्मच"),
                _buildBulletPoint(_isEnglish
                    ? "Five sugarcane leaves"
                    : "पांच गन्ने के पत्ते"),
                _buildBulletPoint(_isEnglish
                    ? "Sweet potato and suthani"
                    : "शकरकंदी और सुथनी"),
                _buildBulletPoint(
                    _isEnglish ? "Betel leaf and betel nut" : "पान और सुपारी"),
                _buildBulletPoint(_isEnglish ? "Turmeric" : "हल्दी"),
                _buildBulletPoint(_isEnglish
                    ? "Green plant of radish and ginger"
                    : "मूली और अदरक का हरा पौधा"),
                _buildBulletPoint(
                    _isEnglish ? "Sweet lemon" : "मीठा डाभ नींबू"),

                _buildSectionTitle(
                    _isEnglish ? "Chhathi Mata Katha:" : "छठी माता कथा:"),
                // Section for the story in English
                _buildSectionContent(_isEnglish
                    ? "According to the story, there was a king named Priyavrat. His wife's name was Malini. But both of them had no children. The king and his wife were very sad about this. One day, with the desire to have a child, they got Putrayeshti Yagya performed by Maharishi Kashyap. As a result of this yagya, the queen became pregnant.\n\n"
                        "After nine months, when the time came to get the happiness of having a child, the queen got a dead son. The king was very sad to know about this. In the grief of not having a child, he decided to commit suicide. But as soon as the king tried to commit suicide, a beautiful goddess appeared in front of him.\n\n"
                        "The goddess told the king that 'I am Shashti Devi'. I give people the good fortune of having a son. Apart from this, I fulfill all the wishes of the person who worships me with true devotion. If you worship me, I will give you a son.' Impressed by the words of the goddess, the king followed her orders.\n\n"
                        "The king and his wife worshipped Goddess Shashti with full rituals on the day of Shashti Tithi of Kartik Shukla. As a result of this worship, they got a beautiful son. Since then, the holy festival of Chhath started being celebrated.\n\n"
                        "According to another story related to Chhath fast, when the Pandavas lost their entire kingdom in gambling, Draupadi kept the Chhath fast. Due to the effect of this fast, her wishes were fulfilled and the Pandavas got their kingdom back."
                    : "कथा के अनुसार प्रियव्रत नाम के एक राजा थे। उनकी पत्नी का नाम मालिनी था। परंतु दोनों की कोई संतान न थी। इस बात से राजा और उसकी पत्नी बहुत दुखी रहते थे। उन्होंने एक दिन संतान प्राप्ति की इच्छा से महर्षि कश्यप द्वारा पुत्रेष्टि यज्ञ करवाया। इस यज्ञ के फल स्वरूप रानी गर्भवती हो गई।\n\n"
                        "नौ महीने बाद संतान सुख को प्राप्त करने का समय आया तो रानी को मरा हुआ पुत्र प्राप्त हुआ। इस बात का पता चलने पर राजा को बहुत दुख हुआ। संतान शोक में वह आत्म हत्या का मन बना लिया। परंतु जैसे ही राजा ने आत्महत्या करने की कोशिश की उनके सामने एक सुंदर देवी प्रकट हुईं।\n\n"
                        "देवी ने राजा को कहा कि 'मैं षष्टी देवी हूं'। मैं लोगों को पुत्र का सौभाग्य प्रदान करती हूं। इसके अलावा जो सच्चे भाव से मेरी पूजा करता है मैं उसके सभी प्रकार के मनोरथ को पूर्ण कर देती हूं। यदि तुम मेरी पूजा करोगे तो मैं तुम्हें पुत्र रत्न प्रदान करूंगी।' देवी की बातों से प्रभावित होकर राजा ने उनकी आज्ञा का पालन किया।\n\n"
                        "राजा और उनकी पत्नी ने कार्तिक शुक्ल की षष्टी तिथि के दिन देवी षष्टी की पूरे विधि -विधान से पूजा की। इस पूजा के फलस्वरूप उन्हें एक सुंदर पुत्र की प्राप्ति हुई। तभी से छठ का पावन पर्व मनाया जाने लगा।\n\n"
                        "छठ व्रत के संदर्भ में एक अन्य कथा के अनुसार जब पांडव अपना सारा राजपाट जुए में हार गए, तब द्रौपदी ने छठ व्रत रखा। इस व्रत के प्रभाव से उसकी मनोकामनाएं पूरी हुईं तथा पांडवों को राजपाट वापस मिल गया।"),

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
