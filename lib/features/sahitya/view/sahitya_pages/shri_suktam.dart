import 'dart:async';
import 'package:flutter/material.dart';

import '../../controller/share_helper.dart';
import 'commanbannerwidget.dart';

class ShriSuktam extends StatefulWidget {
  const ShriSuktam({super.key});

  @override
  State<ShriSuktam> createState() => _ShriSuktamState();
}

class _ShriSuktamState extends State<ShriSuktam> {
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
  Color _themeColor = Colors.deepOrange; // Default theme color

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
        ShareHelper.shareContent(context, "श्री सूक्तम् पाठ 📖✨");
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
          _isEnglish ? 'Shri Suktam Paath' : "श्री सूक्तम पाठ",
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

                // _buildSectionContent(_isEnglish ?"" :"" ),
                // _buildSectionContent(_isEnglish
                //     ?""
                //     :""
                // ),
                const CommanBannerWidget(
                  imagePath: 'assets/sahitya_images/Sri Suktam Paath.jpg',
                ),

                _buildSectionTitle(_isEnglish
                    ? "About Shri Suktam Paath:"
                    : "श्री सूक्तम पाठ के बारे में:"),
                _buildSectionContent(_isEnglish
                    ? "Shri Sukta or Shri Suktam is a hymn mentioned in Rigveda for the worship of Mahalakshmi. The recitation of Shri Sukta pleases Mahalakshmi and makes her blessed. It is also recited and performed for business growth, freedom from debt and wealth.\n\n"
                        "Mata Lakshmi blesses the person who recites this hymn with faith and devotion. With the blessings of Lakshmi ji, a person not only gets wealth and prosperity but also fame and glory.\n\n"
                        "It is recited to get the blessings of Goddess Lakshmi, the presiding deity of wealth and grains. There are 15 hymns in Shri Sukta and 16 hymns are considered including Mahatmya. Reciting any hymn without Mahatmya does not yield results. Therefore, it is necessary to recite all the 16 hymns.\n\n"
                        "By reciting Shri Sukta, a person gets prosperity, health, wealth, happiness. By the grace of Maa Lakshmi, one gets rid of poverty and debt. Along with this, respect and prestige increases in the society. Along with this, the person who recites it correctly, never faces poverty."
                    : "श्री सूक्त या श्री सूक्तम महालक्ष्मी की उपासना के लिए ऋग्वेद में वर्णित एक स्तोत्र है। श्री सूक्त का पाठ महालक्ष्मी की प्रसन्नता एवं उनकी कृपा प्राप्त कराने वाला है साथ ही व्यापार में वृद्धि, ऋण से मुक्ति और धन प्राप्ति के लिए भी इसका पाठ तथा अनुष्ठान किया जाता है।\n\n"
                        "श्रद्धा एवं विश्वास के साथ इस स्तोत्र का पाठ करने वाले व्यक्ति पर माता लक्ष्मी कृपा करती हैं। लक्ष्मी जी की कृपा होने पर व्यक्ति सिर्फ धन और ऐश्वर्य ही नहीं बल्कि यश एवं कीर्ति भी प्राप्त करता है।\n\n"
                        "इसका पाठ धन-धान्य की अधिष्ठात्री देवी लक्ष्मी की कृपा प्राप्ति के लिए किया जाता है. श्रीसूक्त में 15 ऋचाएं हैं और माहात्म्य सहित 16 ऋचाएं मानी गई हैं. किसी भी स्त्रोत का बिना माहात्म्य के पाठ करने से फल नहीं मिलता है. इसलिए सभी 16 ऋचाओं का पाठ करना जरूरी है.\n\n"
                        "श्री सूक्त का पाठ करने से व्यक्ति को समृद्धि, स्वास्थ्य, धन, आनंद की प्राप्ति होती है। मां लक्ष्मी की कृपा से दरिद्रता, कर्ज से छुटकारा मिल जाता है। इसके साथ ही समाज में मान-सम्मान और प्रतिष्ठा बढ़ती है। इसके साथ ही जो व्यक्ति इसका पाठ सही तरीके करता है, तो वह कभी भी गरीबी का सामना नहीं करता है।"),

