import 'dart:async';
import 'package:flutter/material.dart';

import '../../controller/share_helper.dart';
import 'commanbannerwidget.dart';

class VaibhavLaxmi extends StatefulWidget {
  const VaibhavLaxmi({super.key});

  @override
  State<VaibhavLaxmi> createState() => _VaibhavLaxmiState();
}

class _VaibhavLaxmiState extends State<VaibhavLaxmi> {
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
        ShareHelper.shareContent(context, "वैभव लक्ष्मी व्रत कथा");
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
          _isEnglish ? 'Vaibhav Lakshmi' : "वैभव लक्ष्‍मी",
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
                // _buildSectionContent(_isEnglish ?"" :"" ),
                // _buildSectionContent(_isEnglish
                //     ?""
                //     :""
                // ),

                const SizedBox(height: 1),

                const CommanBannerWidget(
                  imagePath:
                      'assets/sahitya_images/Vaibhav Laxmi Vrat Katha.jpg',
                ),

                _buildSectionTitle(_isEnglish
                    ? "Vaibhav Lakshmi Vrat Katha"
                    : "वैभव लक्ष्मी व्रत के बारे में:"),
                _buildSectionContent(_isEnglish
                    ? "Vaibhav Lakshmi Vrat is observed on Friday. In this fast, the Ashtalakshmi form of Goddess Lakshmi is worshiped and the story of the fast is recited. It is said that for the fulfillment of wishes, one should observe the Vaibhav Lakshmi fast on at least 11 or 21 Fridays and then conclude this fast by performing Udyaapan.\n\n"
                        "There is a law to worship Goddess Lakshmi for wealth. But the worship of the Vaibhav Lakshmi form of Goddess Lakshmi is considered to be of special importance. This fast is observed on Friday. This fast can be observed not only by women but also by men. All the wishes of the fasting person are fulfilled by this fast. Happiness, prosperity and good fortune increase."
                    : "वैभव लक्ष्मी व्रत शुक्रवार के दिन किया जाता है। इस व्रत में देवी लक्ष्मी के अष्टलक्ष्मी स्वरूप की पूजा की जाती है और व्रत की कथा का पाठ किया जाता है। कहते हैं जो मनोकामना पूर्ति के लिए कम से कम 11 अथवा 21 शुक्रवार को वैभव लक्षमी का व्रत रखना चाहिए और फिर उद्यापन करके इस व्रत का समापना करना चाहिए।\n\n"
                        "धन के लिए मां लक्ष्‍मी की पूजा का विधान है। लेकिन मां लक्ष्‍मी के वैभव लक्ष्‍मी स्‍वरूप की पूजा का विशेष महत्‍व माना गया है। यह व्रत शुक्रवार के दिन रखा जाता है। यह व्रत स्‍त्री ही नहीं बल्कि पुरुष भी रख सकते हैं। इस व्रत से व्रती की सभी मनोकामनाएं पूरी होती हैं। सुख-समृद्धि और सौभाग्‍य में वृद्धि होती है।"),

