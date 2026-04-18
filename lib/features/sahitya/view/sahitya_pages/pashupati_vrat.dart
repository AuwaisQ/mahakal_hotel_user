import 'dart:async';
import 'package:flutter/material.dart';

import '../../controller/share_helper.dart';
import 'commanbannerwidget.dart';

class PashupatiVrat extends StatefulWidget {
  const PashupatiVrat({super.key});

  @override
  State<PashupatiVrat> createState() => _PashupatiVratState();
}

class _PashupatiVratState extends State<PashupatiVrat> {
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
  Color _themeColor = Colors.cyan; // Default theme color

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
        ShareHelper.shareContent(context, "पशुपतिनाथ व्रत कथा");
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
          _isEnglish ? 'Pashupati Vrat Katha' : " पशुपति व्रत कथा",
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
                      'assets/sahitya_images/Pashupatinath Vrat Katha.jpg',
                ),
                _buildSectionTitle(_isEnglish
                    ? "About Pashupati Vrat:"
                    : "पशुपति व्रत के बारे में:"),
                _buildSectionContent(_isEnglish
                    ? "Pashupati Vrat should always be started on the day of Purnima which is Monday and if this is not possible then the fast should be started from any Monday of Shukla Paksha. If this is also not possible then the Pashupati Vrat should be started from the Monday on which you have the idea of ​​starting Pashupati Vrat.\n\n"
                        "By observing Pashupati Vrat, all the problems going on in a person's life come to an end because you will know that Pashupati Astra is an infallible weapon whose attack never goes in vain, similarly the wish of the person observing Pashupati Vrat never goes in vain.\n\n"
                        "Pashupatinath Vrat can be started from Monday of any month. According to beliefs, by observing this fast, one gets freedom from even the biggest crisis. It is said to observe this fast for at least five Mondays. In this fast, Lord Shankar is worshipped in the morning and evening."
                    : "पशुपति व्रत हमेशा पूर्णिमा के दिन जो सोमवार हो उसी दिन से शुरू करना चाहिए और अगर ऐसा संभव न हो तो किसी भी शुक्ल पक्ष के सोमवार से व्रत प्रारंभ कर देना चाहिए। अगर यह भी नहीं हो सके तो जो सोमवार से मन में पशुपति व्रत शुरू करने का विचार है उसी सोमवार से पशुपति व्रत प्रारंभ कर देना चाहिए।\n\n"
                        "पशुपति व्रत करने से मनुष्य के जीवन में चल रही सभी समस्याओं का अंत हो जाता है क्योंकि आपको पता होगा कि पशुपति अस्त्र एक अमोघ अस्त्र है जिसका वार कभी खाली नहीं जाता इसी प्रकार पशुपति व्रत करने वाले की मनोकामना कभी खाली नहीं जाती।\n\n"
                        "पशुपतिनाथ व्रत किसी भी महीने के सोमवार से प्रारंभ किया जा सकता है। मान्यताओं के अनुसार इस व्रत को करने से बड़े से बड़े संकट से भी मुक्ति मिल जाती है। ये व्रत कम से कम पांच सोमवार तक करने का विधान बताया गया है। इस व्रत में सुबह और शाम दोनों तक भगवान शंकर की विधि विधान पूजा की जाती है।"),
                _buildSectionTitle(_isEnglish
                    ? "Benefits of observing Pashupati Vrat:"
                    : "पशुपति व्रत करने के लाभ:"),
                _buildSectionContent(_isEnglish
                    ? "Only five fasts are observed in Pashupati Vrat, which helps in achieving the rarest of desires of a person. Like Pashupati weapon, Pashupati Vrat is also infallible and there is no difficulty in observing it because it is observed only in five times. Udyaapan is performed in the fifth fast only, so it is a very effective and easy fast."
                    : "पशुपति व्रत मात्र पांच व्रत किया जाता है जिससे मनुष्य के दुर्लभ से दुर्लभ मनोकामनाओं की सिद्धी होने लगती है। पशुपति अस्त्र के समान पशुपति व्रत भी अमोघ है तथा इसे करने में किसी प्रकार की कठिनाई भी नहीं आती है क्योंकि इसे मात्र पांच की संख्या में ही किया जाता है। पांचवे व्रत में ही उद्यापन किया जाता है इसलिए यह काफी असरदार और आसान व्रत होता है।"),
                _buildSectionTitle(_isEnglish
                    ? "Worship material for Pashupati Vrat:"
                    : "पशुपति व्रत की पूजा सामग्री :"),
                _buildBulletPoint(_isEnglish
                    ? "A plate of brass, copper or bronze"
                    : "पीतल, तांबे या कांसे की एक थाली"),
                _buildBulletPoint(_isEnglish
                    ? "White sandalwood, flower, Belpatra"
                    : "सफेद चंदन, फूल, बेलपत्र"),
                _buildBulletPoint(_isEnglish
                    ? "Durva for Nandi ji"
                    : "नंदी जी के लिए दूर्वा"),
                _buildBulletPoint(_isEnglish
                    ? "Flower and leaf of Ankde"
                    : "आंकड़े का फूल और पत्ता"),
                _buildBulletPoint(_isEnglish
                    ? "Flower and leaf of Shami"
                    : "शमी का फूल और पत्ता"),
                _buildBulletPoint(_isEnglish
                    ? "Panchamrit i.e. milk, curd, ghee, sugar, honey"
                    : "पंचामृत यानी दूध, दही, घी, शक्कर, शहद"),
                _buildBulletPoint(_isEnglish
                    ? "Clean water mixed with Ganga water"
                    : "साफ जल जिसमे गंगाजल मिश्रित हो"),
                _buildBulletPoint(_isEnglish ? "Belpatra" : "बेलपत्र"),
                _buildBulletPoint(_isEnglish
                    ? "Some material for bhog, prasad like"
                    : "भोग, प्रसाद के लिए कुछ सामग्री जैस"),
                _buildBulletPoint(_isEnglish
                    ? "Roli, sandalwood, a lamp of ghee, ash, perfume, Kalava, Janeu etc."
                    : "रोली, चंदन, घी का एक दिया, भस्म, इत्र, कलवा, जनेऊ इत्यादि।"),
                _buildSectionTitle(_isEnglish
                    ? "Rules of Pashupati Vrat:"
                    : "पशुपति व्रत के नियम:"),
                _buildBulletPoint(_isEnglish
                    ? "The person observing Pashupati Vrat should first wake up early in the morning."
                    : "पशुपति व्रत करने वाले को सर्वप्रथम सुबह जल्दी जागना चाहिए।"),
                _buildBulletPoint(_isEnglish
                    ? "The person observing Pashupati Vrat must take a thali. He must go to the Shiva temple with all the worship materials in the thali."
                    : "पशुपति व्रत करने वाले को एक थाली ज़रूर लेना चाहिए। थाली में ही पूजा की सभी सामग्रियाँ लेकर शिवालय में जाना चाहिए।"),
                _buildBulletPoint(_isEnglish
                    ? "Keep in mind that the thali with which you are going to do the morning worship must not be washed again after the morning worship. He must go to the Shiva temple with all the worship materials and five lamps in that thali."
                    : "ध्यान रहे जिस थाली से सुबह पूजन करना है उस थाली को वापस सुबह के पूजन के बाद धोना नहीं है। उस थाली में पूजा की सभी सामग्रियां लेकर और पांच दीपक लेकर शिवालय में जाना चाहिए।"),
                _buildBulletPoint(_isEnglish
                    ? "The person observing the fast must be pure in mind, action and speech."
                    : "व्रत करने वाले को मन, कर्म तथा वचन से शुद्ध होना अनिवार्य है।"),
                _buildSectionTitle(_isEnglish
                    ? "Pashupati Vrat Puja Vidhi:"
                    : "पशुपति व्रत की पूजा विधि:"),
                _buildSectionContent(_isEnglish
                    ? "The person observing the Pashupati Vrat must wake up in the Brahma Muhurta, finish all his daily activities and after worshipping his gods and goddesses at home, prepare a thali in which he must decorate the above mentioned materials and take it to any Shiva temple. If the arrangement is far away and you cannot go, then you can do this worship at home as well, but if you want to make this worship fruitful quickly, then you must go to any Shiva temple.\n\n"
                        "First of all, bathe Lord Bholenath with water mixed with Gangajal, after this, anoint Lord Bholenath with milk, curd, ghee, sugar and honey one by one. When all the anointments are complete, then finally bathe Mahadev with clean water.\n\n"
                        "After that, adorn Bholenath. After this, first apply perfume to him and then sandalwood.After that, you will put on the sacred thread and finally offer him a cloth called mauli. After this, you will offer flowers or garlands of flowers that you have brought along with you. Also, offer Shami leaves and Bel leaves. He is pleased soon by offering leaves or flowers of Ankde.\n\n"
                        "After all this, light a lamp of ghee. Offer whatever material you have brought for bhog there in the form of bhog. If there are Gauri-Ganesh and Kartikeya ji separately in the temple, then worship them too and if you are married, then you must also offer vermilion to Gauri Mata. In the end, you can recite any stotra. In this way, your morning worship is completed."
                    : "पशुपति व्रत करने वाले को ब्रह्म मुहूर्त में जागकर अपने सभी दैनिक क्रियाकलापों से निवृत होकर घर में अपने देवी-देवताओं की पूजा करने के बाद एक थाली तैयार करें जिस थाली में उपरोक्त सामग्रियों को सजा लें और इसे लेकर किसी भी शिव मंदिर ज़रूरी है। यदि व्यवस्था दूर हो और न जा सकें तो घर पर भी यह पूजन कर सकते हैं परंतु इस पूजन को जल्दी फलीभूत करना है तो आप अवश्य किसी शिव मंदिर जाएँ।\n\n"
                        "सर्वप्रथम भगवान भोलेनाथ को गंगाजल मिले हुए जल से स्नान कराएं इसके बाद दूध, दही, घी, शक्कर और शहद से एक -एक करके सभी चीजों से भगवान भोलेनाथ का अभिषेक करें। जब सभी अभिषेक पूर्ण हो जाए तो अंत में फिर स्वच्छ जल से महादेव को स्नान कराएं।\n\n"
                        "तत्पश्चात भोलेनाथ का श्रृंगार करेंगे। इसके बाद उन्हें सबसे पहले इत्र लगाएंगे फिर चंदन लगाएंगे उसके बाद जनेऊ पहनाएंगे तथा अंत में वस्त्र स्वरूप मौली उन्हें अर्पित करेंगे। इसके बाद फूल या फूलों की माला जो आप ले गए हों वह चढ़ाएंगे इसके साथ ही शमी पत्र और बेलपत्र भी ज़रूर चढ़ाएं। आंकड़े के पत्ते या फूल भी चढ़ाने से वह शीघ्र प्रसन्न होते हैं।\n\n"
                        "इन सबके बाद घी का एक दीपक भी प्रज्वलित करें। भोग के लिए जो भी सामग्रियां ले गए हैं वह भोग स्वरूप में वहां पर अर्पित करें। मंदिर में अलग से गौरी-गणेश और कार्तिकेय जी हैं तो उनका भी पूजन करें और अगर आप सुहागत हैं तोह आप गौरी माता को सिन्दूर भी ज़रूर अर्पित करें। अंत में किसी भी स्तोत्र का पाठ कर सकते हैं। इस प्रकार आपकी सुबह की पूजा पूर्ण हो गई।"),
                _buildSectionTitle(_isEnglish
                    ? "Evening worship method in Pashupati fast:"
                    : "पशुपति व्रत में शाम की पूजा विधि:"),
                _buildSectionContent(_isEnglish
                    ? "In Pashupati fast, keep the plate that you have taken for morning worship without washing it. Leave the remaining material as it is and worship Bholenath in the evening with the same. It is not necessary to do Abhishek in the evening, just prepare any bhog material in your house like you can make semolina pudding, kheer, malpua or churma. After that take 6 ghee lamps with you to the temple. After going to the temple, light five lamps there. Divide the Prasad you have taken for Bholenath into three parts, leave two parts in the temple and take one part for yourself and bring it home and consume that Prasad yourself after the worship and do not give it to anyone else even by mistake. Before accepting the Prasad, light five lamps in the temple and return to your house without lighting one lamp and place this lamp on the doorstep of the house, i.e. you should face your house and then light a ghee lamp on the doorstep of the house on the side of your right hand and bow to Bholenath and wish for the fulfillment of your wish, then come home and consume the third part that you have brought from the temple. In this way your evening worship is also completed."
                    : "पशुपति व्रत में जो सुबह पूजन के लिए आप थाली ले गए हैं उस थाली को बिना धोए रख दें। जो सामग्रियाँ बची हुई हैं उसे उसी प्रकार रहने दें और उसी से शाम को भी भोलेनाथ की पूजा करें। शाम को अभिषेक करना आवश्यकता नहीं है, केवल अपने घर में कोई भी भोग की सामग्री बना लें जैसे सूजी का हलवा बना सकते हैं, खीर बना सकते हैं, मालपुआ बना सकते हैं या चूरमा भी बना सकते हैं। उसके बाद घी के 6 दिए अपने साथ लेकर मंदिर जाएँ। मंदिर जाकर पांच दिए वहां जला दें। भोलेनाथ को जो प्रसाद आप ले गए हैं उस प्रसाद के तीन हिस्से करें, दो हिस्से मंदिर में छोड़ दें और एक हिस्सा स्वयं के लिए उठाकर घर ले आएं और उस प्रसाद को पूजा के बाद स्वयं ग्रहण करें और भूल से भी उसे किसी अन्य व्यक्ति को ना दें। प्रसाद ग्रहण करने से पहले पांच दिए मंदिर में प्रज्वलित करें और एक दिए को बिना जलाए अपने घर आएं और इस दिए को घर की चौखट पर यानी आप अपने घर की तरफ मुंह कर लें और फिर आपका दाहिना हाथ जिधर है इस दाहिनी हाथ की तरफ घर की चौखट पर घी का एक दिया जला दें और भोलेनाथ को प्रणाम कर अपनी मनोकामना की पूर्ति की कामना करें फिर घर में आकर वह जो तीसरा हिस्सा आप मंदिर से ले आए हैं उसे ग्रहण कर लें। इस प्रकार आपकी शाम की पूजा भी पूर्ण हो गई।"),
                _buildSectionTitle(_isEnglish
                    ? "Udyapan method of Pashupati Vrat:"
                    : "पशुपति व्रत की उद्यापन विधि:"),
                _buildSectionContent(_isEnglish
                    ? "Udyapan of Pashupati Vrat is done on the fifth day of the fast. The entire method of Udyapan will be the same as we do every day, light five lamps, divide the Prasad into three parts, apart from that one more thing has to be done on the day of Udyapan, a little simple (raw grain) is taken, a coconut is wrapped with Kalawa five times, 11 or 21 rupees are kept in the Shiva temple and prayed to Lord Bholenath to fulfill their wishes, then it is given directly to a Brahmin as Dakshina and then they leave. This is the Udyaapan method of the fast and by observing the fast in this way, Mahadev fulfills all the wishes."
                    : "पशुपति व्रत का उद्यापन व्रत के पांचवें दिन ही किया जाता है। उद्यापन की सारी विधि सामान्य वही रहेगी जो हम प्रतिदिन पूजा करते हैं, पांच दीपक जलाते हैं प्रसाद का तीन हिस्सा करते हैं उसके अलावा एक काम और करना होता है उद्यापन दिन, थोड़ा सा सीधा (कच्चा अनाज) ले लिया जाता हैम, एक नारियल पर पांच बार कलावा लपेटकर 11 या 21 रुपए शिव मंदिर में भगवान भोलेनाथ से अपनी मनोकामना पूरी करने के उसे रखकर प्रार्थना करके फिर उसे दक्षिणा स्वरुप सीधा किसी ब्राह्मण को देकर चले आते हैं। बस यही है व्रत की उद्यापन विधि और इस प्रकार व्रत करने से महादेव सभी कामनाएं पूर्ण कर देते हैं।"),
                _buildSectionTitle(_isEnglish ? "Story:" : "कथा:"),
                _buildSectionContent(_isEnglish
                    ? "Once upon a time, Lord Shiva, attracted by the beautiful Tapobhoomi of Nepal, left Kailash and came here and stayed here. He started roaming in this area in the form of a three-horned deer (chinkara). Therefore, this area is also called Pashupati Kshetra or Mrigasthali. Seeing Shiva absent like this, Brahma and Vishnu got worried and both the gods set out in search of Lord Shiva.\n\n"
                        "In this beautiful area, he saw a dazzling, charming three-horned deer roaming around. He started suspecting Shiva in the form of a deer. Brahma ji immediately recognized with the help of yoga that this was not a deer, but Lord Ashutosh. Immediately Brahma Ji jumped and tried to catch the horn of the deer. This broke the horn into 3 pieces.\n\n"
                        "A sacred piece of the same lion broke and fell here due to which Maharudra Ji was born here who later became famous as Pashupatinath Ji. As per the wish of Lord Shiva, Lord Vishnu, after giving salvation to Lord Shiva, established a linga on the high mound of Nagmati, which became famous as Pashupati."
                    : "एक बार की बात है भगवान शिव नेपाल की सुन्दर तपोभूमि से आकर्षित होकर एक बार कैलाश छोड़कर यहाँ आये और यहीं ठहरे। इस क्षेत्र में वह तीन सींग वाले हिरण (चिंकारा) के रूप में विचरण करने लगा। इसलिए इस क्षेत्र को पशुपति क्षेत्र या मृगस्थली भी कहा जाता है। शिव को इस तरह अनुपस्थित देखकर ब्रह्मा और विष्णु चिंतित हो गए और दोनों देवता भगवान शिव की खोज में निकल पड़े।\n\n"
                        "इस रमणीय क्षेत्र में उसने एक देदीप्यमान, मोहक तीन सींग वाला मृग विचरण करते देखा। उन्हें मृग रूपी शिव पर शक होने लगा। योग विद्या से ब्रह्मा जी ने तुरंत पहचान लिया कि यह मृग नहीं, बल्कि भगवान आशुतोष हैं। तुरंत ही ब्रह्मा जी उछल पड़े और मृग के सींग को पकड़ने की कोशिश करने लगे। इससे मृग के सींग के 3 टुकड़े हो गए।\n\n"
                        "उसी सिंह का एक पवित्र टुकड़ा टूटकर यहां पर भी गिर गया जिसकी वजह से यहां महारुद्र जी का जन्म हुआ जो आगे चलकर पशुपतिनाथ जी के नाम से प्रसिद्ध हुए भगवान शिव जी की इच्छा के अनुसार, भगवान विष्णु ने भगवान शिव को मोक्ष देने के बाद, नागमती के ऊंचे टीले पर एक लिंग स्थापित किया, जो पशुपति के रूप में प्रसिद्ध हुआ।"),
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