                _buildSectionTitle(_isEnglish
                    ? "5 benefits are definitely obtained by reciting Shri Sukta."
                    : "श्री सूक्त पाठ द्वारा 5 लाभ अवश्य प्राप्त होते है।"),
                _buildSectionContent(_isEnglish
                    ? "Wealth, property and prosperity are obtained.\n\n"
                        "Benefits are obtained in business or business.\n\n"
                        "Positivity comes in your life.\n\n"
                        "Spiritual progress increases by reciting.\n\n"
                        "This keeps the family together."
                    : "धन, संपत्ति और समृद्धि प्राप्त होती है।\n\n"
                        "व्यापार या व्यवसाय में लाभ मिलता है।\n\n"
                        "अपने जीवन में सकारात्मकता आती है।\n\n"
                        "पाठ द्वारा आध्यात्मिक उन्नति बढ़ती है।\n\n"
                        "इससे परिवार एक साथ जुड़ा रहता है।"),

                Center(
                    child: _buildSectionTitle(
                        _isEnglish ? "॥ shri sukt ॥" : "॥ श्री सूक्त ॥")),

                _buildSectionContent(_isEnglish
                    ? "ॐ हिरण्यवर्णां हरिणीं सुवर्णरजतस्रजाम्। \nचन्द्रां हिरण्मयीं लक्ष्मीं जातवेदो म आ वह ॥1॥\n\n"
                        "Meaning – O omniscient Agnidev! Invoke for me the goddess Lakshmi who is of golden complexion, wears gold and silver necklaces, has a moon-like radiance and is covered with gold."
                    : "ॐ हिरण्यवर्णां हरिणीं सुवर्णरजतस्रजाम्। \nचन्द्रां हिरण्मयीं लक्ष्मीं जातवेदो म आ वह ॥1॥\n\n"
                        "अर्थ – हे सर्वज्ञ अग्निदेव ! सुवर्ण के रंग वाली, सोने और चाँदी के हार पहनने वाली, चन्द्रमा के समान प्रसन्नकांति, स्वर्णमयी लक्ष्मीदेवी को मेरे लिये आवाहन करो।"),

                _buildSectionContent(_isEnglish
                    ? "तां म आ वह जातवेदो लक्ष्मीमनपगामिनीम्।\nयस्यां हिरण्यं विन्देयं गामश्वं पुरुषानहम् ॥2॥\n\n"
                        "Meaning: O Agni! Invoke for me that goddess of wealth, who is never destroyed and whose arrival will grant me gold, cows, horses and sons"
                    : "तां म आ वह जातवेदो लक्ष्मीमनपगामिनीम्।\nयस्यां हिरण्यं विन्देयं गामश्वं पुरुषानहम् ॥2॥\n\n"
                        "अर्थ – अग्ने ! उन लक्ष्मीदेवी को, जिनका कभी विनाश नहीं होता तथा जिनके आगमन से मैं सोना, गौ, घोड़े तथा पुत्रादि को प्राप्त करूँगा, मेरे लिये आवाहन करो।"),

                _buildSectionContent(_isEnglish
                    ? "अश्वपूर्वां रथमध्यां हस्तिनादप्रमोदिनीम्।\nश्रियं देवीमुप ह्वये श्रीर्मा देवी जुषताम् ॥3॥\n\n"
                        "Meaning – I invoke the Goddess Shridevi who is preceded by horses and followed by chariots and who is delighted on hearing the roar of elephants; may I receive Goddess Lakshmi."
                    : "अश्वपूर्वां रथमध्यां हस्तिनादप्रमोदिनीम्।\nश्रियं देवीमुप ह्वये श्रीर्मा देवी जुषताम् ॥3॥\n\n"
                        "अर्थ – जिन देवी के आगे घोड़े तथा उनके पीछे रथ रहते हैं तथा जो हस्तिनाद को सुनकर प्रमुदित होती हैं, उन्हीं श्रीदेवी का मैं आवाहन करता हूँ; लक्ष्मीदेवी मुझे प्राप्त हों।"),

                _buildSectionContent(_isEnglish
                    ? "कां सोस्मितां हिरण्यप्राकारामार्द्रां ज्वलन्तीं तृप्तां तर्पयन्तीम्।\nपद्मेस्थितां पद्मवर्णां तामिहोप ह्वये श्रियम् ॥4॥\n\n"
                        "Meaning – I invoke Goddess Lakshmi here, who is the embodiment of Brahma, who smiles softly, is covered in gold, is compassionate, radiant, full of desire, who showers her blessings on her devotees, who sits on a lotus seat and is colored with a lotus."
                    : "कां सोस्मितां हिरण्यप्राकारामार्द्रां ज्वलन्तीं तृप्तां तर्पयन्तीम्।\nपद्मेस्थितां पद्मवर्णां तामिहोप ह्वये श्रियम् ॥4॥\n\n"
                        "अर्थ – जो साक्षात ब्रह्मरूपा, मंद-मंद मुसकराने वाली, सोने के आवरण से आवृत, दयार्द्र, तेजोमयी, पूर्णकामा, अपने भक्तों पर अनुग्रह करनेवाली, कमल के आसन पर विराजमान तथा पद्मवर्णा हैं, उन लक्ष्मीदेवी का मैं यहाँ आवाहन करता हूँ।"),