                _buildSectionTitle(_isEnglish
                    ? "Vaibhav Lakshmi Vrat Vidhi:"
                    : "वैभव लक्ष्मी व्रत  विधि :"),
                _buildBulletPoint(_isEnglish
                    ? "Vaibhav Lakshmi Vrat is observed on Friday."
                    : "वैभव लक्ष्मी व्रत शुक्रवार को किया जाता है."),
                _buildBulletPoint(_isEnglish
                    ? "Before observing the fast, take a bath in the morning and wear clean clothes."
                    : "व्रत करने से पहले सुबह स्नान करके साफ़ कपड़े पहनें."),
                _buildBulletPoint(_isEnglish
                    ? "Take a resolution for the fast and eat fruits throughout the day."
                    : "व्रत का संकल्प लें और पूरे दिन फलाहार करें."),
                _buildBulletPoint(_isEnglish
                    ? "In the evening, after taking a bath again, place a stool in the east direction and spread a red cloth on it."
                    : "शाम को दोबारा स्नान करके पूर्व दिशा में चौकी लगाएं और उस पर लाल कपड़ा बिछाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Place an idol or statue of Maa Lakshmi on the stool and keep a Shriyantra."
                    : "चौकी पर मां लक्ष्मी की मूर्ति या प्रतिमा स्थापित करें और श्रीयंत्र रखें."),
                _buildBulletPoint(_isEnglish
                    ? "Place a pile of rice in front of Maa Lakshmi's picture and place a copper urn filled with water on it."
                    : "मां लक्ष्मी की तस्वीर के सामने चावल का ढेर लगाएं और उस पर जल से भरा तांबे का कलश रखें."),
                _buildBulletPoint(_isEnglish
                    ? "Place silver coins or any gold-silver ornament on the urn."
                    : "कलश के ऊपर चांदी के सिक्के या कोई सोने-चांदी का आभूषण रखें."),
                _buildBulletPoint(_isEnglish
                    ? "Offer roli, mauli, vermilion, flowers, rice pudding etc."
                    : "रोली, मौली, सिंदूर, फूल, चावल की खीर आदि चढ़ाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Read Vaibhav Lakshmi Katha after the Puja."
                    : "पूजा के बाद वैभव लक्ष्मी कथा पढ़ें."),
                _buildBulletPoint(_isEnglish
                    ? "Chant Maa Lakshmi Mantra and perform Aarti."
                    : "मां लक्ष्मी मंत्र का जप करें और आरती करें."),
                _buildBulletPoint(_isEnglish
                    ? "Eat food after the evening Puja."
                    : "शाम को पूजा के बाद अन्न ग्रहण करें."),

