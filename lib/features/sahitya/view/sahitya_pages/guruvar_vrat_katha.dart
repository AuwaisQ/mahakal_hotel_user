import 'dart:async';
import 'package:flutter/material.dart';

import '../../controller/share_helper.dart';

class GuruvarVrat extends StatefulWidget {
  const GuruvarVrat({super.key});

  @override
  State<GuruvarVrat> createState() => _GuruvarVratState();
}

class _GuruvarVratState extends State<GuruvarVrat> {
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
        ShareHelper.shareContent(context, "गुरुवार व्रत कथा");
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
          _isEnglish ? 'Thursday fast story' : "ब्रहस्पतिवार( गुरुवर) व्रत कथा",
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

                _buildSectionTitle(_isEnglish
                    ? "About Thursday Vrat:"
                    : "गुरुवार व्रत के बारे में:"),
                _buildSectionContent(_isEnglish
                    ? "Thursday fast is dedicated to Lord Vishnu and Brihaspati Dev. Keeping fast on this day fulfills wishes and blessings are showered on those who worship with goodwill. Thursday is a very important day in Hinduism. On this day, Vishnu ji is worshipped. Thursday means the day of Guru Dev Brihaspati. Keeping fast and reciting Vishnu ji's mantra on this day gives relief from troubles. Those who keep fast on Thursday and worship Lord Vishnu and read this Vrat Katha, they get special blessings of Lord Vishnu. By observing this fast, all the troubles of a person are removed and happiness is attained!"
                    : "गुरुवार का व्रत भगवान विष्णु और बृहस्पति देव को समर्पित है. इस दिन व्रत रखने से मनोकामनाएं पूरी होती हैं और सद्भावना से पूजन करने वालों पर कृपा बरसती है. गुरुवार का दिन हिंदू धर्म में बहुत मायने रखता है. इस दिन विष्णु जी की पूजा-अर्चना की जाती है. गुरुवार यानि गुरु देव बृहस्पति का दिन. इस दिन विष्णु जी की व्रत रखने और पाठ करने से कष्टों से मुक्ति मिलती है. जो जातक गुरुवार के दिन व्रत रखकर भगवान विष्णु की पूजा करते हैं और इस व्रत कथा को पढ़ते हैं, उन्हें भगवान विष्णु की विशेष कृपा प्राप्त होती है. इस व्रत को करने से व्यक्ति के सारे कष्ट दूर होते हैं सुखों की प्राप्ति होती है!"),

                _buildSectionTitle(_isEnglish
                    ? "Method of Thursday Vrat:"
                    : "गुरुवार व्रत की विधि :"),
                // Section for Vishnu and Brihaspati Puja celebration instructions in English
                _buildBulletPoint(_isEnglish
                    ? "Get up in the morning, take a bath and take a vow to fast."
                    : "सुबह उठकर स्नान करें और व्रत का संकल्प लें."),
                _buildBulletPoint(_isEnglish
                    ? "Meditate on Lord Vishnu and Brihaspati Dev."
                    : "भगवान विष्णु और बृहस्पति देव का ध्यान करें."),
                _buildBulletPoint(_isEnglish
                    ? "Offer yellow clothes, flowers, fruits, sweets etc. to Lord Vishnu and Brihaspati Dev."
                    : "भगवान विष्णु और बृहस्पति देव को पीले वस्त्र, फूल, फल, मिठाई आदि चढ़ाएं."),
                _buildBulletPoint(_isEnglish
                    ? "Use bananas and banana leaves in the puja."
                    : "पूजा में केले और केले के पत्ते का इस्तेमाल करें."),
                _buildBulletPoint(_isEnglish
                    ? "Listen to the story after the puja."
                    : "पूजा के बाद कथा सुनें."),
                _buildBulletPoint(_isEnglish
                    ? "Do the aarti of Vishnu ji."
                    : "विष्णु जी की आरती करें."),
                _buildBulletPoint(_isEnglish
                    ? "Listen to the story in the evening."
                    : "शाम के समय कथा सुनें."),
                _buildBulletPoint(_isEnglish
                    ? "Eat yellow food without salt."
                    : "बिना नमक का पीला भोजन करें."),