                _buildSectionContent(_isEnglish
                    ? "चन्द्रां प्रभासां यशसा ज्वलन्तीं श्रियं लोके देवजुष्टामुदाराम्।\nशतां पद्मिनीमीं शरणं प्र पद्ये अलक्ष्मीर्मे नश्यतां त्वां वृणे ॥5॥\n\n"
                        "Meaning – I seek refuge in the goddess Lakshmi who is as bright as the moon, beautiful and radiant, radiant with fame, worshipped by the gods in heaven, generous and has lotus-handed hands. May my poverty be removed. I accept you as my refuge."
                    : "चन्द्रां प्रभासां यशसा ज्वलन्तीं श्रियं लोके देवजुष्टामुदाराम्।\nशतां पद्मिनीमीं शरणं प्र पद्ये अलक्ष्मीर्मे नश्यतां त्वां वृणे ॥5॥\n\n"
                        "अर्थ – मैं चन्द्रमा के समान शुभ्र कान्तिवाली, सुन्दर द्युतिशालिनी, यश से दीप्तिमती, स्वर्गलोक में देवगणों के द्वारा पूजिता, उदारशीला, पद्महस्ता लक्ष्मीदेवी की शरण ग्रहण करता हूँ। मेरा दारिद्र्य दूर हो जाय। मैं आपको शरण्य के रूप में वरण करता हूँ।"),

                _buildSectionContent(_isEnglish
                    ? "आदित्यवर्णे तपसोऽधि जातो वनस्पतिस्तव वृक्षोऽथ बिल्वः।\nतस्य फलानि तपसा नुदन्तु या अन्तरा याश्च बाह्या अलक्ष्मीः ॥6॥\n\n"
                        "Meaning – O one who is as bright as the Sun! It is because of your penance that the Bilva tree, the best among trees, was born. May its fruits remove our external and internal poverty."
                    : "आदित्यवर्णे तपसोऽधि जातो वनस्पतिस्तव वृक्षोऽथ बिल्वः।\nतस्य फलानि तपसा नुदन्तु या अन्तरा याश्च बाह्या अलक्ष्मीः ॥6॥\n\n"
                        "अर्थ – हे सूर्य के समान प्रकाशस्वरूपे ! तुम्हारे ही तप से वृक्षों में श्रेष्ठ मंगलमय बिल्ववृक्ष उत्पन्न हुआ। उसके फल हमारे बाहरी और भीतरी दारिद्र्य को दूर करें।"),

                _buildSectionContent(_isEnglish
                    ? "उपैतु मां देवसखः कीर्तिश्च मणिना सह।\n"
                        "प्रादुर्भूतोऽस्मि राष्ट्रेऽस्मिन् कीर्तिमृद्धिं ददातु मे ॥7॥\n\n"
                        "Meaning – O one who is as bright as the Sun! It is because of your penance that the Bilva tree, the best among trees, was born. May its fruits remove our external and internal poverty."
                    : "उपैतु मां देवसखः कीर्तिश्च मणिना सह।\n"
                        "प्रादुर्भूतोऽस्मि राष्ट्रेऽस्मिन् कीर्तिमृद्धिं ददातु मे ॥7॥\n\n"
                        "अर्थ – देवि ! देवसखा कुबेर और उनके मित्र मणिभद्र तथा दक्ष प्रजापति की कन्या कीर्ति मुझे प्राप्त हों अर्थात मुझे धन और यश की प्राप्ति हो। मैं इस राष्ट्र में उत्पन्न हुआ हूँ, मुझे कीर्ति और ऋद्धि प्रदान करें।"),

