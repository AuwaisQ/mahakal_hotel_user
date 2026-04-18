import 'dart:async';
import 'package:flutter/material.dart';

import '../../controller/share_helper.dart';
import 'commanbannerwidget.dart';

class GangaurKatha extends StatefulWidget {
  const GangaurKatha({super.key});

  @override
  State<GangaurKatha> createState() => _GangaurKathaState();
}

class _GangaurKathaState extends State<GangaurKatha> {
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
  Color _themeColor = Colors.redAccent; // Default theme color

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
        ShareHelper.shareContent(context, "गणगौर व्रत कथा");
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
          _isEnglish ? 'Gangaur Katha' : "गणगौर कथा",
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
                  imagePath: 'assets/sahitya_images/ganguar katha.jpg',
                ),

                _buildSectionTitle(
                    _isEnglish ? "About Gangaur:" : "गणगौर के बारे में:"),
                _buildSectionContent(_isEnglish
                    ? "According to the Hindu calendar, Gangaur Teej is celebrated on the Tritiya Tithi of Shukla Paksha in the month of Chaitra. On this day, married women worship Gangaur Mata i.e. Mata Gauri with rituals to wish for a long life of their husband. The fast of Gangaur Teej is mainly celebrated in Madhya Pradesh and Rajasthan.\n\n"
                        "After Lord Shiva adopted Mata Parvati, Mata Parvati's family bid her farewell with Lord Shiva with great pomp and show. In this Gangaur festival celebrated in Rajasthan, Ishar is considered a symbol of Lord Shiva and Gangaur is considered a symbol of Mata Parvati. Married, newly married and unmarried women in Rajasthan worship Gangaur.\n\n"
                        "According to the Gangaur Katha, Goddess Parvati is the embodiment of devotion and with her long penance and devotion, she was able to marry Lord Shiva. During Gangaur, she visits her parents' house to seek blessings and celebrates with her parents, relatives and friends."
                    : "हिंदू पंचांग के अनुसार, चैत्र माह में शुक्ल पक्ष की तृतीया तिथि को गणगौर तीज मनाते हैं। इस दिन सुहागिनें पति की लंबी आयु की कामना के लिए गणगौर माता यानी माता गौरा की विधि-विधान से पूजा करती हैं। गणगौर तीज का व्रत मुख्य रूप में मध्य प्रदेश और राजस्थान में मनाया जाता है।\n\n"
                        "भगवान शिव द्वारा माता पार्वती को अपनाने के बाद गाजे-बाजे के सात माता पार्वती के परिवार ने भगवान शिव के साथ उनको विदा किया था. राजस्थान में मनाए जाने वाले इस गणगौर के त्यौहार में ईशर को भगवान शिव व गणगौर को माता पार्वती का प्रतीक माना जाता है. राजस्थान में विवाहित, नवविवाहित व अविवाहित महिलाएं गणगौर की पूजा करती हैं.\n\n"
                        "गणगौर कथा के अनुसार, देवी पार्वती भक्ति की प्रतिमूर्ति हैं और अपनी लंबी तपस्या और भक्ति से, वह भगवान शिव से विवाह करने में सक्षम थीं । गणगौर के दौरान, वह आशीर्वाद लेने के लिए अपने माता-पिता के घर जाती हैं और अपने माता-पिता, रिश्तेदारों और दोस्तों के साथ खुशियाँ मनाती हैं।"),

                _buildSectionTitle(_isEnglish
                    ? "Gangaur Vrat Puja Vidhi:"
                    : "गणगौर व्रत पूजा विधि:"),
                _buildSectionContent(_isEnglish
                    ? "On this day, idols of Lord Shiva and Mother Parvati are made from pure clay. Along with this, they are dressed in new clothes and Maa Parvati is adorned with sixteen adornments. After this, worship Shiva-Parvati duly. Offer flowers, garlands, vermilion, white sandalwood, Akshat etc. and offer sweet churma."
                    : "इस दिन शुद्ध मिट्टी से भगवान शिव और माता पार्वती की मूर्ति बनाई जाती है। इसके साथ ही इन्हें नए वस्त्र पहनाएं जाते हैं और मां पार्वती का सोलह श्रृंगार किया जाता है। इसके बाद शिव-पार्वती की विधिवत पूजा कर लें। फूल, माला, सिंदूर, सफेद चंदन, अक्षत आदि चढ़ाने के साथ मीठे चूरमे का भोग लगाएं।"),

                _buildSectionTitle(
                    _isEnglish ? "Puja material:" : "पूजा सामग्री:"),

                // Section for the worship items in English
                _buildBulletPoint(_isEnglish ? "Chowki" : "चौकी"),
                _buildBulletPoint(_isEnglish ? "Copper urn" : "तांबे का कलश"),
                _buildBulletPoint(_isEnglish ? "Black soil" : "काली मिट्टी"),
                _buildBulletPoint(_isEnglish
                    ? "Makeup items, silver ring"
                    : "श्रृंगार का सामान, चांदी की अंगुठी"),
                _buildBulletPoint(_isEnglish ? "Holi ash" : "होली की राख"),
                _buildBulletPoint(_isEnglish
                    ? "Cow dung or earthen pots"
                    : "गोबर या मिट्टी के कुंडे, गमले"),
                _buildBulletPoint(
                    _isEnglish ? "Pots, earthen lamp" : "मिट्टी का दीपक"),
                _buildBulletPoint(_isEnglish ? "Kumkum" : "कुमकुम"),
                _buildBulletPoint(_isEnglish ? "Turmeric" : "हल्दी"),
                _buildBulletPoint(
                    _isEnglish ? "Rice, bindi, mehndi" : "चावल, बिंदी, मेंहदी"),
                _buildBulletPoint(
                    _isEnglish ? "Gulal and abir" : "गुलाल और अबीर"),
                _buildBulletPoint(
                    _isEnglish ? "Kajal, ghee, flowers" : "काजल, घी, फूल"),
                _buildBulletPoint(_isEnglish
                    ? "Mango leaves, urn filled with water"
                    : "आम के पत्ते, जल से भरा हुआ कलश"),
                _buildBulletPoint(
                    _isEnglish ? "Coconut, betel nut" : "नारियल, सुपारी"),
                _buildBulletPoint(
                    _isEnglish ? "Gangaur clothes" : "गणगौर के कपड़े"),
                _buildBulletPoint(_isEnglish
                    ? "Wheat and bamboo basket"
                    : "गेंहू और बांस की टोकरी"),
                _buildBulletPoint(_isEnglish
                    ? "Chunri, cowrie shells, coins, puri, ghevar"
                    : "चुनरी, कौड़ी, सिक्के, पूड़ी, घेवर"),

                _buildSectionTitle(
                    _isEnglish ? "Gangaur story:" : "गणगौर कथा:"),

                // Section for the story in English
                _buildSectionContent(_isEnglish
                    ? "Knowing this, Maharishi Naradji praised Mother Parvati and the incident that happened due to her pativrata effect.\n\n"
                        "Once upon a time, Lord Shankar went for a tour with Mother Parvati and Naradji. While walking, they reached a village on Chaitra Shukla Tritiya. Hearing about their arrival, the poor women of the village immediately reached for worship with turmeric and rice in plates to welcome them.\n\n"
                        "Understanding their devotion, Parvati sprinkled all the Suhaag Ras on them. They returned after getting unshakable Suhaag. After some time, the women of the rich class arrived with many types of dishes decorated in gold and silver plates.\n\n"
                        "Seeing these women, Lord Shankar said to Mother Parvati: You have given all the Suhaag Ras to the women of the poor class. What will you give to them now?\n\n"
                        "Parvati ji said: Prannath! Those women have been given juice made from superficial substances. That is why their juice will remain with the dhoti. But I will give the Suhaag Ras of blood by cutting my finger to these women of the rich class, who will become fortunate like me.\n\n"
                        "When these women finished the worship, Parvati ji cut her finger and sprinkled that blood on them. Whoever got the blood sprinkled got the same kind of marital bliss. After this, Parvati ji took permission from her husband Lord Shankar and went to take a bath in the river.\n\n"
                        "After taking a bath, she made an idol of Lord Shiva out of sand and worshipped it. She offered food and circumambulated the idol and applied a tilak on her forehead after eating two grains of Prasad.\n\n"
                        "At that very moment, Lord Shiva appeared from that earthen Linga and gave a boon to Parvati: The woman who worships me and observes your fast on this day, her husband will live forever and will attain salvation. Lord Shiva gave this boon and disappeared.\n\n"
                        "Parvati ji took a lot of time doing all this. Parvati ji walked from the river bank and came to the place where she had left Lord Shankar and Narad ji. When Shiv ji asked the reason for coming late, Parvati ji said, my brother and sister-in-law met me on the river bank. They requested me to eat milk rice and stay. That is why I was late in coming.\n\n"
                        "Knowing this, the omniscient Lord Shiva also started walking towards the river bank in the greed of eating milk rice. Parvati silently meditated on Lord Shiva and prayed, 'O Lord, please save the honour of your exclusive maid.' Praying, Parvati started following him. They saw Maya's palace on the river bank far away. There, inside the palace, Shiva's brother-in-law and brother-in-law welcomed Shiva and Parvati.\n\n"
                        "They stayed there for two days, on the third day, when Parvati asked Shiva to leave, Lord Shiva was not ready to leave. Then Parvati got upset and left alone. In such a situation, Lord Shiva also had to go with Parvati. Narad ji also went with them. While walking, Lord Shiva said, 'I forgot my rosary at your maternal home.' When Parvati got ready to bring the rosary, Lord Shiva sent Narad ji instead of Parvati ji.\n\n"
                        "On reaching there, Narad ji did not see any palace. There was only forest far and wide. Suddenly lightning flashed and Naradji saw Lord Shiva's garland hanging on a tree. Naradji took off the garland and went to Lord Shiva and started telling him about the hardships of the journey.\n\n"
                        "Lord Shiva said smilingly: All this is Parvati's leela.\n\n"
                        "On this Parvati said: What am I worthy of? All this is your grace.\n\n"
                        "Knowing this, Maharishi Naradji praised Goddess Parvati and the incident that happened due to her devotion towards her husband."
                    : "ऐसा जानकर महर्षि नारदजी ने माता पार्वती तथा उनके पतिव्रत प्रभाव से उत्पन्न घटना की मुक्त कंठ से प्रंशसा की।\n\n"
                        "एक समय की बात है, भगवान शंकर, माता पार्वती जी एवं नारदजी के साथ भ्रमण हेतु चल दिए। वे चलते-चलते चैत्र शुक्ल तृतीया को एक गाँव में पहुँचे। उनका आगमन सुनकर ग्राम की निर्धन स्त्रियाँ उनके स्वागत के लिए थालियों में हल्दी एवं अक्षत लेकर पूजन हेतु तुरतं पहुँच गई।\n\n"
                        "पार्वती जी ने उनके पूजा भाव को समझकर सारा सुहाग रस उन पर छिड़क दिया। वे अटल सुहाग प्राप्त कर लौटीं। धनी वर्ग की स्त्रियाँ थोडी देर बाद अनेक प्रकार के पकवान सोने-चाँदी के थालो में सजाकर पहुँची।\n\n"
                        "इन स्त्रियाँ को देखकर भगवान् शंकर ने माता पार्वती से कहा: तुमने सारा सुहाग रस तो निर्धन वर्ग की स्त्रियों को ही दे दिया। अब इन्हें क्या दोगी?\n\n"
                        "पार्वतीजी बोलीं: प्राणनाथ! उन स्त्रियों को ऊपरी पदार्थो से बना रस दिया गया है। इसलिए उनका रस धोती से रहेगा। परन्तु मैं इन धनी वर्ग की स्त्रियों को अपनी अंगुली चीरकर रक्त का सुहाग रस दूँगी जो मेरे समान सौभाग्यवती हो जाएँगी।\n\n"
                        "जब इन स्त्रियों ने पूजन समाप्त कर लिया तब पार्वती जी ने अपनी अंगुली चीरकर उस रक्त को उनके ऊपर छिड़क दिया। जिस पर जैसे छीटें पड़े उसने वैसा ही सुहाग पा लिया। इसके बाद पार्वती जी अपने पति भगवान शंकर से आज्ञा लेकर नदी में स्नान करने चली गईं।\n\n"
                        "स्नान करने के पश्चात् बालू की शिवजी मूर्ति बनाकर पूजन किया। भोग लगाया तथा प्रदक्षिणा करके दो कणों का प्रसाद खाकर मस्तक पर टीका लगाया।\n\n"
                        "उसी समय उस पार्थिव लिंग से शिवजी प्रकट हुए तथा पार्वती को वरदान दिया: आज के दिन जो स्त्री मेरा पूजन और तुम्हारा व्रत करेगी उसका पति चिरंजीवी रहेगा तथा मोक्ष को प्राप्त होगा। भगवान शिव यह वरदान देकर अन्तर्धान हो गए।\n\n"
                        "इतना सब करते-करते पार्वती जी को काफी समय लग गया। पार्वतीजी नदी के तट से चलकर उस स्थान पर आई जहाँ पर भगवान शंकर व नारदजी को छोड़कर गई थीं। शिवजी ने विलम्ब से आने का कारण पूछा तो इस पर पार्वती जी बोली, मेरे भाई-भावज नदी किनारे मिल गए थे। उन्होने मुझसे दूध भात खाने तथा ठहरने का आग्रह किया। इसी कारण से आने में देर हो गई।\n\n"
                        "ऐसा जानकर अन्तर्यामी भगवान शंकर भी दूध भात खाने के लालच में नदी तट की ओर चल दिए। पार्वतीजी ने मौन भाव से भगवान शिवजी का ही ध्यान करके प्रार्थना की, भगवान आप अपनी इस अनन्य दासी की लाज रखिए। प्रार्थना करती हुई पार्वती जी उनके पीछे-पीछे चलने लगी। उन्हे दूर नदी तट पर माया का महल दिखाई दिया। वहाँ महल के अन्दर शिवजी के साले तथा सहलज ने शिव पार्वती का स्वागत किया।\n\n"
                        "वे दो दिन वहाँ रहे, तीसरे दिन पार्वती जी ने शिवजी से चलने के लिए कहा तो भगवान शिव चलने को तैयार न हुए। तब पार्वती जी रूठकर अकेली ही चल दी। ऐसी परिस्थिति में भगवान शिव को भी पार्वती के साथ चलना पड़ा। नारदजी भी साथ चल दिए। चलते-चलते भगवान शंकर बोले, मैं तुम्हारे मायके में अपनी माला भूल आया। माला लाने के लिए पार्वतीजी तैयार हुई तो भगवान ने पार्वतीजी को न भेजकर नारद जी को भेजा।\n\n"
                        "वहाँ पहुँचने पर नारद जी को कोई महल नजर नहीं आया। वहाँ दूर-दूर तक जंगल ही जंगल था। सहसा बिजली कौंधी, नारदजी को शिवजी की माला एक पेड पर टंगी दिखाई दी। नारदजी ने माला उतारी और शिवजी के पास पहुँच कर यात्रा कर कष्ट बताने लगे।\n\n"
                        "शिवजी हँसकर कहने लगे: यह सब पार्वती की ही लीला हैं।\n\n"
                        "इस पर पार्वती जी बोलीं: मैं किस योग्य हूँ। यह सब तो आपकी ही कृपा है।\n\n"
                        "ऐसा जानकर महर्षि नारदजी ने माता पार्वती तथा उनके पतिव्रत प्रभाव से उत्पन्न घटना की मुक्त कंठ से प्रंशसा की।"),

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
