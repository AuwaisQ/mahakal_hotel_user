import 'dart:async';
import 'package:flutter/material.dart';

import '../../controller/share_helper.dart';
import 'commanbannerwidget.dart';

class NagPanchmi extends StatefulWidget {
  const NagPanchmi({super.key});

  @override
  State<NagPanchmi> createState() => _NagPanchmiState();
}

class _NagPanchmiState extends State<NagPanchmi> {
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
  Color _themeColor = Colors.red; // Default theme color

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
        ShareHelper.shareContent(context, "नाग पंचमी व्रत कथा");
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
          _isEnglish ? 'Nag Panchami Vrat' : "नागपंचमी व्रत",
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
                  imagePath: 'assets/sahitya_images/Nag Panchami katha.jpg',
                ),
                _buildSectionTitle(_isEnglish
                    ? "About Nag Panchami:"
                    : "नागपंचमी के बारे में:"),
                _buildSectionContent(_isEnglish
                    ? "Nag Panchami is a major festival of Hindus. According to Hindu calendar, the fifth day of Krishna Paksha of Sawan month is celebrated as Nag Panchami. On this day, Nag Devta or snake is worshipped and they are given a bath with milk. But in some places, the tradition of feeding milk has started. Feeding milk to snakes leads to their death due to indigestion or allergy. In the scriptures, it is said not to feed milk to snakes but to bathe them with milk. On this day, Navnag is worshipped."
                    : "नाग पंचमी हिन्दुओं का एक प्रमुख त्योहार है। हिन्दू पंचांग के अनुसार सावन माह की कृष्ण पक्ष के पंचमी को नाग पंचमी के रूप में मनाया जाता है। इस दिन नाग देवता या सर्प की पूजा की जाती है और उन्हें दूध से स्नान कराया जाता है। लेकिन कहीं-कहीं दूध पिलाने की परम्परा चल पड़ी है। नाग को दूध पिलाने से पाचन नहीं हो पाने या प्रत्यूर्जता से उनकी मृत्यु हो जाती है। शास्त्रों में नागों को दूध पिलाने को नहीं बल्कि दूध से स्नान कराने को कहा गया है। इस दिन नवनाग की पूजा की जाती है।"),
                _buildSectionTitle(
                    _isEnglish ? "Method of worship:" : "पूजन विधि:"),
                _buildBulletPoint(_isEnglish
                    ? "Get up in the morning, clean the house and finish your daily chores."
                    : "प्रातः उठकर घर की सफाई कर नित्यकर्म से निवृत्त हो जाएँ।"),
                _buildBulletPoint(_isEnglish
                    ? "After that, take a bath and wear clean clothes."
                    : "पश्चात स्नान कर साफ-स्वच्छ वस्त्र धारण करें।"),
                _buildBulletPoint(_isEnglish
                    ? "Prepare fresh food like vermicelli, rice etc. for worship. In some parts, food is prepared and kept a day before Nag Panchami and stale food is eaten on the day of Nag Panchami."
                    : "पूजन के लिए सेंवई-चावल आदि ताजा भोजन बनाएँ। कुछ भागों में नागपंचमी से एक दिन भोजन बना कर रख लिया जाता है और नागपंचमी के दिन बासी खाना खाया जाता है।"),
                _buildBulletPoint(_isEnglish
                    ? "After this, a place for worship is made by applying ochre on the wall."
                    : "इसके बाद दीवाल पर गेरू पोतकर पूजन का स्थान बनाया जाता है।"),
                _buildBulletPoint(_isEnglish
                    ? "Then after grinding coal in raw milk, they make a house-like structure on the ochre-coated wall and draw figures of many serpent gods in it."
                    : "फिर कच्चे दूध में कोयला घिसकर उससे गेरू पुती दीवाल पर घर जैसा बनाते हैं और उसमें अनेक नागदेवों की आकृति बनाते हैं।"),
                _buildBulletPoint(_isEnglish
                    ? "At some places, they draw the five-hooded serpent gods on both sides of the main door of the house using pens made of gold, silver, wood and clay and ink made of turmeric and sandalwood or cow dung and worship them."
                    : "कुछ जगहों पर सोने, चांदी, काठ व मिट्टी की कलम तथा हल्दी व चंदन की स्याही से अथवा गोबर से घर के मुख्य दरवाजे के दोनों बगलों में पाँच फन वाले नागदेव अंकित कर पूजते हैं।"),
                _buildBulletPoint(_isEnglish
                    ? "First of all, a bowl of milk is offered in the hole of the serpents."
                    : "सर्वप्रथम नागों की बांबी में एक कटोरी दूध चढ़ा आते हैं।"),
                _buildBulletPoint(_isEnglish
                    ? "And then the serpent god made on the wall is worshipped with curd, durva, kusha, fragrance, whole rice, flowers, water, raw milk, roli and rice etc. and vermicelli and sweets are offered to him."
                    : "और फिर दीवाल पर बनाए गए नागदेवता की दधि, दूर्वा, कुशा, गंध, अक्षत, पुष्प, जल, कच्चा दूध, रोली और चावल आदि से पूजन कर सेंवई व मिष्ठान से उनका भोग लगाते हैं।"),
                _buildBulletPoint(_isEnglish
                    ? "After that, one should perform aarti and listen to the story."
                    : "पश्चात आरती कर कथा श्रवण करना चाहिए।"),
                _buildSectionTitle(
                    _isEnglish ? "Puja material:" : "पूजा सामग्री:"),
                _buildBulletPoint(_isEnglish
                    ? "Statue or photo of the snake god"
                    : "नाग देवता की प्रतिमा या फोटो"),
                _buildBulletPoint(_isEnglish ? "Milk, flower" : "दूध, फूल"),
                _buildBulletPoint(_isEnglish
                    ? "Pancha phal pancha meva"
                    : "पंच फल, पंच मेवा"),
                _buildBulletPoint(
                    _isEnglish ? "Utensils of worship" : "पूजन के बर्तन"),
                _buildBulletPoint(_isEnglish ? "Kushasan" : "कुशासन"),
                _buildBulletPoint(
                    _isEnglish ? "Curd, pure desi ghee" : "दही, शुद्ध देसी घी"),
                _buildBulletPoint(_isEnglish
                    ? "Honey, Ganga water, holy water"
                    : "शहद, गंगाजल, पवित्र जल"),
                _buildBulletPoint(_isEnglish
                    ? "Panch Ras, perfume, mauli janeu"
                    : "पंच रस, इत्र, मौली जनेऊ"),
                _buildBulletPoint(_isEnglish ? "Panch Mithai" : "पंच मिठाई"),
                _buildBulletPoint(_isEnglish
                    ? "Bilvapatra, dhatura, bhang, plum"
                    : "बिल्वपत्र, धतूरा, भांग, बेर"),
                _buildBulletPoint(_isEnglish ? "Mango buds" : "आम के कोंपल"),
                _buildBulletPoint(_isEnglish ? "Barley ears" : "जौ की बालियां"),
                _buildBulletPoint(
                    _isEnglish ? "Tulsi leaves" : "तुलसी के पत्ते"),
                _buildBulletPoint(_isEnglish ? "Mandar flower" : "मंदार फूल"),
                _buildBulletPoint(
                    _isEnglish ? "Raw cow milk" : "कच्चा गाय का दूध"),
                _buildBulletPoint(_isEnglish
                    ? "Sugarcane juice, camphor, incense"
                    : "गन्ने का रस, कपूर, अगरबत्ती"),
                _buildSectionTitle(_isEnglish ? "Story:" : "कथा:"),
                _buildSectionContent(_isEnglish
                    ? "In ancient times, a rich man had seven sons. All seven were married. The wife of the youngest son was a learned and well behaved woman of good character, but she had no brother.\n\n"
                        "One day, the eldest daughter-in-law asked all the daughters-in-law to accompany her to bring yellow soil for plastering the house, so all of them took spades and hoes and started digging the soil. Then a snake came out, which the eldest daughter-in-law started killing with the hoe. Seeing this, the younger daughter-in-law stopped her and said, 'Don't kill it? This poor fellow is innocent.'\n\n"
                        "On hearing this the elder daughter in law did not kill him and the snake went and sat on one side. Then the younger daughter in law said to him- 'We will be back just now, you do not go from here. Saying this she went home with everyone carrying the soil and there getting caught up in work she forgot the promise she had made to the snake.\n\n"
                        "The next day she remembered that and reached there taking everyone with her and seeing the snake sitting at that place she said- Namaskar snake brother! The snake said- 'You have called me brother, that is why I am leaving you, otherwise I would have bitten you right now for telling a lie. She said- Bhaiya me I have made a mistake, I apologize for that. Then the snake said- well, from today you are my sister and I am your brother. Ask for whatever you want. She said- brother! I have no one, it is good that you became my brother.\n\n"
                        "After some days, the snake came to her house in the form of a human and said, 'Send my sister.' Everyone said that he had no brother, so he said- I am his distant relative, I went out in childhood. On his assurance, the people of the house sent Choti with him. On the way, he told her that 'I am the same snake, so do not be afraid and wherever you have difficulty in walking, hold my tail.' She did as he said and thus she reached his house. She was surprised to see the wealth and prosperity there.\n\n"
                        "One day the snake's mother said to her- 'I am going out for some work, you feed cold milk to your brother.' She did not remember this and made him feed hot milk, which burnt his face badly. Seeing this, the snake's mother became very angry. But she calmed down after the snake explained. Then the snake said that the sister should now be sent to her home. Then the snake and his father sent her home, giving her lots of gold, silver, jewels, clothes, ornaments etc.\n\n"
                        "Seeing so much wealth, the elder daughter-in-law said with jealousy - your brother is very rich, you should bring more wealth from him. When the snake heard these words, he brought all the things made of gold. Seeing this, the elder daughter-in-law said - 'The broom to sweep them should also be made of gold'. Then the snake brought a broom made of gold too.\n\n"
                        "The snake had given a wonderful necklace of diamonds and gems to the younger daughter-in-law. The queen of that country also heard its praise and she said to the king - The necklace of the Seth's younger daughter-in-law should come here.' The king ordered the minister to bring that necklace from her and present himself soon. The minister went to the Seth and said that 'Maharaniji will wear the necklace of the younger daughter-in-law, take it from her and give it to me'. Due to fear, the Sethji asked the younger daughter-in-law to bring the necklace and gave it to him.\n\n"
                        "The younger daughter-in-law felt very bad about this, she remembered her snake brother and prayed to him when he came- Brother! The queen has snatched the necklace, you do something so that as long as the necklace is around her neck, it turns into a snake and when she returns it to me, it turns into diamonds and gems. The snake did exactly the same. As soon as the queen wore the necklace, it turned into a snake. Seeing this, the queen screamed and started crying.\n\n"
                        "Seeing this, the king sent a message to the Seth to send the younger daughter-in-law immediately. The Sethji got scared thinking what the king would do? He himself came along with the younger daughter-in-law. The king asked the younger daughter-in-law- What magic have you done, I will punish you. The younger daughter-in-law said- King! Please forgive my impudence, this necklace is such that it remains made of diamonds and gems around my neck and turns into a snake around someone else's neck. Hearing this, the king gave her the snake necklace and said- show me by wearing it now. As soon as the younger daughter-in-law wore it, it turned into diamonds and gems.\n\n"
                        "On seeing this, the king believed her words and happily gave her a lot of coins as a reward. The younger daughter-in-law returned home with her necklace and jewellery. Seeing her wealth, the elder daughter-in-law, out of jealousy, told her husband that the younger daughter-in-law had got money from somewhere. On hearing this, her husband called his wife and said- Tell me exactly who gives you this money? Then she started remembering the snake.\n\n"
                        "Then at that very moment the snake appeared and said- If anyone doubts the conduct of my sister-in-law, I will eat him. On hearing this, the husband of the younger daughter-in-law became very happy and he honoured the snake god greatly. From that day onwards, the festival of Nagpanchami is celebrated and women worship the snake considering it as their brother."
                    : "प्राचीन काल में एक सेठजी के सात पुत्र थे। सातों के विवाह हो चुके थे। सबसे छोटे पुत्र की पत्नी श्रेष्ठ चरित्र की विदूषी और सुशील थी, परंतु उसके भाई नहीं था। एक दिन बड़ी बहू ने घर लीपने को पीली मिट्टी लाने के लिए सभी बहुओं को साथ चलने को कहा तो सभी धलिया और खुरपी लेकर मिट्टी खोदने लगी। तभी वहां एक सर्प  निकला, जिसे बड़ी बहू खुरपी से मारने लगी। यह देखकर छोटी बहू ने उसे रोकते हुए कहा- 'मत मारो इसे? यह बेचारा निरपराध है।'\n\n"
                        "यह सुनकर बड़ी बहू ने उसे नहीं मारा तब सर्प एक ओर जा बैठा। तब छोटी बहू ने उससे कहा-'हम अभी लौट कर आती हैं तुम यहां से जाना मत। यह कहकर वह सबके साथ मिट्टी लेकर घर चली गई और वहां कामकाज में फंसकर सर्प से जो वादा किया था उसे भूल गई।\n\n"
                        "उसे दूसरे दिन वह बात याद आई तो सब को साथ लेकर वहां पहुंची और सर्प को उस स्थान पर बैठा देखकर बोली- सर्प भैया नमस्कार! सर्प ने कहा- 'तू भैया कह चुकी है, इसलिए तुझे छोड़ देता हूं, नहीं तो झूठी बात कहने के कारण तुझे अभी डस लेता। वह बोली- भैया मुझसे भूल हो गई, उसकी क्षमा मांगती हूँ, तब सर्प बोला- अच्छा, तू आज से मेरी बहन हुई और मैं तेरा भाई हुआ। तुझे जो मांगना हो, मांग ले। वह बोली- भैया! मेरा कोई नहीं है, अच्छा हुआ जो तू मेरा भाई बन गया।\n\n"
                        "कुछ दिन व्यतीत होने पर वह सर्प मनुष्य का रूप रखकर उसके घर आया और बोला कि 'मेरी बहन को भेज दो।' सबने कहा कि 'इसके तो कोई भाई नहीं था, तो वह बोला- मैं दूर के रिश्ते में इसका भाई हूं, बचपन में ही बाहर चला गया था। उसके विश्वास दिलाने पर घर के लोगों ने छोटी को उसके साथ भेज दिया। उसने मार्ग में बताया कि 'मैं वहीं सर्प  हूं, इसलिए तू डरना नहीं और जहां चलने में कठिनाई हो वहां मेरी पूंछ पकड़ लेना। उसने कहे अनुसार ही किया और इस प्रकार वह उसके घर पहुंच गई। वहां के धन-ऐश्वर्य को देखकर वह चकित हो गई।\n\n"
                        "एक दिन सर्प की माता ने उससे कहा- 'मैं एक काम से बाहर जा रही हूँ, तू अपने भाई को ठंडा दूध पिला देना। उसे यह बात ध्यान न रही और उससे गर्म दूध पिला दिया, जिसमें उसका मुख बेतरह जल गया। यह देखकर सर्प की माता बहुत क्रोधित हुई। परंतु सर्प के समझाने पर शांत हो गई। तब सर्प ने कहा कि बहिन को अब उसके घर भेज देना चाहिए। तब सर्प और उसके पिता ने उसे बहुत सा सोना, चांदी, जवाहरात, वस्त्र-भूषण आदि देकर उसके घर पहुंचा दिया।\n\n"
                        "इतना ढेर सारा धन देखकर बड़ी बहू ने ईर्ष्या से कहा- भाई तो बड़ा धनवान है, तुझे तो उससे और भी धन लाना चाहिए। सर्प ने यह वचन सुना तो सब वस्तुएं सोने की लाकर दे दीं। यह देखकर बड़ी बहू ने कहा- 'इन्हें झाड़ने की झाड़ू भी सोने की होनी चाहिए'। तब सर्प ने झाडू भी सोने की लाकर रख दी।\n\n"
                        "सर्प ने छोटी बहू को हीरा-मणियों का एक अद्भुत हार दिया था। उसकी प्रशंसा उस देश की रानी ने भी सुनी और वह राजा से बोली कि- सेठ की छोटी बहू का हार यहां आना चाहिए।' राजा ने मंत्री को हुक्म दिया कि उससे वह हार लेकर शीघ्र उपस्थित हो मंत्री ने सेठजी से जाकर कहा कि 'महारानीजी छोटी बहू का हार पहनेंगी, वह उससे लेकर मुझे दे दो'। सेठजी ने डर के कारण छोटी बहू से हार मंगाकर दे दिया।\n\n"
                        "छोटी बहू को यह बात बहुत बुरी लगी, उसने अपने सर्प भाई को याद किया और आने पर प्रार्थना की- भैया ! रानी ने हार छीन लिया है, तुम कुछ ऐसा करो कि जब वह हार उसके गले में रहे, तब तक के लिए सर्प बन जाए और जब वह मुझे लौटा दे तब हीरों और मणियों का हो जाए। सर्प ने ठीक वैसा ही किया। जैसे ही रानी ने हार पहना, वैसे ही वह सर्प बन गया। यह देखकर रानी चीख पड़ी और रोने लगी।\n\n"
                        "यह देख कर राजा ने सेठ के पास खबर भेजी कि छोटी बहू को तुरंत भेजो। सेठजी डर गए कि राजा न जाने क्या करेगा? वे स्वयं छोटी बहू को साथ लेकर उपस्थित हुए। राजा ने छोटी बहू से पूछा- तुने क्या जादू किया है, मैं तुझे दंड दूंगा। छोटी बहू बोली- राजन ! धृष्टता क्षमा कीजिए, यह हार ही ऐसा है कि मेरे गले में हीरों और मणियों का रहता है और दूसरे के गले में सर्प बन जाता है। यह सुनकर राजा ने वह सर्प बना हार उसे देकर कहा- अभी पहनकर दिखाओ। छोटी बहू ने जैसे ही उसे पहना वैसे ही हीरों-मणियों का हो गया।\n\n"
                        "यह देखकर राजा को उसकी बात का विश्वास हो गया और उसने प्रसन्न होकर उसे बहुत सी मुद्राएं भी पुरस्कार में दीं। छोटी वह अपने हार और इन सहित घर लौट आई। उसके धन को देखकर बड़ी बहू ने ईर्ष्या के कारण उसके पति को सिखाया कि छोटी बहू के पास कहीं से धन आया है। यह सुनकर उसके पति ने अपनी पत्नी को बुलाकर कहा- ठीक-ठीक बता कि यह धन तुझे कौन देता है? तब वह सर्प को याद करने लगी।\n\n"
                        "तब उसी समय सर्प ने प्रकट होकर कहा- यदि मेरी धर्म बहन के आचरण पर संदेह प्रकट करेगा तो मैं उसे खा लूंगा। यह सुनकर छोटी बहू का पति बहुत प्रसन्न हुआ और उसने सर्प देवता का बड़ा सत्कार किया। उसी दिन से नागपंचमी का त्योहार मनाया जाता है और स्त्रियां सर्प को भाई मानकर उसकी पूजा करती हैं।"),
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