                _buildSectionContent(_isEnglish
                    ? "क्षुत्पिपासामलां ज्येष्ठामलक्ष्मीं नाशयाम्यहम्।\n"
                        "अभूतिमसमृद्धिं च सर्वां निर्णुद मे गृहात् ॥8॥\n\n"
                        "Meaning – I want the destruction of Lakshmi's elder sister Alakshmi (the presiding goddess of poverty), who is dirty and emaciated due to hunger and thirst. Goddess! Remove all kinds of poverty and misfortune from my house."
                    : "क्षुत्पिपासामलां ज्येष्ठामलक्ष्मीं नाशयाम्यहम्।\n"
                        "अभूतिमसमृद्धिं च सर्वां निर्णुद मे गृहात् ॥8॥\n\n"
                        "अर्थ – लक्ष्मी की ज्येष्ठ बहिन अलक्ष्मी (दरिद्रता की अधिष्ठात्री देवी) का, जो क्षुधा और पिपासा से मलिन और क्षीणकाय रहती हैं, मैं नाश चाहता हूँ। देवि ! मेरे घर से सब प्रकार के दारिद्र्य और अमंगल को दूर करो।"),

                // Section for the first verse and its meaning
                _buildSectionContent(_isEnglish
                    ? "गन्धद्वारां दुराधर्षां नित्यपुष्टां करीषिणीम्।\n"
                        "ईश्वरीं सर्वभूतानां तामिहोप ह्वये श्रियम् ॥9॥\n\n"
                        "Meaning – I invoke the goddess Lakshmi, who is difficult to overcome, always nourished, and endowed with the fragrance of cow dung. She is the mistress of all beings, and I invite her into my home."
                    : "गन्धद्वारां दुराधर्षां नित्यपुष्टां करीषिणीम्।\n"
                        "ईश्वरीं सर्वभूतानां तामिहोप ह्वये श्रियम् ॥9॥\n\n"
                        "अर्थ – जो दुराधर्षा और नित्यपुष्टा हैं तथा गोबर से (पशुओं से) युक्त गन्धगुणवती हैं। पृथ्वी ही जिनका स्वरुप है, सब भूतों की स्वामिनी उन लक्ष्मी देवी का मैं यहाँ अपने घर में आवाहन करता हूँ."),

                _buildSectionContent(_isEnglish
                    ? "मनसः काममाकूतिं वाचः सत्यमशीमहि।\n"
                        "पशूनां रूपमन्नस्य मयि श्रीः श्रयतां यशः ॥10॥\n\n"
                        "Meaning – May I get the fulfillment of my desires and resolutions and may I get the truthfulness of my speech. May Goddess Sridevi come to us in the form of animals like cows and various types of edible items and in the form of fame."
                    : "मनसः काममाकूतिं वाचः सत्यमशीमहि।\n"
                        "पशूनां रूपमन्नस्य मयि श्रीः श्रयतां यशः ॥10॥\n\n"
                        "अर्थ – मन की कामनाओं और संकल्प की सिद्धि एवं वाणी की सत्यता मुझे प्राप्त हो। गौ आदि पशु एवं विभिन्न प्रकार के अन्न भोग्य पदार्थों के रूप में तथा यश के रूप में श्री देवी हमारे यहाँ आगमन करें."),

                // Section for the first verse and its meaning
                _buildSectionContent(_isEnglish
                    ? "कर्दमेन प्रजा भूता मयि सम्भव कर्दम।\n"
                        "श्रियं वासय मे कुले मातरं पद्ममालिनीम् ॥11॥\n\n"
                        "Meaning – We are the children of Kardam, son of Lakshmi. Kardam Rishi! Please be born in our family and establish mother Lakshmi Devi who wears a garland of lotuses in our family."
                    : "कर्दमेन प्रजा भूता मयि सम्भव कर्दम।\n"
                        "श्रियं वासय मे कुले मातरं पद्ममालिनीम् ॥11॥\n\n"
                        "अर्थ – लक्ष्मी के पुत्र कर्दम की हम संतान हैं। कर्दम ऋषि ! आप हमारे यहाँ उत्पन्न हों तथा पद्मों की माला धारण करनेवाली माता लक्ष्मी देवी को हमारे कुल में स्थापित करें."),

                _buildSectionContent(_isEnglish
                    ? "आपः सृजन्तु स्निग्धानि चिक्लीत वस मे गृहे।\n"
                        "नि च देवीं मातरं श्रियं वासय मे कुले ॥12॥\n\n"
                        "Meaning – Water should create smooth substances. Laxmiputra Chiklit! You should also reside in my house and make mother Laxmi Devi reside in my family."
                    : "आपः सृजन्तु स्निग्धानि चिक्लीत वस मे गृहे।\n"
                        "नि च देवीं मातरं श्रियं वासय मे कुले ॥12॥\n\n"
                        "अर्थ – जल स्निग्ध पदार्थों की सृष्टि करे। लक्ष्मीपुत्र चिक्लीत ! आप भी मेरे घर में वास करें और माता लक्ष्मी देवी का मेरे कुल में निवास करायें."),

