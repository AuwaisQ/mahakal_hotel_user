import 'dart:async';

import 'package:flutter/material.dart';

import '../../controller/share_helper.dart';
import 'commanbannerwidget.dart';

class HariyaliTeej extends StatefulWidget {
  const HariyaliTeej({super.key});

  @override
  State<HariyaliTeej> createState() => _HariyaliTeejState();
}

class _HariyaliTeejState extends State<HariyaliTeej> {
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
  Color _themeColor = Colors.teal; // Default theme color

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
        ShareHelper.shareContent(context, "हरियाली तीज व्रत कथा");
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
          _isEnglish ? 'Hariyali Teej Vrat' : "हरियाली तीज व्रत",
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
                      'assets/sahitya_images/Hariyali Teej Vrat Katha.jpg',
                ),

                _buildSectionTitle(_isEnglish
                    ? "About Hariyali Teej:"
                    : "हरियाली तीज के बारे में:"),
                // Section for Hariyali Teej information in English
                _buildSectionContent(_isEnglish
                    ? "Hariyali Teej is observed on the third day of Shukla Paksha of Shravan month. On this day, there is a ritual of Nirjala fasting and worship of Shiva-Parvati ji. According to the belief, Lord Shiva and Goddess Parvati were reunited on this day. It is also known as Chhoti Teej or Shravan Teej. This festival is celebrated to commemorate the reunion of Lord Shiva and his beloved wife Goddess Parvati. On the occasion of this holy festival, women offer Belpatra, flowers, fruits and turmeric-coated rice to Goddess Parvati. They try to seek the blessings of the goddess to ensure the safety and well-being of their husbands.\n\n"
                        "Hariyali Teej (literally meaning 'green teej'), also known as Sindhara Teej, Choti Teej, Shravan Teej or Sawan Teej, falls on the third day of the new moon in the month of Shravan, marking the day when Shiva accepted Goddess Parvati's wish to marry him, which is celebrated by married women!\n\n"
                        "This festival symbolizes Parvati's unwavering devotion to her husband. When Indian women seek her blessings during Teej, they do so as a means to secure a strong marriage and a good husband. Teej is not only centered around a strong marriage, but it also focuses on the happiness and health of children.\n\n"
                        "On this day, unmarried girls observe a fast to get their desired groom and married women worship Bholenath to wish for unbroken good fortune and a long life for their husbands. Hence the festival of Hariyali Teej is celebrated."
                    : "हरियाली तीज श्रावण माह के शुक्ल पक्ष की तृतीया को रखा जाता है। इस दिन निर्जला उपवास और शिव-पार्वती जी की पूजा का विधान है। मान्यता के अनुसार इसी दिन भगवान शिव और देवी पार्वती के पुनर्मिलन हुआ था। इसे छोटी तीज या श्रवण तीज के नाम से भी जाना जाता है। यह त्योहार भगवान शिव और उनकी प्रिय पत्नी देवी पार्वती के पुनर्मिलन के उपलक्ष्य में मनाया जाता है। इस पवित्र त्योहार के अवसर पर, महिलाएं देवी पार्वती को बेलपत्र, फूल, फल और हल्दी लगे चावल चढ़ाती हैं। वे अपने पति की सुरक्षा और भलाई सुनिश्चित करने के लिए देवी का आशीर्वाद लेने की कोशिश करती हैं।\n\n"
                        "हरियाली तीज (शाब्दिक अर्थ 'हरी तीज'), जिसे सिंधारा तीज, छोटी तीज, श्रावण तीज या सावन तीज के नाम से भी जाना जाता है, श्रावण मास की अमावस्या के तीसरे दिन आती है, यह उस दिन को चिह्नित करता है जब शिव ने देवी पार्वती की उनसे विवाह करने की इच्छा को स्वीकार किया था, जिसे विवाहित महिलाएं मनाती हैं!\n\n"
                        "यह त्यौहार पार्वती के अपने पति के प्रति अटूट समर्पण का प्रतीक है। जब भारतीय महिलाएं तीज के दौरान उनका आशीर्वाद लेती हैं, तो वे ऐसा एक मजबूत विवाह और अच्छे पति की प्राप्ति के साधन के रूप में करती हैं। तीज न केवल एक मजबूत विवाह के इर्द-गिर्द केंद्रित है, बल्कि यह बच्चों की खुशी और स्वास्थ्य पर भी केंद्रित है।\n\n"
                        "इस दिन पर कुंवारी लड़कियां मनचाहे वर की प्राप्ति के लिए व्रत करती हैं और सुहागिन महिलाएं अखण्ड सौभाग्य और पति की लंबी उम्र की कामना के लिए भोलेनाथ की आराधना करती हैं। इसलिए हरियाली तीज का त्योहार मनाया जाता है।"),

                _buildSectionTitle(_isEnglish
                    ? "Hariyali Teej Puja Vidhi and Materials:"
                    : "हरियाली तीज की पूजा विधि और सामग्री :"),
                // Section for Hariyali Teej celebration instructions in English
                _buildBulletPoint(_isEnglish
                    ? "On the day of Hariyali Teej, wake up in the morning, take a bath and wear clean clothes."
                    : "हरियाली तीज के दिन सुबह उठकर स्नान करें और साफ कपड़े पहनें."),
                _buildBulletPoint(_isEnglish
                    ? "Offer water to the Sun God."
                    : "सूर्य देव को जल अर्पित करें."),
                _buildBulletPoint(_isEnglish
                    ? "Spread a red or yellow cloth on the pedestal."
                    : "पीठ पर लाल या पीला कपड़ा बिछाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Install the idol of Lord Shiva and Mother Parvati made of clay."
                    : "मिट्टी से बनी भगवान शिव और माता पार्वती की मूर्ति स्थापित करें."),
                _buildBulletPoint(_isEnglish
                    ? "Do sixteen adornments to Mother Parvati."
                    : "माता पार्वती को सोलह श्रृंगार करें."),
                _buildBulletPoint(_isEnglish
                    ? "Put Gangajal, roli, rice, some coins, and mango leaves in the Kalash."
                    : "कलश में गंगाजल, रोली, चावल, कुछ सिक्के और आम के पत्ते डालें."),
                _buildBulletPoint(_isEnglish
                    ? "Bath the idol with Gangajal."
                    : "मूर्ति का गंगाजल से अभिषेक करें."),
                _buildBulletPoint(_isEnglish
                    ? "Decorate the idol with vermilion, roli, sandalwood, and flowers."
                    : "मूर्ति को सिंदूर, रोली, चंदन और फूलों से सजाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Light a lamp and incense."
                    : "दीपक और अगरबत्ती जलाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Offer flowers, akshat, and naivedya while chanting mantras."
                    : "फूल, अक्षत और नैवेद्य अर्पित करें और मंत्रों का जाप करें."),
                _buildBulletPoint(_isEnglish
                    ? "Listen to the Hariyali Teej fast story."
                    : "हरियाली तीज व्रत कथा सुनें."),
                _buildBulletPoint(_isEnglish
                    ? "Perambulate the idol."
                    : "मूर्ति की परिक्रमा करें."),
                _buildBulletPoint(_isEnglish
                    ? "Married women should apply vermilion and worship."
                    : "सुहागिन महिलाएं सिंदूर लगाएं और पूजा करें."),
                _buildBulletPoint(_isEnglish
                    ? "Give prasad to everyone after the puja."
                    : "पूजा के बाद सभी को प्रसाद दें."),
                _buildSectionContent(_isEnglish
                    ? "Yellow cloth, raw cotton, new clothes, banana leaves, aak flower, belpatra, dhatura, shami leaves, janeu, pooja chowki, copper and brass kalash, coconut with husk, betel nut, kalash, akshat, durva grass, ghee, camphor, abir-gulal, incense, coconut, sandalwood, cow milk, Gangajal, panchamrit curd, sugar candy, honey, five types of fruits, sweets, dakshina, Shiv Chalisa,!"
                    : "पीला वस्त्र, कच्चा सूता, नए वस्त्र, केले के पत्ते, आक का फूल, बेलपत्र, धतूरा, शमी के पत्ते, जनेऊ, पूजा की चौकी, तांबे और पीतल का कलश, जटा वाला नारियल, सुपारी, कलश, अक्षत, दूर्वा घास, घी, कपूर, अबीर-गुलाल, धूप, श्रीफल, चंदन, गाय का दूध, गंगाजल, पंचामृत दही, मिश्री, शहद, पांच प्रकार के फल, मिठाई, दक्षिणा, शिव चालीसा,!"),

                _buildSectionTitle(
                    _isEnglish ? "Hariyali Teej Katha:" : "हरियाली तीज कथा:"),
                // Section for the story of Lord Shiva and Goddess Parvati in English
                _buildSectionContent(_isEnglish
                    ? "It is believed that this story was narrated by Lord Shiva to Parvati ji to remind her about her previous birth. The story is something like this-\n\n"
                        "Shiva ji says: O Parvati. A long time ago you did severe penance on the Himalayas to get me as your husband. During this time you gave up food and water and spent the day chewing dry leaves. You did continuous penance without caring about the weather. Seeing your condition, your father was very sad and angry. In such a situation, Narad ji came to your house.\n\n"
                        "When your father asked him the reason for his arrival, Naradji said – 'O Giriraj! I have come here on the orders of Lord Vishnu. Pleased with the severe penance of your daughter, he wants to marry her. I want to know your opinion about this.' On hearing Naradji's words, the mountain king said with great happiness - O Naradji. If Lord Vishnu himself wants to marry my daughter, then nothing can be greater than this. I am ready for this marriage.'\n\n"
                        "Shiva says to Parvati ji, 'After getting your father's approval, Naradji went to Vishnuji and told him this good news. But when you came to know about this marriage, you felt very sad. You had accepted me, i.e. Kailashpati Shiva, as your husband in your heart.\n\n"
                        "You told your friend about your troubled mind. Your friend suggested that she will take you to a dense forest and hide you there and you should stay there and meditate to attain Shiva. After this, your father became very worried and sad on not finding you at home. He started thinking that what will happen if Vishnuji comes with the marriage procession and you are not found at home. He searched the entire world in search of you but you were not found.\n\n"
                        "You were engrossed in my worship inside a cave in the forest. On Bhadrapad Tritiya Shukla, you made a Shivling from sand and worshipped me and I was pleased with you and fulfilled your wish. After this you told your father that 'Father, I have spent a long time of my life in the penance of Lord Shiva. And Lord Shiva has also accepted me, pleased with my penance. Now I will come with you only on one condition that you will marry me only with Lord Shiva.' The mountain king accepted your wish and took you back home. After some time he married us with full rituals.\n\n"
                        "Lord Shiva then said – 'O Parvati! The fast that you did by worshipping me on Bhadrapada Shukla Tritiya, was the result of which our marriage became possible. The importance of this fast is that I give the desired result to every woman who observes this fast with complete devotion. Lord Shiva told Parvati that any woman who observes this fast with complete devotion will get everlasting marital bliss like you."
                    : "माना जाता है कि इस कथा को भगवान शिव ने पार्वती जी को उनके पूर्व जन्म के बारे में याद दिलाने के लिए सुनाया था। कथा कुछ इस प्रकार है–\n\n"
                        "शिवजी कहते हैं: हे पार्वती। बहुत समय पहले तुमने हिमालय पर मुझे वर के रूप में पाने के लिए घोर तप किया था। इस दौरान तुमने अन्न-जल त्याग कर सूखे पत्ते चबाकर दिन व्यतीत किया था। मौसम की परवाह किए बिना तुमने निरंतर तप किया। तुम्हारी इस स्थिति को देखकर तुम्हारे पिता बहुत दुःखी और नाराज़ थे। ऐसी स्थिति में नारदजी तुम्हारे घर पधारे।\n\n"
                        "जब तुम्हारे पिता ने उनसे आगमन का कारण पूछा तो नारदजी बोले – 'हे गिरिराज! मैं भगवान् विष्णु के भेजने पर यहाँ आया हूँ। आपकी कन्या की घोर तपस्या से प्रसन्न होकर वह उससे विवाह करना चाहते हैं। इस बारे में मैं आपकी राय जानना चाहता हूँ।' नारदजी की बात सुनकर पर्वतराज अति प्रसन्नता के साथ बोले- हे नारदजी। यदि स्वयं भगवान विष्णु मेरी कन्या से विवाह करना चाहते हैं तो इससे बड़ी कोई बात नहीं हो सकती। मैं इस विवाह के लिए तैयार हूं।\n\n"
                        "शिवजी पार्वती जी से कहते हैं, 'तुम्हारे पिता की स्वीकृति पाकर नारदजी, विष्णुजी के पास गए और यह शुभ समाचार सुनाया। लेकिन जब तुम्हें इस विवाह के बारे में पता चला तो तुम्हें बहुत दुख हुआ। तुम मुझे यानि कैलाशपति शिव को मन से अपना पति मान चुकी थी।\n\n"
                        "तुमने अपने व्याकुल मन की बात अपनी सहेली को बताई। तुम्हारी सहेली ने सुझाव दिया कि वह तुम्हें एक घनघोर वन में ले जाकर छुपा देगी और वहां रहकर तुम शिवजी को प्राप्त करने की साधना करना। इसके बाद तुम्हारे पिता तुम्हें घर में न पाकर बड़े चिंतित और दुःखी हुए। वह सोचने लगे कि यदि विष्णुजी बारात लेकर आ गए और तुम घर पर ना मिली तो क्या होगा। उन्होंने तुम्हारी खोज में धरती-पाताल एक करवा दिए लेकिन तुम ना मिली।"),

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
