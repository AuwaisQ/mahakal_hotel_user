import 'dart:async';
import 'package:flutter/material.dart';

import '../../controller/share_helper.dart';
import 'commanbannerwidget.dart';

class SheetlaSaptmi extends StatefulWidget {
  const SheetlaSaptmi({super.key});

  @override
  State<SheetlaSaptmi> createState() => _SheetlaSaptmiState();
}

class _SheetlaSaptmiState extends State<SheetlaSaptmi> {
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
        ShareHelper.shareContent(context, "शीतला सप्तमी व्रत कथा");
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
          _isEnglish ? 'Sheetla Saptami Vrat' : "शीतला सप्तमी व्रत",
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
                      'assets/sahitya_images/Silisatam_Sheetala Saptami  Vrat Katha.jpg',
                ),
                _buildSectionTitle(_isEnglish
                    ? "About Sheetla Saptami:"
                    : "शीतला सप्तमी के बारे में:"),
                _buildSectionContent(_isEnglish
                    ? "In Hinduism, Sheetla Saptami Vrat is considered very auspicious. It is believed that by keeping this fast, the health of children always remains good. Let us know the holy story related to this festival.\n\n"
                        "On the day of Basoda festival i.e. Sheetla Saptami or Ashtami, Sheetla Mata is worshipped and the story is read. According to folk legends, Basoda is worshipped to please Mother Sheetla. According to this story, once in a village, when the villagers were worshipping Sheetla Mata, the villagers offered heavy food to the mother as prasad.\n\n"
                        "When the mouth of Mother Bhavani, the embodiment of coolness, got burnt by the hot food, she got angry and with her wrathful glance, she set the entire village on fire. Only the house of an old woman was left safe.\n\n"
                        "When the villagers went and asked the old woman about the house not burning, the old woman told that she fed heavy food to Mother Sheetla and that she cooked food at night and fed cold and stale food to the mother. Due to which the mother was pleased and saved the old woman's house from burning.\n\n"
                        "On hearing the old woman's words, the villagers apologized to Mother Sheetla and fed her stale food on the seventh day after Rangpanchami and performed Basoda Puja of the mother. This is the only fast among Hindu fasts in which stale food is eaten.\n\n"
                        "By worshipping Mother Sheetla on this day, the mother blesses her devotees with wealth and grains, gives long life to their children and keeps every devotee away from natural calamities.\n\n"
                    : "हिंदू धर्म में शीतला सप्तमी के व्रत की काफी महिमा बताई जाती है। मान्यता है इस व्रत को रखने से संतानों की सेहत हमेशा अच्छी रहती हैं। चलिए जानते हैं इस पर्व से जुड़ी पावन कथा।\n\n"
                        "बसौड़ा पर्व यानी शीतला सप्तमी या अष्टमी के दिन शीतला माता का पूजन तथा कथा का वाचन किया जाता है लोक किंवदंतियों के अनुसार बसौड़ा की पूजा माता शीतला को प्रसन्न करने के लिए की जाती है। इस कथा के अनुसार कि एक बार किसी गांव में गांववासी शीतला माता की पूजा-अर्चना कर रहे थे तो मां को गांववासियों ने गरिष्ठ भोजन प्रसादस्वरूप चढ़ा दिया।\n\n"
                        "शीतलता की प्रतिमूर्ति मां भवानी का गर्म भोजन से मुंह जल गया तो वे नाराज हो गईं और उन्होंने कोपदृष्टि से संपूर्ण गांव में आग लगा दी। बस केवल एक बुढि़या का घर सुरक्षित बचा हुआ था।\n\n"
                        "गांव वालों ने जाकर उस बुढ़िया से घर न जलने के बारे में पूछा तो बुढि़या ने मां शीतला को गरिष्ठ भोजन खिलाने वाली बात कही और कहा कि उन्होंने रात को ही भोजन बनाकर मां को भोग में ठंडा-बासी भोजन खिलाया। जिससे मां ने प्रसन्न होकर बुढ़िया का घर जलने से बचा लिया।\n\n"
                        "बुढ़िया की बात सुनकर गांव वालों ने मां शीतला से क्षमा मांगी और रंगपंचमी के बाद आने वाली सप्तमी के दिन उन्हें बासी भोजन खिलाकर मां का बसौड़ा पूजन किया। हिन्दू व्रतों में केवल यही व्रत ऐसा है जिसमें बासी भोजन किया जाता है।\n\n"
                        "इस दिन मां शीतला का पूजन करने से माता अपने भक्तों को धन-धान्य से परिपूर्ण कर, उनके संतानों को लंबी आयु देती है तथा हर भक्त प्राकृतिक विपदाओं से दूर रखती हैं।\n\n"),

                _buildSectionTitle(_isEnglish
                    ? "Method of worship of Sheetla saptami:"
                    : "शीतला सप्तमी के बारे में:"),
                _buildBulletPoint(_isEnglish
                    ? "Get up early in the morning, take a bath and wear clean clothes."
                    : "सुबह जल्दी उठकर स्नान करें और साफ़ कपड़े पहनें."),
                _buildBulletPoint(_isEnglish
                    ? "Clean the temple and sprinkle Gangajal."
                    : "मंदिर को साफ़ करके गंगाजल छिड़कें."),
                _buildBulletPoint(_isEnglish
                    ? "Decorate two plates for worship:"
                    : "पूजा के लिए दो थालियां सजाएं:"),
                _buildBulletPoint(_isEnglish
                    ? "In one plate, keep curd, roti, pua, millet, salt para, mathri, and sweet rice made on Saptami day."
                    : "एक थाली में दही, रोटी, पुआ, बाजरा, नमक पारे, मठरी, और सप्तमी के दिन बने मीठे चावल रखें."),
                _buildBulletPoint(_isEnglish
                    ? "In the second plate, keep a flour lamp, roli, clothes, rice, coin, mehndi, and a pot of cold water."
                    : "दूसरी थाली में आटे का दीपक, रोली, वस्त्र, अक्षत, सिक्का, मेहंदी, और ठंडे पानी का लोटा रखें."),
                _buildBulletPoint(_isEnglish
                    ? "Worship Sheetla Mata in the temple."
                    : "मंदिर में शीतला माता की पूजा करें."),
                _buildBulletPoint(_isEnglish
                    ? "Offer water to the mother."
                    : "माता को जल चढ़ाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Offer the food kept in the plate."
                    : "थाली में रखा भोग चढ़ाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Recite the Sheetla Strot."
                    : "शीतला स्त्रोत का पाठ करें."),
                _buildBulletPoint(_isEnglish
                    ? "Perform the Aarti of Sheetla Mata."
                    : "शीतला माता की आरती करें."),
                _buildBulletPoint(_isEnglish
                    ? "Apply roli or turmeric tilak to all the members of the family."
                    : "परिवार के सभी लोगों को रोली या हल्दी का टीका लगाएं."),
                _buildBulletPoint(_isEnglish
                    ? "If the puja material is left, donate it to a cow or a Brahmin."
                    : "पूजा सामग्री बचने पर गाय या ब्राह्मण को दान दें."),

                // _buildSectionContent(_isEnglish ?"" :"" ),
                // _buildSectionContent(_isEnglish
                //     ?""
                //     :""
                // ),

                _buildSectionTitle(_isEnglish
                    ? "Sheetla Saptami Puja Vidhi:"
                    : "शीतला सप्तमी पूजा विधि:"),
                _buildSectionContent(_isEnglish
                    ? "For the puja, keep flour lamps, roli, turmeric, akshat, clothes, garland of badkule, mehndi, coins etc. in a plate. After this, worship Sheetla Mata. Light a lamp for Mata Sheetla and offer water to her. Bring some water from there for home as well and sprinkle it after coming home."
                    : "पूजा के लिए एक थाली में आटे के दीपक, रोली, हल्दी, अक्षत, वस्त्र बड़कुले की माला, मेहंदी, सिक्के आदि रख लें. इसके बाद शीतला माता की पूजा करें. माता शीतला को दीपक जलाएं और उन्हें जल अर्पित करें. वहां से थोड़ा जल घर के लिए भी लाएं और घर आकर उसे छिड़क दें."),

                _buildSectionTitle(_isEnglish
                    ? "Sheetla Saptami Katha:"
                    : "शीतला सप्तमी कथा:"),
                _buildSectionContent(_isEnglish
                    ? "A Brahmin couple lived in a village. They had two sons and both were married. Both the daughters-in-law did not have any children. After a long time they had children. After this, the festival of Sheetla Saptami came, on this occasion cold food was prepared in the house.\n\n"
                        "Both the daughters-in-law thought that if we eat cold food then the children can get sick. Both the daughters-in-law made two Baatis without telling anyone.\n\n"
                        "Mother-in-law and daughter-in-law worshipped Sheetla Mata and listened to the story. After this, the mother-in-law started singing the hymns of Sheetla Mata and both the daughters-in-law came home making an excuse of the children. Both of them came home and ate hot food. After this, when the mother-in-law came home, she asked both the daughters-in-law to eat. Both the daughters-in-law started working. The mother-in-law said that the children were sleeping for a long time, wake them up and feed them something. As soon as she went to wake up the children, both the children were dead.\n\n"
                        "This happened due to the wrath of Sheetla Mata. Both the daughters-in-law cried and told their mother-in-law everything. The mother-in-law scolded them a lot and said that for the sake of your sons, you have disregarded Mata Sheetla. Both of you leave the house and step into the house only after bringing both the children alive and healthy.\n\n"
                        "Both the daughters-in-law put their children in a basket and left the house. On the way, they came across a dilapidated tree. Which was a Khejri tree. Two sisters were sitting under it whose names were Ori and Sheetla. Both had lice in their hair. The daughters-in-law were also very tired, they also sat under that tree. After this, both of them removed a lot of lice from the head of Ori and Sheetla. They felt very good after the lice were removed. Both the sisters said that they felt Sheetala in their heads. They said that you both have cooled our heads, may you get peace of stomach in the same way.\n\n"
                        "Both the daughters-in-law said that we are wandering around with what our stomachs have given us. But we did not get the darshan of Sheetala Mata. Then Sheetala Mata said that you both are wicked, you are immoral. Your faces are not worth seeing. Instead of eating cold food on Sheetala Saptami, you both ate hot food.\n\n"
                        "On hearing this, both the daughters-in-law recognized Sheetala Mata. Both of them started praying to Mata Sheetala. Both of them said, Mother, forgive us, we ate food unknowingly. We both were deprived of your influence. Forgive us both. We both will not do such a thing again.\n\n"
                        "On hearing both of them, Mata Sheetala felt pity on them and she brought both the children back to life. After this, both the daughters-in-law returned home with their sons. And they told that they had seen Sheetala Mata. Both of them were welcomed with great pomp and show and were made to enter the village. The daughters-in-law said that we will build a temple of Sheetala Mata in the village and will eat only cold food on the day of Sheetala Saptami in the month of Chaitra."
                    : "एक गांव में ब्राह्मण दंपति रहते थे। उनके दो बेटे थे और दोनों की ही शादी हो चुकी थी। उन दोनों बहुओं को कोई संतान नहीं थी। लंबे समय बाद उन्हें संतान हुई। इसके बाद शीतला सप्तमी का पर्व आया इस अवसर पर ठंडा खाना बनाया गया।\n\n"
                        "दोनों बहुओं के मन में विचार आया कि अगर हम ठंडा खाना खाएंगे तो बच्चे बीमार हो सकते हैं। दोनों बहुओं ने बिना किसी को बताएं दो बाटी बना ली।\n\n"
                        "सास बहू शीतला माता की पूजा की और कथा सुनी। इसके बाद सास शीतला माता के भजन गाने लगी और दोनों बहुएं बच्चों का बहाना बनाकर घर आ गई। दोनों घर आकर गरम गरम खाना खाया। इसके बाद जब सास घर आई तो उसने दोनों बहुओं से खाना खाने के लिए कहा। दोनों बहुएं काम में लग गई। सास ने कहा कि बच्चे बहुत देर से सो रहे हैं, उन्हें जगाकर कुछ खिला दो। जैसे ही वह दोनों बच्चों को उठाने के लिए गई, दोनों बच्चे मृत थे।\n\n"
                        "ऐसा शीतला माता के प्रकोप से हुआ। दोनों बहुओं ने रो-रोकर अपनी सास को सारी बात बताई। सास ने दोनों को बहुत सुना और कहा कि अपने बेटों के लिए तुमने माता शीतला की अवहेलना की है। दोनों घर से निकल जाओ और दोनों बच्चों को जिंदा स्वस्थ लेकर ही घर में कदम रखना।\n\n"
                        "दोनों बहुएं अपने बच्चों को टोकरे में रखकर घर से निकल पड़ी। जाते-जाते रास्ते में एक जीर्ण वृक्ष आया। जो खेजड़ी का वृक्ष था। इसके नीचे दो बहने बैठी थीं जिनका नाम ओरी और शीतला था। दोनों के बालों में जूं थी। बहुएं काफी थक गई थीं, वह भी उस वृक्ष के नीचे बैठ गईं। इसके बाद दोनों ने ओरी और शीतला के सिर से बहुत सारी जुएं निकाली। जुओं के निकल जाने से उन्हें काफी अच्छा अनुभव हुआ। दोनों बहनों ने कहा कि अपने मस्तक में शीलता का अनुभव किया। कहा तुम दोनों ने हमारे मस्तक को शीतला ठंडा किया है, वैसे ही तुम्हें पेट की शांति मिले।\n\n"
                        "इतना सुनते ही दोनों बहुओं ने शीतला माता को पहचान लिया। दोनों माता शीतला से वंदन करने लगी। दोनों ने कहा माता हमें माफ कर दो हमने अनजाने में भोजन कर लिया। हम दोनों आपके प्रभाव से वंचित थे। हम दोनों को माफ कर दो। हम दोनों फिर से ऐसा काम नहीं करेंगे।"
                        "दोनों के बात सुनकर माता शीतला को उन पर तरस आ गया और उन्होंने दोनों बच्चों को जिंदा कर दिया। इसके बाद दोनों बहुएं अपने बेटों को लेकर घर लौट आई। और उन्होंने बताया कि उन्हें शीतला माता के दर्शन हुए थे। दोनों का धूमधाम से स्वागत करके गांव में प्रवेश करवाया। बहुओं ने कहा हम गांव में शीतला माता के मंदिर का निर्माण करवाएंगे और चैत्र महीने में शीलता सप्तमी के दिन सिर्फ ठंडा खाना ही खाएंगे।"),

                Center(
                    child: _buildSectionTitle(_isEnglish
                        ? "卐 sheetla Mata Ki Aarti Lyrics 卐"
                        : "卐  शीतला माता की आरती  卐")),
                _buildSectionContent(_isEnglish
                    ? "Jai Sheetla Mata,\n"
                        "Maiya Jai Sheetla Mata.\n"
                        "Aadi Jyoti Maharani,\n"
                        "Sab Phal Ki Data.\n"
                        "Om Jai Sheetla Mata\n"
                        "Ratan Sinhasan Shobhit,\n"
                        "Shvet Chhatra Bhata.\n"
                        "Rddhi Siddhi Chanvar Dhulaven,\n"
                        "Jagamag Chhavi Chhata.\n"
                        "Om Jai Sheetla Mata\n"
                        "Vishnu Sevat Thadhe,\n"
                        "Seven Shiv Dhata.\n"
                        "Ved Puran Varanat,\n"
                        "Paar Nahin Pata.\n"
                        "Om Jai Sheetla Mata\n"
                        "Indr Mridang Bajavat,\n"
                        "Chandra Veena Hatha.\n"
                        "Suraj Taal Bajavai,\n"
                        "Narad Muni Gata.\n"
                        "Om Jai Sheetla Mata\n"
                        "Ghanta Shankh Shahanai,\n"
                        "Bajai Man Bhata.\n"
                        "Karai Bhaktajan Aarti,\n"
                        "Lakhi Lakhi Harshata.\n"
                        "Om Jai Sheetla Mata\n"
                        "Brahma Roop Varadani,\n"
                        "Tuhi Teen Kaal Gyata.\n"
                        "Bhaktan Ko Sukh Deti,\n"
                        "Matu Pita Bhrata.\n"
                        "Om Jai Sheetla Mata\n"
                        "Jo Jan Dhyan Lagave,\n"
                        "Prem Shakti Pata.\n"
                        "Sakal Manorath Pave,\n"
                        "Bhavanidhi Tar Jata.\n"
                        "Om Jai Sheetla Mata\n"
                        "Rogon Se Jo Peedit Koi,\n"
                        "Sharan Teri Aata.\n"
                        "Kodhi Pave Nirmal Kaya,\n"
                        "Andh Netra Pata.\n"
                        "Om Jai Sheetla Mata\n"
                        "Banjh Putra Ko Pave,\n"
                        "Daridra Kat Jata.\n"
                        "Tako Bhajai Jo Nahin,\n"
                        "Sir Dhuni Pachhatata.\n"
                        "Om Jai Sheetla Mata\n"
                        "Sheetal Karti Janani,\n"
                        "Too Hi Hai Jag Trata.\n"
                        "Utpatti Vyadhi Binashan,\n"
                        "Too Sab Ki Ghaata.\n"
                        "Om Jai Sheetla Mata\n"
                        "Das Vichitra Kar Jode,\n"
                        "Sun Meri Mata.\n"
                        "Bhakti Aapani Deejai,\n"
                        "Aur Na Kuchh Bhata.\n"
                        "Om Jai Sheetla Mata"
                    : "जय शीतला माता, मैया जय शीतला माता,\n"
                        "आदि ज्योति महारानी सब फल की दाता।।\n"
                        "ऊं जय शीतला माता\n"
                        "रतन सिंहासन शोभित, श्वेत छत्र भ्राता।\n"
                        "ऋद्धि सिद्धि चंवर डोलावें, जगमग छवि छाता।।\n"
                        "ऊं जय शीतला माता\n"
                        "विष्णु सेवत ठाढ़े, सेवें शिव धाता।\n"
                        "वेद पुराण बरणत, पार नहीं पाता।।\n"
                        "ऊं जय शीतला माता\n"
                        "इन्द्र मृदंग बजावत, चन्द्र वीणा हाथा।\n"
                        "सूरज ताल बजाते, नारद मुनि गाता।।\n"
                        "ऊं जय शीतला माता\n"
                        "घण्टा शङ्ख शहनाई, बाजै मन भाता।\n"
                        "करै भक्तजन आरती, लखि लखि हर्षाता।।\n"
                        "ऊं जय शीतला माता\n"
                        "ब्रह्म रूप वरदानी, तुही तीन काल ज्ञाता।\n"
                        "भक्तन को सुख देती, मातु पिता भ्राता।।\n"
                        "ऊं जय शीतला माता\n"
                        "जो जन ध्यान लगावे, प्रेम शक्ति पाता।\n"
                        "सकल मनोरथ पावे, भवनिधि तर जाता।।\n"
                        "ऊं जय शीतला माता\n"
                        "रोगों से जो पीड़ित कोई, शरण तेरी आता।\n"
                        "कोढ़ी पावे निर्मल काया, अन्ध नेत्र पाता।।\n"
                        "ऊं जय शीतला माता\n"
                        "बांझ पुत्र को पावे, दारिद्र कट जाता।\n"
                        "तको भजै जो नहीं, सिर धुनि पछताता।।\n"
                        "ऊं जय शीतला माता\n"
                        "शीतल करती जननी, तू ही है जग त्राता।\n"
                        "उत्पत्ति व्याधि बिनाशन , तू सब की घाता।।\n"
                        "ऊं जय शीतला माता\n"
                        "दास विचित्र कर जोड़े, सुन मेरी माता।\n"
                        "भक्ति आपनी दीजै, और न कुछ भाता।।\n"
                        "जय शीतला माता, मैया जय शीतला माता।\n"
                        "आदि ज्योति महारानी, सब फल की दाता।।\n"
                        "ऊं जय शीतला माता"),
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