                _buildSectionContent(_isEnglish
                    ? "आर्द्रां पुष्करिणीं पुष्टिं पिङ्गलां पद्ममालिनीम्।\n"
                        "चन्द्रां हिरण्मयीं लक्ष्मीं जातवेदो म आ वह ॥13॥\n\n"
                        "Meaning – O Agni! Invoke before me Lakshmidevi of golden complexion, with moist nature, lotus hands, Pushti form, yellow complexion, wearing a garland of lotus flowers, with golden glow like the moon."
                    : "आर्द्रां पुष्करिणीं पुष्टिं पिङ्गलां पद्ममालिनीम्।\n"
                        "चन्द्रां हिरण्मयीं लक्ष्मीं जातवेदो म आ वह ॥13॥\n\n"
                        "अर्थ – अग्ने ! आर्द्रस्वभावा, कमलहस्ता, पुष्टिरूपा, पीतवर्णा, पद्मों की माला धारण करनेवाली, चन्द्रमा के समान शुभ्र कान्ति से युक्त, स्वर्णमयी लक्ष्मी देवी का मेरे यहाँ आवाहन करें."),

                _buildSectionContent(_isEnglish
                    ? "आर्द्रां यः करिणीं यष्टिं सुवर्णां हेममालिनीम्।\n"
                        "सूर्यां हिरण्मयीं लक्ष्मीं जातवेदो म आ वह ॥14॥\n\n"
                        "Meaning – Fire! Invoke for me Goddess Lakshmi, who controls the wicked yet has a gentle nature, who gives auspiciousness, who provides support, who has a beautiful complexion, who wears a gold garland, who has the form of the sun and who is like a deer."
                    : "आर्द्रां यः करिणीं यष्टिं सुवर्णां हेममालिनीम्।\n"
                        "सूर्यां हिरण्मयीं लक्ष्मीं जातवेदो म आ वह ॥14॥\n\n"
                        "अर्थ – अग्ने ! जो दुष्टों का निग्रह करनेवाली होने पर भी कोमल स्वभाव की हैं, जो मंगलदायिनी, अवलम्बन प्रदान करनेवाली यष्टिरूपा, सुन्दर वर्णवाली, सुवर्णमालाधारिणी, सूर्यस्वरूपा तथा हिरण्यमयी हैं, उन लक्ष्मी देवी का मेरे लिये आवाहन करें."),

                _buildSectionContent(_isEnglish
                    ? "तां म आ वह जातवेदो लक्ष्मीमनपगामिनीम्।\n"
                        "यस्यां हिरण्यं प्रभूतं गावो दास्योऽश्वान् विन्देयं पुरुषानहम् ॥15॥\n\n"
                        "Meaning – O Agni! Invoke for me the never-ending goddess of wealth, Lakshmi, whose arrival may grant us lots of wealth, cows, maids, horses and sons."
                    : "तां म आ वह जातवेदो लक्ष्मीमनपगामिनीम्।\n"
                        "यस्यां हिरण्यं प्रभूतं गावो दास्योऽश्वान् विन्देयं पुरुषानहम् ॥15॥\n\n"
                        "अर्थ – अग्ने ! कभी नष्ट न होनेवाली उन लक्ष्मी देवी का मेरे लिये आवाहन करें, जिनके आगमन से बहुत-सा धन, गौएँ, दासियाँ, अश्व और पुत्रादि को हम प्राप्त करें."),

                _buildSectionContent(_isEnglish
                    ? "यः शुचिः प्रयतो भूत्वा जुहुयादाज्यमन्वहम्।\n"
                        "सूक्तं पञ्चदशर्चं च श्रीकामः सततं जपेत् ॥16॥\n\n"
                        "Meaning – One who wishes for Goddess Lakshmi should be pure and disciplined and offer ghee to the fire every day and should continuously recite Shri Sukta consisting of these fifteen verses."
                    : "यः शुचिः प्रयतो भूत्वा जुहुयादाज्यमन्वहम्।\n"
                        "सूक्तं पञ्चदशर्चं च श्रीकामः सततं जपेत् ॥16॥\n\n"
                        "अर्थ – जिसे लक्ष्मी की कामना हो, वह प्रतिदिन पवित्र और संयमशील होकर अग्नि में घी की आहुतियाँ दे तथा इन पंद्रह ऋचाओं वाले श्री सूक्त का निरन्तर पाठ करे."),

