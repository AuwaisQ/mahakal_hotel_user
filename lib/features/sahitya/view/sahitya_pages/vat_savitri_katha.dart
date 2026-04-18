import 'dart:async';
import 'package:flutter/material.dart';

import '../../controller/share_helper.dart';
import 'commanbannerwidget.dart';

class VatSavitriVrat extends StatefulWidget {
  const VatSavitriVrat({super.key});

  @override
  State<VatSavitriVrat> createState() => _VatSavitriVratState();
}

class _VatSavitriVratState extends State<VatSavitriVrat> {
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
        ShareHelper.shareContent(context, "वट सावित्री व्रत कथा");
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
          _isEnglish ? 'Rishi Panchmi Vrat' : "वट सावित्री व्रत",
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
                  imagePath: 'assets/sahitya_images/vat savitri vrat katha.jpg',
                ),

                _buildSectionTitle(_isEnglish
                    ? "Story of Vat Savitri:"
                    : "वट सावत्री की कहानी:"),
                // Section for the story in English
                _buildSectionContent(_isEnglish
                    ? "Vat Savitri Vrat is celebrated every year on the Amavasya Tithi of Krishna Paksha in the month of Jyeshtha. On this day, married women observe a fast for the long life of their husbands. It is believed that by worshipping with due rituals during Vat Savitri Vrat, one gets the full fruits of the worship.\n\n"
                        "According to the popular story of the worship of Vat Savitri Amavasya, Savitri was the daughter of Ashvapati, she had accepted Satyavan as her husband. Satyavan used to go to the forest to cut wood. Savitri used to go to the forest behind Satyavan after serving her blind parents-in-law.\n\n"
                        "One day Satyavan felt dizzy while cutting wood and he came down from the tree and sat down. At the same time, Yamraj came riding on a buffalo to take Satyavan's life. Savitri recognized him and said that you should not take the life of my Satyavan.\n\n"
                        "Yam refused, but she did not return. Pleased with Savitri's devotion to her husband, Yamraj blessed her blind parents-in-law with eyesight and blessed Savitri with hundred sons and released Satyavan. It was under this Banyan tree that Savitri brought her dead husband back to life with her devotion to her husband. Since then, this fast is known as 'Vat Savitri Vrat'."
                    : "वट सावित्री व्रत प्रत्येक वर्ष ज्येष्ठ मास में कृष्ण पक्ष की अमावस्या तिथि को मनाया जाता है। इस दिन सुहागिनें अपने पति की लंबी आयु के लिए व्रत रखती हैं। मान्यता है कि वट सावित्री व्रत के दौरान विधि-विधान से पूजा करने से पूजा का फल पूरा मिलता है।\n\n"
                        "वट सावित्री अमावस्या के पूजन की प्रचलित कहानी के अनुसार सावित्री अश्वपति की कन्या थी, उसने सत्यवान को पति रूप में स्वीकार किया था। सत्यवान लकड़ियां काटने के लिए जंगल में जाया करता था। सावित्री अपने अंधे सास-ससुर की सेवा करके सत्यवान के पीछे जंगल में चली जाती थी।\n\n"
                        "एक दिन सत्यवान को लकड़ियां काटते समय चक्कर आ गया और वह पेड़ से उतरकर नीचे बैठ गया। उसी समय भैंसे पर सवार होकर यमराज सत्यवान के प्राण लेने आए। सावित्री ने उन्हें पहचाना और सावित्री ने कहा कि आप मेरे सत्यवान के प्राण न लें।\n\n"
                        "यम ने मना किया, मगर वह वापस नहीं लौटी। सावित्री के पतिव्रत धर्म से प्रसन्न होकर यमराज ने वरदान के रूप में अंधे सास-ससुर की सेवा में आंखें दीं और सावित्री को सौ पुत्र होने का आशीर्वाद दिया और सत्यवान को छोड़ दिया। इसी वट वृक्ष के नीचे सावित्री ने अपने पतिव्रत धर्म से मृत पति को पुन: जीवित कराया था। तभी से यह व्रत ‘वट सावित्री व्रत’ के नाम से जाना जाता है।"),

                _buildSectionTitle(_isEnglish
                    ? "Vat Savitri Vrat Puja Vidhi:"
                    : "वट सावित्री व्रत की पूजा विधि:"),
                _buildSectionContent(_isEnglish
                    ? "On the day of Vat Savitri, the devotees should wake up early in the morning and take bath and meditate. After this, after reaching near the Banyan tree, first of all, the picture or statue of Satyavan, Savitri should be placed at the root of the Banyan tree. After this, incense, lamps should be lit and then flowers, rice etc. should be offered."
                    : "वट सावित्री के दिन सुबह जल्दी उठकर व्रतियों को स्नान-ध्यान करना चाहिए। इसके बाद वट वृक्ष के पास पहुंचकर सबसे पहले सत्यवान, सावित्री की तस्वीर या प्रतिमा वट वृक्ष की जड़ पर स्थापित करनी चाहिए। इसके बाद धूप, दीप जलाना चाहिए और उसके बाद फूल, अक्षत आदि आर्पित करना चाहिए।"),

                _buildSectionTitle(
                    _isEnglish ? "Puja Samagri:" : "पूजा सामग्री है-"),
                // Section for the worship items in English
                _buildBulletPoint(_isEnglish ? "Banyan fruit" : "बरगद का फल"),
                _buildBulletPoint(_isEnglish
                    ? "Idol or picture of Savitri and Satyavan"
                    : "सावित्री और सत्यवान की मूर्ति या तस्वीर"),
                _buildBulletPoint(
                    _isEnglish ? "Soaked black gram" : "भिगोया हुआ काला चना"),
                _buildBulletPoint(_isEnglish ? "Kalawa" : "कलावा"),
                _buildBulletPoint(
                    _isEnglish ? "White raw thread" : "सफेद कच्चा सूत"),
                _buildBulletPoint(_isEnglish ? "Rakshasutra" : "रक्षासूत्र"),
                _buildBulletPoint(_isEnglish ? "Bamboo fan" : "बांस का पंखा"),
                _buildBulletPoint(
                    _isEnglish ? "1.25 meter cloth" : "सवा मीटर का कपड़ा"),
                _buildBulletPoint(
                    _isEnglish ? "Red and yellow flowers" : "लाल और पीले फूल"),
                _buildBulletPoint(_isEnglish
                    ? "Sweets, batasha, fruit, incense, lamp, agarbatti"
                    : "मिठाई, बताशा, फल, धूप, दीपक, अगरबत्ती"),
                _buildBulletPoint(_isEnglish
                    ? "Earthen lamp, vermilion, akshat, roli"
                    : "मिट्टी का दीया, सिंदूर, अक्षत, रोली"),
                _buildBulletPoint(_isEnglish
                    ? "1.25 meter cloth, betel leaf, betel nut, coconut"
                    : "सवा मीटर का कपड़ा, पान का पत्ता, सुपारी, नारियल!"),

                _buildSectionTitle(_isEnglish
                    ? "Vat Savitri Vrat Katha:"
                    : "वट सावित्री व्रत कथा:"),
                // Section for the story in English
                _buildSectionContent(_isEnglish
                    ? "There was a king named Ashvapati in Bhadra country. King Ashvapati of Bhadra country had no children.\n\n"
                        "He offered one lakh oblations daily with chanting of mantras to get a child. This sequence continued for eighteen years.\n\n"
                        "After this, Savitri Devi appeared and blessed him that: Rajan, you will have a radiant daughter. The girl was named Savitri because she was born by the grace of Savitri Devi.\n\n"
                        "The girl grew up to be very beautiful. Savitri's father was sad because he could not find a suitable groom. He sent the daughter to look for a groom herself.\n\n"
                        "Savitri started wandering in Tapovan. King Dyumatsena of Salva country lived there because someone had snatched his kingdom. Seeing his son Satyavan, Savitri chose him as her husband.\n\n"
                        "When Rishiraj Narad came to know about this, he went to King Ashwapati and said, O King! What are you doing? Satyavan is virtuous, virtuous and strong too, but his age is very short, he is short-lived. He will die after one year.\n\n"
                        "On hearing Rishiraj Narad's words, King Ashwapati got deeply worried. When Savitri asked him the reason, the king said, daughter, the prince you have chosen as your groom is short-lived. You should make someone else your life partner.\n\n"
                        "On this Savitri said that father, Aryan girls choose their husband only once, the king gives orders only once and the Pandit takes a vow only once and the Kanyadan is also done only once.\n\n"
                        "Savitri started insisting and said that I will marry Satyavan only. King Ashwapati married Savitri to Satyavan.\n\n"
                        "Savitri started serving her in-laws as soon as she reached her in-laws' house. Time kept passing. Narad Muni had already told Savitri about the day of Satyavan's death. As that day started coming closer, Savitri started getting impatient. She started fasting three days in advance. She worshipped the ancestors on the fixed date told by Narad Muni.\n\n"
                        "Like every day, Satyavan went to the forest to cut wood that day too, Savitri also went with him. After reaching the forest, Satyavan climbed a tree to cut wood. Then he started having a severe pain in his head, troubled by the pain, Satyavan came down from the tree. Savitri understood her future.\n\n"
                        "Keeping Satyavan's head in her lap, Savitri started caressing Satyavan's head. Just then Yamraj was seen coming there. Yamraj started taking Satyavan with him. Savitri also followed him.\n\n"
                        "Yamraj tried to explain to Savitri that this is the law of destiny. But Savitri did not agree.\n\n"
                        "Seeing Savitri's loyalty and devotion towards her husband, Yamraj said to Savitri that O Goddess, you are blessed. You can ask for any boon from me."
                    : "भद्र देश के एक राजा थे, जिनका नाम अश्वपति था। भद्र देश के राजा अश्वपति के कोई संतान न थी।\n\n"
                        "उन्होंने संतान की प्राप्ति के लिए मंत्रोच्चारण के साथ प्रतिदिन एक लाख आहुतियाँ दीं। अठारह वर्षों तक यह क्रम जारी रहा।\n\n"
                        "इसके बाद सावित्री देवी ने प्रकट होकर वर दिया कि: राजन, तुझे एक तेजस्वी कन्या पैदा होगी। सावित्री देवी की कृपा से जन्म लेने के कारण से कन्या का नाम सावित्री रखा गया।\n\n"
                        "कन्या बड़ी होकर बेहद रूपवान हुई। योग्य वर न मिलने की वजह से सावित्री के पिता दुःखी थे। उन्होंने कन्या को स्वयं वर तलाशने भेजा।\n\n"
                        "सावित्री तपोवन में भटकने लगी। वहाँ साल्व देश के राजा द्युमत्सेन रहते थे, क्योंकि उनका राज्य किसी ने छीन लिया था। उनके पुत्र सत्यवान को देखकर सावित्री ने पति के रूप में उनका वरण किया।\n\n"
                        "ऋषिराज नारद को जब यह बात पता चली तो वह राजा अश्वपति के पास पहुंचे और कहा कि हे राजन! यह क्या कर रहे हैं आप? सत्यवान गुणवान हैं, धर्मात्मा हैं और बलवान भी हैं, पर उसकी आयु बहुत छोटी है, वह अल्पायु हैं। एक वर्ष के बाद ही उसकी मृत्यु हो जाएगी।\n\n"
                        "ऋषिराज नारद की बात सुनकर राजा अश्वपति घोर चिंता में डूब गए। सावित्री ने उनसे कारण पूछा, तो राजा ने कहा, पुत्र ी, तुमने जिस राजकुमार को अपने वर के रूप में चुना है वह अल्पायु हैं। तुम्हे किसी और को अपना जीवन साथी बनाना चाहिए।\n\n"
                        "इस पर सावित्री ने कहा कि पिताजी, आर्य कन्याएं अपने पति का एक बार ही वरण करती हैं, राजा एक बार ही आज्ञा देता है और पंडित एक बार ही प्रतिज्ञा करते हैं और कन्यादान भी एक ही बार किया जाता है।\n\n"
                        "सावित्री हठ करने लगीं और बोलीं मैं सत्यवान से ही विवाह करूंगी। राजा अश्वपति ने सावित्री का विवाह सत्यवान से कर दिया।\n\n"
                        "सावित्री अपने ससुराल पहुंचते ही सास-ससुर की सेवा करने लगी। समय बीतता चला गया। नारद मुनि ने सावित्री को पहले ही सत्यवान की मृत्यु के दिन के बारे में बता दिया था। वह दिन जैसे-जैसे करीब आने लगा, सावित्री अधीर होने लगीं। उन्होंने तीन दिन पहले से ही उपवास शुरू कर दिया। नारद मुनि द्वारा कथित निश्चित तिथि पर पितरों का पूजन किया।\n\n"
                        "हर दिन की तरह सत्यवान उस दिन भी लकड़ी काटने जंगल चले गये साथ में सावित्री भी गईं। जंगल में पहुंचकर सत्यवान लकड़ी काटने के लिए एक पेड़ पर चढ़ गये। तभी उसके सिर में तेज दर्द होने लगा, दर्द से व्याकुल सत्यवान पेड़ से नीचे उतर गये। सावित्री अपना भविष्य समझ गईं।\n\n"
                        "सत्यवान के सिर को गोद में रखकर सावित्री सत्यवान का सिर सहलाने लगीं। तभी वहां यमराज आते दिखे। यमराज अपने साथ सत्यवान को ले जाने लगे। सावित्री भी उनके पीछे-पीछे चल पड़ीं।\n\n"
                        "यमराज ने सावित्री को समझाने की कोशिश की कि यही विधि का विधान है। लेकिन सावित्री नहीं मानी।\n\n"
                        "सावित्री की निष्ठा और पतिपरायणता को देख कर यमराज ने सावित्री से कहा कि हे देवी, तुम धन्य हो। तुम मुझसे कोई भी वरदान मांगो।"),

                _buildSectionNumber(
                    _isEnglish ? 1 : 1,
                    _isEnglish
                        ? "Savitri said that my father-in-law and mother-in-law are forest dwellers and blind, please give them divine light. Yamraj said that it will happen. Now go back."
                        : "सावित्री ने कहा कि मेरे सास-ससुर वनवासी और अंधे हैं, उन्हें आप दिव्य ज्योति प्रदान करें। यमराज ने कहा ऐसा ही होगा। जाओ अब लौट जाओ।"),
                _buildSectionContent(_isEnglish
                    ? "But Savitri kept following her husband Satyavan. Yamraj said Goddess you go back. Savitri said Lord, I have no problem in following my husband. It is my duty to follow my husband. Hearing this, he again asked her to ask for another boon."
                    : "लेकिन सावित्री अपने पति सत्यवान के पीछे-पीछे चलती रहीं। यमराज ने कहा देवी तुम वापस जाओ। सावित्री ने कहा भगवन मुझे अपने पतिदेव के पीछे-पीछे चलने में कोई परेशानी नहीं है। पति के पीछे चलना मेरा कर्तव्य है। यह सुनकर उन्होने फिर से उसे एक और वर मांगने के लिए कहा।"),

                _buildSectionNumber(
                    _isEnglish ? 2 : 2,
                    _isEnglish
                        ? "Savitri said that our father-in-law's kingdom has been taken away, please give it back to him."
                        : "सावित्री बोलीं हमारे ससुर का राज्य छिन गया है, उसे पुन: वापस दिला दें। यमराज ने सावित्री को यह वरदान भी दे दिया और कहा अब तुम लौट जाओ। लेकिन सावित्री पीछे-पीछे चलती रहीं।"),
                _buildSectionContent(_isEnglish
                    ? "Yamraj gave this boon to Savitri and said that now you go back. But Savitri kept following him. Yamraj asked Savitri to ask for the third boon."
                    : "यमराज ने सावित्री को तीसरा वरदान मांगने को कहा।"),

                _buildSectionNumber(
                    _isEnglish ? 3 : 3,
                    _isEnglish
                        ? "On this, Savitri asked for the boon of 100 children and good fortune. Yamraj gave this boon to Savitri as well."
                        : "इस पर सावित्री ने 100 संतानों और सौभाग्य का वरदान मांगा। यमराज ने इसका वरदान भी सावित्री को दे दिया।"),
                _buildSectionContent(_isEnglish
                    ? "Savitri told Yamraj that Prabhu, I am a faithful wife and you have blessed me with a son. Hearing this, Yamraj had to let Satyavan's life go. Yamraj disappeared and Savitri came to the same banyan tree where her husband's dead body was lying.\n\n"
                        "Satyavan became alive and both of them happily started walking towards their kingdom. When both of them reached home, they saw that their parents had attained divine light. In this way Savitri and Satyavan enjoyed the pleasures of the kingdom for a long time.\n\n"
                        "So, in keeping with the example of the devoted Savitri, first worship your in-laws and then start other rituals. By observing Vat Savitri Vrat and listening to this story, any kind of danger that may have come in the married life of the fasting person or in the life of the life partner is averted."
                    : "सावित्री ने यमराज से कहा कि प्रभु मैं एक पतिव्रता पत्नी हूं और आपने मुझे पुत्रवती होने का आशीर्वाद दिया है। यह सुनकर यमराज को सत्यवान के प्राण छोड़ने पड़े। यमराज अंतध्यान हो गए और सावित्री उसी वट वृक्ष के पास आ गई जहां उसके पति का मृत शरीर पड़ा था।\n\n"
                        "सत्यवान जीवंत हो गया और दोनों खुशी-खुशी अपने राज्य की ओर चल पड़े। दोनों जब घर पहुंचे तो देखा कि माता-पिता को दिव्य ज्योति प्राप्त हो गई है। इस प्रकार सावित्री-सत्यवान चिरकाल तक राज्य सुख भोगते रहे।\n\n"
                        "अतः पतिव्रता सावित्री के अनुरूप ही, प्रथम अपने सास-ससुर का उचित पूजन करने के साथ ही अन्य विधियों को प्रारंभ करें। वट सावित्री व्रत करने और इस कथा को सुनने से उपवासक के वैवाहिक जीवन या जीवन साथी की आयु पर किसी प्रकार का कोई संकट आया भी हो तो वो टल जाता है।"),

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

  Widget _buildSectionNumber(int index, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Text(
        "$index) $content", // Adding index number at the beginning
        style: TextStyle(
          fontSize: _textScaleFactor,
          color: _isBlackBackground ? Colors.white : Colors.black,
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
