import 'dart:async';
import 'package:flutter/material.dart';

import '../../controller/share_helper.dart';

class RishiPanchmi extends StatefulWidget {
  const RishiPanchmi({super.key});

  @override
  State<RishiPanchmi> createState() => _RishiPanchmiState();
}

class _RishiPanchmiState extends State<RishiPanchmi> {
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
  Color _themeColor = Colors.purpleAccent; // Default theme color

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
        ShareHelper.shareContent(context, "ऋषि पंचमी व्रत कथा");
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
          _isEnglish ? 'Rishi Panchami Vrat' : "ऋषि पंचमी की व्रत",
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

                //CommanBannerWidget(imagePath: 'assets/sahitya_images/vat savitri vrat katha.jpg',),

                _buildSectionTitle(_isEnglish
                    ? "What is Rishi Panchami Vrat"
                    : "ऋषि पंचमी का व्रत क्या होता है"),
                _buildSectionContent(_isEnglish
                    ? "Rishi Panchami is celebrated every year on Shukla Panchami of Bhadrapada month. Usually Rishi Panchami is celebrated two days after Hartalika Teej and one day after Ganesh Chaturthi."
                    : "हर साल भाद्रपद माह की शुक्ल पंचमी को ऋषि पंचमी मनाई जाती है। आमतौर पर ऋषि पंचमी हरतालिका तीज के दो दिन बाद और गणेश चतुर्थी के एक दिन बाद मनाई जाती है।"),

                _buildSectionTitle(_isEnglish
                    ? "Method of worship of Rishi Panchami"
                    : "ऋषि पंचमी की पूजन विधि"),
                _buildSectionContent(_isEnglish
                    ? "On the day of Rishi Panchami, after taking bath in the morning, wear clean and light yellow clothes. Panchamrit, flowers, sandalwood, incense sticks and various types of fruits and flowers are offered in the worship. During the worship, the aarti and mantras of the sages are recited and the Vrat Katha is heard. After this, the devotees keep Nirjala or fruit-eating fast and meditate on the Sapta Rishis along with God throughout the day."
                    : "ऋषि पंचमी के दिन सवेरे स्नानादि के बाद साफ-सुथरे और हल्के पीले रंग के वस्‍त्र पहनें .पूजा में पंचामृत, पुष्प, चंदन, धूप-दीप और विभिन्न प्रकार के फल-फूल अर्पित किए जाते हैं। पूजा के दौरान ऋषियों की आरती व मंत्रों का पाठ किया जाता है और व्रत कथा सुनी जाती है। इसके बाद श्रद्धालु निर्जला या फलाहार व्रत रखते हैं और दिनभर भगवान के साथ सप्त ऋषियों का ध्यान करते हैं"),
                _buildBulletPoint(_isEnglish
                    ? "Clean the house and temple."
                    : "घर और मंदिर की सफ़ाई करें."),
                _buildBulletPoint(_isEnglish
                    ? "Place the picture or idol of the Sapta Rishis on a wooden stand."
                    : "लकड़ी की चौकी पर सप्त ऋषियों की तस्वीर या मूर्ति रखें."),
                _buildBulletPoint(_isEnglish
                    ? "Place a vessel filled with water along with the chowki."
                    : "चौकी के साथ जल से भरा कलश रखें."),
                _buildBulletPoint(_isEnglish
                    ? "Offer incense, lamp, fruits, flowers, sweets, and naivedya."
                    : "धूप, दीप, फल, फूल, मिठाई, और नैवेद्य अर्पित करें."),
                _buildBulletPoint(_isEnglish
                    ? "Apologize to the Sapta Rishis for your mistakes."
                    : "सप्त ऋषियों से अपनी गलतियों के लिए माफ़ी मांगें."),
                _buildBulletPoint(_isEnglish
                    ? "Take a pledge to help others."
                    : "दूसरों की मदद करने का संकल्प लें."),
                _buildBulletPoint(_isEnglish
                    ? "Perform the aarti of the Sapta Rishis."
                    : "सप्त ऋषियों की आरती उतारें."),
                _buildBulletPoint(_isEnglish
                    ? "Listen to the Vrat Katha."
                    : "व्रत कथा सुनें."),
                _buildBulletPoint(_isEnglish
                    ? "Distribute the bhog as prasad."
                    : "भोग को प्रसाद के रूप में वितरित करें."),
                _buildBulletPoint(_isEnglish
                    ? "Take the blessings of the elders."
                    : "बड़े-बुज़ुर्गों का आशीर्वाद लें."),

