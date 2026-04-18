import 'dart:async';
import 'package:flutter/material.dart';

import '../../controller/share_helper.dart';

class KarwaChauth extends StatefulWidget {
  const KarwaChauth({super.key});

  @override
  State<KarwaChauth> createState() => _KarwaChauthState();
}

class _KarwaChauthState extends State<KarwaChauth> {
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
        ShareHelper.shareContent(context, "करवा चौथ व्रत कथा");
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
          _isEnglish ? "Karva Chouth" : 'करवा चौथ व्रत',
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
      backgroundColor: _isBlackBackground ? Colors.black : Colors.white,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isBlackBackground
                      ? [Colors.black, Colors.grey[850]!]
                      : [_themeColor.withOpacity(0.5), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 260,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                        //borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                            image: AssetImage("assets/image/karva_chouth.jpg"),
                            fit: BoxFit.fill)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 1),
                        // Add your content here...
                        _buildSectionTitle(_isEnglish
                            ? "Story of Karva Chauth:"
                            : "करवा चौथ की कहानी:"),
                        _buildSectionContent(_isEnglish
                            ? "Karva Chauth festival is celebrated on the moonrise Vyapini Chaturthi (Karak Chaturthi[1]) of Krishna Paksha of Kartik month. On this festival, married women fast for the longevity, health and good fortune of their husbands and wait for the moonrise. After the moonrise, they offer arghya to the moon and then eat.\n\n"
                                "The fast of Karva Chauth is related to Karva Mata and Ganesha. Ganesha is worshipped on Ganesh Chaturthi of the year and the Chaturthi of Kartik month is longer, so Karva Chauth fast is observed on this day. Therefore, the story of Karva Mata and Ganesha is read on this day. There is a rule of listening to the story in this fast. Everyone listens to the fast story according to their own tradition. This fast is incomplete without listening to the story.\n\n"
                            : "करवा चौथ त्योहार, कार्तिक मास के कृष्ण पक्ष की चन्द्रोदय व्यापिनी चतुर्थी (करक चतुर्थी) को मनाया जाता है। इस पर्व पर विवाहित स्त्रियाँ पति की दीर्घायु, स्वास्थ्य एवं अपने सौभाग्य हेतु निराहार रहकर चन्द्रोदय की प्रतीक्षा करती हैं और उदय उपरांत चंद्रमा को अर्घ्य अर्पित कर भोजन करती हैं।\n\n"
                                "करवा चौथ के व्रत का संबंध करवा माता और गणेश जी से है। साल की गणेश चतुर्थी को गणेश जी पूजन किया जाता है और कार्तिक मास की चतुर्थी बड़ी होती है, इसलिए इस दिन करवा चौथ का व्रत होता है। इसलिए इस दिन करवा माता और गणेश जी की कहानी पढ़ी जाती है। इस व्रत में कथा सुनने का विधान है। सभी लोग अपने-अपनी-अपनी परंपरा के अनुसार व्रत कथा सुनते हैं। यह व्रत कथा सुनने के बिना अधूरा है।\n\n"),

                        _buildSectionTitle(_isEnglish ? "Method:" : "विधि:"),
                        _buildSectionContent(_isEnglish
                            ? "Shiva-Parvati, Swami Kartikeya, Ganesha and Moon are established on a sand or white clay altar. In the absence of an idol, a string is tied to a betel nut and it is installed by imagining the deity. After this, the gods are worshipped as per one's capacity."
                            : "बालू अथवा सफेद मिट्टी की वेदी पर शिव-पार्वती, स्वामी कार्तिकेय, गणेश एवं चंद्रमा की स्थापना की जाती है। मूर्ति के अभाव में सुपारी पर नाड़ा बाँधकर देवता की भावना करके स्थापित किया जाता है। पश्चात यथाशक्ति देवों का पूजन किया जाता है।"),

                        _buildSectionTitle(_isEnglish ? "Arghya:" : "अर्ध्य:"),
                        _buildSectionContent(_isEnglish
                            ? "When the moon rises in the evening, the moon is worshipped and Arghya is offered. After this, food is served to Brahmins, married women and the husband's parents. After this, the husband and other family members eat."
                            : "बालू अथवा सफेद मिट्टी की वेदी पर शिव-पार्वती, स्वामी कार्तिकेय, गणेश एवं चंद्रमा की स्थापना की जाती है। मूर्ति के अभाव में सुपारी पर नाड़ा बाँधकर देवता की भावना करके स्थापित किया जाता है। पश्चात यथाशक्ति देवों का पूजन किया जाता है।"),

                        _buildSectionTitle(_isEnglish
                            ? "Materials for Karwa Chauth Puja:"
                            : "करवा चौथ की पूजा के लिए सामग्री:"),

                        // Bilingual Bullet Points for Materials Required
                        _buildBulletPoint(_isEnglish
                            ? "Clay or copper pot and its lid"
                            : "मिट्टी या तांबे का करवा और उसका ढक्कन"),
                        _buildBulletPoint(
                            _isEnglish ? "Betel leaf" : "पान का पत्ता"),
                        _buildBulletPoint(_isEnglish ? "Kalash" : "कलश"),
                        _buildBulletPoint(_isEnglish
                            ? "Whole rice grains"
                            : "साबुत चावल के दाने"),
                        _buildBulletPoint(
                            _isEnglish ? "Clay lamp" : "मिट्टी का दीपक"),
                        _buildBulletPoint(_isEnglish ? "Fruits" : "फल"),
                        _buildBulletPoint(_isEnglish ? "Flowers" : "फूल"),
                        _buildBulletPoint(_isEnglish ? "Turmeric" : "हल्दी"),
                        _buildBulletPoint(_isEnglish ? "Desi ghee" : "देसी घी"),
                        _buildBulletPoint(
                            _isEnglish ? "Raw milk" : "कच्चा दूध"),
                        _buildBulletPoint(_isEnglish ? "Honey" : "शहद"),
                        _buildBulletPoint(_isEnglish ? "Sugar" : "चीनी"),
                        _buildBulletPoint(_isEnglish ? "Roli" : "रोली"),
                        _buildBulletPoint(_isEnglish ? "Mauli" : "मौली"),
                        _buildBulletPoint(_isEnglish ? "Sweets" : "मिठाई"),
                        _buildBulletPoint(_isEnglish ? "Sieve" : "छलनी"),
                        _buildBulletPoint(_isEnglish ? "Coconut" : "नारियल"),
                        _buildBulletPoint(_isEnglish
                            ? "Book of Karwa Katha"
                            : "करवा कथा की पुस्तक"),
                        _buildBulletPoint(
                            _isEnglish ? "Makeup items" : "श्रृंगार का सामान"),
                        _buildBulletPoint(
                            _isEnglish ? "Water pot" : "जल का लोटा"),

                        const SizedBox(height: 10),

                        // Start of Hartalika Teej Vrat Katha Section
                        _buildSectionTitle(
                            _isEnglish ? "Method of Puja:" : "पूजन विधि:"),
                        _buildSectionContent(_isEnglish
                            ? "On the night of Chandra Uday Vyapini Chaturthi of Kartik Krishna Paksha, that is, on the Chaturthi in which the moon is visible, after taking a bath in the morning, wearing beautiful clothes, applying mehendi on hands, women fast till moonrise and worship Lord Shiva-Parvati, Kartikeya, Ganesha and Chandradev for the long life, health and good fortune of their husbands. All the above mentioned gods are installed on it by making an altar of sand or white clay."
                            : "जकार्तिक कृष्ण पक्ष की चंद्रोदय व्यापिनी चतुर्थी अर्थात उस चतुर्थी की रात्रि को जिसमें चंद्रमा दिखाई देने वाला है, उस दिन प्रातः स्नान उपरांत सुंदर वस्त्र धारण कर, हाथों में मेंहंदी लगा, अपने पति की लंबी आयु, आरोग्य व सौभाग्य के लिए स्त्रीयाँ चंद्रोदय तक निराहार रहकर भगवान शिव-पार्वती, कार्तिकेय, गणेश एवं चंद्रदेव का पूजन करती हैं। पूजन करने के लिए बालू अथवा सफेद मिट्टी की वेदी बनाकर उपरोक्त सभी देवों को स्थापित किया जाता है।"),

                        Center(
                            child: _buildSectionTitle(
                                _isEnglish ? " (Story)" : " (कथा)")),
                        _buildSectionTitle(_isEnglish
                            ? "The story of the washerwoman of Karva Chauth:"
                            : "करवा चौथ की धोबिन वाली कहानी:"),

                        _buildSectionContent(_isEnglish
                            ? "A devoted washerwoman named Karva lived with her husband on the banks of the Tungabhadra river. One day, when her husband was washing clothes, a crocodile caught him in its teeth and started taking him to Yamlok. Hearing her husband's call, Karva reached there and tied the crocodile with a raw thread and took it to Yamraj. Karva requested Yamraj to protect her husband and said that if she did not help save her husband, he would curse her. Fearing Karva's courage, Yamraj sent the crocodile to Yamlok and blessed her husband with a long life. It is believed that since then, Karva Chauth fast is observed on Kartik Krishna Chaturthi. In the fast of Karva Chauth, married women pray to Karva Mata that just as she had brought her husband back from the jaws of death, she should also protect their husbands!"
                            : "करवा नाम की एक पतिव्रता धोबिन अपने पति के साथ तुंगभद्रा नदी के किनारे रहती थी। एक दिन जब पति कपड़े धो रहे थे, तब एक मगरमच्छ ने उन्हें अपने दांतों में दबाकर यमलोक ले जाने लगा। पति की पुकार सुनकर करवा वहां पहुंचीं और मगर को कच्चे धागे से बांधकर यमराज के पास ले गईं। करवा ने यमराज से अपने पति की रक्षा करने की गुजारिश की और कहा कि अगर उन्होंने अपने पति को बचाने में मदद नहीं की, तो वह उन्हें श्राप देंगे। करवा के साहस से डरकर यमराज ने मगर को यमलोक भेज दिया और पति को दीर्घायु होने का वरदान दिया। मान्यता है कि तब से कार्तिक कृष्ण की चतुर्थी को करवा चौथ का व्रत रखा जाने लगा। करवा चौथ के व्रत में सुहागिन महिलाएं करवा माता से प्रार्थना करती हैं कि जैसे उन्होंने अपने पति को मृत्यु के मुंह से वापस निकाला था, वैसे ही उनके सुहाग की भी रक्षा करें!"),

                        _buildSectionTitle(_isEnglish
                            ? "The story of the moneylender's seven sons and seven daughters:"
                            : "साहूकार के सात बेटों और सात बेटियों वाली कथा:"),
                        _buildSectionContent(_isEnglish
                            ? "A moneylender had seven sons and a daughter. The sons of the moneylender loved their sister very much. The moneylender's wife, her daughters-in-law and daughter had kept the fast of Chauth. The fast is broken only after seeing the moon. At night, when the sons of the moneylender started eating, they asked their sister for food. On this, the sister told that she was fasting today and she could break the fast and eat something only after offering arghya to the moon. The youngest brother could not see his sister's condition and he lit a lamp on a tree far away and kept it under a sieve. He shows it to his sister from a distance, the lamp kept under the sieve looks like the moon. In this way, it looks as if it is the moon of Chaturthi. The sister also told her sister-in-law that the moon hascome out and they should break the fast, but the sisters-in-law did not listen to her and did not break the fast.The sister did not understand the cleverness of her brothers and after seeing her, she offered arghya to Karva and ate the morsel of food. As soon as she puts the first piece in her mouth, she sneezes. When she puts the second piece in her mouth, a hair comes out and when she puts the third piece in her mouth, she gets the news of her husband's death. She becomes very sad. Her sister-in-law tells her the truth about why this happened to her. Due to breaking the fast in the wrong way, the Goddess is angry with her. On this, she decides that she will not perform the last rites of her husband and will bring him back to life with her chastity. In grief, she sat with her husband's dead body for a year and kept collecting the grass growing on it. She fasted on Chaturthi of the whole year and when Kartik Krishna Chaturthi came again the next year, she observed Karva Chauth fast with full rituals, in the evening she requests the married women to take Yam's needle, give Piya's needle, make me a married woman like you, as a result of which, with the blessings of Karva Mata and Ganesh ji, her husband came back to life. Just as Ganpati and Karva Mata listened to her, everyone should listen to them, may everyone's marital life be immortal."
                            : "एक साहूकार के सात लड़के और एक लड़की थी। साहूकार के बेटे अपनी बहन से बहुत प्यार करते थे साहूकारनी के साथ उसकी बहुओं और बेटी ने चौथ का व्रत रखा था। चौथ का व्रत में चांद देखकर ही व्रत खोलते है। रात को जब साहूकार के लड़के भोजन करने लगे तो उन्होंने अपनी बहन से भोजन के लिए कहा। इस पर बहन ने बताया कि उसका आज उसका व्रत है और वह खाना चंद्रमा को अर्घ्य देकर ही व्रत खोल सकती है और कुछ खा सकती है। सबसे छोटे भाई को अपनी बहन की हालत देखी नहीं गई और वह दूर पेड़ पर एक दीपक जलाकर चलनी की ओट में रख देता है। दूर से बहन को दिखाता है, छलनी की ओट में रखा दीपक चांद की तरह लगता है। ऐसे में वो ऐसा लगता है जैसे चतुर्थी का चांद हो। बहन ने अपनी भाभी से भी कहा कि चंद्रमा निकल आया है व्रत खोल लें, लेकिन भाभियों ने उसकी बात नहीं मानी और व्रत नहीं खोला।बहन को अपने भाईयों की चतुराई समझ में नहीं आई और उसे देख कर करवा उसे अर्घ्य देकर खाने का निवाला खा लिया। जैसे ही वह पहला टुकड़ा मुंह में डालती है उसे छींक आ जाती है। दूसरा टुकड़ा डालती है तो उसमें बाल निकल आता है और तीसरा टुकड़ा मुंह में डालती है तभी उसके पति की मृत्यु का समाचार उसे मिलता है। वह बेहद दुखी हो जाती है। उसकी भाभी सच्चाई बताती है कि उसके साथ ऐसा क्यों हुआ। व्रत गलत तरीके से टूटने के कारण माता उससे नाराज हो गए हैं। इस पर वह निश्चय करती है कि वह अपने पति का अंतिम संस्कार नहीं करेगी और अपने सतीत्व से उन्हें पुनर्जीवन दिलाकर रहेगी। शोकातुर होकर वह अपने पति के शव को लेकर एक वर्ष तक बैठी रही और उसके ऊपर उगने वाली घास को इकट्ठा करती रही। उसने पूरे साल की चतुर्थी को व्रत किया और अगले साल कार्तिक कृष्ण चतुर्थी फिर से आने पर उसने पूरे विधि-विधान से करवा चौथ व्रत किया, शाम को सुहागिनों से अनुरोध करती है कि यम सूई ले लो, पिय सूई दे दो, मुझे भी अपनी जैसी सुहागिन बना दो जिसके फलस्वरूप करवा माता और गणेश जी के आशीर्वाद से उसका पति पुनः जीवित हो गया। जैसे गणपति और करवा माता ने उसकी सुनी, वैसे सभी की सुनें, सभी का सुहाग अमर हो।"),

                        _buildSectionTitle(_isEnglish
                            ? "Ganesh Ji's story of blind old lady:"
                            : "गणेश जी की अंधी बुढिया माई वाली कहानी:"),
                        _buildSectionContent(_isEnglish
                            ? "There was a blind old lady who had a son and daughter-in-law. She was very poor. That blind old lady used to worship Ganesh Ji and observe fast on Chauth every day. Pleased with the worship of the lady, one day Lord Ganesh Ji appeared before her and said that old lady, you worship me selflessly every day, ask for whatever you want. The old lady said, O Lord Ganesh Ji, the destroyer of obstacles, I don't know how to ask, so what should I ask for. Then Lord Ganesh Ji said, mother, I will come tomorrow, you ask your son and daughter-in-law and then ask. Then the old lady asked her son and daughter-in-law, the son said, mother ask for money and the daughter-in-law said, mother ask for a grandson. The old lady thought that the son and daughter-in-law are talking for their own benefit.\n\n"
                                "So the old lady asked her neighbor. The neighbor said that old lady, you have only a little life left. Why should you ask for money and why should you ask for a grandson? You should just ask for your eyes, so that you can spend your life happily. After listening to the talk of her son, daughter-in-law and neighbor, the old lady went inside the house and thought that she should ask for something that will make her son and daughter-in-law happy and will also do good to her.\n\n"
                                "The next day Lord Ganesh came and said, old lady, ask for it. On hearing the words of Lord Ganesh, the old lady said, O Vighnaharta, give me food, give me wealth, give me a healthy body, give me eternal happiness, give me eyes, I want to see my grandson drinking milk in a golden bowl, give me eternal happiness and give happiness to the whole family. Give me a place in your lotus feet. On hearing the words of the old lady, Ganesh said, old lady, you have cheated me. And she says that you don't know how to ask, whatever you have asked for, you will get it. Saying this, Lord Ganesh disappeared. O Lord Ganesh, give to everyone the same as you gave to the old lady, give to everyone in the same way and keep your blessings on everyone.\n\n"
                            : "एक अंधी बुढ़िया थी, जिसका एक लड़का और बहू थी। वह बहुत गरीब थी। वह अंधी बुढ़िया माई नित्यप्रतिदिन गणेशजी की पूजा और चौथ का व्रत करती थी। माई की पूजा से प्रसन्न होकर एक दिन गणेशजी भगवान ने उसे दर्शन दिए और बोले कि बुढ़िया माई तू रोज निस्वार्थ भाव से मेरी पूजा करती हैं जो चाहे सो मांग ले। बुढ़ियामाई बोली हे विध्नहर्ता गणेश जी भगवान मुझे तो मांगना नहीं आता सो क्या मांगू। तब गणेशजी भगवान बोले कि माई मैं कल आऊंगा तू अपने बहू-बेटे से पूछ कर मांग ले। तब बुढ़िया ने अपने बेटे बहू से पूछा तो बेटा बोला कि मां धन मांग ले और बहू ने कहा कि मां पोता मांग लो। बुढ़िया ने सोचा कि बेटा-बहू तो अपने-अपने मतलब की बातें कर रहे हैं।\n\n"
                                "अतः उस बुढ़िया ने पड़ोसिन से पूछा तो पड़ोसिन ने कहा कि बुढ़िया माई तेरी थोड़ी-सी जिंदगी बची है।तू क्यों तो मांगे धन औरक्यों मांगे पोता, तू तो केवल अपने आंखे मांग ले, जिससे तेरा जीवन सुख से व्यतीत हो जाए। उस बुढ़ियामाई ने बेटे, बहू तथा पड़ोसिन की बात सुनकर घर में जाकर सोचा, जिससे बेटा-बहू भी खुश हो जाए और मेरा भी भला हो वह भी मांग लूं ।\n\n"
                                "जब दूसरे दिन गणेशजी भगवान आए और बोले, बुढ़िया माई मांग ले |गणेशजी भगवान के वचन सुनकर बुढ़ियामाई बोली हे विघ्नहर्ता , अन्न देवो , धन देवो , निरोगी काया देवों , अमर सुहाग देंवो , दीदा गोढा देवो , सोने के कटोरे में पोते को दूध पीता देखू , अमर सुहाग देवो और समस्त परिवार को सुख देंवो आपके श्री चरणों में मुझे स्थान देवो बुढ़िया की बात सुनकर गणेशजी बोले- बुढ़िया मां तूने तो मुझे ठग लिया। और कहती हैं की मांगना नहीं आता , जो कुछ तूने मांग लिया वह सभी तुझे मिलेगा। यूं कहकर गणेशजी भगवान अंतर्ध्यान हो गए। हे गणेशजी भगवान जैसा बुढ़िया माई को दिया वैसा सबको देना , वैसे ही सबको देना और सभी पर अपनी कृपा बनाये रखना।"),

                        _buildSectionTitle(_isEnglish
                            ? "Shree Karwa Mata ki Aarti"
                            : "करवाचौथ माता की आरती"),

                        _buildSectionContent(_isEnglish
                            ? "OM Jai Karwa Maiyya,\n"
                                "Mata Jai Karwa Maiyya\n"
                                "Jo Vrat Kare Tumhara, Paar Kero Naiyya,\n"
                                "OM Jai Karwa Maiyya\n"
                                "Sab Jag Ki Ho Mata, Tum Ho Rudrani,\n"
                                "Yash Tumhara Gavat, Jag Ke Sab Praani,\n"
                                "OM Jai Karwa Maiyya\n"
                                "Kartik Krishna Chaturthi, Jo Nari Vrat Kerti,\n"
                                "Deerghayu Pati Hove, Dukh Sare Harti,\n"
                                "OM Jai Karwa Maiyya\n"
                                "Hoye Suhagan Nari, Sukh Sampati Paave,\n"
                                "Ganpati Ji Bade Dayalu, Vighna Sabhi Naashe,\n"
                                "OM Jai Karwa Maiyya\n"
                                "Karwa Maiyya Ki Aarti, Vrat Ker Jo Gaave,\n"
                                "Vrat Ho Jata Puran, Sab Vidhi Sukh Paave,\n"
                                "OM Jai Karwa Maiyya"
                            : "ओम जय करवा मैया,\n"
                                "माता जय करवा मैया.\n"
                                "जो व्रत करे तुम्हारा, पार करो नइया..\n"
                                "ओम जय करवा मैया.\n"
                                "सब जग की हो माता, तुम हो रुद्राणी.\n"
                                "यश तुम्हारा गावत, जग के सब प्राणी..\n"
                                "कार्तिक कृष्ण चतुर्थी, जो नारी व्रत करती.\n"
                                "दीर्घायु पति होवे, दुख सारे हरती..\n"
                                "ओम जय करवा मैया.\n"
                                "होए सुहागिन नारी, सुख संपत्ति पावे.\n"
                                "गणपति जी बड़े दयालु, विघ्न सभी नाशे..\n"
                                "ओम जय करवा मैया.\n"
                                "करवा मैया की आरती, व्रत कर जो गावे.\n"
                                "व्रत हो जाता पूरन, सब विधि सुख पावे..\n"
                                "ओम जय करवा मैया."),

                        _buildSectionTitle(_isEnglish
                            ? "Shree Ganesh ji ki Aarti :"
                            : "श्री गणेश जी की आरती"),

                        _buildSectionContent(_isEnglish
                            ? "Jai Ganesh Jai Ganesh, Jai Ganesh Deva\n"
                                "Mata Jaki Parvati Pita Mahadeva\n"
                                "Jai Ganesh Jai Ganesh, Jai Ganesh Deva\n"
                                "Mata Jaki Parvati Pita Mahadeva\n"
                                "Ek Dant Daya Want\n"
                                "Char Bhuja Dhari\n"
                                "Mastak Sindoor Shoye\n"
                                "Muse Ki Sawari\n"
                                "Paan Chadhe Phool Chadhe\n"
                                "Aur Chadhe Mewa\n"
                                "Laduvan Ka Bhog Lage\n"
                                "Sant Kare Seva\n"
                                "Jai Ganesh Jai Ganesh, Jai Ganesh Deva\n"
                                "Mata Jaki Parvati Pita Mahadeva\n"
                                "Andhan Ko aankh Dett kodhin ko kaya\n"
                                "Banjhan ko Garbh dett nirdhan ko maya\n"
                                "Surshyaam sharan aaye safal kije Seva\n"
                                "Mata Jaki Parvati Pita Mahadeva\n"
                                "Jai Ganesh Jai Ganesh, Jai Ganesh Deva\n"
                                "Mata Jaki Parvati Pita Mahadeva"
                            : "जय गणेश जय गणेश, जय गणेश देवा।\n"
                                "माता जाकी पार्वती, पिता महादेवा॥\n"
                                "एक दंत दयावंत, चार भुजा धारी।\n"
                                "माथे सिंदूर सोहे, मूसे की सवारी॥\n"
                                "जय गणेश जय गणेश, जय गणेश देवा।\n"
                                "माता जाकी पार्वती, पिता महादेवा॥\n"
                                "पान चढ़े फल चढ़े, और चढ़े मेवा।\n"
                                "लड्डुअन का भोग लगे, संत करें सेवा॥\n"
                                "जय गणेश जय गणेश, जय गणेश देवा।\n"
                                "माता जाकी पार्वती, पिता महादेवा॥\n"
                                "अंधन को आंख देत, कोढ़िन को काया।\n"
                                "बांझन को पुत्र देत, निर्धन को माया॥\n"
                                "जय गणेश जय गणेश, जय गणेश देवा।\n"
                                "माता जाकी पार्वती, पिता महादेवा॥\n"
                                "‘सूर’ श्याम शरण आए, सफल कीजे सेवा।\n"
                                "माता जाकी पार्वती, पिता महादेवा॥\n"
                                "जय गणेश जय गणेश, जय गणेश देवा।\n"
                                "माता जाकी पार्वती, पिता महादेवा॥\n"
                                "दीनन की लाज रखो, शंभु सुतकारी।\n"
                                "कामना को पूर्ण करो, जाऊं बलिहारी॥\n"
                                "जय गणेश जय गणेश, जय गणेश देवा।\n"
                                "माता जाकी पार्वती, पिता महादेवा॥"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
            width: double.maxFinite, // Make the dialog width flexible
            child: GridView.count(
              crossAxisCount: 3, // Number of columns in the grid
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
                    color: _isBlackBackground ? Colors.white : _themeColor),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
