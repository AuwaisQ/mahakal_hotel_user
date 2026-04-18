import 'dart:async';
import 'package:flutter/material.dart';

import '../../controller/share_helper.dart';
import 'commanbannerwidget.dart';

class HartalikaTeej extends StatefulWidget {
  const HartalikaTeej({super.key});

  @override
  _HartalikaTeejState createState() => _HartalikaTeejState();
}

class _HartalikaTeejState extends State<HartalikaTeej> {
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
        ShareHelper.shareContent(context, "हरतालिका तीज व्रत कथा");
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
          _isEnglish ? 'Hartalika Teej Vrat' : "हरतालिका तीज व्रत",
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
            child: Column(
              children: [
                const CommanBannerWidget(
                  imagePath: 'assets/image/hartalika_teej.jpg',
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(_isEnglish
                          ? "About Hartalika Teej"
                          : "हरतालिका तीज के बारे में:"),
                      _buildSectionContent(_isEnglish
                          ? "The word Hartalika is made up of two words, 'Harat' and 'Aalika': Harat means kidnapping, Aalika means female friend.\n\n"
                              "So, Hartalika means 'abduction by friends'. Hartalika Teej is celebrated on the third day of Shukla Paksha of Bhadrapada month. This festival is mainly of women. On this day, worship is done for the long life and happiness and prosperity of the husband.\n\n"
                              "Hartalika Teej fast This festival is celebrated every year on the third day of Shukla Paksha of Bhadrapada month. By observing this fast, blessings of Lord Shiva and Mother Parvati are received and all the troubles of life are removed. The festival of Hartalika Teej is celebrated keeping in mind the unbreakable relationship between Lord Shiva and Mother Parvati. On this day, women worship by doing 16 adornments and get the blessings of unbroken good fortune. Also, they listen to the story of Hartalika Teej. Just by listening and reading the story of Hartalik Teej, one gets the blessings of Lord Shiva and Mother Parvati and happiness, peace and prosperity increases. This story is considered very sacred, so one must listen and read the story of Hartalik Teej on this day…\n\n"
                              "Goddess Parvati performed rigorous penance in the forest to please Lord Shiva. Due to Goddess Parvati's determination, Lord Shiva blessed her so that her wish to marry him was fulfilled. Since a friend of Goddess Parvati helped her to get Lord Shiva as her husband, this day is also celebrated as a unity of friendship among female friends!"
                          : "हरतालिका शब्द दो शब्दों से मिलकर बना है, 'हरत' और 'आलिका': हरत का अर्थ है अपहरण, आलिका का अर्थ है महिला मित्र.\n\n"
                              "इसलिए, हरतालिका का मतलब है, 'सखियों द्वारा हरण'. हरतालिका तीज, भाद्रपद महीने के शुक्ल पक्ष की तृतीया को मनाई जाती है. यह त्योहार मुख्य रूप से महिलाओं का होता है. इस दिन सुहाग की लंबी उम्र और सुख-समृद्धि के लिए पूजा की जाती है.\n\n"
                              "हरतालिका तीज का व्रत यह पर्व हर वर्ष भाद्रपद माह के शुक्ल पक्ष तृतीया तिथि को मनाते हैं। इस व्रत के करने से भगवान शिव और माता पार्वती का आशीर्वाद प्राप्त होता है और जीवन के सभी कष्ट दूर होते हैं। हरतालिका तीज का पर्व भगवान शिव और माता पार्वती के अटूट रिश्तो को ध्यान में रखकर किया जाता है। इस दिन महिलाएं 16 श्रृंगार करके पूजा अर्चना करती हैं और अखंड सौभाग्य का आशीर्वाद प्राप्त करती हैं। साथ ही फिर हरतालिका तीज की कथा सुनती हैं। हरतालिक तीज के कथा सुनने व पढ़ने मात्र से भगवान शिव और माता पार्वती का आशीर्वाद प्राप्त होता है और सुख-शांति और समृद्धि में वृद्धि होती है। यह कथा बहुत पवित्र मानी जाती है इसलिए इस दिन हरतालिका तीज की कथा अवश्य सुननी व पढ़नी चाहिए…\n\n"
                              "देवी पार्वती ने भगवान शिव को प्रसन्न करने के लिए जंगल में कठोर तपस्या की थी। देवी पार्वती के दृढ़ संकल्प के कारण, भगवान शिव ने उन्हें आशीर्वाद दिया ताकि उनसे विवाह करने की उनकी इच्छा पूरी हो जाए। चूँकि देवी पार्वती की एक सहेली ने उन्हें भगवान शिव को पति के रूप में पाने में मदद की थी, इसलिए इस दिन को महिला मित्रों के बीच दोस्ती की एकजुटता के रूप में भी मनाया जाता है!"),

                      _buildSectionTitle(_isEnglish
                          ? "Hartalika Teej Puja Vidhi:"
                          : "हरतालिका तीज की पूजा विधि :"),
                      _buildBulletPoint(_isEnglish
                          ? "Get up early in the morning, take a bath and clean the temple."
                          : "सुबह जल्दी उठकर स्नान करें और मंदिर की सफ़ाई करें."),
                      _buildBulletPoint(_isEnglish
                          ? "Install the idol of Lord Shiva and Mother Parvati on the chowki."
                          : "चौकी पर भगवान शिव और माता पार्वती की मूर्ति स्थापित करें."),
                      _buildBulletPoint(_isEnglish
                          ? "Offer sixteen Shringar items to Mother Parvati."
                          : "मां पार्वती को सोलह श्रृंगार की चीज़ें अर्पित करें."),
                      _buildBulletPoint(_isEnglish
                          ? "Offer Belpatra, flowers, Shamipatri, Dhatura, Bhang, Malayagiri Chandan, and Aksh at to Lord Shiva."
                          : "भगवान शिव को बेलपत्र, फूल, शमिपत्री, धतूरा, भांग, मलयागिरि चंदन, और अक्षत चढ़ाएं."),
                      _buildBulletPoint(_isEnglish
                          ? "Apply Tilak to Shri Ganesh and offer Durva."
                          : "श्रीगणेश को तिलक लगाएं और दूर्वा अर्पित करें."),
                      _buildBulletPoint(_isEnglish
                          ? "Light a lamp and incense stick in front of the idol."
                          : "प्रतिमा के सामने दीपक और धूपबत्ती जलाएं."),
                      _buildBulletPoint(_isEnglish
                          ? "Recite Hartalika Teej Vrat Katha."
                          : "हरतालिका तीज व्रत कथा का पाठ करें."),
                      _buildBulletPoint(_isEnglish
                          ? "Perform Aarti of Lord Shiva and Goddess Parvati."
                          : "भगवान शिव और माता पार्वती की आरती करें."),
                      _buildBulletPoint(
                          _isEnglish ? "Offer Prasad." : "प्रसाद लगाएं."),
                      _buildBulletPoint(_isEnglish
                          ? "Distribute Prasad to family members and consume it yourself."
                          : "परिवारजनों को प्रसाद बांटें और खुद भी ग्रहण करें."),
                      _buildBulletPoint(_isEnglish
                          ? "Break the fast the next day and make donations."
                          : "अगले दिन व्रत पारण करें और दान करें."),

                      const SizedBox(height: 10),

                      // Materials required for Hartalika Teej Puja Section
                      _buildSectionTitle(_isEnglish
                          ? "Materials required for Hartalika Teej Puja:"
                          : "हरतालिका तीज की पूजा के लिए ज़रूरी सामग्री:"),
                      _buildBulletPoint(
                          _isEnglish ? "Wet black soil." : "गीली काली मिट्टी."),
                      _buildBulletPoint(
                          _isEnglish ? "Wooden plank." : "लकड़ी का पाटा."),
                      _buildBulletPoint(
                          _isEnglish ? "Yellow cloth." : "पीला कपड़ा."),
                      _buildBulletPoint(_isEnglish ? "Coconut." : "नारियल."),
                      _buildBulletPoint(_isEnglish ? "Dupatta." : "चुनरी."),
                      _buildBulletPoint(_isEnglish ? "Kumkum." : "कुमकुम."),
                      _buildBulletPoint(
                          _isEnglish ? "Banana leaf." : "केले का पत्ता."),
                      _buildBulletPoint(_isEnglish ? "Batashas." : "बताशे."),

                      const SizedBox(height: 10),

                      // Start of Hartalika Teej Vrat Katha Section
                      _buildSectionTitle(_isEnglish
                          ? "Start of Hartalika Teej Vrat Katha:"
                          : "हरतालिका तीज व्रत कथा आरंभ :"),
                      _buildSectionContent(_isEnglish
                          ? "I salute both Bhavani-Shankar, whose hair is adorned with garland of Mandar (Aak) flowers and Lord Shankar, who has moon on his forehead and garland of skulls around his neck, Goddess Parvati who is wearing divine clothes and Lord Shankar who is in Digambar attire.\n\n"
                              "Once on the peak of Kailash mountain, Goddess Parvati asked Mahadev ji- O Lord! Tell me the most secret thing which is simpler than all religions and gives great results to everyone. O Nath! If you are pleased, then please reveal it to me. O Jagat Nath! You are without beginning, middle and end, there is no limit to your Maya. How have I attained you? By the virtue of which fast, penance or donation did I get you as a boon? Please tell me.\n\n"
                              "Mahadev said- O Goddess! Listen, I am telling you about that fast which is the most secret, just like the moon is the best among the stars and the sun is the best among the planets, Brahmin is the best among the castes, Ganga is the best among the gods, Mahabharata is the best among the Puranas, Sama is the best among the Vedas and mind is the best among the senses. Similarly, it has been described in all the Puranas and Vedas. Due to whose effect you have got half of my seat. O beloved! I am describing that to you, listen- by merely performing this fast on the day of Tritiya (Teej) of the Shukla Paksha of Bhadrapada (Bhadon) month with Hasta Nakshatra, all sins are destroyed. You had earlier observed this great fast on the Himalayas, let me tell you. Parvati ji said- O Lord, I want to hear why I observed this fast. So please tell me. Shankar Ji said- There is a great mountain named Himalaya in Aryavarta, where many types of land are adorned with many types of trees, which are always covered with snow and Om is resonating with the sound of the murmuring of the Ganges. O Parvati Ji! You had performed extreme penance at the same place in your childhood and did penance by staying in water for twelve years and by entering fire in the month of Vaishakh. In the month of Shravan, on the third day of the month with Hasta Nakshatra in the open month, you worshipped me with rituals and kept vigil singing songs at night.\n\n"
                              "Due to the effect of that great vow of yours, my seat started shaking. I reached the same place where both you and your friend were. I came and said to you, O Varna, I am pleased with you, ask me what boon you want from me. Then you said, O Dev, if you are pleased with me then you should be my husband. - Saying 'Tathastu', I went to Mount Kailash and as soon as it was morning, you immersed my sand idol in the river. O Shubhe, you observed the fast there along with your friend. Meanwhile, your father Himavan also reached the same dense forest while searching for you. At that time, he saw two girls on the bank of the river, so he came to you and started crying while hugging you. And said- Daughter, why did you come to this dense forest full of lions and tigers?\n\n"
                              "Then you said, O father, I had already dedicated my body to Shankar ji, but, you did the opposite. That is why I came to the forest. Hearing this, Himavan told you that I will not do this against your wish. Then he took you home and returned and got you married to me. O beloved, due to the effect of that fast, you have received my Ardhaasan. I have also not described this Vratraj to anyone till now.\n\n"
                              "O Goddess! Now I tell you why this fast got this name? Your friend had kidnapped you, that is why it was named Hartalika. Parvati ji said- O Lord! You have told me the name of this Vratraj, but please also tell me its method and result, what result is obtained by doing it. Then Lord Shankar said- Listen to the method of this best fast for women. Women who desire good fortune should observe this fast according to the method. Make a pavilion with banana pillars and decorate it with garlands. Stretch a chandelier of fine silk cloth of various colors over it. Women should gather after applying fragrant substances like sandalwood etc. Play conch, bheri, mridang etc. After performing auspicious rituals, install the sand made idol of Shri Gauri Shankar. Then worship Lord Shiva Parvati ji according to the method with fragrance, incense, flowers etc. Offer many offerings and stay awake at night. Collect coconut, betel nut, jamwari, lemon, clove, pomegranate, orange etc. seasonal fruits and flowers and worship with incense, lamp etc. and say- O Shiva, the embodiment of welfare! O auspicious Shiva! O auspicious Maheshwari! O Shiva! Salutations to you, the goddess of auspiciousness who fulfills all wishes. Mother Parvati, the form of auspiciousness, we salute you. We always salute Lord Shankar. O Brahma-form (mother) who nurtures the world, salutations to you. O lion-rider! I am troubled by worldly fear, please protect me. O Maheshwari! I have worshipped you with this desire. O Parvati, please be pleased with me and grant me happiness and good fortune. Worship Shankar ji along with Uma with these words. After listening to the story as per rituals, donate cow, clothes, ornaments etc. to Brahmins. In this way, all the sins of the person observing the fast are destroyed.\n\n"
                          : "जिनके केशों पर मंदार (आक) के पुष्पों की माला शोभा देती है और जिन भगवान शंकर के मस्तक पर चंद्र और गले में मुण्डों की माला पड़ी हुई है, जो माता पार्वती दिव्य वस्त्रों से तथा भगवान शंकर दिगंबर वेष धारण किए हैं, उन दोनों भवानी-शंकर को नमस्कार करता हूं।\n\n"
                              "एक बार कैलाश पर्वत के शिखर पर माता पार्वती जी ने महादेव जी से पूछा-हे प्रभु! मुझ से आप वह गुप्त से गुप्त वार्ता कहिए जो सबके लिए सब धर्मों से भी सरल तथा महान फल देने वाली हो। हे नाथ! यदि आप प्रसन्न हैं तो आप उसे मेरे सम्मुख प्रकट की \n\n"
                              "जाए। हे जगत नाथ! आप आदि, मध्य और अंत रहित हैं, आपकी माया का कोई पार नहीं है। आपको मैंने किस भांति प्राप्त किया है? कौन से व्रत, तप या दान के पुण्य फल से आप मुझको वर रूप में मिले? कृपया करके बताएं।\n\n"
                              "महादेव बोले-हे देवी ! सुनिए, मैं आपके सम्मुख उस व्रत को कहता हूं, जो परम गुप्त है, जैसे तारागणों में चंद्रमा और ग्रहों से सूर्य, वर्णों में ब्राह्मण, देवताओं में गंगा, पुराणों में महाभारत, वेदों में साम और इन्द्रियों में मन श्रेष्ठ है। वैसे ही पुराण और वेद सबमें इसका वर्णन किया गया है। जिसके प्रभाव से तुमको मेरा आधा आसन प्राप्त हुआ है। हे प्रिये ! उसी का मैं तुमसे वर्णन करता हूं, सुनो-भाद्रपद (भादों) मास के शुक्ल पक्ष की हस्त नक्षत्र संयुक्त तृतीया (तीज) के दिन इस व्रत का अनुष्ठान मात्र करने से सब पापों का नाश हो जाता है। तुमने पहले हिमालय पर्वत पर इस महान व्रत को किया था, जो मैं तुम्हें सुनाता दूं। पार्वती जी बोली-हे प्रभु इस व्रत को मैंने किसलिए किया था, यह मुझे सुनने की इच्छा हो रही है। तो कृपा करके मुझसे कहिए।\n\n"
                              "शंकर जी बोले-आर्यावर्त में हिमालय नामक एक महान पर्वत है, जहां अनेक प्रकार की भूमि अनेक प्रकार के वृक्षों से सुशोभित है, जो सदैव बर्फ से ढके हुए तथा गंगा की कल-कल ध्वनि से शब्दायमान ओम रहता है। हे पार्वती जी ! तुमने बाल्यकाल में उसी स्थान पर परम तप किया था और बारह वर्ष तक के महीने में जल में रहकर तथा वैशाख मास में अग्नि में प्रवेश करके तप किया। श्रावण के महीने में बाहर खुले मास की हस्त नक्षत्र युक्त तृतीया के दिन तुमने मेरा विधि विधान से पूजन किया तथा रात्रि को गीत गाते हुए जागरण किया।\n\n"
                              "तुम्हारे उस महाव्रत के प्रभाव से मेरा आसन डोलने लगा। मैं उसी स्थान पर आ पहुंचा जहां तुम और तुम्हारी सखी दोनों थीं। मैंने आकर तुमसे कहा हे वरानने, मैं तुमसे प्रसन्न हूं, मागों तुम मुझसे वरदान में क्या मांगना चाहती हो। तब तुमने कहा कि हे देव, यदि आप मुझसे प्रसन्न हैं तो आप मेरे पति हों। - मैं 'तथास्तु' ऐसा कहकर कैलाश पर्वत को चला गया और तुमने प्रभात होते ही मेरी उस बालू की प्रतिमा को नदी में विसर्जित कर दिया। हे शुभे, तुमने वहां अपनी सखी सहित व्रत का पारायण किया। इतने में तुम्हारे पिता हिमवान भी तुम्हें ढूंढते-ढूंढते उसी घने वन में आ पहुंचे। उस समय उन्होंने नदी के तट पर दो कन्याओं को देखा तो वे तुम्हारे पास आ गये और तुम्हें हृदय से लगाकर रोने लगे। और बोले-बेटी तुम इस सिंह व्याघ्नदि युक्त घने जंगल में क्यों चली आई?\n\n"
                              "तब तुमने कहा हे पिता, मैंने पहले ही अपना शरीर शंकर जी को समर्पित कर दिया था, लेकिन, आपने इसके विपरीत कार्य किया। इसलिए मैं वन में चली आई। ऐसा सुनकर हिमवान ने तुमसे कहा कि मैं तुम्हारी इच्छा के विरुद्ध यह कार्य नहीं करूंगा। तब वे तुम्हें लेकर घर और वापस लौट आए और तुम्हारा विवाह मेरे साथ कर दिया। हे प्रिये, उसी व्रत के प्रभाव से तुमको मेरा अर्द्धासन प्राप्त हुआ है। इस व्रतराज को मैंने भी अभी तक किसी के सम्मुख वर्णन नहीं किया है।\n\n"
                              "हे देवी! अब मैं तुम्हें यह बताता हूं कि इस व्रत का यह नाम क्यों पड़ा? तुमको सखी हरण करके ले गई थी, इसलिए हरतालिका नाम पड़ा। पार्वती जी बोलीं- हे स्वामी! आपने इस व्रतराज का नाम तो बता दिया लेकिन, मुझे इसकी विधि और फल भी बताइए कि इसके करने से किस फल की प्राप्ति होती है। तब भगवान शंकर जी बोले-इस स्त्री जाति के अत्युत्तम व्रत की विधि सुनिये। सौभाग्य की इच्छा रखने वाली स्त्रियां इस व्रत को विधि पूर्वक करें। केले के खम्भों से मण्डप बनाकर उसे वन्दनवार ों से सुशोभित करें। उसमें विविध रंगों के उत्तम रेशमी वस्त्र की चांदनी ऊपर तान दें। चंदन आदि सुगन्धित द्रव्यों को लेपन करके स्त्रियां एकत्र हों। शंख, भेरी, मृदंग आदि बजायें। विधि पूर्वक मंगलाचार करके श्री गौरी शंकर की बालू निर्मित प्रतिमा स्थापित करें। फिर भगवान शिव पार्वती जी का गन्ध, धूप, पुष्प आदि से विधि पूर्वक पूजन करें।\n\n"
                              "अनेकों नैवेद्यों का भोग लगाएं और रात के समय जागरण करें। नारियल, सुपारी, जंवारी, नींबू, लौंग, अनार, नारंगी आदि ऋतु फलों तथा फूलों को एकत्रित करके धूप, दीप आदि से पूजन करके कहें-हे कल्याण स्वरूप शिव! हे मंगल रूप शिव ! हे मंगल रूप महेश्वरी! हे शिवे! सब कामनाओं को देने वाली देवी कल्याण रूप तुम्हें नमस्कार है। कल्याण स्वरुप माता पार्वती, हम तुम्हें नमस्कार करते हैं। भगवान शंकर जी को सदैव नमस्कार करते हैं। हे ब्रह्म रुपिणी जगत का पालन करने वाली (मां) आपको नमस्कार है। हे सिंहवाहिनी! मैं सांसारिक भय से व्याकुल हूं, तुम मेरी रक्षा करो। हे महेश्वरी ! मैंने इसी अभिलाषा से आपका पूजन किया है। हे पार्वती माता आप मेरे ऊपर प्रसन्न होकर मुझे सुख और सौभाग्य प्रदान कीजिए। इस प्रकार के शब्दों द्वारा उमा सहित शं कर जी का पूजन करें। विधिपूर्वक कथा सुनकर गौ, वस्त्र, आभूषण आदि ब्राह्मणों को दान करें। इस प्रकार से व्रत करने वाले के सब पाप नष्ट हो जाते हैं।\n\n"),

                      Center(
                          child: _buildSectionTitle(_isEnglish
                              ? " ( Arti Lyrics)"
                              : " ( ओम जय शिव ओंकारा, आरती)")),
                      _buildSectionContent(_isEnglish
                          ? "Jai Shiv Omkaara, Om Jai Shiva Omkara,\n"
                              "Bramha, Vishnu, Sadashiv, Ardhangi Dhaara.\n"
                              "Om Jai Shiv Omkara\n"
                              "Ekaanan Chaturaanan Panchaanan Raje,\n"
                              "Hansaanan Garudaasan Vrishvaahan Saaje.\n"
                              "Om Jai Shiv Omkara\n"
                              "Do Bhuj Chaar Chaturbhuj Dasamukh Ati Sohe,\n"
                              "Trigun Rup Nirakhate Tribhuvan Jan Mohe.\n"
                              "Om Jai Shiv Omkara\n"
                              "Akshamaala Vanamaala Mundamaala Dhaari,\n"
                              "Tripuraari Kansaari Kar Maala Dhaari.\n"
                              "Om Jai Shiv Omkara\n"
                              "Shvetambar Pitambar Baaghambar Ange,\n"
                              "Sanakaadik Garunaadik Bhutaadik Sange.\n"
                              "Om Jai Shiv Omkara\n"
                              "Kar Ke Madhy Kamandalu Charka Trishuladhaari,\n"
                              "Sukhakaari Dukhahaari Jagapaalan Kaari.\n"
                              "Om Jai Shiv Omkara\n"
                              "Bramha Vishnu Sadaashiv Jaanat Aviveka,\n"
                              "Pranavaakshar Mein Shobhit Ye Tino Ekaa.\n"
                              "Om Jai Shiv Omkara\n"
                              "Lakshmi Va Saavitri Paarvati Sangaa,\n"
                              "Paarvati Ardhaangi, Shivalahari Gangaa.\n"
                              "Om Jai Shiv Omkaara\n"
                              "Parvat Sohe Parvati, Shankar Kailasa,\n"
                              "Bhang Dhatur Ka Bhojan, Bhasmi Mein Vaasa.\n"
                              "Om Jai Shiv Omkaara\n"
                              "Jataa Me Gang Bahat Hai, Gal Mundan Maala,\n"
                              "Shesh Naag Lipataavat, Odhat Mrugachaala.\n"
                              "Om Jai Shiv Omkaara\n"
                              "Kashi Me Viraaje Vishvanaath, Nandi Bramhchaari,\n"
                              "Nit Uthh Darshan Paavat, Mahimaa Ati Bhaari.\n"
                              "Om Jai Shiv Omkaara\n"
                              "Trigunasvamiji Ki Aarti Jo Koi Nar Gave,\n"
                              "Kahat Shivanand Svami Sukh Sampati Pave.\n"
                              "Om Jai Shiv Omkaara."
                          : "ब्रह्मा, विष्णु, सदाशिव, अ र्द्धांगी धारा॥ ओम जय शिव ओंकारा॥\n"
                              "ओम जय शिव ओंकारा, स्वामी जय शिव ओंकारा।\n"
                              "एकानन चतुरानन पञ्चानन राजे।\n"
                              "हंसासन गरूड़ासन वृषवाहन साजे॥ ओम जय शिव ओंकारा॥\n"
                              "दो भुज चार चतुर्भुज दसभुज अति सोहे।\n"
                              "त्रिगुण रूप निरखत त्रिभुवन जन मोहे॥ ओम जय शिव ओंकारा॥\n"
                              "अक्षमाला वनमाला मुण्डमालाधारी।\n"
                              "त्रिपुरारी कंसारी कर माला धारी॥ ओम जय शिव ओंकारा॥\n"
                              "श्वेताम्बर पीताम्बर बाघंबर अंगे।\n"
                              "सनकादिक गरुड़ादिक भूतादिक संगे॥ ओम जय शिव ओंकारा॥\n"
                              "कर के मध्य कमण्डल चक्र त्रिशूलधारी।\n"
                              "जगकर्ता जगभर्ता जगसंहारकर्ता॥ ओम जय शिव ओंकारा॥\n"
                              "ब्रह्मा विष्णु सदाशिव जानत अविवेका।\n"
                              "प्रणवाक्षर के मध्य ये तीनों एका॥ ओम जय शिव ओंकारा॥\n"
                              "पर्वत सोहैं पार्वती, शंकर कैलासा।\n"
                              "भांग धतूरे का भोजन, भस्मी में वासा॥ ओम जय शिव ओंकारा॥\n"
                              "जटा में गंग बहत है, गल मुण्डन माला।\n"
                              "शेष नाग लिपटावत, ओढ़त मृगछाला॥ ओम जय शिव ओंकारा॥\n"
                              "काशी में विराजे विश्वनाथ, नन्दी ब्रह्मचारी।\n"
                              "नित उठ दर्शन पावत, महिमा अति भारी॥ ओम जय शिव ओंकारा॥\n"
                              "त्रिगुणस्वामी जी की आरति जो कोइ नर गावे।\n"
                              "कहत शिवानन्द स्वामी, मनवान्छित फल पावे॥\n"
                              "ओम जय शिव ओंकारा॥ स्वामी ओम जय शिव ओंकारा॥\n"),
                    ],
                  ),
                ),
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