                _buildSectionContent(_isEnglish
                    ? "पद्मानने पद्मविपद्मपत्रे पद्मप्रिये पद्मदलायताक्षि।\n"
                        "विश्वप्रिये विष्णुमनोऽनुकूले त्वत्पादपद्मं मयि सं नि धत्स्व ॥17॥\n\n"
                        "Meaning – One with a face like a lotus! One who keeps her feet on a lotus leaf! One who loves lotus! One with eyes as big as a lotus leaf! One who is dear to the whole world! One who behaves according to the heart of Lord Vishnu! Please place your feet in my heart."
                    : "पद्मानने पद्मविपद्मपत्रे पद्मप्रिये पद्मदलायताक्षि।\n"
                        "विश्वप्रिये विष्णुमनोऽनुकूले त्वत्पादपद्मं मयि सं नि धत्स्व ॥17॥\n\n"
                        "अर्थ – कमल के समान मुखवाली ! कमलदल पर अपने चरणकमल रखनेवाली ! कमल में प्रीति रखनेवाली ! कमलदल के समान विशाल नेत्रोंवाली ! समग्र संसार के लिये प्रिय ! भगवान विष्णु के मन के अनुकूल आचरण करनेवाली ! आप अपने चरणकमल को मेरे हृदय में स्थापित करें."),

                _buildSectionContent(_isEnglish
                    ? "पद्मानने पद्मऊरु पद्माक्षि पद्मसम्भवे।\n"
                        "तन्मे भजसि पद्माक्षि येन सौख्यं लभाम्यहम् ॥18॥\n\n"
                        "Meaning - One with a face like a lotus! One with thighs like a lotus! One with eyes like a lotus! One born from a lotus! Padmakshi! You should take care of me in such a way that I get happiness."
                    : "पद्मानने पद्मऊरु पद्माक्षि पद्मसम्भवे।\n"
                        "तन्मे भजसि पद्माक्षि येन सौख्यं लभाम्यहम् ॥18॥\n\n"
                        "अर्थ – कमल के समान मुखमण्डल वाली ! कमल के समान ऊरुप्रदेश वाली ! कमल के समान नेत्रोंवाली ! कमल से आविर्भूत होनेवाली ! पद्माक्षि ! आप उसी प्रकार मेरा पालन करें, जिससे मुझे सुख प्राप्त हो."),

                _buildSectionContent(_isEnglish
                    ? "अश्वदायि गोदायि धनदायि महाधने।\n"
                        "धनं मे जुषतां देवि सर्वकामांश्च देहि मे ॥19॥\n\n"
                        "Meaning – O Goddess who gives horses, cows, wealth and is the embodiment of great wealth! May I always have wealth, may you give me all the things I desire."
                    : "अश्वदायि गोदायि धनदायि महाधने।\n"
                        "धनं मे जुषतां देवि सर्वकामांश्च देहि मे ॥19॥\n\n"
                        "अर्थ – अश्वदायिनी, गोदायिनी, धनदायिनी, महाधनस्वरूपिणी हे देवि ! मेरे पास सदा धन रहे, आप मुझे सभी अभिलषित वस्तुएँ प्रदान करें."),

                _buildSectionContent(_isEnglish
                    ? "पुत्रपौत्रधनं धान्यं हस्त्यश्वाश्वतरी रथम्।\n"
                        "प्रजानां भवसि माता आयुष्मन्तं करोतु मे ॥20॥\n\n"
                        "Meaning – You are the mother of living beings who are blessed with long life. Please prolong the life of my sons, grandsons, wealth, grains, elephants, horses, mules and chariots."
                    : "पुत्रपौत्रधनं धान्यं हस्त्यश्वाश्वतरी रथम्।\n"
                        "प्रजानां भवसि माता आयुष्मन्तं करोतु मे ॥20॥\n\n"
                        "अर्थ – आप प्राणियों की माता हैं जो आयु से सम्पन्न हैं। मेरे पुत्र, पौत्र, धन, धान्य, हाथी, घोड़े, खच्चर तथा रथ को दीर्घ करें."),

                _buildSectionContent(_isEnglish
                    ? "धनमग्निर्धनं वायुर्धनं सूर्यो धनं वसुः।\n"
                        "धनमिन्द्रो बृहस्पतिर्वरुणो धनमश्विना ॥21॥\n\n"
                        "Meaning – Agni, Vayu, Surya, Vasugana, Indra, Jupiter, Varun and Ashwini Kumar – all these are forms of glory."
                    : "धनमग्निर्धनं वायुर्धनं सूर्यो धनं वसुः।\n"
                        "धनमिन्द्रो बृहस्पतिर्वरुणो धनमश्विना ॥21॥\n\n"
                        "अर्थ – अग्नि, वायु, सूर्य, वसुगण, इन्द्र, बृहस्पति, वरुण तथा अश्विनी कुमार – ये सब वैभवस्वरूप हैं."),