                _buildSectionTitle(_isEnglish
                    ? "Puja Samagri for Rishi Panchami Vrat."
                    : "ऋषि पंचमी के व्रत की पूजा सामग्री."),
                _buildSectionContent(_isEnglish
                    ? "\n\n"
                        "\n\n"
                        "\n\n"
                    : "ऋषि पंचमी के दिन सुबह जल्दी उठकर स्नान करें और घर-मंदिर की सफ़ाई करें.\n\n"
                        "पूजा के लिए लकड़ी की चौकी पर लाल या पीला कपड़ा बिछाएं.\n\n"
                        "चौकी पर सप्तऋषि की तस्वीर स्थापित करें."),

                _buildSectionTitle(_isEnglish
                    ? "Rishi Panchami Vrat Udyaapan Vidhi"
                    : "ऋषि पंचमी व्रत उद्यापन विधि"),
                _buildSectionContent(_isEnglish
                    ? "Clean the place of worship and prepare it for the ritual. Arrange all the necessary materials for the puja. Take a bath and wear clean clothes. Keep the necessary items like water, fruits and sweets ready for offering. To make Rishi Panchami Vrat Udyapan smooth and successful, it is necessary to prepare well in advance. A day before the puja, inform 7 Brahmins or 7 Pandits in advance that they have to come for the puja."
                    : "ऋषि पंचमी के दिन व्रत रखने के बाद उद्यापन किया जाता है। उद्यापन अनुष्ठान किए बिना कोई भी व्रत पूरा नहीं होता, इसलिए ऋषि पंचमी का व्रत रखने वालों को उद्यापन अवश्य करना चाहिए।"),

                _buildSectionTitle(_isEnglish
                    ? "Rishi Panchami Vrat Udyapan Vidhi Materials"
                    : "ऋषि पंचमी व्रत उद्यापन विधि सामग्री"),
                _buildBulletPoint(_isEnglish
                    ? "Shriphal i.e. coconut, turmeric knot."
                    : "श्रीफल यानी नारियल, हल्दी की गांठ।"),
                _buildBulletPoint(_isEnglish
                    ? "Betel leaf, roli, mauli, 7 Puja betel nuts."
                    : "पान, रोली, मौली, 7 पूजा सुपारी।"),
                _buildBulletPoint(_isEnglish
                    ? "Mango leaves, earthen pot."
                    : "आम के पत्ते, मट्टी का कलश।"),
                _buildBulletPoint(_isEnglish
                    ? "Akshat (rice), Ganga water, Panchamrit."
                    : "अक्षत (चावल), गंगाजल, पंचामृत।"),
                _buildBulletPoint(_isEnglish
                    ? "Cow ghee, cotton wick, cloves, cardamom."
                    : "गाय घी, रूई की बत्ती, लौंग, इलायची।"),
                _buildBulletPoint(_isEnglish
                    ? "Chock flour, camphor, white sandalwood."
                    : "चौक आटा, कपूर, सफेद चंदन।"),
                _buildBulletPoint(_isEnglish
                    ? "Banana leaves, fruits, lotus seeds, dates, almonds, cashews, raisins, peanuts, earthen lamp, 7 types of offerings, jaggery, yellow towel and dhoti - to give to the Sapta Rishis."
                    : "केले के पत्ते, फल,मखाने , छुआरा, बादाम, काजू ,किशमिश , मूंगफली,मिट्टी का दीपक, 7 तरह का नैवेद्य, गुड़,पीला गमछा और धोती - सप्त ऋषियों को देने के लिए."),

