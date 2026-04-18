import 'dart:async';

import 'package:flutter/material.dart';

import '../../controller/share_helper.dart';
import 'commanbannerwidget.dart';

class Janmashtami extends StatefulWidget {
  const Janmashtami({super.key});

  @override
  State<Janmashtami> createState() => _JanmashtamiState();
}

class _JanmashtamiState extends State<Janmashtami> {
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
  Color _themeColor = Colors.pinkAccent; // Default theme color

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
        ShareHelper.shareContent(context, "जन्माष्टमी व्रत कथा");
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
          _isEnglish ? 'Story Of Janmashtami' : "जन्माष्टमी की कथा",
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
                  imagePath: 'assets/sahitya_images/Janmashtami Vrat Katha.jpg',
                ),

                _buildSectionTitle(_isEnglish
                    ? "About Janmashtami:"
                    : "जन्माष्टमी के बारे में:"),
                // Section for Janmashtami information in English
                _buildSectionContent(_isEnglish
                    ? "Janmashtami is celebrated according to Hindu tradition when Krishna is believed to have been born in Mathura at midnight on the eighth day of the Bhadrapada month (overlapping with August and September in the Gregorian calendar). Krishna was born in the field of chaos.\n\n"
                        "Krishna Janmashtami (Sanskrit: कृष्णाजनमशत्मी, Romanized: कृष्णाजनमशत्मी), also known as Krishnashtami, Janmashtami or Gokulashtami, is an annual Hindu festival that celebrates the birth of Krishna, the eighth incarnation of Lord Vishnu.\n\n"
                        "Lord Krishna was born on the Ashtami Tithi of Krishna Paksha of the Bhadrapada month. Therefore, the festival of Janmashtami is celebrated with great enthusiasm in the month of Bhadrapada. If you want to get the blessings of Laddu Gopal on this auspicious occasion, then do read the Janmashtami Vrat Katha during the puja. This fulfills all the wishes of the seeker.\n\n"
                        "The festival of Janmashtami is being celebrated for centuries. This festival is celebrated with great pomp every year. To free the earth from the atrocities of Kansa, Lord Vishnu took birth from Devaki's womb in the form of Krishna on the eighth day of the Bhadrapad month in the Dwapar era. Both the world and the afterlife were delighted with the birth of Krishna.\n\n"
                        "According to mythological beliefs, Lord Krishna was born in Mathura. It is said that he was born to kill Kansa. Let us tell you that in the Dwapar era, Kansa usurped the throne of his father Ugrasen Raja and imprisoned him.\n\n"
                        "On the occasion of Janmashtami, temples are decorated beautifully and prayers are offered at midnight. An idol of Shri Krishna is made and placed in a cradle and it is rocked slowly. People sing bhajans all night and Aarti is performed. After Aarti and offering food to Balkrishna, the fast of the whole day is concluded."
                    : "जन्माष्टमी हिंदू परंपरा के अनुसार तब मनाई जाती है जब माना जाता है कि कृष्ण का जन्म मथुरा में भाद्रपद महीने के आठवें दिन (ग्रेगोरियन कैलेंडर में अगस्त और सितंबर के साथ अधिव्यपित) की आधी रात को हुआ था। कृष्ण का जन्म अराजकता के क्षेत्र में हुआ था।\n\n"
                        "कृष्ण जन्माष्टमी (संस्कृत: कृष्णजन्माष्टमी, रोमनकृत: कृष्णजन्माष्टमी), जिसे कृष्णाष्टमी, जन्माष्टमी या गोकुलाष्टमी के नाम से भी जाना जाता है, एक वार्षिक हिंदू त्योहार है जो भगवान विष्णु के आठवें अवतार कृष्ण के जन्म का जश्न मनाया जाता है।\n\n"
                        "भाद्रपद माह के कृष्ण पक्ष की अष्टमी तिथि को भगवान श्रीकृष्ण का अवतरण हुआ था। इसलिए भाद्रपद के महीने में जन्माष्टमी का पर्व बेहद उत्साह के साथ मनाया जाता है। अगर आप इस शुभ अवसर पर लड्डू गोपाल का आशीर्वाद प्राप्त करना चाहते हैं, तो पूजा के दौरान जन्माष्टमी व्रत कथा का पाठ जरूर करें। इससे साधक की सभी मुरादें पूरी होती हैं।\n\n"
                        "जन्माष्टमी का त्योहार सदियों से मनाया जा रहा है। ये पर्व हर साल बहुत ही धूमधाम के साथ मनाया जाता है। कंस के अत्याचारों से धरती को मुक्त कराने के लिए भगवान विष्णु ने द्वापर युग में भाद्रपद महीने की अष्टमी तिथि पर कृष्ण के रूप में देवकी के गर्भ से जन्म लिया। कृष्ण के जन्म से लोक परलोक दोनों ही प्रसन्न हो गए।\n\n"
                        "पौराणिक मान्यताओं के अनुसार, भगवान श्रीकृष्ण का जन्म मथुरा में हुआ था। ऐसा बताया जाता है कि उनका जन्म कंस का वध करने के लिए हुआ था। बता दें कि द्वापर युग में कंस ने अपने पिता उग्रसेन राजा की राजगद्दी छीन ली थी और उन्हें जेल में बंद कर दिया था।\n\n"
                        "जन्माष्टमी के अवसर पर मन्दिरों को अति सुन्दर ढंग से सजाया जाता है तथा मध्यरात्रि को प्रार्थना की जाती है। श्रीकृष्ण की मूर्ति बनाकर उसे एक पालने में रखा जाता है तथा उसे धीरे–धीरे से हिलाया जाता है। लोग सारी रात भजन गाते हैं तथा आरती की जाती है। आरती तथा बालकृष्ण को भोजन अर्पित करने के बाद सम्पूर्ण दिन के उपवास का समापन किया जाता है।"),

                _buildSectionTitle(_isEnglish
                    ? "Janmashtami Puja Vidhi and Samagri:"
                    : "जन्माष्टमी की पूजा विधि और सामग्री:"),
                // Section for Janmashtami celebration instructions in English
                _buildBulletPoint(_isEnglish
                    ? "On the day of Janmashtami, take a bath in the morning and wear clean clothes."
                    : "जन्माष्टमी के दिन सुबह स्नान करके साफ़ कपड़े पहनें."),
                _buildBulletPoint(_isEnglish
                    ? "Clean the Puja Ghar and the house."
                    : "पूजा घर और घर की साफ़-सफ़ाई करें."),
                _buildBulletPoint(_isEnglish
                    ? "Decorate Laddu Gopal's cradle."
                    : "लड्डू गोपाल का पालना सजाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Anoint Laddu Gopal with Gangajal or Panchamrit."
                    : "लड्डू गोपाल को गंगाजल या पंचामृत से अभिषेक करें."),
                _buildBulletPoint(_isEnglish
                    ? "Make Laddu Gopal wear clean clothes, crown and garland of flowers."
                    : "लड्डू गोपाल को साफ़ कपड़े, मुकुट, और फूलों की माला पहनाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Adorn Laddu Gopal."
                    : "लड्डू गोपाल का श्रृंगार करें."),
                _buildBulletPoint(_isEnglish
                    ? "In the afternoon, prepare a delivery room for Devki Ji with black sesame seeds."
                    : "मध्यान्ह में काले तिलों से देवकी जी के लिए प्रसूति गृह बनाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Lay a bed in the delivery room and install an auspicious Kalash."
                    : "प्रसूति गृह में बिछौना बिछाकर शुभ कलश स्थापित करें."),
                _buildBulletPoint(_isEnglish
                    ? "Worship Lord Krishna, Mother Devki, Nandlal, Yashoda Maiya, Vasudev, Baldev and Lakshmi Ji."
                    : "भगवान कृष्ण, माता देवकी, नंदलाल, यशोदा मैया, वासुदेव, बलदेव, और लक्ष्मी जी की पूजा करें."),
                _buildBulletPoint(_isEnglish
                    ? "Cut the cucumber at 12 in the night and separate it from its stem."
                    : "रात 12 बजे खीरे को काटकर उसके तने से अलग करें."),
                _buildBulletPoint(_isEnglish
                    ? "Perform the Aarti of Lord Krishna."
                    : "भगवान कृष्ण की आरती करें."),
                _buildBulletPoint(_isEnglish
                    ? "Offer Bhog to the Lord."
                    : "भगवान को भोग लगाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Swing Laddu Gopal."
                    : "लड्डू गोपाल को झूला झुलाएं."),
                _buildBulletPoint(
                    _isEnglish ? "End the fast." : "व्रत का पारण करें."),

                _buildSectionTitle(_isEnglish ? "Method:" : "विधि:"),
                _buildSectionContent(_isEnglish
                    ? "Light a lamp and show incense to Lord Krishna. Apply a Tilak of Ashtagandha Chandan or Roli and also apply Akshat (rice) on the Tilak. Offer a flower garland. Offer Makhan Mishri, Panjiri, Panchamrit, other Bhog items and offer a Tulsi leaf.\n\nBhadrapada Krishna Ashtami is called Sri Krishna Janmashtami, because this day is considered to be the birthday of Lord Krishna. On this date, in the dark midnight of Rohini Nakshatra, Lord Krishna was born from the womb of Vasudev's wife Devaki in the prison of Mathura. This date reminds us of that auspicious moment and is celebrated with great pomp in the whole country."
                    : "भगवान् कृष्ण को दीप जलाएं और धूप दिखाएं। अष्टगंध चन्दन या रोली का तिलक लगाएं और साथ ही अक्षत (चावल) भी तिलक पर लगाएं। फूल माला अर्पित करें। माखन मिश्री, पंजीरी, पंचामृत, अन्य भोग सामग्री अर्पित करें और तुलसी का पत्ता अर्पित करें।\n\nभाद्रपद कृष्ण अष्टमी को श्रीकृष्ण जन्माष्टमी कहते हैं, क्योंकि यह दिन भगवान श्रीकृष्ण का जन्मदिवस माना जाता है।इसी तिथि की घनघोर अंधेरी आधी रात को रोहिणी नक्षत्र में मथुरा के कारागार में वसुदेव की पत्नी देवकी के गर्भ से भगवान श्रीकृष्ण ने जन्म लिया था। यह तिथि उसी शुभ घड़ी की याद दिलाती है और सारे देश में बड़ी धूमधाम से मनाई जाती है।"),

                _buildSectionTitle(_isEnglish ? "katha:" : "कथा:"),
                // Section for the story of Krishna's birth in English
                _buildSectionContent(_isEnglish
                    ? "In Dwapar Yuga, Bhojvanshi King Ugrasen ruled in Mathura. His tyrannical son Kansa dethroned him and himself became the king of Mathura. Kansa had a sister named Devaki, who was married to a Yaduvanshi chieftain named Vasudev.\n\n"
                        "Once Kansa was going to take his sister Devaki to her in-laws' place. On the way, a voice from the sky said- 'O Kansa, the Devaki whom you are taking with so much love, is the one in whose hands you will die. The eighth child born from her womb will kill you.' Hearing this, Kansa prepared to kill Vasudev.\n\n"
                        "Then Devaki humbly told him- 'I will bring the child born from my womb in front of you. What is the benefit of killing brother-in-law?'\n\n"
                        "Kansa accepted Devaki's words and came back to Mathura. He put Vasudev and Devaki in prison.\n\n"
                        "Vasudev-Devaki had seven children one by one and Kansa killed all seven as soon as they were born. Now the eighth child was about to be born. Strict guards were posted on them in the prison. At the same time, Nanda's wife Yashoda was also about to have a child. Seeing the unhappy life of Vasudev-Devaki, he devised a way to protect the eighth child. At the time when Vasudev and Devaki gave birth to a son, by chance Yashoda gave birth to a daughter, who was nothing but 'Maya'.\n\n"
                        "The cell in which Devaki and Vasudev were imprisoned suddenly became bright and the Chaturbhuj Bhagwan appeared in front of them holding a conch, chakra, mace and lotus. Both of them fell at the feet of the Lord. Then the Lord said to them- 'Now I will again take the form of a newborn baby. You send me right now to your friend Nandji's house in Vrindavan and bring the girl born there and hand her over to Kansa. The environment is not favorable at this time. Still you don't worry. The awake guards will fall asleep, the prison gates will open automatically and the surging bottomless Yamuna will give you a way to cross.'\n\n"
                        "At the same time Vasudev put the newborn baby Sri Krishna in a basket and left the prison and after crossing the bottomless Yamuna reached Nandji's house. There he put the newborn baby to sleep with Yashoda and came to Mathura with the girl. The prison gates were closed as before. Now Kansa got the information that Vasudev and Devaki have given birth to a child.\n\n"
                        "He went to the prison and tried to snatch the newborn girl from Devaki's hand and throw it on the ground, but the girl flew in the sky and said from there- 'Hey fool, what will happen if I kill you? The one who will kill you has reached Vrindavan. He will soon punish you for your sins.' This is the story of Krishna's birth!"
                    : "द्वापर युग में भोजवंशी राजा उग्रसेन मथुरा में राज्य करता था। उसके आततायी पुत्र कंस ने उसे गद्दी से उतार दिया और स्वयं मथुरा का राजा बन बैठा। कंस की एक बहन देवकी थी, जिसका विवाह वसुदेव नामक यदुवंशी सरदार से हुआ था।\n\n"
                        "एक समय कंस अपनी बहन देवकी को उसकी ससुराल पहुंचाने जा रहा था। रास्ते में आकाशवाणी हुई- 'हे कंस, जिस देवकी को तू बड़े प्रेम से ले जा रहा है, उसी में तेरा काल बसता है। इसी के गर्भ से उत्पन्न आठवां बालक तेरा वध करेगा।' यह सुनकर कंस वसुदेव को मारने के लिए उद्यत हुआ।\n\n"
                        "तब देवकी ने उससे विनयपूर्वक कहा- 'मेरे गर्भ से जो संतान होगी, उसे मैं तुम्हारे सामने ला दूंगी। बहनोई को मारने से क्या लाभ है?'\n\n"
                        "कंस ने देवकी की बात मान ली और मथुरा वापस चला आया। उसने वसुदेव और देवकी को कारागृह में डाल दिया।\n\n"
                        "वसुदेव-देवकी के एक-एक करके सात बच्चे हुए और सातों को जन्म लेते ही कंस ने मार डाला। अब आठवां बच्चा होने वाला था। कारागार में उन पर कड़े पहरे बैठा दिए गए। उसी समय नंद की पत्नी यशोदा को भी बच्चा होने वाला था। उन्होंने वसुदेव-देवकी के दुखी जीवन को देख आठवें बच्चे की रक्षा का उपाय रचा। जिस समय वसुदेव-देवकी को पुत्र पैदा हुआ, उसी समय संयोग से यशोदा के गर्भ से एक कन्या का जन्म हुआ, जो और कुछ नहीं सिर्फ 'माया' थी।\n\n"
                        "जिस कोठरी में देवकी-वसुदेव कैद थे, उसमें अचानक प्रकाश हुआ और उनके सामने शंख, चक्र, गदा, पद्म धारण किए चतुर्भुज भगवान प्रकट हुए। दोनों भगवान के चरणों में गिर पड़े। तब भगवान ने उनसे कहा- 'अब मैं पुनः नवजात शिशु का रूप धारण कर लेता हूं। तुम मुझे इसी समय अपने मित्र नंदजी के घर वृंदावन में भेज आओ और उनके यहां जो कन्या जन्मी है, उसे लाकर कंस के हवाले कर दो। इस समय वातावरण अनुकूल नहीं है। फिर भी तुम चिंता न करो। जागते हुए पहरेदार सो जाएंगे, कारागृह के फाटक अपने आप खुल जाएंगे और उफनती अथाह यमुना तुमको पार जाने का मार्ग दे देगी।'\n\n"
                        "उसी समय वसुदेव नवजात शिशु-रूप श्रीकृष्ण को सूप में रखकर कारागृह से निकल पड़े और अथाह यमुना को पार कर नंदजी के घर पहुंचे। वहां उन्होंने नवजात शिशु को यशोदा के साथ सुला दिया और कन्या को लेकर मथुरा आ गए। कारागृह के फाटक पूर्ववत बंद हो गए। अब कंस को सूचना मिली कि वसुदेव-देवकी को बच्चा पैदा हुआ है।\n\n"
                        "उसने बंदीगृह में जाकर देवकी के हाथ से नवजात कन्या को छीनकर पृथ्वी पर पटक देना चाहा, परंतु वह कन्या आकाश में उड़ गई और वहां से कहा- 'अरे मूर्ख, मुझे मारने से क्या होगा? तुझे मारनेवाला तो वृंदावन में जा पहुंचा है। वह जल्द ही तुझे तेरे पापों का दंड देगा।' यह है कृष्ण जन्म की कथा!"),

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