                _buildSectionContent(_isEnglish
                    ? "वैनतेय सोमं पिब सोमं पिबतु वृत्रहा।\n"
                        "सोमं धनस्य सोमिनो मह्यं ददातु सोमिनः ॥22॥\n\n"
                        "Meaning – O Garuda! You should drink Soma. Indra, the destroyer of Vritraasura, should drink Soma. Garuda and Indra should give the Soma of the rich person who wants to drink Soma to me, who wants to drink Soma."
                    : "वैनतेय सोमं पिब सोमं पिबतु वृत्रहा।\n"
                        "सोमं धनस्य सोमिनो मह्यं ददातु सोमिनः ॥22॥\n\n"
                        "अर्थ – हे गरुड ! आप सोमपान करें। वृत्रासुर के विनाशक इन्द्र सोमपान करें। वे गरुड तथा इन्द्र धनवान सोमपान करने की इच्छा वाले के सोम को मुझ सोमपान की अभिलाषा वाले को प्रदान करें."),

                _buildSectionContent(_isEnglish
                    ? "न क्रोधो न च मात्सर्यं न लोभो नाशुभा मतिः।\n"
                        "भवन्ति कृतपुण्यानां भक्त्या श्रीसूक्तजापिनाम् ॥23॥\n\n"
                        "Meaning – The virtuous people who chant Sri Sukta with devotion, neither get angry, nor feel jealous, nor are they afflicted by greed and their intellect does not get corrupted."
                    : "न क्रोधो न च मात्सर्यं न लोभो नाशुभा मतिः।\n"
                        "भवन्ति कृतपुण्यानां भक्त्या श्रीसूक्तजापिनाम् ॥23॥\n\n"
                        "अर्थ – भक्तिपूर्वक श्री सूक्त का जप करनेवाले, पुण्यशाली लोगों को न क्रोध होता है, न ईर्ष्या होती है, न लोभ ग्रसित कर सकता है और न उनकी बुद्धि दूषित ही होती है."),

                _buildSectionContent(_isEnglish
                    ? "सरसिजनिलये सरोजहस्ते\n"
                        "धवलतरांशुकगन्धमाल्यशोभे।\n"
                        "भगवति हरिवल्लभे मनोज्ञे\n"
                        "त्रिभुवनभूतिकरि प्र सीद मह्यम् ॥24॥\n\n"
                        "Meaning – Goddess Bhagwati, who is a lotus dweller, who holds a lotus in her hand, who is adorned with very white clothes, perfume and garlands, who is beloved of Lord Vishnu and who bestows prosperity on all three worlds. Be happy with me."
                    : "सरसिजनिलये सरोजहस्ते\n"
                        "धवलतरांशुकगन्धमाल्यशोभे।\n"
                        "भगवति हरिवल्लभे मनोज्ञे\n"
                        "त्रिभुवनभूतिकरि प्र सीद मह्यम् ॥24॥\n\n"
                        "अर्थ – कमलवासिनी, हाथ में कमल धारण करनेवाली, अत्यन्त धवल वस्त्र, गन्धानुलेप तथा पुष्पहार से सुशोभित होनेवाली, भगवान विष्णु की प्रिया लावण्यमयी तथा त्रिलोकी को ऐश्वर्य प्रदान करनेवाली हे भगवति ! मुझपर प्रसन्न होइये."),

                _buildSectionContent(_isEnglish
                    ? "विष्णुपत्नीं क्षमां देवीं माधवीं माधवप्रियाम्।\n"
                        "लक्ष्मीं प्रियसखीं भूमिं नमाम्यच्युतवल्लभाम् ॥25॥\n\n"
                        "Meaning – I salute Lord Vishnu's wife, Kshamaswarupini, Madhavi, Madhavpriya, Priyasakhi, Achyutavallabha, Bhudevi Bhagwati Lakshmi."
                    : "विष्णुपत्नीं क्षमां देवीं माधवीं माधवप्रियाम्।\n"
                        "लक्ष्मीं प्रियसखीं भूमिं नमाम्यच्युतवल्लभाम् ॥25॥\n\n"
                        "अर्थ – भगवान विष्णु की भार्या, क्षमास्वरूपिणी, माधवी, माधवप्रिय, प्रियसखी, अच्युतवल्लभा, भूदेवी भगवती लक्ष्मी को मैं नमस्कार करता हूँ."),

