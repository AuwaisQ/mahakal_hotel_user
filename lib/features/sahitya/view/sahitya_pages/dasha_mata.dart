import 'dart:async';

import 'package:flutter/material.dart';

import '../../controller/share_helper.dart';
import 'commanbannerwidget.dart';

class Dasha_mata extends StatefulWidget {
  const Dasha_mata({super.key});

  @override
  State<Dasha_mata> createState() => _Dasha_mataState();
}

class _Dasha_mataState extends State<Dasha_mata> {
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
  Color _themeColor = Colors.green; // Default theme color

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
        ShareHelper.shareContent(context, "दशा माता व्रत कथा");
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
          _isEnglish ? 'Dasha Mata Vrat' : "दशा माता व्रत",
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
                  imagePath: 'assets/sahitya_images/Dasha Mata Vrat Katha.jpg',
                ),

                _buildSectionTitle(
                    _isEnglish ? "Story of Dasha Mata:" : "दशा माता की कहानी:"),
                _buildSectionContent(_isEnglish
                    ? "The fast of Dasha Mata is observed on the Dashami of Krishna Paksha of Chaitra month. On this day, married women observe fast to improve the condition of their house. It is believed that by worshipping on this day, happiness and prosperity comes in the house and the planetary position of the family members remains good.\n\n"
                        "In our Hindu religion, there is a tradition of worshipping Dasha Mata and doing Katha etc. from the second day of Holi since very ancient times. In which the people and women of Hindu sect do and listen to Katha for 10 consecutive days. In these stories, people are told about the glory of Dasha Mata and her grace.\n\n"
                        "The story of Dasha Mata or Dasha Mata Ki Kahani can be started by any married woman or widow. If any woman is thinking of starting the worship of Dasha Mata, then let me tell them that there are some rules for this, which you should keep in mind while starting your worship. For example, a woman who does the story and worship of Dasha Mata has to wake up early in the morning, take a bath and start her worship with the material for Dasha Mata worship.\n\n"
                        "First of all, the woman has to make a satvik mark on any wall of her house and put 10-10 dots on the wall with mehndi and kumkum. After putting kumkum and mehndi dots on the wall of the house, Ganpati ji is worshipped in the form of Swastik and then Dasha Mata ji is worshipped in the form of 10 dots with rice, betel nut, incense, roli, moli, lamp, agarbatti and naivedya."
                    : "दशा माता का व्रत चैत्र महीने के कृष्ण पक्ष की दशमी को रखा जाता है। इस दिन सुहागिन महिलाएं अपने घर की दशा सुधारने के लिए व्रत रखती हैं। मान्यता है कि इस दिन पूजा-पाठ करने से घर में सुख-समृद्धि आती है और परिवार के सदस्यों की ग्रह दशा ठीक रहती है।\n\n"
                        "हमारे हिन्दू धर्म में होली के दूसरे दिन से दशा माता की पूजा अर्चना और कथा आदि करने का बहुत ही प्राचीन काल से एक प्रथा चली आ रही हैं। जिसमें हिंदू संप्रदाय के व्यक्ति व महिलाएं लगातार 10 दिन तक कथा कहानी करते और सुनते हैं। इन कथाओं में दशा माता की महिमा और उनकी कृपा के बारे में लोगों को सुनाया जाता है।\n\n"
                        "दशा माता की कथा अथवा दशा माता की कहानी कोई भी सुहागन स्त्री अथवा विधवा स्त्री प्रारम्भ कर सकती है। जो भी स्त्री दशा माता की पूजा प्रारंभ करने की सोच रही हैं तो उन्हें बता दूं इसके कुछ नियम होते हैं जिन्हें आपको ध्यान में रखते हुए अपनी पूजा प्रारंभ करनी चाहिए। जैसे दशा माता की कथा कहानी व पूजा करने वाली स्त्री को प्रतिदिन सुबह प्रातकाल उठकर स्नानादि करके दशा माता के पूजन की सामग्री लेकर अपनी पूजा प्रारंभ करनी होती है।\n\n"
                        "सर्वप्रथम महिला को अपने घर के किसी दीवाल पर सात्विक बनाते हुए मेहंदी और कुमकुम से दीवाल पर 10-10 बिंदिया लगाने होते हैं। घर के दीवाल पर कुमकुम और मेहंदी की बिंदिया लगाने के बाद स्वास्तिक के रूप में गणपति जी का फिर से 10 बिंदुओं के रूप में दशा माता जी की चावल सुपारी धूप रोली मोली दीप अगरबत्ती और नैवेद्य से पूजा किया जाता हैं।"),

                _buildSectionTitle(_isEnglish
                    ? "Method and material of worship of Dasha Mata:"
                    : "दशा माता की पूजा विधि और सामग्री:"),
                // Section for the worship instructions in English
                _buildBulletPoint(_isEnglish
                    ? "Dasha Mata is worshipped on the Dashami of Krishna Paksha of Chaitra month."
                    : "दशा माता की पूजा चैत्र महीने के कृष्ण पक्ष की दशमी को की जाती है."),
                _buildBulletPoint(_isEnglish
                    ? "For worship, take a 10-strand string of raw cotton and make 10 knots in it."
                    : "पूजा के लिए कच्चे सूत का 10 तार का डोरा लेकर उसमें 10 गठानें लगाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Worship the Peepal tree and circumambulate it 10 times while wrapping the thread."
                    : "पीपल के पेड़ की पूजा करें और 10 बार सूत लपेटते हुए परिक्रमा करें."),
                _buildBulletPoint(_isEnglish
                    ? "Tie the thread around your neck."
                    : "डोरे को गले में बांध लें."),
                _buildBulletPoint(_isEnglish
                    ? "After the worship, listen to the story of Nala-Damayanti."
                    : "पूजा के बाद नल-दमयंती की कथा सुनें."),
                _buildBulletPoint(_isEnglish
                    ? "Put impressions of turmeric and kumkum on the place of worship."
                    : "पूजा स्थल पर हल्दी और कुमकुम के छापे लगाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Eat only one type of food at a time."
                    : "एक ही तरह का अन्न एक समय खाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Do not add salt in food."
                    : "भोजन में नमक न हो."),
                _buildBulletPoint(_isEnglish
                    ? "Especially eat wheat food."
                    : "खास तौर पर गेहूं का अन्न खाएं."),
                _buildBulletPoint(
                    _isEnglish ? "Clean the house." : "घर की साफ़-सफ़ाई करें."),
                _buildBulletPoint(_isEnglish
                    ? "Buy household items and broom."
                    : "घरेलू ज़रूरत के सामान और झाड़ू खरीदें."),
                _buildBulletPoint(_isEnglish
                    ? "Offer jewelry to the goddess."
                    : "माता को गहने चढ़ाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Take a scarf to wave to the goddess."
                    : "माता को उड़ाने के लिए चुन्नी लें."),
                _buildBulletPoint(
                    _isEnglish ? "Take some dakshina." : "थोड़ी दक्षिणा लें."),
                _buildBulletPoint(_isEnglish
                    ? "If you do not have an idol or picture of Dasha Mata, draw her image with turmeric or sandalwood on a Peepal leaf and worship."
                    : "अगर आपके पास दशा माता की मूर्ति या फ़ोटो नहीं है, तो पीपल के पत्ते पर हल्दी या चंदन से दशा माता का चित्र बनाकर पूजा करें."),

                _buildSectionTitle(
                    _isEnglish ? "Dashamata Ki Katha:" : "दशामाता की कथा:"),
                // Section for the story in English
                _buildSectionContent(_isEnglish
                    ? "King Nala and Queen Damyanti lived in a kingdom. King Nala was running his empire very gracefully and peacefully. Queen Damyanti was also living her royal life with Nala very happily. There was no dearth of wealth in their kingdom and the people were also very happy with King Nala and Queen Damyanti and respected them a lot.\n\n"
                        "One day the queen got information about the glory of Dasha Mata from one of her maids and her maid narrated the glory of Dasha Mata to Queen Damyanti and the story of Dasha Mata. Queen Damyanti is very impressed by listening to the story of Dasha Mata and asks the maid about the worship and fasting method of Dasha Mata.\n\n"
                        "The maid gave complete information to Queen Damyanti about the worship method and fasting rules of Dasha Mata and also told her the story of Dasha Mata and said that after the worship you have to listen to the story of Dasha Mata every day, only then your worship will be successful.\n\n"
                        "So, Queen Damyanti makes a string of raw cotton (Dasha Mata ka Bela) in the name of Dasha Mata on the Dashami day of Krishna Paksha of Chaitra month and on the day of Holika Dahan, she shows that string to the fire and wears it around her neck and starts worshipping Dasha Mata. She listens to the story of Dasha Mata every day and also narrates the story of Dasha Mata to other maids.\n\n"
                        "Since Queen Damyanti used to worship Dasha Mata, one day King Nala saw the string of raw cotton around her neck and he broke the string of raw cotton which was Dasha Mata's Bela from Queen Damyanti's neck saying that 'Only diamonds and jewels and ornaments look good on a queen's neck, not a thread of ordinary cotton', saying this King Nala broke the thread from the queen's neck.\n\n"
                        "The queen is very sad but she was completely unaware of the trouble that was to come. After some time, King Nala's administration started deteriorating. Day by day, the wealth of his kingdom started getting depleted. Not only this, gradually pieces of stone started falling from their palace. King Nala and Queen Damyanti could not understand why this was happening. Both were worried thinking how so much trouble suddenly broke into their kingdom and palace.\n\n"
                        "The condition of the kingdom became so bad that people started starving. Finally, the king decided to leave the kingdom and go to another kingdom to earn money and asked Queen Damyanti to go to her maternal home for a few days. But Queen Damyanti was a devoted wife, her husband was everything for her, so she refused to go. In this way, both of them left their kingdom and left for another kingdom.\n\n"
                        "The king and queen were going towards another kingdom hungry and thirsty. A lot of time passed while walking and it was evening too, so they went to a nearby gardener to rest and asked him for shelter to spend the night. The gardener's garden was very beautiful and green. Both the king and the queen rested the whole night in the gardener's beautiful garden and when they woke up in the morning, they saw that the entire garden had become barren.\n\n"
                        "They could not understand how it was possible that a green garden could become barren in one night. Then the gardener came there and seeing his barren garden, he scolded King Nala and Queen Damyanti and asked them to leave from there.\n\n"
                        "Now both of them again move forward towards their destination early in the morning. While going ahead, they saw an oilman and the sun was also strong, so they asked the oilman for shelter at his place. The oilman agreed to stay at his place and gave them shelter.\n\n"
                        "The oilman's entire house was filled with oil cans but when she saw, all her oil cans were empty. It did not take her long to understand that both of them were unfortunate, so she cursed them and asked them to leave. She was very angry because she had suffered a lot by giving shelter to the king and the queen. After going a little further, they started resting under a tree. Then the king remembered that his sister's house was nearby. So the king informed his sister about his presence under the tree. The king's sister sent them bread and onion pieces through one of her servants. After seeing the bread, the king and queen buried it in the ground instead of eating it and moved on.\n\n"
                        "Further, the king's friend meets him and seeing his plight, he takes him to his house and treats him with great respect. Then a peacock comes to his house and swallows a gold necklace hanging on a peg in the house, about which no one knows. Then the king's friend's wife's eyes fall on the peg and not finding the necklace there, she tells her husband that what kind of friend do you have, you stole it from the house of those whom you gave shelter.\n\n"
                        "On hearing this, the king's friend silences him and says that his friend is not a thief, today his condition is not good, it is possible that he needs that necklace, that is why he must have taken it, which he will return to us later. King Nala and Queen Damyanti hear the conversation of their friend and his wife and both leave from there.\n\n"
                        "While walking on the way, the queen remembers that all this is happening due to breaking the fast of Dasha Mata and she tells the king that our condition has become bad, that is why everyone has become our enemy. The king had also understood everything by now, but both had nothing except regret. After a few days of travel, they reach a kingdom where the king and queen start finding work and making a living. The whole year passes like this and the month of Chaitra comes near.\n\n"
                        "Queen Damyanti talks to the king about performing Dasha Mata Katha Puja Vrat. The king also starts working harder for the worship of his wife.\n\n"
                        "The king used to cut wood from the forests and sell it in the market and the money he earned was used to support both of them. The Dashami of Krishna Paksha of Chaitra month comes near. The king now cuts more wood and earns money by selling it and brings home the Dasha Mata Puja material and gives it to his queen Damyanti.\n\n"
                        "On the day of Holi, the queen makes a string of raw cotton i.e. Dasha Mata's vine and wears it around her neck. In this way, Queen Damyanti starts Dasha Mata's Katha Puja Vrat. Now slowly their condition started improving. One day the king's wood turned out to be sandalwood, by selling which he brought home a lot of money and with his wife he performed the story of Dasha Mata Puja.\n\n"
                        "This way the days passed and now the king had become very rich, so he thought of going back to his kingdom again and in this way both the king and the queen left for their kingdom. On the way he sees his friend's house, he goes there and takes rest after having food, then the peacock comes back to the house and starts spitting out the gold necklace.\n\n"
                        "The king calls his friend on seeing the peacock spitting out the necklace, so the friend understands everything and he feels ashamed of his wife. The king's friend apologizes to him for his mistake and the king hugs him and says that it is not your fault, my condition had become bad, that is why you said so.\n\n"
                        "The king now moves forward with the queen and he sees his sister's kingdom. The king goes under the same tree where his sister had given him roti, which the king buried in the ground. When the king and queen dig that place, they find diamonds and jewels there. So the king takes them out and gives them to his sister.\n\n"
                        "After giving gifts to his sister, the king moves towards his kingdom with the queen. By evening, he reaches the same Telan and asks for her help to rest. Since it had been a long time, the Telan does not recognize them and gives them shelter.\n\n"
                        "When she woke up in the morning, she was surprised because the storehouse where the Telan had stopped the king and queen for rest had empty oil cans which were now full. Then the king tells her that those two are the same unfortunate people whose mere footsteps had emptied your godown a few days ago. But today, due to the glory of Dasha Mata, your storehouse has become as it was before.\n\n"
                        "Now the king reaches the garden where the entire garden had become barren due to their stay, but as soon as the king reaches, the gardener's garden becomes even more beautiful and green, due to which the gardener hails the king and bids them farewell.\n\n"
                        "Now the king enters his kingdom. Seeing King Nala and Queen Damyanti, the entire kingdom is filled with joy. There is an atmosphere of happiness everywhere, it seems as if it is Diwali. All the members of the royal court and the public welcome their king and queen. In this way, prosperity returns to the kingdom of King Nala as before. Queen Damyanti keeps reciting the Dasha Mata Katha and Vrat and also asks her entire subjects to recite the Dasha Mata Katha and Vrat Puja."
                    : "किसी राज्य में राजा नल और रानी दमयंती रहा करती थी। राजा नल अपना साम्राज्य बहुत ही शान से और शांति पूर्ण तरीके से चला रहे थे। रानी दमयंती भी बहुत सुख से नल के साथ अपना राजशिक जीवन व्यतीत कर रही थी। उनके राज्य में धन धान्य की कोई कमी नहीं थी और जनता भी राजा नल और रानी दमयंती से बहुत खुश थे और उनका बहुत सम्मान करते थे।\n\n"
                        "एक दिन रानी को अपनी किसी दासी से दशा माता की महिमा की जानकारी प्राप्त हुई और उनकी दासी ने रानी दमयंती को दशा माता की महिमा के बखान करते हुए दशा माता की कथा और दशा माता की कहानी सुनाई। रानी दमयंती दशा माता की कथा सुनकर बहुत अधिक प्रभावित होती है और दासी से दशा माता की पूजा व्रत विधि के बारे में पूछती है।\n\n"
                        "दासी रानी दमयंती को दशा माता की पूजा विधि और व्रत नियम आदि के बारे में पूरी जानकारी दी और उन्हें दशा माता की कथा भी सुनाई और कहा पूजा के पश्चात् आपको प्रतिदिन दशा माता की कहानी को सुनना है तभी आपका पूजा सफल होगा।\n\n"
                        "अतः रानी दमयंती चैत्र मास की कृष्ण पक्ष के दशमी के दिन दशा माता के नाम से कच्चे सुत का डोरा (दशा माता का बेला) बनाती है और उस डोरे को होलिका दहन के दिन अग्नि दिखा कर अपने गले में धारण करके दशा माता की पूजा प्रारम्भ करती है और प्रतिदिन दशा माता की कथा सुनती और अन्य दासियों को भी दशा माता की कहानी सुनाती।\n\n"
                        "चूंकि रानी दमयंती दशा माता की पूजा करती थी तो उनके गले में कच्चे सूत की डोरी एक दिन राजा नल ने देख ली और उन्होंने महारानी दमयंती के गले से वह कच्चा सुत जो दशा माता का बेला था उसको तोड़ दिया यह कहते हुए की 'एक रानी के गले में मात्र हीरे जवाहरात के आभूषण और गहने ही सोभा देते है कोई साधारण सुत का धागा नहीं' ऐसा कहते हुए राजा नल ने रानी के गले से धागा तोड़ दिया।\n\n"
                        "रानी बहुत दुखी होती है लेकिन वे आने वाली मुसीबत से बिल्कुल अनजान थी। कुछ समय बिता राजा नल की राज व्यवस्था बिगड़ने लगी। दिन प्रतिदिन उनके राज्य की संपत्ति समाप्त होने लगी। इतना ही नहीं धीरे धीरे करके उनकी महल से पत्थर के टुकड़े गिरने लगे राजा नल और रानी दमयंती को कुछ समझ नहीं आ रहा था कि ऐसा क्यों हो रहा। अचानक से इतनी ज्यादा मुसीबत कैसे उनके राज्य और राजमहल में टूट पड़ी दोनों यही सोच कर परेशान थे।\n\n"
                        "राज्य की स्थिति इतनी खराब हो गई की लोग दाने दाने को तरस गए। अंततः राजा ने राज्य त्यागने और दूसरे राज्य में जाकर धन कमाने का निश्चय किया और रानी दमयंती को कुछ दिन के लिए उनके मायके जाने को कहा। किन्तु रानी दमयंती एक पतिव्रता स्त्री थी उनके लिए उनका पति ही सब कुछ था अतः उन्होंने जाने से मना कर दिया। इस तरह से दोनों अपना राज्य त्याग करके दूसरी राज्य की तरफ रवाना होते है।\n\n"
                        "राजा रानी भूखे प्यासे दूसरी राज्य कि ओर चले जा रहे थे। चलते चलते बहुत समय बीत गया और संध्या भी होने लगी थी तो उन्होने विश्राम के लिए पास के है एक माली के पास गए और उससे रात गुजारने के लिए शरण मांगी। माली का बगीचा बहुत ही सुन्दर और हराभरा था। राजा रानी दोनों माली के सुंदर से बगीचे में पूरी रात विश्राम करते है और सुबह जब उनकी नींद खुलती है तो उन्होंने देखा कि पूरा बगीचा बंजर बन गया है।\n\n"
                        "उनको समझ नहीं आ रहा था कि ऐसा कैसे हो सकता है कि एक ही रात में हराभरा बगीचा बंजर कैसे हो सकता है। तभी वहां माली आ जाता हैं और अपने बंजर बगीचे को देख राजा नल और रानी दमयंती को बहुत खरी खोटी सुनाता है और उन्हें वहां से जाने को कहता है।\n\n"
                        "अब दोनों सुबह-सुबह फिर से अपनी मंजिल की तरफ आगे बढ़ते हैं। आगे जाते जाते उन्हें एक तेलन दिखती है और कड़ी धूप भी थी अतः उन्होंने तेलन से उसके यहां विश्राम करने के लिए शरण मांगी। तेलर ने अपने यहां रुकने के लिए सहमत हो जाती है और उन्हें शरण देदेती है।\n\n"
                        "तिलन का पूरा घर तेल के डिब्बे से भरा हुआ था लेकिन जब उसने देखा तो उसका पूरा तेल का डिब्बा खाली हो गया था। उसको समझते देर न लगी यह दोनों कोई अभागे हैं अतः उन्हें कोसते हुए जाने को कहती है। वह बहुत गुस्सा थी क्योंकि राजा रानी को अपने यहां आश्रय देकर उसका बहुत नुक़सान हुआ था।\n\n"
                        "थोड़ी ही दूर जाकर वे एक वृक्ष के नीचे विश्राम करने लगते है। तभी राजा को याद आया कि उसकी बहन का घर पास में ही है। अतः राजा ने अपने यहां वृक्ष के नीचे होने की खबर अपनी बहन के घर तक पहुंचाया। राजा की बहन दोनों के लिए रोटी और प्याज के टुकड़े अपने एक सेवक के हाथो उन तक पहुंचाती है। राजा रानी रोटी देख कर उसे खाने के बजाय उसे वहीं जमीन में गाड़ देते है और आगे बढ़ते हैं।\n\n"
                        "आगे राजा का मित्र मिलता है और वो उनकी यह दुर्दशा देख अपने घर ले जाता है और खूब आदर करता है तभी उनके घर में एक मोर आता है और वो घर की खूंटी पर लटका हुआ एक स्वर्ण हार निगल लेता है जिसके बारे में किसी को खबर नहीं होती है। तभी राजा के मित्र के पत्नी की नजर खुटी पर पड़ती हैं वहा हार न पाकर अपने पति से कहती है कि कैसे मित्र है तुम्हारे जिन्हें आपने शरण दी उन्ही के घर चोरी कर ली।\n\n"
                        "इतना सुनते ही राजा का मित्र उसे चुप करते हुए कहता है कि उसका मित्र चोर नहीं है आज उसकी दशा सही नहीं है हो सकता है उसको उस हार की आवश्यकता हो इस लिए उसने हार लिया होगा जिसको वो बाद में हमें लौटा देगा। अपने मित्र और उसके पत्नी की बात राजा नल और रानी दमयंती सुन लेती हैं और दोनों वहा से प्रस्थान करते हैं।\n\n"
                        "रास्ते में चलते हुए रानी को स्मरण हुआ की ये सब हो न हो दशा माता का व्रत भंग होने के कारण हो रहा और वो राजा से कहती है कि हमारी दशा खराब हो गई है तभी हर कोई हमारा बैरी बन गया है। राजा भी अब तक सब समझ चुका था लेकिन दोनों के पास पछताने के सिवाय कुछ नहीं था। कुछ दिन की यात्रा के बाद वे एक राज्य में पहुंचते है वहां पर राजा रानी काम खोज कर अपना गुज़ारा करने लगते है। ऐसे ही पूरा साल बिता और चैत्र माह नजदीक आता है।\n\n"
                        "रानी दमयंती  दशा माता की कथा पूजा व्रत करने की बात राजा से करती है। राजा भी अपनी पत्नी की पूजा के लिए और अधिक मेहनत करना शुरू करता है।\n\n"
                        "राजा जंगलों से लकड़ी काटता और उन्हें बाज़ार में बेच कर जो पैसा कमाता उसी से दोनों का गुजारा होता था। चैत्र मास का कृष्ण पक्ष की दशमी नजदीक आ जाती है। राजा अब और लकड़ियां काटता है और उन्हें बेचकर को धन कमाता है उसका वह दशा माता की पूजा सामग्री घर लाकर अपनी रानी दमयंती को देता है।\n\n"
                        "रानी होलिका के दिन कच्चे सुत का डोरा अर्थात् दशा माता का बेल बनाती हैं और उसे अपने गले में धारण करती हैं। इस तरह रानी दमयंती दशा माता की कथा पूजा व्रत प्रारंभ करती है। अब धीरे धीरे उनकी दशा में सुधार होने लगा था। एक दिन राजा की लकड़ियां चंदन की निकली, जिसको बेचकर वह बहुत धन घर लाता है और पत्नी के साथ दशा माता की कथा पूजा करते है।\n\n"
                        "ऐसे करके दिन बीतते गए और अब राजा बहुत धनवान हो गया था अतः वह पुनः अपने राज्य वापस चलने का विचार करता है और इस तरह दोनों राजा रानी अपने राज्य की तरफ रवाना होते है। रास्ते में उसके मित्र का घर दिखता है वह वहां उसके पास जाता है और भोजन करके विश्राम करता है तभी वह मोर घर में वापस आता है और स्वर्ण हर उगलने लगता है।\n\n"
                        "राजा मोर को हार उलगते देख अपने मित्र को बुलाता है अतः मित्र सब समझ जाता है और उसे अपनी पत्नी पर लज्जा आती हैं। राजा का मित्र उससे अपनी भूल के लिए क्षमा मांगता है और राजा उसे अपने गले से लगाते हुए बोलता है कि इसमें तुम्हारा कोई दोष नहीं है मेरी दशा ही खराब हो गई थी इस लिए तुमने ऐसा कहा।\n\n"
                        "राजा अब रानी के साथ आगे बढ़ता है उसे अपनी बहन का राज्य दिखाई देता है। राजा उसी वृक्ष के नीचे जाता है जहा उसकी बहन ने रोटी दी थी जिसको राजा ने जमीन में गाड़ दिया था। राजा और रानी जब उस स्थान को खोदते है तो उन्हें वहां हीरे जवाहरात मिलते है। अतः राजा उनको निकाल कर अपनी बहन को से आता है।\n\n"
                        "बहन को उपहार देने के बाद राजा रानी के साथ अपनी राज्य कि और बढ़ता है। शाम होते होते वह उसी टेलन के पास पहुंचता है और उससे विश्राम करने के लिए मदद मांगता है। चूंकि बहुत दिन हो गया था तो तेलान उन्हें पहचान नहीं पाती और उन्हें आश्रय देती है।\n\n"
                        "सुबह जब नींद खुली तो वह आश्चर्य चकित हो गई क्योंकि जिस गोदाम में तेल न ने राजा रानी को विश्राम के लिए रोका था उसमे तेल की खाली टीने थी जो अब पूरी भर गई थी। तब राजा उसे बताता है कि वे दोनों वहीं अभागे है कुछ दिनों पहले जिनके चरण मात्र पड़ने से तुम्हारा गोदान खाली हो गया था। लेकिन आज दशा माता की महिमा के कारण तुम्हारा गोदाम पुनः पहले जैसा हो गया है।\n\n"
                        "अब राजा पहुंचता है उस बगीचे पर जहा उनके रुकने से पूरा बगीचा बंजर हो गया था लेकिन राजा के पहुंचते ही माली का बगीचा और भी ज्यादा सुंदर और हराभरा हो जाता है जिससे माली राजा की जय जयकार करता है और उन्हें विदा करता है।\n\n"
                        "अब राजा अपने राज्य में प्रवेश करते है राजा नल और रानी दमयंती को देख पूरा प्रदेश हर्सोल्लास से भर गया। हर तरफ खुशियों का माहौल छा गया ऐसा प्रतीत हो रहा था जैसे दीपावली हो। राजदरबार के सभी सदस्य और जनता अपने राजा रानी का स्वागत अभिनन्दन करती है। इस प्रकार राजा नल के साम्राज्य में पुनः खुशहाली पहले जैसी हो जाती है। रानी दमयंती दशा माता की कथा व्रत करती रही और अपने पूरे प्रजा को भी दशा माता की कथा और व्रत पूजा पाठ करने को कहती है।"),
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
