import 'dart:async';
import 'package:flutter/material.dart';

import '../../controller/share_helper.dart';
import 'commanbannerwidget.dart';

class ShanivaarVrat extends StatefulWidget {
  const ShanivaarVrat({super.key});

  @override
  State<ShanivaarVrat> createState() => _ShanivaarVratState();
}

class _ShanivaarVratState extends State<ShanivaarVrat> {
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
        ShareHelper.shareContent(context, "शनिवार व्रत कथा");
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
          _isEnglish ? 'Saturday fast story' : "शनिवार व्रत कथा",
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
                      'assets/sahitya_images/Shanivar (Saturday) Vrat Katha.jpg',
                ),

                _buildSectionTitle(_isEnglish
                    ? "About Saturday fast:"
                    : "शनिवार व्रत के बारे में:"),
                _buildSectionContent(_isEnglish
                    ? "Saturday fast is dedicated to Shani Dev. By observing this fast, Shani Dosh in the horoscope is removed and Shani Dev's wrath does not occur. By observing this fast, respect increases, happiness and peace come in the house and health also remains good. Among all the planets, Shani has the most harmful wrath on humans. Therefore, while observing Saturday fast, Shani Devta should be worshipped. Although Saturday fast can be started anytime, but starting Saturday fast in Shravan month is considered to be of special importance."
                    : "शनिवार का व्रत शनि देव को समर्पित होता है. इस व्रत को करने से कुंडली में शनि दोष दूर होता है और शनिदेव का प्रकोप नहीं लगता. इस व्रत को करने से मान-सम्मान बढ़ता है, घर में सुख-शांति आती है और स्वास्थ्य भी अच्छा रहता है. सभी ग्रहों में शनि का मनुष्य पर सबसे हानिकारक प्रकोप होता है। अतः शनिवार का व्रत करते हुए शनि देवता की पूजा-अर्चना करनी चाहिए। वैसे तो शनिवार का व्रत कभी भी शुरू किया जा सकता है, लेकिन श्रावण मास में शनिवार का व्रत प्रारंभ करने का विशेष महत्व माना गया है।"),

                _buildSectionTitle(_isEnglish ? "Vrat Vidhi:" : "व्रत विधि:"),
                // Section for Shani Puja celebration instructions in English
                _buildBulletPoint(_isEnglish
                    ? "Get up in Brahma Muhurta and take bath with water from river or well."
                    : "ब्रह्म मुहूर्त में उठकर नदी या कुएं के जल से स्नान करें."),
                _buildBulletPoint(_isEnglish
                    ? "After that offer water to the Peepal tree."
                    : "तत्पश्चात पीपल के वृक्ष पर जल अर्पण करें."),
                _buildBulletPoint(_isEnglish
                    ? "Bathe the idol of Shani Devta made of iron with Panchamrit."
                    : "लोहे से बनी शनि देवता की मूर्ति को पंचामृत से स्नान कराएं."),
                _buildBulletPoint(_isEnglish
                    ? "Then install this idol on a lotus made of twenty-four leaves of rice."
                    : "फिर इस मूर्ति को चावलों से बनाए चौबीस दल के कमल पर स्थापित करें."),
                _buildBulletPoint(_isEnglish
                    ? "After this, worship with black sesame, flowers, incense, black cloth and oil etc."
                    : "इसके बाद काले तिल, फूल, धूप, काला वस्त्र व तेल आदि से पूजा करें."),
                _buildBulletPoint(_isEnglish
                    ? "During the worship, chant these 10 names of Shani- Konastha, Krishna, Pippala, Sauri, Yama, Pinglo, Rodrotko, Babhru, Mand, Shanaishchar."
                    : "पूजन के दौरान शनि के इन 10 नामों का उच्चारण करें- कोणस्थ, कृष्ण, पिप्पला, सौरि, यम, पिंगलो, रोद्रोतको, बभ्रु, मंद, शनैश्चर."),
                _buildBulletPoint(_isEnglish
                    ? "After the worship, do seven rounds of the trunk of the Peepal tree with a cotton thread."
                    : "पूजन के बाद पीपल के वृक्ष के तने पर सूत के धागे से सात परिक्रमा करें."),

                _buildSectionTitle(_isEnglish
                    ? "After this, pray to Shani Dev with the following mantra-"
                    : "इसके पश्चात निम्न मंत्र से शनि देव की प्रार्थना करें-"),
                _buildSectionContent(_isEnglish
                    ? "Shanaishchar Namastubhyam Namaste Tvath Rahve.\n"
                        "Ketaveath Namastubhyam Sarvashantiprado Bhava.\n\n"
                        "Similarly, while fasting for 7 Saturdays, for protection from the wrath of Shani, offer 108 oblations each with the Shani mantra samidha, for protection from the evil eye of Rahu, offer durva samidha, for protectionfrom Ketu, offer kusha samidha in Ketu mantra, offer 108 oblations each with barley and black sesame seeds.\n\n"
                        "Similarly, while fasting for 7 Saturdays, one should offer 108 oblations each in the samidha of Shani mantra for protection from the wrath of Shani, in the samidha of Durva for protection from the evil eye of Rahu, in the samidha of Kusha in Ketu mantra for protection from Ketu, with black barley and black sesame seeds."
                    : "शनैश्चर नमस्तुभ्यं नमस्ते त्वथ राहवे।\n"
                        "केतवेअथ नमस्तुभ्यं सर्वशांतिप्रदो भव॥\n\n"
                        "इसी तरह 7 शनिवार तक व्रत करते हुए शनि के प्रकोप से सुरक्षा के लिए शनि मंत्र की समिधाओं में, राहु की कुदृष्टि से सुरक्षा के लिए दूर्वा की समिधा में, केतु से सुरक्षा के लिए केतु मंत्र में कुशा की समिधा में, कृष्ण जौ, काले तिल से 108 आहुति प्रत्येक के लिए देनी चाहिए।\n\n"
                        "इसी तरह 7 शनिवार तक व्रत करते हुए शनि के प्रकोप से सुरक्षा के लिए शनि मंत्र की समिधाओं में, राहु की कुदृष्टि से सुरक्षा के लिए दूर्वा की समिधा में, केतु से सुरक्षा के लिए केतु मंत्र में कुशा की समिधा में, कृष्ण जौ, काले तिल से 108 आहुति प्रत्येक के लिए देनी चाहिए।\n\n"),

                _buildSectionTitle(_isEnglish ? "Story" : "कथा:"),
                // Section for the story of King Vikramaditya and Lord Shani in English
                _buildSectionContent(_isEnglish
                    ? "Once in heaven, there was a debate among the nine planets on the question 'Who is the greatest?' The dispute increased so much that a situation of fierce war arose. For the decision, all the gods went to Devraj Indra and said- 'O Devraj! You have to decide who is the greatest among us?' Hearing the question of the gods, Devraj Indra got confused.\n\n"
                        "Indra said- 'I am unable to answer this question. We all go to King Vikramaditya in the city of Ujjaini on Earth. All the planets (gods) including Devraj Indra reached the city of Ujjaini. When the gods reached the palace and asked him their question, King Vikramaditya also got worried for a while because all the gods were great due to their respective powers. Calling anyone small or big could cause terrible harm due to the fury of their anger!\n\n"
                        "Suddenly King Vikramaditya thought of a solution and he got nine seats made of different metals- gold, silver, bronze, copper, lead, tin, zinc, mica and iron. He asked the gods to sit on their respective thrones by placing all the seats one behind the other according to the properties of the metals. After the gods sat, King Vikramaditya said- 'Your decision has been made automatically. The one who sits on the throne first is the greatest.'\n\n"
                        "On hearing the decision of King Vikramaditya, Lord Shani got angry and said- 'King Vikramaditya! You have insulted me by making me sit at the back. You are not aware of my powers. I will destroy you completely.'\n\n"
                        "Shani said- 'The Sun stays on a zodiac sign for one month, the Moon for two and a quarter days, Mars for one and a half months, Mercury and Venus for one month, Jupiter for thirteen months, but I stay on a zodiac sign for seven and a half years (Sadhe Sati). I have afflicted even the greatest of gods with my wrath.\n\n"
                        "Ram had to live in the forest due to Sade Sati and Ravana had to die in the war due to Sade Sati. King! Now you too will not be able to escape my wrath.' After this, the gods of other planets left happily, but Shani Dev left from there with great anger. King Vikramaditya continued to dispense justice as before. All the men and women in his kingdom were living very happily. Some days passed like this. On the other hand, Shani Dev had not forgotten his insult. To take revenge from Vikramaditya, one day Shani Dev took the form of a horse trader and reached Ujjaini city with many horses. When King Vikramaditya heard the news of a horse trader coming to the kingdom, he sent his horse keeper to buy some horses.\n\n"
                        "The horses were very valuable. When the horse keeper returned and told about this, King Vikramaditya himself came and chose a beautiful and powerful horse. The fast running horse took the king to a faraway forest and then dropped the king there and disappeared somewhere in the forest. The king started wandering in the forest to return to his city. But he could not find any way to return. The king felt hungry and thirsty. After wandering a lot, he found a shepherd.\n\n"
                        "The king asked him for water. After drinking water, the king gave his ring to the shepherd. Then after asking him for directions, he left the forest and reached the nearby city. The king sat at a merchant's shop and rested for some time. When the merchant talked to the king, the king told him that he had come from Ujjaini city. The merchant's sale of goods increased a lot when the king sat at the shop for some time.\n\n"
                        "The merchant considered the king very lucky and happily took him to his house for food. A gold necklace was hanging on a hook in the merchant's house. Leaving the king in that room, the merchant went out for some time. Then a surprising incident happened. In front of the king's eyes, the hook swallowed that gold necklace.\n\n"
                        "When the merchant returned to the room and saw that the necklace was missing, he suspected the king of theft because the king was the only one sitting in that room. The merchant told his servants to tie this foreigner with ropes and take him to the king of the city. When the king asked Vikramaditya about the necklace, he told that the peg had swallowed the necklace in front of his eyes. On this, the king got angry and ordered to cut off Vikramaditya's hands and feet for the crime of theft. After cutting off King Vikramaditya's hands and feet, he was left on the road of the city.\n\n"
                        "After a few days, an oilman picked him up and took him to his house and made him sit on his oil press. The king kept calling and driving the oxen. In this way, the oilman's ox kept moving and the king kept getting food. After the end of the seven and a half years of Saturn's wrath, the rainy season started. King Vikramaditya was singing Megh Malhar one night when Princess Mohini, the daughter of the king of the city, passed by the oilman's house riding a chariot. When she heard Megh Malhar, she liked it very much and sent her maid to call the singer.\n\n"
                        "The maid returned and told the princess everything about the handicapped king. The princess was very fascinated by his Megh Malhar. So, despite knowing everything, she decided to marry the handicapped king. When the princess told this to her parents, they were shocked. The queen explained to Mohini- 'Daughter! It is written in your fate to be the queen of some king. Then why are you shooting yourself in the foot by marrying that handicapped man?\n\n"
                        "The princess did not give up her stubbornness. To get her stubbornness fulfilled, she stopped eating and decided to give up her life. Finally, the king and queen were forced to get the princess married to the handicapped Vikramaditya. After marriage, King Vikramaditya and the princess started living in the house of an oilman. That very night, in the dream, Shani Dev said to the king- 'King, you have seen my anger.\n\n"
                        "I have punished you for insulting me.' The king asked Shani Dev to forgive him and prayed- 'O Shani Dev! Don't give the pain you have given me to anyone else.\n\n"
                        "Shani Dev thought for a while and said- 'King! I accept your prayer. Any man or woman who worships me, observes a fast on Saturday and listens to my Vrat Katha, will always have my mercy on him. When King Vikramaditya woke up in the morning, he was very happy to see his hands and feet. He prayed to Shani Dev in his mind. The princess was also surprised to see the King's hands and feet intact. Then King Vikramaditya introduced himself and told the whole story of Shani Dev's wrath.\n\n"
                        "When the Seth came to know about this, he rushed to the oilman's house and fell at the King's feet and asked for forgiveness. The King forgave him because all this had happened due to Shani Dev's wrath. The Seth took the King to his house and fed him. While eating, a surprising incident happened there. In front of everyone, that peg spat out the necklace. Seth ji also married his daughter to the king and sent off the king with many gold ornaments, money etc.\n\n"
                        "When King Vikramaditya reached Ujjaini with Princess Mohini and Seth's daughter, the people of the city welcomed him with joy. The next day King Vikramaditya announced in the whole kingdom that Shani Dev is the best among all the gods. Every man and woman should observe fast on Saturday and listen to Vrat Katha. Shani Dev was very happy with the announcement of King Vikramaditya. Due to observing fast on Saturday and listening to Vrat Katha, the wishes of all the people started getting fulfilled by the mercy of Shani Dev. Everyone started living happily."
                    : "एक समय स्वर्गलोक में 'सबसे बड़ा कौन?' के प्रश्न पर नौ ग्रहों में वाद-विवाद हो गया। विवाद इतना बढ़ा कि परस्पर भयंकर युद्ध की स्थिति बन गई। निर्णय के लिए सभी देवता देवराज इंद्र के पास पहुंचे और बोले- 'हे देवराज! आपको निर्णय करना होगा कि हममें से सबसे बड़ा कौन है?' देवताओं का प्रश्न सुनकर देवराज इंद्र उलझन में पड़ गए।\n\n"
                        "इंद्र बोले- 'मैं इस प्रश्न का उत्तर देने में असमर्थ हूं। हम सभी पृथ्वीलोक में उज्जयिनी नगरी में राजा विक्रमादित्य के पास चलते हैं। देवराज इंद्र सहित सभी ग्रह (देवता) उज्जयिनी नगरी पहुंचे। महल में पहुंचकर जब देवताओं ने उनसे अपना प्रश्न पूछा तो राजा विक्रमादित्य भी कुछ देर के लिए परेशान हो उठे क्योंकि सभी देवता अपनी-अपनी शक्तियों के कारण महान थे। किसी को भी छोटा या बड़ा कह देने से उनके क्रोध के प्रकोप से भयंकर हानि पहुंच सकती थी!\n\n"
                        "अचानक राजा विक्रमादित्य को एक उपाय सूझा और उन्होंने विभिन्न धातुओं- स्वर्ण, रजत (चांदी), कांसा, ताम्र (तांबा), सीसा, रांगा, जस्ता, अभ्रक व लोहे के नौ आसन बनवाए। धातुओं के गुणों के अनुसार सभी आसनों को एक-दूसरे के पीछे रखवाकर उन्होंने देवताओं को अपने-अपने सिंहासन पर बैठने को कहा। देवताओं के बैठने के बाद राजा विक्रमादित्य ने कहा- 'आपका निर्णय तो स्वयं हो गया। जो सबसे पहले सिंहासन पर विराजमान है, वहीं सबसे बड़ा है।'\n\n"
                        "राजा विक्रमादित्य के निर्णय को सुनकर शनि देवता ने सबसे पीछे आसन पर बैठने के कारण अपने को छोटा जानकर क्रोधित होकर कहा- 'राजा विक्रमादित्य! तुमने मुझे सबसे पीछे बैठाकर मेरा अपमान किया है। तुम मेरी शक्तियों से परिचित नहीं हो। मैं तुम्हारा सर्वनाश कर दूंगा।'\n\n"
                        "शनि ने कहा- 'सूर्य एक राशि पर एक महीने, चंद्रमा सवा दो दिन, मंगल डेढ़ महीने, बुध और शुक्र एक महीने, वृहस्पति तेरह महीने रहते हैं, लेकिन मैं किसी राशि पर साढ़े सात वर्ष (साढ़े साती) तक रहता हूँ। बड़े-बड़े देवताओं को मैंने अपने प्रकोप से पीड़ित किया है। राम को साढ़े साती के कारण ही वन में जाकर रहना पड़ा और रावण को साढ़े साती के कारण ही युद्ध में मृत्यु का शिकार बनना पड़ा। राजा! अब तू भी मेरे प्रकोप से नहीं बच सकेगा।' इसके बाद अन्य ग्रहों के देवता तो प्रसन्नता के साथ चले गए, परंतु शनि देव बड़े क्रोध के साथ वहां से विदा हुए। राजा विक्रमादित्य पहले की तरह ही न्याय करते रहे। उनके राज्य में सभी स्त्री-पुरुष बहुत आनंद से जीवन-यापन कर रहे थे। कुछ दिन ऐसे ही बीत गए। उधर शनि देवता अपने अपमान को भूले नहीं थे। विक्रमादित्य से बदला लेने के लिए एक दिन शनि देव ने घोड़े के व्यापारी का रूप धारण किया और बहुत से घोड़ों के साथ उज्जयिनी नगरी पहुंचे। राजा विक्रमादित्य ने राज्य में किसी घोड़े के व्यापारी के आने का समाचार सुना तो अपने अश्वपाल को कुछ घोड़े खरीदने के लिए भेजा।\n\n"
                        "घोड़े बहुत कीमती थे। अश्वपाल ने जब वापस लौटकर इस संबंध में बताया तो राजा विक्रमादित्य ने स्वयं आकर एक सुंदर व शक्तिशाली घोड़े को पसंद किया। तेजी से दौड़ता घोड़ा राजा को दूर एक जंगल में ले गया और फिर राजा को वहां गिराकर जंगल में कहीं गायब हो गया। राजा अपने नगर को लौटने के लिए जंगल में भटकने लगा। लेकिन उन्हें लौटने का कोई रास्ता नहीं मिला। राजा को भूख-प्यास लग आई। बहुत घूमने पर उसे एक चरवाहा मिला।\n\n"
                        "राजा ने उससे पानी मांगा। पानी पीकर राजा ने उस चरवाहे को अपनी अंगूठी दे दी। फिर उससे रास्ता पूछकर वह जंगल से निकलकर पास के नगर में पहुंचा। राजा ने एक सेठ की दुकान पर बैठकर कुछ देर आराम किया। उस सेठ ने राजा से बातचीत की तो राजा ने उसे बताया कि मैं उज्जयिनी नगरी से आया हूँ। राजा के कुछ देर दुकान पर बैठने से सेठ जी की बहुत बिक्री हुई।\n\n"
                        "सेठ ने राजा को बहुत भाग्यवान समझा और खुश होकर उसे अपने घर भोजन के लिए ले गया। सेठ के घर में सोने का एक हार खूंटी पर लटका हुआ था। राजा को उस कमरे में छोड़कर सेठ कुछ देर के लिए बाहर गया। तभी एक आश्चर्यजनक घटना घटी। राजा के देखते-देखते सोने के उस हार को खूंटी निगल गई।\n\n"
                        "सेठ ने कमरे में लौटकर हार को गायब देखा तो चोरी का संदेह राजा पर ही किया क्योंकि उस कमरे में राजा ही अकेला बैठा था। सेठ ने अपने नौकरों से कहा कि इस परदेसी को रस्सियों से बांधकर नगर के राजा के पास ले चलो। राजा ने विक्रमादित्य से हार के बारे में पूछा तो उसने बताया कि उसके देखते ही देखते खूंटी ने हार को निगल लिया था। इस पर राजा ने क्रोधित होकर चोरी करने के अपराध में विक्रमादित्य के हाथ-पांव काटने का आदेश दे दिया। राजा विक्रमादित्य के हाथ-पांव काटकर उसे नगर की सड़क पर छोड़ दिया गया।\n\n"
                        "कुछ दिन बाद एक तेली उसे उठाकर अपने घर ले गया और उसे अपने कोल्हू पर बैठा दिया। राजा आवाज देकर बैलों को हांकता रहता। इस तरह तेली का बैल चलता रहा और राजा को भोजन मिलता रहा। शनि के प्रकोप की साढ़े साती पूरी होने पर वर्षा ऋतु प्रारंभ हुई। राजा विक्रमादित्य एक रात मेघ मल्हार गा रहा था कि तभी नगर के राजा की लड़की राजकुमारी मोहिनी रथ पर सवार उस तेली के घर के पास से गुजरी। उसने मेघ मल्हार सुना तो उसे बहुत अच्छा लगा और दासी को भेजकर गाने वाले को बुला लाने को कहा।\n\n"
                        "दासी ने लौटकर राजकुमारी को अपंग राजा के बारे में सब कुछ बता दिया। राजकुमारी उसके मेघ मल्हार से बहुत मोहित हुई। अतः उसने सब कुछ जानकर भी अपंग राजा से विवाह करने का निश्चय कर लिया। राजकुमारी ने अपने माता-पिता से जब यह बात कही तो वे हैरान रह गए। रानी ने मोहिनी को समझाया- 'बेटी! तेरे भाग्य में तो किसी राजा की रानी होना लिखा है। फिर तू उस अपंग से विवाह करके अपने पांव पर कुल्हाड़ी क्यों मार रही है?\n\n"
                        "राजकुमारी ने अपनी जिद नहीं छोड़ी। अपनी जिद पूरी कराने के लिए उसने भोजन करना छोड़ दिया और प्राण त्याग देने का निश्चय कर लिया। आखिर राजा-रानी को विवश होकर अपंग विक्रमादित्य से राजकुमारी का विवाह करना पड़ा। विवाह के बाद राजा विक्रमादित्य और राजकुमारी तेली के घर में रहने लगे। उसी रात स्वप्न में शनि देव ने राजा से कहा- 'राजा तुमने मेरा प्रकोप देख लिया।\n\n"
                        "मैंने तुम्हें अपने अपमान का दंड दिया है।' राजा ने शनि देव से क्षमा करने को कहा और प्रार्थना की- 'हे शनि देव! आपने जितना दुःख मुझे दिया है, अन्य किसी को न देना।\n\n"
                        "शनि देव ने कुछ सोचकर कहा- 'राजा! मैं तुम्हारी प्रार्थना स्वीकार करता हूँ। जो कोई स्त्री-पुरुष मेरी पूजा करेगा, शनिवार को व्रत करके मेरी व्रतकथा सुनेगा, उस पर मेरी अनुकंपा बनी रहेगी। प्रातःकाल राजा विक्रमादित्य की नींद खुली तो अपने हाथ-पांव देखकर राजा को बहुत खुशी हुई। उसने मन ही मन शनि देव को प्रणाम किया। राजकुमारी भी राजा के हाथ-पांव सही-सलामत देखकर आश्चर्य में डूब गई। तब राजा विक्रमादित्य ने अपना परिचय देते हुए शनि देव के प्रकोप की सारी कहानी सुनाई।\n\n"
                        "सेठ को जब इस बात का पता चला तो दौड़ता हुआ तेली के घर पहुंचा और राजा के चरणों में गिरकर क्षमा मांगने लगा। राजा ने उसे क्षमा कर दिया क्योंकि यह सब तो शनि देव के प्रकोप के कारण हुआ था। सेठ राजा को अपने घर ले गया और उसे भोजन कराया। भोजन करते समय वहां एक आश्चर्यजनक घटना घटी। सबके देखते-देखते उस खूंटी ने हार उगल दिया। सेठ जी ने अपनी बेटी का विवाह भी राजा के साथ कर दिया और बहुत से स्वर्ण-आभूषण, धन आदि देकर राजा को विदा किया।\n\n"
                        "राजा विक्रमादित्य राजकुमारी मोहिनी और सेठ की बेटी के साथ उज्जयिनी पहुंचे तो नगरवासियों ने हर्ष से उनका स्वागत किया। अगले दिन राजा विक्रमादित्य ने पूरे राज्य में घोषणा कराई कि शनि देव सब देवों में सर्वश्रेष्ठ हैं। प्रत्येक स्त्री-पुरुष शनिवार को उनका व्रत करें और व्रतकथा अवश्य सुनें। राजा विक्रमादित्य की घोषणा से शनि देव बहुत प्रसन्न हुए। शनिवार का व्रत करने और व्रत कथा सुनने के कारण सभी लोगों की मनोकामनाएं शनि देव की अनुकंपा से पूरी होने लगीं। सभी लोग आनंदपूर्वक रहने लगे।"),
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