                _buildSectionTitle(_isEnglish ? "Story:" : "कथा:"),
                _buildSectionContent(_isEnglish
                    ? "It is a story of ancient times. A big businessman lived in a city. He used to send goods to other countries by loading them in ships. He used to donate generously just as he earned a lot of money, but his wife was very miserly. She did not let anyone give even a penny. Once when the merchant went to another country for business, Brihaspatidev, disguised as a saint, asked for alms from his wife. The businessman's wife said to Brihaspatidev, 'O Sadhu Maharaj, I am fed up of this charity and good deeds. Please tell me a way by which all my wealth is destroyed and I can live peacefully. I cannot see this wealth being wasted.' "
                        "Brihaspatidev said, 'O Goddess, you are very strange, does anyone become unhappy with children and wealth? If you have a lot of wealth, then use it in auspicious works, get unmarried girls married, get schools and gardens constructed. By doing such pious deeds, your life in this world and the next can become meaningful.' But the businessman's wife was not happy with these words of the saint. "
                        "He said, 'I don't need such wealth that I can donate.' Then Brihaspatidev said, 'If you have such a desire then you should try one remedy. For seven Thursdays, smear the house with cow dung, wash your hair with yellow soil, take bath while washing hair, ask a merchant to shave you, eat meat and wine in your food, wash clothes at your home. By doing this, all your wealth will be destroyed.' Saying this, Brihaspatidev disappeared. "
                        "The merchant's wife decided to do the same for seven Thursdays as Brihaspatidev had said. Only three Thursdays had passed when all her wealth was destroyed and she died. When the merchant returned, he saw that everything of his had been destroyed. That merchant consoled his daughter and went and settled in another city. "
                        "There he would cut wood from the forest and sell it in the city. In this way he started living his life. One day his daughter expressed her desire to eat curd but the merchant did not have money to buy curd. He assured his daughter and went to the forest to cut wood. There, under a tree, he saw that the wood was burnt. Sitting down, he started crying thinking about his previous condition. That day was Thursday. "
                        "Then Brihaspatidev came to the merchant in the form of a saint and said, 'O man, why are you sitting in this forest worried?' Then the merchant said, 'O Maharaj, you know everything.' Saying this, the merchant started crying after telling his story. "
                        "Brihaspatidev said, 'Look son, your wife insulted Brihaspatidev, that is why you are in this condition, but now you do not worry about anything. You should recite Brihaspatidev's mantra on Thursday. Take two paise worth of gram and jaggery, add sugar in a pot of water and distribute that nectar and prasad among your family members and those who listen to the story. You also take prasad and charanamrit. God will definitely bless you.' "
                        "Hearing the saint's words, the businessman said, 'Maharaj. I do not even have enough money to buy curd for my daughter.' On this, the saint said, 'You go to the city to sell the wood, you will get four times the price of the wood, with which all your work will be accomplished.' "
                        "The woodcutter cut the wood and set out to sell it in the city. His wood was sold at a good price, from which he bought curd for his daughter and gram, jaggery for the Thursday's story, narrated the story and distributed the prasad and ate it himself. "
                        "From that day all his difficulties started going away, but on the next Thursday he forgot to narrate the story. The next day the king of that place organized a big yagya and a feast for the people of the whole city. As per the king's order the whole city went to the king's palace for the feast. But the merchant and his daughter reached a little late, so the king took both of them to the palace and fed them. "
                        "When both of them returned, the queen saw that her necklace hanging on the peg was missing. The queen suspected the merchant and his daughter that they both had stolen her necklace. By the king's order both of them were imprisoned in a cell. Both of them were very sad after being imprisoned. "
                        "There he remembered Brihaspati Devta. Brihaspati Devta appeared and made the merchant realize his mistake and advised him that on Thursdays you will get two paise at the prison door, with that you should buy gram and raisins and worship Brihaspati Devta properly. All your sorrows will be removed. On Thursday he got two paise at the prison door. "
                        "Outside on the road a woman was going. The merchant called her and asked her to bring jaggery and gram. On this the woman said, 'I am going to buy jewelry for my daughter-in-law, I don't have time.' Saying this she went away. "
                        "After a while another woman came from there, the merchant called her and said that O sister I have to do the Thursday story. You bring me jaggery and gram worth two paise. Hearing Brihaspatidev's name, the woman said, 'Brother, I will bring you jaggery and gram right now. My only son has died. I was going to get a shroud for him but I will first do your work, after that I will bring a shroud for my son.' "
                        "The woman brought jaggery and gram for the merchant from the market and also heard Brihaspatidev's story. After the story was over, the woman took the shroud and went to her home. At home, people were preparing to take her son's dead body to the crematorium, chanting 'Ram naam satya hai'. The woman said, 'Let me see my son's face.' "
                        "Seeing her son's face, the woman put prasad and charanamrit in his mouth. Due to the effect of prasad and charanamrit, he became alive again. The first woman who had disrespected Brihaspatidev, when she returned with jewelry for her daughter-in-law for her son's wedding, as soon as her son came out sitting on the mare, the mare jumped so high that he fell from the mare and died. "
                        "Seeing this, the woman started crying and begging forgiveness from Brihaspatidev. On the request of that woman, Brihaspati Dev reached there in the guise of a saint and said, 'Devi. You do not need to mourn too much. This has happened because of disrespecting Brihaspati Dev. Go back and apologize to my devotee and listen to the story, only then your wish will be fulfilled.' "
                        "Going to the jail, that woman apologized to the businessman and listened to the story. After the story, she went back to her home with Prasad and Charanamrit. Coming home, she put Charanamrit in the mouth of her dead son. Due to the effect of Charanamrit, her son also came back to life. "
                        "That very night Brihaspati Dev came in the dream of the king and said, 'O King. The businessman and his daughter whom you have imprisoned in the jail are absolutely innocent. Your queen's necklace is hanging on the same peg.' When the day broke, the king and queen saw the necklace hanging on the peg. The king released that businessman and his daughter and gave them half the kingdom and got his daughter married in a high family and gave diamonds and jewels in dowry."
                    : "प्राचीन समय की बात है। एक नगर में एक बड़ा व्यापारी रहता था। वह जहाजों में माल लदवाकर दूसरे देशों में भेजा करता था। वह जिस प्रकार अधिक धन कमाता था उसी प्रकार जी खोलकर दान भी करता था, परंतु उसकी पत्नी अत्यंत कंजूस थी। वह किसी को एक दमड़ी भी नहीं देने देती थी। एक बार सेठ जब दूसरे देश व्यापार करने गया तो पीछे से बृहस्पतिदेव ने साधु-वेश में उसकी पत्नी से भिक्षा मांगी। व्यापारी की पत्नी बृहस्पतिदेव से बोली हे साधु महाराज, मैं इस दान और पुण्य से तंग आ गई हूं। आप कोई ऐसा उपाय बताएं, जिससे मेरा सारा धन नष्ट हो जाए और मैं आराम से रह सकूं। मैं यह धन लुटता हुआ नहीं देख सकती। "
                        "बृहस्पतिदेव ने कहा, हे देवी, तुम बड़ी विचित्र हो, संतान और धन से कोई दुखी होता है। अगर अधिक धन है तो इसे शुभ कार्यों में लगाओ, कुंवारी कन्याओं का विवाह कराओ, विद्यालय और बाग-बगीचों का निर्माण कराओ। ऐसे पुण्य कार्य करने से तुम्हारा लोक-परलोक सार्थक हो सकता है, परन्तु साधु की इन बातों से व्यापारी की पत्नी को ख़ुशी नहीं हुई। उसने कहा- मुझे ऐसे धन की आवश्यकता नहीं है, जिसे मैं दान दूं। "
                        "तब बृहस्पतिदेव बोले यदि तुम्हारी ऐसी इच्छा है तो तुम एक उपाय करना। सात बृहस्पतिवार घर को गोबर से लीपना, अपने केशों को पीली मिटटी से धोना, केशों को धोते समय स्नान करना, व्यापारी से हजामत बनाने को कहना, भोजन में मांस-मदिरा खाना, कपड़े अपने घर धोना। ऐसा करने से तुम्हारा सारा धन नष्ट हो जाएगा। इतना कहकर बृहस्पतिदेव अंतर्ध्यान हो गए। "
                        "व्यापारी की पत्नी ने बृहस्पति देव के कहे अनुसार सात बृहस्पतिवार वैसा ही करने का निश्चय किया। केवल तीन बृहस्पतिवार बीते थे कि उसी समस्त धन-संपत्ति नष्ट हो गई और वह परलोक सिधार गई। जब व्यापारी वापस आया तो उसने देखा कि उसका सब कुछ नष्ट हो चुका है। उस व्यापारी ने अपनी पुत्री को सांत्वना दी और दूसरे नगर में जाकर बस गया। "
                        "वहां वह जंगल से लकड़ी काटकर लाता और शहर में बेचता। इस तरह वह अपना जीवन व्यतीत करने लगा।एक दिन उसकी पुत्री ने दही खाने की इच्छा प्रकट की लेकिन व्यापारी के पास दही खरीदने के पैसे नहीं थे। वह अपनी पुत्री को आश्वासन देकर जंगल में लकड़ी काटने चला गया। वहां एक वृक्ष के नीचे बैठ अपनी पूर्व दशा पर विचार कर रोने लगा। उस दिन बृहस्पतिवार था। "
                        "तभी वहां बृहस्पतिदेव साधु के रूप में सेठ के पास आए और बोले 'हे मनुष्य, तू इस जंगल में किस चिंता में बैठा है?' तब व्यापारी बोला 'हे महाराज, आप सब कुछ जानते हैं।' इतना कहकर व्यापारी अपनी कहानी सुनाकर रो पड़ा। "
                        "बृहस्पतिदेव बोले 'देखो बेटा, तुम्हारी पत्नी ने बृहस्पति देव का अपमान किया था इसी कारण तुम्हारा यह हाल हुआ है लेकिन अब तुम किसी प्रकार की चिंता मत करो। तुम गुरुवार के दिन बृहस्पतिदेव का पाठ करो। दो पैसे के चने और गुड़ को लेकर जल के लोटे में शक्कर डालकर वह अमृत और प्रसाद अपने परिवार के सदस्यों और कथा सुनने वालों में बांट दो। स्वयं भी प्रसाद और चरणामृत लो। भगवान तुम्हारा अवश्य कल्याण करेंगे।' "
                        "साधु की बात सुनकर व्यापारी बोला 'महाराज। मुझे तो इतना भी नहीं बचता कि मैं अपनी पुत्री को दही लाकर दे सकूं।' इस पर साधु जी बोले 'तुम लकड़ियां शहर में बेचने जाना, तुम्हें लकड़ियों के दाम पहले से चौगुने मिलेंगे, जिससे तुम्हारे सारे कार्य सिद्ध हो जाएंगे।' "
                        "लकड़हारे ने लकड़ियां काटीं और शहर में बेचने के लिए चल पड़ा। उसकी लकड़ियां अच्छे दाम में बिक गई जिससे उसने अपनी पुत्री के लिए दही लिया और गुरुवार की कथा हेतु चना, गुड़ लेकर कथा की और प्रसाद बांटकर स्वयं भी खाया। "
                        "उसी दिन से उसकी सभी कठिनाइयां दूर होने लगीं, परंतु अगले बृहस्पतिवार को वह कथा करना भूल गया। अगले दिन वहां के राजा ने एक बड़े यज्ञ का आयोजन कर पूरे नगर के लोगों के लिए भोज का आयोजन किया। राजा की आज्ञा अनुसार पूरा नगर राजा के महल में भोज करने गया। "
                        "लेकिन व्यापारी व उसकी पुत्री तनिक विलंब से पहुंचे, अत: उन दोनों को राजा ने महल में ले जाकर भोजन कराया। जब वे दोनों लौटकर आए तब रानी ने देखा कि उसका खूंटी पर टंगा हार गायब है। रानी को व्यापारी और उसकी पुत्री पर संदेह हुआ कि उसका हार उन दोनों ने ही चुराया है। राजा की आज्ञा से उन दोनों को कारावास की कोठरी में कैद कर दिया गया। "
                        "कैद में पड़कर दोनों अत्यंत दुखी हुए। वहां उन्होंने बृहस्पति देवता का स्मरण किया। बृहस्पति देव ने प्रकट होकर व्यापारी को उसकी भूल का आभास कराया और उन्हें सलाह दी कि गुरुवार के दिन कैदखाने के दरवाजे पर तुम्हें दो पैसे मिलेंगे उनसे तुम चने और मुनक्का मंगवाकर विधिपूर्वक बृहस्पति देवता का पूजन करना। तुम्हारे सब दुख दूर हो जाएंगे। "
                        "बृहस्पतिवार को कैदखाने के द्वार पर उन्हें दो पैसे मिले। बाहर सड़क पर एक स्त्री जा रही थी। व्यापारी ने उसे बुलाकर गुड़ और चने लाने को कहा। इसपर वह स्त्री बोली 'मैं अपनी बहू के लिए गहने लेने जा रही हूं, मेरे पास समय नहीं है।' इतना कहकर वह चली गई। "
                        "थोड़ी देर बाद वहां से एक और स्त्री निकली, व्यापारी ने उसे बुलाकर कहा कि हे बहन मुझे बृहस्पतिवार की कथा करनी है। तुम मुझे दो पैसे का गुड़-चना ला दो। बृहस्पतिदेव का नाम सुनकर वह स्त्री बोली 'भाई, मैं तुम्हें अभी गुड़-चना लाकर देती हूं। मेरा इकलौता पुत्र मर गया है, मैं उसके लिए कफन लेने जा रही थी लेकिन मैं पहले तुम्हारा काम करूंगी, उसके बाद अपने पुत्र के लिए कफन लाऊंगी।' "
                        "वह स्त्री बाजार से व्यापारी के लिए गुड़-चना ले आई और स्वयं भी बृहस्पतिदेव की कथा सुनी। कथा के समाप्त होने पर वह स्त्री कफन लेकर अपने घर गई। घर पर लोग उसके पुत्र की लाश को 'राम नाम सत्य है' कहते हुए श्मशान ले जाने की तैयारी कर रहे थे। "
                        "स्त्री बोली 'मुझे अपने लड़के का मुख देख लेने दो।' अपने पुत्र का मुख देखकर उस स्त्री ने उसके मुंह में प्रसाद और चरणामृत डाला। प्रसाद और चरणामृत के प्रभाव से वह पुन: जीवित हो गया। "
                        "पहली स्त्री जिसने बृहस्पतिदेव का निरादर किया था, वह जब अपने पुत्र के विवाह हेतु पुत्रवधू के लिए गहने लेकर लौटी और जैसे ही उसका पुत्र घोड़ी पर बैठकर निकला वैसे ही घोड़ी ने ऐसी उछाल मारी कि वह घोड़ी से गिरकर मर गया। "
                        "यह देख स्त्री रो-रोकर बृहस्पति देव से क्षमा याचना करने लगी। उस स्त्री की याचना से बृहस्पतिदेव साधु वेश में वहां पहुंचकर कहने लगे 'देवी। तुम्हें अधिक विलाप करने की आवश्यकता नहीं है। यह बृहस्पतिदेव का अनादार करने के कारण हुआ है। तुम वापस जाकर मेरे भक्त से क्षमा मांगकर कथा सुनो, तब ही तुम्हारी मनोकामना पूर्ण होगी।' "
                        "जेल में जाकर उस स्त्री ने व्यापारी से माफी मांगी और कथा सुनी। कथा के उपरांत वह प्रसाद और चरणामृत लेकर अपने घर वापस गई। घर आकर उसने चरणामृत अपने मृत पुत्र के मुख में डाला। चरणामृत के प्रभाव से उसका पुत्र भी जीवित हो उठा। "
                        "उसी रात बृहस्पतिदेव राजा के सपने में आए और बोले 'हे राजन। तूने जिस व्यापारी और उसके पुत्री को जेल में कैद कर रखा है वह बिलकुल निर्दोष हैं। तुम्हारी रानी का हार वहीं खूंटी पर टंगा है।' "
                        "दिन निकला तो राजा रानी ने हार खूंटी पर लटका हुआ देखा। राजा ने उस व्यापारी और उसकी पुत्री को रिहा कर दिया और उन्हें आधा राज्य देकर उसकी पुत्री का विवाह उच्च कुल में करवाकर दहेज़ में हीरे-जवाहरात दिए।"),
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