                _buildSectionTitle(_isEnglish
                    ? "Rishi Panchami Vrat Katha-1"
                    : "ऋषि पंचमी की व्रतकथा-1"),
                _buildSectionContent(_isEnglish
                    ? "A virtuous Brahmin named Uttank lived in Vidarbha country. His wife was very devoted to her husband, whose name was Sushila. That Brahmin had two children, a son and a daughter. When she became of marriageable age, he married his daughter to a groom of similar family.\n"
                        "They got her married. By chance, she became a widow after a few days. The sad Brahmin couple started living with their daughter in a hut on the banks of the Ganga.\n"
                        "One day, the Brahmin girl was sleeping and her body was filled with worms. The girl told everything to her mother. The mother told everything to her husband and asked- Prannath! What is the reason for this fate of my pious daughter?\n"
                        "Uttank found out about this incident through meditation and told- This girl was a Brahmin in her previous birth too. She had touched the utensils as soon as she menstruated. In this birth too, she did not observe the Rishi Panchami fast following the example of others. That is why there are worms in her body.\n"
                        "It is believed in religious scriptures that a menstruating woman is impure like a Chandalini on the first day, a Brahmaghatini on the second day and a washerwoman on the third day. She becomes pure by taking a bath on the fourth day. If she observes the Rishi Panchami fast even now with a pure heart, then all her sorrows will go away and she will get unshakable good fortune in her next birth.\n"
                        "Following her father's orders, the daughter observed Rishi Panchami fast and worshipped the day as per rituals. Due to the effect of the fast, she was freed from all sorrows. In her next birth, she enjoyed eternal happiness along with unshakable good fortune.\n"
                    : "विदर्भ देश में उत्तंक नामक एक सदाचारी ब्राह्मण रहता था। उसकी पत्नी बड़ी पतिव्रता थी, जिसका नाम सुशीला था। उस ब्राह्मण के एक पुत्र तथा एक पुत्री दो संतान थी। विवाह योग्य होने पर उसने समान कुलशील वर के साथ कन्या का विवाह कर दिया। दैवयोग से कुछ दिनों बाद वह विधवा हो गई। दुखी ब्राह्मण दम्पति कन्या सहित गंगा तट पर कुटिया बनाकर रहने लगे।\n"
                        "एक दिन ब्राह्मण कन्या सो रही थी कि उसका शरीर कीड़ों से भर गया। कन्या ने सारी बात मां से कही। मां ने पति से सब कहते हुए पूछा- प्राणनाथ! मेरी साध्वी कन्या की यह गति होने का क्या कारण है?\n"
                        "उत्तंक ने समाधि द्वारा इस घटना का पता लगाकर बताया- पूर्व जन्म में भी यह कन्या ब्राह्मणी थी। इसने रजस्वला होते ही बर्तन छू दिए थे। इस जन्म में भी इसने लोगों की देखा-देखी ऋषि पंचमी का व्रत नहीं किया। इसलिए इसके शरीर में कीड़े पड़े हैं।\n"
                        "धर्म-शास्त्रों की मान्यता है कि रजस्वला स्त्री पहले दिन चाण्डालिनी, दूसरे दिन ब्रह्मघातिनी तथा तीसरे दिन धोबिन के समान अपवित्र होती है। वह चौथे दिन स्नान करके शुद्ध होती है। यदि यह शुद्ध मन से अब भी ऋषि पंचमी का व्रत करें तो इसके सारे दुख दूर हो जाएंगे और अगले जन्म में अटल सौभाग्य प्राप्त करेगी।\n"
                        "पिता की आज्ञा से पुत्री ने विधिपूर्वक ऋषि पंचमी का व्रत एवं पूजन किया। व्रत के प्रभाव से वह सारे दुखों से मुक्त हो गई। अगले जन्म में उसे अटल सौभाग्य सहित अक्षय सुखों का भोग मिला।"),

                _buildSectionContent(_isEnglish
                    ? "Rishi Panchami Vrat Katha-2"
                    : "ऋषि पंचमी की व्रतकथा-2"),