                // Section for the first verse and its meaning
                _buildSectionContent(_isEnglish
                    ? "महालक्ष्म्यै च विद्महे विष्णुपत्न्यै च धीमहि।\n"
                        "तन्नो लक्ष्मीः प्रचोदयात् ॥26॥\n\n"
                        "Meaning – We know Vishnu's wife Mahalakshmi and meditate on her. May Goddess Lakshmi inspire us to follow the right path."
                    : "महालक्ष्म्यै च विद्महे विष्णुपत्न्यै च धीमहि।\n"
                        "तन्नो लक्ष्मीः प्रचोदयात् ॥26॥\n\n"
                        "अर्थ – हम विष्णु पत्नी महालक्ष्मी को जानते हैं तथा उनका ध्यान करते हैं। वे लक्ष्मीजी सन्मार्ग पर चलने के लिये हमें प्रेरणा प्रदान करें."),

// Section for the second verse and its meaning
                _buildSectionContent(_isEnglish
                    ? "आनन्दः कर्दमः श्रीदश्चिक्लीत इति विश्रुताः।\n"
                        "ऋषयः श्रियः पुत्राश्च श्रीर्देवीर्देवता मताः ॥27॥\n\n"
                        "Meaning – In the previous Kalpa, there were four famous sages named Anand, Kardam, Shrid and Chiklit. In the next Kalpa also, they were the sons of Lakshmi with the same names. Later, Mahalakshmi was born with a very luminous body from those sons. The gods were also blessed by the same Mahalakshmi."
                    : "आनन्दः कर्दमः श्रीदश्चिक्लीत इति विश्रुताः।\n"
                        "ऋषयः श्रियः पुत्राश्च श्रीर्देवीर्देवता मताः ॥27॥\n\n"
                        "अर्थ – पूर्व कल्प में जो आनन्द, कर्दम, श्रीद और चिक्लीत नामक विख्यात चार ऋषि हुए थे। उसी नाम से दूसरे कल्प में भी वे ही सब लक्ष्मी के पुत्र हुए। बाद में उन्हीं पुत्रों से महालक्ष्मी अति प्रकाशमान शरीर वाली हुईं, उन्हीं महालक्ष्मी से देवता भी अनुगृहीत हुए."),

// Section for the third verse and its meaning
                _buildSectionContent(_isEnglish
                    ? "ऋणरोगादिदारिद्र्यपापक्षुदपमृत्यवः।\n"
                        "भयशोकमनस्तापा नश्यन्तु मम सर्वदा ॥28॥\n\n"
                        "Meaning – Debt, disease, poverty, sin, hunger, untimely death, fear, grief and mental tension etc. – may all these obstacles of mine be destroyed forever."
                    : "ऋणरोगादिदारिद्र्यपापक्षुदपमृत्यवः।\n"
                        "भयशोकमनस्तापा नश्यन्तु मम सर्वदा ॥28॥\n\n"
                        "अर्थ – ऋण, रोग, दरिद्रता, पाप, क्षुधा, अपमृत्यु, भय, शोक तथा मानसिक ताप आदि – ये सभी मेरी बाधाएँ सदा के लिये नष्ट हो जाएँ."),

// Section for the fourth verse and its meaning
                _buildSectionContent(_isEnglish
                    ? "श्रीर्वर्चस्वमायुष्यमारोग्यमाविधाच्छोभमानं महीयते।\n"
                        "धनं धान्यं पशुं बहुपुत्रलाभं शतसंवत्सरं दीर्घमायुः ॥29॥\n\n"
                        "Meaning – Goddess Mahalakshmi should provide the human with vigour, longevity, health, wealth, grains, many sons and a long life of hundred years and the human should get prestige by being adorned by these."
                    : "श्रीर्वर्चस्वमायुष्यमारोग्यमाविधाच्छोभमानं महीयते।\n"
                        "धनं धान्यं पशुं बहुपुत्रलाभं शतसंवत्सरं दीर्घमायुः ॥29॥\n\n"
                        "अर्थ – भगवती महालक्ष्मी मानव के लिये ओज, आयुष्य, आरोग्य, धन-धान्य, पशु, अनेक पुत्रों की प्राप्ति तथा सौ वर्ष के दीर्घ जीवन का विधान करें और मानव इनसे मण्डित होकर प्रतिष्ठा प्राप्त करे."),

                // _buildSectionTitle(_isEnglish ?"" :"" ),
                //
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
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Card(
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