                _buildSectionTitle(_isEnglish ? "Story" : "कथा"),
                _buildSectionContent(_isEnglish
                    ? "Lakhs of people lived in a city. Everyone was busy in their own work. No one cared for anyone. Values like bhajan-kirtan, devotion, kindness, charity had reduced. Evils had increased in the city. Many crimes like alcohol, gambling, racing, adultery, theft, robbery etc. used to happen in the city. Despite these, some good people also lived in the city. Sheela and her husband's household was considered to be among such people. Sheela was religious by nature and had a contented nature. Her husband was also prudent and well behaved. Sheela and her husband never spoke ill of anyone and were spending their time in the worship of God. The people of the city appreciated their household. The times changed in no time. Sheela's husband became friends with bad people. Now he started dreaming of becoming a millionaire as soon as possible. Therefore, he started walking on the wrong path. His condition had become like a beggar wandering on the road. He also got addicted to alcohol along with his friends. In this way, he lost everything.\n\n"
                        "Sheela was very sad with her husband's behavior, but she started tolerating everything by trusting God. She started spending most of her time in devotion to God. Suddenly one day in the afternoon, someone knocked at their door. When Sheela opened the door, she saw a mother standing there. There was a supernatural glow on her face. It was as if nectar was flowing from her eyes. Her majestic face was overflowing with compassion and love. On seeing her, Sheela felt immense peace in her heart. Sheela was filled with joy in every pore of her body. Sheela brought her home with respect. There was nothing to make her sit in the house. So Sheela made her sit on a torn sheet hesitantly. The mother said- Why Sheela! Didn't you recognize me? I also come to the Lakshmi temple every Friday during the bhajan-kirtan. Despite this, Sheela was not able to understand anything. Then the mother said- 'You have not come to the temple for a long time, so I came to see you.'\n\n"
                        "Sheela's heart melted with the mother's very loving words. Tears came to her eyes and she started crying bitterly. The mother said- 'Daughter! Happiness and sorrow are like sunshine and shade. Be patient daughter! Tell me all your problems.' Sheela got a lot of strength from the mother's behavior and in the hope of happiness, she told her mother her whole story. After listening to the story, Mataji said- 'Karma has its own course. Every person has to suffer the consequences of his deeds. So don't worry. Now you have suffered the consequences of your deeds. Now your days of happiness will surely come. You are a devotee of Maa Lakshmi. Maa Lakshmi is the incarnation of love and compassion. She always has affection for her devotees. So you should be patient and observe the fast of Maa Lakshmi. This will make everything fine.' On Sheela's asking, Mataji also told her the entire procedure of the fast. Mataji said- 'Daughter! The fast of Maa Lakshmi is very simple. It is called 'Varadalakshmi Vrat' or 'Vaibhav Lakshmi Vrat'. All the wishes of the one who observes this fast are fulfilled. He attains happiness, wealth and fame.'\n\n"
                        "Sheela was delighted to hear this. Sheela took a vow and opened her eyes but there was no one in front of her. She was surprised that where did Maaji go? It did not take long for Sheela to understand that Maaji was none other than Goddess Lakshmi herself. The next day was Friday. In the morning, after taking a bath and wearing clean clothes, Sheela observed the fast with full devotion as per the method told by Maaji. At the end, Prasad was distributed. This Prasad was fed to her husband first. As soon as the Prasad was eaten, there was a change in the nature of the husband. That day he did not beat Sheela, nor did he torture her. Sheela was very happy. Her faith in the 'Vaibhavlakshmi Vrat' increased. Sheela observed the 'Vaibhavlakshmi Vrat' with full faith and devotion for twenty-one Fridays. On the twenty-first Friday, after performing the Udya apan Vidhi as told by Maaji, she gifted seven books of 'Vaibhavlakshmi Vrat' to seven women. Then she bowed to the image of the goddess in the form of 'Dhanlakshmi' and started praying in her mind with emotion- 'O Maa Dhanlakshmi! I had vowed to do your 'Vaibhavlakshmi Vrat', I have completed that fast today. O Maa! Remove all my problems. Do good to all of us. Give a child to the one who does not have a child. Keep the good fortune of a fortunate woman intact. Give a pleasing husband to an unmarried girl. Remove all the problems of those who do this miraculous Vaibhav Lakshmi Vrat of yours. Make everyone happy. O Maa, your glory is infinite.' Saying this, she bowed to the image of Lakshmiji in the form of 'Dhanlakshmi'. Due to the effect of the fast, Sheela's husband became a good man and started doing business by working hard. He immediately redeemed Sheela's mortgaged jewelry. There was a flood of money in the house. There was happiness and peace in the house as before. Seeing the effect of the 'Vaibhav Lakshmi Vrat', other women of the locality also started observing the 'Vaibhav Lakshmi Vrat' according to the prescribed method.\n\n"
                        "Vaibhav Lakshmi Vrat should be observed with full devotion and emotion for seven, eleven or twenty-one Fridays, whatever number of Fridays you have vowed. On the last Friday, its Udyaapan should be done according to the classical method. On the last Friday, kheer should be prepared for Prasad. The way we worship every Friday, it should be done in the same way. After worship, break a coconut in front of the mother, then apply a tilak of kumkum to at least seven unmarried girls or fortunate women and gift them one copy each of the book of Maa Vaibhav Lakshmi Vrat Katha and give kheer prasad to everyone. After this, bow down to Maa Lakshmi with devotion. Then after paying obeisance to the image of the 'Dhan Lakshmi form' of the mother, pray in your mind with emotion- 'O Mother Dhan Lakshmi! I had vowed to observe your 'Vaibhavlakshmi Vrat'; I have completed that fast today. O Mother, fulfill my (state any wish you have) wish. Remove all my troubles. Do good to all of us. Give children to those who do not have children. Keep the good fortune of a fortunate woman intact. Give a desirable husband to an unmarried girl. Remove all the troubles of those who observe this miraculous Vaibhavlakshmi Vrat of yours. Make everyone happy. O Mother, your glory is boundless. Jai to you! Saying this, bow to the image of Lakshmiji in the form of 'Dhanlakshmi'."
                    : "किसी शहर में लाखों लोग रहते थे। सभी अपने-अपने कामों में रत रहते थे। किसी को किसी की परवाह नहीं थी। भजन-कीर्तन, भक्ति-भाव, दया-माया, परोपकार जैसे संस्कार कम हो गए। शहर में बुराइयां बढ़ गई थीं। शराब, जुआ, रेस, व्यभिचार, चोरी-डकैती वगैरह बहुत से गुनाह शहर में होते थे। इनके बावजूद शहर में कुछ अच्छे लोग भी रहते थे। ऐसे ही लोगों में शीला और उनके पति की गृहस्थी मानी जाती थी। शीला धार्मिक प्रकृति की और संतोषी स्वभाव वाली थी। उनका पति भी विवेकी और सुशील था। शीला और उसका पति कभी किसी की बुराई नहीं करते थे और प्रभु भजन में अच्छी तरह समय व्यतीत कर रहे थे। शहर के लोग उनकी गृहस्थी की सराहना करते थे। देखते ही देखते समय बदल गया। शीला का पति बुरे लोगों से दोस्ती कर बैठा। अब वह जल्द से जल्द करोड़पति बनने के ख्वाब देखने लगा। इसलिए वह गलत रास्ते पर चल पड़ा। उसकी हालत रास्ते पर भटकते भिखारी जैसी हो गई थी। दोस्तों के साथ उसे भी शराब की आदत हो गई। इस प्रकार उसने अपना सब कुछ गवां दिया।\n\n"
                        "शीला को पति के बर्ताव से बहुत दुःख हुआ, किंतु वह भगवान पर भरोसा कर सबकुछ सहने लगी। वह अपना अधिकांश समय प्रभु भक्ति में बिताने लगी। अचानक एक दिन दोपहर को उनके द्वार पर किसी ने दस्तक दी। शीला ने द्वार खोला तो देखा कि एक मांजी खड़ी थी। उसके चेहरे पर अलौकिक तेज निखर रहा था। उनकी आंखों में से मानो अमृत बह रहा था। उसका भव्य चेहरा करुणा और प्यार से छलक रहा था। उसको देखते ही शीला के मन में अपार शांति छा गई। शीला के रोम-रोम में आनंद छा गया। शीला उस मांजी को आदर के साथ घर में ले आई। घर में बिठाने के लिए कुछ भी नहीं था। अतः शीला ने सकुचाकर एक फटी हुई चद्दर पर उसको बिठाया। मांजी बोलीं- क्यों शीला! मुझे पहचाना नहीं? हर शुक्रवार को लक्ष्मीजी के मंदिर में भजन-कीर्तन के समय मैं भी वहां आती हूं।’ इसके बावजूद शीला कुछ समझ नहीं पा रही थी। फिर मांजी बोलीं- ‘तुम बहुत दिनों से मंदिर नहीं आईं अतः मैं तुम्हें देखने चली आई।’\n\n"
                        "माताजी के अति प्रेम भरे शब्दों से शीला का हृदय पिघल गया। उसकी आंखों में आंसू आ गए और वह बिलख-बिलखकर रोने लगी। मांजी ने कहा- ‘बेटी! सुख और दुःख तो धूप और छांव जैसे होते हैं। धैर्य रखो बेटी! मुझे तेरी सारी परेशानी बता।’ माताजी के व्यवहार से शीला को काफी संबल मिला और सुख की आस में उसने माताजी को अपनी सारी कहानी कह सुनाई। कहानी सुनकर माताजी ने कहा- ‘कर्म की गति न्यारी होती है। हर इंसान को अपने कर्म भुगतने ही पड़ते हैं। इसलिए तू चिंता मत कर। अब तू कर्म भुगत चुकी है। अब तुम्हारे सुख के दिन अवश्य आएंगे। तू तो मां लक्ष्मीजी की भक्त है। मां लक्ष्मीजी तो प्रेम और करुणा की अवतार हैं। वे अपने भक्तों पर हमेशा ममता रखती हैं। इसलिए तू धैर्य रखकर मां लक्ष्मीजी का व्रत कर। इससे सब कुछ ठीक हो जाएगा।’ शीला के पूछने पर माताजी ने उसे व्रत की सारी विधि भी बताई। माताजी ने कहा- ‘बेटी! मां लक्ष्मीजी का व्रत बहुत सरल है। उसे ‘वरदलक्ष्मी व्रत’ या ‘वैभव लक्ष्मी व्रत’ कहा जाता है। यह व्रत करने वाले की सब मनोकामना पूर्ण होती है। वह सुख-संपत्ति और यश प्राप्त करता है।’\n\n"
                        "शीला यह सुनकर आनंदित हो गई। शीला ने संकल्प करके आंखें खोली तो सामने कोई न था। वह विस्मित हो गई कि मांजी कहां गईं? शीला को तत्काल यह समझते देर न लगी कि मांजी और कोई नहीं साक्षात्‌ लक्ष्मीजी ही थीं। दूसरे दिन शुक्रवार था। सवेरे स्नान करके स्वच्छ कपड़े पहनकर शीला ने मांजी द्वारा बताई विधि से पूरे मन से व्रत किया। आखिरी में प्रसाद वितरण हुआ। यह प्रसाद पहले पति को खिलाया। प्रसाद खाते ही पति के स्वभाव में फर्क पड़ गया। उस दिन उसने शीला को मारा नहीं, सताया भी नहीं। शीला को बहुत आनंद हुआ। उनके मन में ‘वैभवलक्ष्मी व्रत’ के लिए श्रद्धा बढ़ गई।शीला ने पूर्ण श्रद्धा-भक्ति से इक्कीस शुक्रवार तक ‘वैभवलक्ष्मी व्रत’ किया। इक्कीसवें शुक्रवार को मांजी के कहे मुताबिक उद्यापन विधि कर के सात स्त्रियों को ‘वैभवलक्ष्मी व्रत’ की सात पुस्तकें उपहार में दीं। फिर माताजी के ‘धनलक्ष्मी स्वरूप’ की छवि को वंदन करके भाव से मन ही मन प्रार्थना करने लगीं- ‘हे मां धनलक्ष्मी! मैंने आपका ‘वैभवलक्ष्मी व्रत’ करने की मन्नत मानी थी, वह व्रत आज पूर्ण किया है। हे मां! मेरी हर विपत्ति दूर करो। हमारा सबका कल्याण करो। जिसे संतान न हो, उसे संतान देना। सौभाग्यवती स्त्री का सौभाग्य अखंड रखना। कुंवारी लड़की को मनभावन पति देना। जो आपका यह चमत्कारी वैभव लक्ष्मी व्रत करें, उनकी सब विपत्ति दूर करना। सभी को सुखी करना। हे मां आपकी महिमा अपार है।’ ऐसा बोलकर लक्ष्मीजी के ‘धनलक्ष्मी स्वरूप’ की छवि को प्रणाम किया। व्रत के प्रभाव से शीला का पति अच्छा आदमी बन गया और कड़ी मेहनत करके व्यवसाय करने लगा। उसने तुरंत शीला के गिरवी रखे गहने छुड़ा लिए। घर में धन की बाढ़ सी आ गई। घर में पहले जैसी सुख-शांति छा गई। ‘वैभवलक्ष्मी व्रत’ का प्रभाव देखकर मोहल्ले की दूसरी स्त्रियां भी विधिपूर्वक ‘वैभवलक्ष्मी व्रत’ करने लगीं।\n\n"
                        "वैभव लक्ष्‍मी व्रत सात, ग्यारह या इक्कीस, जितने भी शुक्रवारों की मन्नत मांगी हो, उतने शुक्रवार तक यह व्रत पूरी श्रद्धा तथा भावना के साथ करना चाहिए। आखिरी शुक्रवार को इसका शास्त्रीय विधि के अनुसार उद्यापन करना चाहिए। आखिरी शुक्रवार को प्रसाद के लिए खी‍र बनानी चाहिए। जिस प्रकार हर शुक्रवार को हम पूजन करते हैं, वैसे ही करना चाहिए। पूजन के बाद मां के सामने एक श्रीफल फोड़ें फिर कम से कम सात‍ कुंआरी कन्याओं या सौभाग्यशाली स्त्रियों को कुमकुम का तिलक लगाकर मां वैभवलक्ष्मी व्रत कथा की पुस्तक की एक-एक प्रति उपहार में देनी चाहिए और सबको खीर का प्रसाद देना चाहिए। इसके बाद मां लक्ष्मीजी को श्रद्धा सहित प्रणाम करना चाहिए। फिर माताजी के ‘धनलक्ष्मी स्वरूप’ की छबि को वंदन करके भाव से मन ही मन प्रार्थना करें- ‘हे मां धनलक्ष्मी! मैंने आपका ‘वैभवलक्ष्मी व्रत’ करने की मन्नत मानी थी, वह व्रत आज पूर्ण किया है। हे मां हमारी (जो मनोकामना हो वह बोले) मनोकामना पूर्ण करें। हमारी हर विपत्ति दूर करो। हमारा सबका कल्याण करो। जिसे संतान न हो, उसे संतान देना। सौभाग्यवती स्त्री का सौभाग्य अखंड रखना। कुंआरी लड़की को मनभावन पति देना। जो आपका यह चमत्कारी वैभवलक्ष्मी व्रत करे, उनकी सब विपत्ति दूर करना। सभी को सुखी करना। हे मां आपकी महिमा अपार है।’ आपकी जय हो! ऐसा बोलकर लक्ष्मीजी के ‘धनलक्ष्मी स्वरूप’ की छबि को प्रणाम करें।"),
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