                _buildSectionContent(_isEnglish
                    ? "In the Satyuga, there was a king named Shyenjit in the city of Vidarbha. He was like a sage. In his kingdom there was a farmer named Sumitra. His wife Jayshree was extremely devoted to her husband.\n"
                        "Once in the rainy season, when his wife was busy in farming, she became menstruating. She came to know that she was menstruating, but she continued to do household chores. After some time, both the man and the woman lived their full life and died. Jayshree became a bitch and Sumitra got the vagina of a bull due to coming in contact with a menstruating woman, because apart from the menstrual defect, there was no fault of both of them.\n"
                        "For this reason, both of them remembered all the details of their previous birth. Both of them started living in the same city in the form of a bitch and a bull at the house of their son Suchitra. The virtuous Suchitra used to treat his guests with full respect. On the day of his father's shraddha, he prepared various types of food for the brahmins to eat.\n"
                        "When his wife had gone out of the kitchen for some work, a snake vomited poison in the pot of kheer in the kitchen. Suchitra's mother was watching everything from a distance in the form of a bitch. When her son's daughter-in-law came, she put her mouth in that pot to save her son from the sin of killing a brahmin. Suchitra's wife Chandravati could not see this act of the bitch and she took out a burning stick from the stove and hit the bitch.\n"
                        "The poor bitch started running here and there after getting beaten. Suchitra's daughter-in-law used to feed the bitch whatever leftovers etc. were left in the kitchen, but due to anger she got that thrown out too. After getting all the food items thrown away, cleaning the pot, she cooked food again and fed the brahmins.\n"
                        "At night, the bitch, being troubled with hunger, came to her former husband who was living in the form of a bull and said, O lord! Today I am dying of hunger. Although my son used to give me food every day, today I did not get anything. Many people had touched the pot of kheer containing snake poison out of fear of committing brahmahatya and made it unfit for them to eat. That is why his daughter-in-law beat me and did not give me anything to eat.\n"
                        "Then the bull said, Oh dear! Because of your sins I have also been born in this womb and today my back has broken carrying the load. Today I too was ploughing the field the whole day. My son did not give me food today and also beat me a lot. By troubling me in this way, he has made this Shraddha fruitless.\n"
                        "Suchitra was listening to these words of her parents, he fed them both to their heart's content at the same time and then went towards the forest, saddened by their sorrow. Going to the forest, he asked the sages that due to which deeds my parents have attained these lower wombs and how can they get freedom now. Then Sarvatma Rishi said that for their liberation you should observe the fast of Rishi Panchami along with your wife and give its fruits to your parents.\n"
                        "On the Shukla Panchami of the month of Bhadrapad, clean your mouth and take a bath in the holy water of the river at noon and wear new silk clothes and worship the Saptarshis along with Arundhati. Hearing this, Suchitra returned to his home and performed the Puja Vrat with his wife as per the rituals. Due to his virtue, both his parents were freed from animal births. Therefore, the woman who observes the Rishi Panchami Vrat with devotion, enjoys all the worldly pleasures and goes to Vaikuntha.\n"
                    : "सतयुग में विदर्भ नगरी में श्येनजित नामक राजा हुए थे। वह ऋषियों के समान थे। उन्हीं के राज में एक कृषक सुमित्र था। उसकी पत्नी जयश्री अत्यंत पतिव्रता थी।\n"
                        "एक समय वर्षा ऋतु में जब उसकी पत्नी खेती के कामों में लगी हुई थी, तो वह रजस्वला हो गई। उसको रजस्वला होने का पता लग गया फिर भी वह घर के कामों में लगी रही। कुछ समय बाद वह दोनों स्त्री-पुरुष अपनी-अपनी आयु भोगकर मृत्यु को प्राप्त हुए। जयश्री तो कुतिया बनीं और सुमित्र को रजस्वला स्त्री के सम्पर्क में आने के कारण बैल की योनी मिली, क्योंकि ऋतु दोष के अतिरिक्त इन दोनों का कोई अपराध नहीं था।\n"
                        "इसी कारण इन दोनों को अपने पूर्व जन्म का समस्त विवरण याद रहा। वे दोनों कुतिया और बैल के रूप में उसी नगर में अपने बेटे सुचित्र के यहां रहने लगे। धर्मात्मा सुचित्र अपने अतिथियों का पूर्ण सत्कार करता था। अपने पिता के श्राद्ध के दिन उसने अपने घर ब्राह्मणों को भोजन के लिए नाना प्रकार के भोजन बनवाए।\n"
                        "जब उसकी स्त्री किसी काम के लिए रसोई से बाहर गई हुई थी तो एक सर्प ने रसोई की खीर के बर्तन में विष वमन कर दिया। कुतिया के रूप में सुचित्र की मां कुछ दूर से सब देख रही थी। पुत्र की बहू के आने पर उसने पुत्र को ब्रह्म हत्या के पाप से बचाने के लिए उस बर्तन में मुंह डाल दिया। सुचित्र की पत्नी चन्द्रवती से कुतिया का यह कृत्य देखा न गया और उसने चूल्हे में से जलती लकड़ी निकाल कर कुतिया को मारी।\n"
                        "बेचारी कुतिया मार खाकर इधर-उधर भागने लगी। चौके में जो झूठन आदि बची रहती थी, वह सब सुचित्र की बहू उस कुतिया को डाल देती थी, लेकिन क्रोध के कारण उसने वह भी बाहर फिकवा दी। सब खाने का सामान फिकवा कर बर्तन साफ करके दोबारा खाना बना कर ब्राह्मणों को खिलाया।\n"
                        "रात्रि के समय भूख से व्याकुल होकर वह कुतिया बैल के रूप में रह रहे अपने पूर्व पति के पास आकर बोली, हे स्वामी! आज तो मैं भूख से मरी जा रही हूं। वैसे तो मेरा पुत्र मुझे रोज खाने को देता था, लेकिन आज मुझे कुछ नहीं मिला। सांप के विष वाले खीर के बर्तन को अनेक ब्रह्म हत्या के भय से छूकर उनके न खाने योग्य कर दिया था। इसी कारण उसकी बहू ने मुझे मारा और खाने को कुछ भी नहीं दिया।\n"
                        "तब वह बैल बोला, हे भद्रे! तेरे पापों के कारण तो मैं भी इस योनी में आ पड़ा हूं और आज बोझा ढ़ोते-ढ़ोते मेरी कमर टूट गई है। आज मैं भी खेत में दिनभर हल में जुता रहा। मेरे पुत्र ने आज मुझे भी भोजन नहीं दिया और मुझे मारा भी बहुत। मुझे इस प्रकार कष्ट देकर उसने इस श्राद्ध को निष्फल कर दिया।\n"
                        "अपने माता-पिता की इन बातों को सुचित्र सुन रहा था, उसने उसी समय दोनों को भरपेट भोजन कराया और फिर उनके दुख से दुखी होकर वन की ओर चला गया। वन में जाकर ऋषियों से पूछा कि मेरे माता-पिता किन कर्मों के कारण इन नीची योनियों को प्राप्त हुए हैं और अब किस प्रकार से इनको छुटकारा मिल सकता है। तब सर्वतमा ऋषि बोले तुम इनकी मुक्ति के लिए पत्नीसहित ऋषि पंचमी का व्रत धारण करो तथा उसका फल अपने माता-पिता को दो।\n"
                        "भाद्रपद महीने की शुक्ल पंचमी को मुख शुद्ध करके मध्याह्न में नदी के पवित्र जल में स्नान करना और नए रेशमी कपड़े पहनकर अरूधन्ती सहित सप्तऋषियों का पूजन करना। इतना सुनकर सुचित्र अपने घर लौट आया और अपनी पत्नीसहित विधि-विधान से पूजन व्रत किया। उसके पुण्य से माता-पिता दोनों पशु योनियों से छूट गए। इसलिए जो महिला श्रद्धापूर्वक ऋषि पंचमी का व्रत करती है, वह समस्त सांसारिक सुखों को भोग कर बैकुंठ को जाती है।\n"),
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

// import 'dart:async';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:share_plus/share_plus.dart';
//
// class RishiPanchmi extends StatefulWidget {
//   const RishiPanchmi({super.key});
//
//   @override
//   State<RishiPanchmi> createState() => _RishiPanchmiState();
// }
//
// class _RishiPanchmiState extends State<RishiPanchmi> {
//   int _currentIndex = 0;
//   bool _isBlackBackground = false;
//   final double _scaleIncrement = 0.1;
//   bool _isAutoScrolling = false;
//   double _scrollSpeed = 2.0;
//   late Timer _scrollTimer;
//   final ScrollController _scrollController = ScrollController();
//
//   bool _isSliderVisible =
//   false; // State variable to track visibility of the slider button
//   double _textScaleFactor = 15.0; // Default font size
//   bool _isEnglish = false; // State variable to track language
//   Color _themeColor = Colors.orangeAccent; // Default theme color
//
//   @override
//   void dispose() {
//     _scrollTimer.cancel();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   // Method to share content
//   void _shareContent() {
//     String contentToShare = 'hi';
//     Share.share(contentToShare, subject: 'Check out this blog!');
//   }
//
//   // Method to show a SnackBar and copy content to clipboard
//   void _showCopyMessage() {
//     const snackBar = SnackBar(
//       content: Text('Content copied!'),
//       duration: Duration(seconds: 2),
//     );
//
//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   }
//
//   void _toggleAutoScroll() {
//     setState(() {
//       _isAutoScrolling = !_isAutoScrolling;
//
//       if (_isAutoScrolling) {
//         _scrollTimer =
//             Timer.periodic(const Duration(milliseconds: 100), (timer) {
//               if (_scrollController.position.pixels <
//                   _scrollController.position.maxScrollExtent) {
//                 _scrollController.animateTo(
//                   _scrollController.position.pixels + _scrollSpeed,
//                   duration: const Duration(milliseconds: 100),
//                   curve: Curves.linear,
//                 );
//               } else {
//                 _scrollController.jumpTo(0);
//               }
//             });
//       } else {
//         _scrollTimer.cancel();
//       }
//     });
//   }
//
//   void _onBottomNavTap(int index) {
//     if (index != 5) {
//       if (_isAutoScrolling) {
//         _toggleAutoScroll();
//       }
//     }
//
//     setState(() {
//       _currentIndex = index;
//
//       if (index == 0) {
//         _isBlackBackground = !_isBlackBackground;
//       } else if (index == 1) {
//         _textScaleFactor += _scaleIncrement;
//       } else if (index == 2) {
//         _textScaleFactor -= _scaleIncrement;
//         if (_textScaleFactor < 0.1) {
//           _textScaleFactor = 0.1;
//         }
//       } else if (index == 3) {
//         _shareContent();
//       } else if (index == 4) {
//         _showCopyMessage();
//       } else if (index == 5) {
//         _toggleAutoScroll();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _isBlackBackground ? Colors.black : Colors.white,
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: _isBlackBackground ? Colors.black : _themeColor,
//         leading: IconButton(
//           onPressed: () {
//             Navigator.of(context).pop(); // Navigate back
//           },
//           icon: Icon(Icons.arrow_back, color: Colors.white),
//         ),
//         title: Text(
//           _isEnglish ? 'Sheetla Saptami Vrat' : "शीतला सप्तमी व्रत",
//           style: TextStyle(color: Colors.white),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.translate, color: Colors.white),
//             onPressed: () {
//               setState(() {
//                 _isEnglish = !_isEnglish; // Toggle language
//               });
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.color_lens, color: Colors.white),
//             onPressed: () {
//               _showColorSelectionDialog(); // Show color selection dialog
//             },
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           controller: _scrollController,
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: _isBlackBackground
//                     ? [Colors.black, Colors.grey]
//                     : [_themeColor.withOpacity(0.5), Colors.white],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//             padding: EdgeInsets.all(15),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 1),
//
//                 _buildSectionTitle(_isEnglish ?"" :"" ),
//                 _buildSectionContent(_isEnglish
//                     ?""
//                     :""
//                  ),
//
//
//               ],
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (_currentIndex == 5)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//               child: Column(
//                 children: [
//                   Text(
//                     "Adjust Scroll Speed",
//                     style: TextStyle(
//                         color: _isBlackBackground ? Colors.white : Colors.black,
//                         fontWeight: FontWeight.w500
//                     ),
//                   ),
//                   Slider(
//                     value: _scrollSpeed,
//                     activeColor: _isBlackBackground ? Colors.white : _themeColor,
//                     inactiveColor: Colors.black.withOpacity(0.5),
//                     min: 1.0,
//                     max: 10.0,
//                     divisions: 10,
//                     label: _scrollSpeed.round().toString(),
//                     onChanged: (double value) {
//                       setState(() {
//                         _scrollSpeed = value;
//                       });
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           BottomNavigationBar(
//             currentIndex: _currentIndex,
//             onTap: _onBottomNavTap,
//             items: [
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.sunny,
//                     color: _isBlackBackground ? Colors.black : _themeColor),
//                 label: '',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.text_increase_outlined,
//                     color: _isBlackBackground ? Colors.black : _themeColor),
//                 label: '',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.text_decrease,
//                     color: _isBlackBackground ? Colors.black : _themeColor),
//                 label: '',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.share_outlined,
//                     color: _isBlackBackground ? Colors.black : _themeColor),
//                 label: '',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.save,
//                     color: _isBlackBackground ? Colors.black : _themeColor),
//                 label: '',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.slideshow,
//                     color: _isBlackBackground ? Colors.black : _themeColor),
//                 label: '',
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showColorSelectionDialog() {
//     Map<Color, String> colorMap = {
//       Colors.red: "Red",
//       Colors.green: "Green",
//       Colors.blue: "Blue",
//       Colors.yellow: "Yellow",
//       Colors.purple: "Purple",
//       Colors.deepOrange: "Orange",
//       Colors.teal: "Teal",
//       Colors.brown: "Brown",
//       Colors.cyan: "Cyan",
//       Colors.indigo: "Indigo",
//       Colors.amber: "Amber",
//       Colors.lime: "Lime",
//     };
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Select Theme Color"),
//           content: Container(
//             height: 400,
//             width: double.maxFinite,
//             child: GridView.count(
//               crossAxisCount: 3,
//               children: colorMap.entries.map((entry) {
//                 return _colorOption(entry.key, entry.value);
//               }).toList(),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//               child: Text("Close"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _colorOption(Color color, String colorName) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _themeColor = color; // Update the theme color
//         });
//         Navigator.of(context).pop(); // Close the dialog
//       },
//       child: Container(
//         margin: EdgeInsets.all(5),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Center(
//           child: Text(
//             colorName,
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(right: 15, left: 15, top: 20, bottom: 5),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: _textScaleFactor,
//           fontWeight: FontWeight.bold,
//           color: _isBlackBackground ? Colors.white : _themeColor,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSectionContent(String content) {
//     return Card(
//       elevation: 4,
//       color: _isBlackBackground ? Colors.black : Colors.white,
//       margin: EdgeInsets.symmetric(vertical: 5),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
//         child: Text(
//           content,
//           style: TextStyle(
//             fontSize: _textScaleFactor,
//             color: _isBlackBackground ? Colors.white : Colors.black,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBulletPoint(String text) {
//     return Column(
//       children: [
//         SizedBox(height: 8),
//         Row(
//           children: [
//             Icon(Icons.check_circle,
//                 color: _isBlackBackground ? Colors.white : _themeColor,
//                 size: 20),
//             SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 text,
//                 style: TextStyle(
//                     fontSize: _textScaleFactor,
//                     color: _isBlackBackground ? Colors.white : Colors.black),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
