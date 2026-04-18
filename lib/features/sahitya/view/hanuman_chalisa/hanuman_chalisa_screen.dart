import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/sahitya/view/hanuman_chalisa/chalisa_player.dart';
import 'package:mahakal/features/sahitya/view/hanuman_chalisa/list_chalisa_player.dart';
import 'package:mahakal/features/sahitya/view/hanuman_chalisa/share_chalisa.dart';
import 'package:mahakal/features/sangeet/controller/audio_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';

import '../../../donation/ui_helper/custom_colors.dart';
import '../../model/hanuman_chalisa_model.dart';
import 'chalisa_musiclist_model.dart';

class HanumanChalisaScreen extends StatefulWidget {
  const HanumanChalisaScreen({super.key});

  @override
  State<HanumanChalisaScreen> createState() => _HanumanChalisaScreenState();
}

class _HanumanChalisaScreenState extends State<HanumanChalisaScreen> {
  late ChalisaPlayer chalisaPlayer = ChalisaPlayer();

  int _currentIndex = 0;
  bool showMusicBar = false;
  bool _isBlackBackground = false;
  bool isTransLate = true;
  bool isShuffle = false;
  bool isBookFormate = false;
  double _textScaleFactor = 1.0;
  final double _scaleIncrement = 0.1;
  bool _isAutoScrolling = false;
  double _scrollSpeed = 2.0;
  late Timer _scrollTimer;
  final ScrollController _scrollController = ScrollController();

  //ChalisaPlayer _chalisaPlayer = ChalisaPlayer();

  @override
  void initState() {
    chalisaPlayer.stopChalisaAudio();
    super.initState();
  }

  void showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Icon or Image
              const Icon(
                Icons.temple_hindu,
                color: Colors.orange,
                size: 50.0,
              ),
              const SizedBox(height: 20.0),
              // Main Message
              const Text(
                "Coming Soon",
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10.0),
              // Description (Optional)
              Text(
                "Stay tuned! We're working on something divine for you.",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20.0),
              // Close Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Close",
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showShuffleOptionsDialog(
      BuildContext context, ChalisaPlayer chalisaPlayer) {
    showDialog(
      context: context,
      builder: (context) {
        return ShuffleOptionsDialog(
          chalisaPlayer: chalisaPlayer,
        );
      },
    );
  }

  // Method to share content
  void _shareContent() {
    // String contentToShare = widget.musicLyrics?? '';
    // Share.share(contentToShare, subject: 'Check out this blog!');
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
        _shareContent();
      } else if (index == 4) {
        isBookFormate = !isBookFormate;
      } else if (index == 5) {
        _toggleAutoScroll();
      }
    });
  }

  List<HanumanChalisaModel> hunumanChalisa = [
    // audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa01.mp3",
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa01.mp3",
        enChoupai:
            "Shri guru charan saroj raj neej manu mukur sudhari । \nBaranu raghubar bimal jasu jo dayaku phal chari ॥ \n Buddhi heen tanu janike sumero pavan kumar । \nBal buddhi bidya deu mohi harau kales bikar ॥",
        hiChoupai:
            "श्रीगुरु चरन सरोज रज, निज मनु मुकुरु सुधारि ।\n बरनउँ रघुबर बिमल जसु, जो दायकु फल चारि ॥\n बुद्धिहीन तनु जानिके, सुमिरौं पवनकुमार ।\nबल बुधि बिद्या देहु मोहिं, हरहु कलेस बिकार ॥",
        meaning:
            " मेरे श्रीगुरुदेव के चरण कमलों की धूल से अपने मन के दर्पण को स्वच्छ करते हुए, मैं प्रभु श्री राम के निर्मल यश का वर्णन करता हूँ, जो चार प्रकार के फल – धर्म, अर्थ, काम व मोक्ष को प्रदान करने वाले हैं। हे पवनकुमार! मैं अपने आप को शरीर और बुद्धि से कमजोर जान कर आपका स्मरण करता हूँ। आप मुझे शारीरिक बल, सद्बुद्धि एवं ज्ञान देकर मेरे दुःखों व दोषों का नाश कीजिए।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa02.mp3",
        enChoupai: "Jai Hanuman gyan gun sagar । \nJai kapis tihu lok ujagar ॥",
        hiChoupai: "जय हनुमान ज्ञान गुन सागर ।\nजय कपीस तिहुँ लोक उजागर ॥ १ ॥",
        meaning:
            "हे ज्ञान व गुणों के सागर श्री हनुमान जी, आपकी जय हो। हे कपीश्वर (वानरों के ईश्वर), आपकी जय हो! तीनों लोकों में आपकी कीर्ति है।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa03.mp3",
        enChoupai:
            "Ram doot atulit bal dhama । \nAnjaani-putra pavan sut nama ॥",
        hiChoupai: "रामदूत अतुलित बल धामा ।\nअंजनिपुत्र पवनसुत नामा ॥ २ ॥",
        meaning:
            "आप अतुलनीय शक्ति के धाम और भगवान श्री राम जी के दूत हैं। आप माता अंजनी के पुत्र व पवनपुत्र के नाम से जाने जाते हैं।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa04.mp3",
        enChoupai: "Mahabir bikram Bajrangi । \nKumati nivar sumati ke sangi ॥",
        hiChoupai: "महाबीर बिक्रम बजरंगी ।\nकुमति निवार सुमति के संगी ॥ ३ ॥",
        meaning:
            "हे महावीर बजरंग बलि, आप अनन्त पराक्रमी हैं। आप दुष्ट बुद्धि को दूर करते हैं तथा सुमति (उत्तम बुद्धि) वालों के मित्र हैं।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa05.mp3",
        enChoupai: "Kanchan baran biraj subesa । \nKanan kundal kunchit kesa ॥",
        hiChoupai: "कंचन बरन बिराज सुबेसा ।\nकानन कुंडल कुंचित केसा ॥ ४ ॥",
        meaning:
            "आपकी त्वचा सुनहरे रंग की है और आप सुन्दर वस्त्रों से सुसज्जित हैं। आपके कानों में कुण्डल व आपके घुंघराले बाल आपकी शोभा को बढ़ा रहे हैं।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa06.mp3",
        enChoupai: "Hath bajra aur dhvaja biraje । \nKaandhe munj janeu saje ॥",
        hiChoupai: "हाथ बज्र औ ध्वजा बिराजै ।\n काँधे मूँज जनेऊ साजै ॥ ५ ॥",
        meaning:
            "आपके हाथों में गदा और ध्वज है। आपके कंधे पर मूँज का जनेऊ शोभायमान है।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa07.mp3",
        enChoupai:
            "Sankar suvan Kesari nandan । \nTej pratap maha jag bandan ॥",
        hiChoupai: "संकर सुवन केसरीनंदन ।\nतेज प्रताप महा जग बंदन ॥ ६ ॥",
        meaning:
            "हे भगवान शिव के अवतार, राजा केसरी के पुत्र! पूरा ब्रह्मांड आपके पराक्रम, आपकी महिमा और वैभव की वंदना करता है।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa08.mp3",
        enChoupai: "Bidyavaan guni ati chatur । \nRam kaj karibe ko aatur ॥",
        hiChoupai: "बिद्यावान गुनी अति चातुर ।\nराम काज करिबे को आतुर ॥ ७ ॥",
        meaning:
            "आप विद्या के शास्त्री, गुणी तथा अत्यन्त कुशल व बुद्धिमान् हैं। आप सदैव भगवान श्री राम जी का कार्य करने के लिए तत्पर रहते हैं।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa09.mp3",
        enChoupai:
            "Prabhu charitra sunibe-ko rasiya । \nRam Lakhan Sita maan basiya ॥",
        hiChoupai:
            "प्रभु चरित्र सुनिबे को रसिया । \nराम लखन सीता मन बसिया ॥ ८ ॥",
        meaning:
            "भगवान श्री राम जी की महिमा को सुनकर आपको अत्यंत आनंद मिलता है। आपके हृदय में प्रभु श्री राम जी, श्री लक्ष्मण जी और माता सीता का निवास है।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa10.mp3",
        enChoupai:
            "Sukshma roop dhari Siyahi dikhava । \nBikat roop dhari Lank jarava ॥",
        hiChoupai:
            "सूक्ष्म रूप धरि सियहिं दिखावा । \nबिकट रूप धरि लंक जरावा ॥ ९ ॥",
        meaning:
            "आपने एक ओर माता सीता को अपना सूक्ष्म रूप दिखाया, तो वहीं दूसरी ओर अपना विकराल रूप धारण करके रावण की लंका को जलाया।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa11.mp3",
        enChoupai: "Bhim roop dhari asur sahare । \nRamachandra ke kaj savare",
        hiChoupai: "भीम रूप धरि असुर सँहारे । \nरामचन्द्र के काज सँवारे ॥ १० ॥",
        meaning:
            "आपने विकराल रूप धारण कर असुरों का सँहार किया, जिससे प्रभु श्री राम जी का कार्य पूर्ण हुआ।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa12.mp3",
        enChoupai:
            "Laye sanjivan Lakhan jiyaye । \nShri Raghuvir harashi ur laye",
        hiChoupai: "लाय संजीवन लखन जियाये । \nश्रीरघुबीर हरषि उर लाये ॥ ११ ॥",
        meaning:
            "संजीवनी बूटी लाकर आपने श्री लक्ष्मण जी के प्राण बचाये, जिससे प्रभु श्री राम जी ने हर्षित होकर आपको हृदय से लगा लिया।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa13.mp3",
        enChoupai:
            "Raghupati kinhi bahut badhaee । \nTum mam priye Bharat-hi-sam bhai ॥",
        hiChoupai:
            "रघुपति किन्ही बहुत बड़ाई । \nतुम मम प्रिय भरतहि सम भाई ॥ १२ ॥",
        meaning:
            "भगवान श्री राम जी ने आपकी बहुत प्रशंसा की और कहा, “आप मुझको भरत के समान ही प्रिय हैं”।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa14.mp3",
        enChoupai:
            "Sahas badan tumharo jas gaave । \nAsa-kahi Shripati kantha lagave ॥",
        hiChoupai:
            "सहस बदन तुम्हरो जस गावैं । \nअस कहि श्रीपति कंठ लगावैं ॥ १३ ॥",
        meaning:
            "हजार सिर वाले सर्पराज आदिशेष आपकी महिमा गाते हैं!” भगवान श्री राम जी (देवी श्री लक्ष्मी जी के पति) ने आपको हृदय से लगाते हुए ऐसा कहा।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa15.mp3",
        enChoupai: "Sankadik brahmadi munisa । \n Narad-sarad sahit ahisa ॥",
        hiChoupai: "सनकादिक ब्रम्हादि मुनीसा । \n नारद सारद सहित अहीसा ॥ १४ ॥",
        meaning:
            "सनक आदि ऋषि, ब्रह्मा आदि देवगण तथा मुनि नारद, माता सरस्वती और आदिशेष जी"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa16.mp3",
        enChoupai:
            "Jum Kuber digpaal jaha teh । \nKabi Kovid kahi sake kahan teh ॥",
        hiChoupai:
            "जम कुबेर दिगपाल जहाँ ते । \n कबि कोबिद कहि सके कहाँ ते ॥ १५ ॥",
        meaning:
            "यहाँ तक कि यम देवता, कुबेर देवता, दिग्पालक (10 दिशाओं के देवता) भी आपकी महिमा का वर्णन नहीं कर पाए हैं। फिर कवि, कोविद (वेदों के ज्ञानी, वेदज्ञ) और विद्वान् इसका पार कहाँ पा सकते हैं।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa17.mp3",
        enChoupai: "Tum upkar Sugreevahi keenha । \nRam milaye rajpad deenha ॥",
        hiChoupai:
            "तुम उपकार सुग्रीवहिं कीन्हा । \n राम मिलाय राज पद दीन्हा ॥ १६ ॥",
        meaning:
            "आपने सुग्रीव पर भी बड़ा उपकार किया। आपने उन्हें प्रभु श्री राम जी से मिलवाया और इस प्रकार उनका राज्य किष्किन्धा उन्हें वापस दिलावाया।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa18.mp3",
        enChoupai:
            "Tumharo mantra Vibhishan maana । \nLankeshvar bhaye sab jag jana ॥",
        hiChoupai:
            "तुम्हरो मंत्र बिभीषन माना । \nलंकेस्वर भए सब जग जाना ॥ १७ ॥",
        meaning:
            "इसी प्रकार आपके उपदेशों का विभीषण ने भी पालन किया और वह लंका के राजा बने। यह सारा संसार जानता है।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa19.mp3",
        enChoupai:
            "Yug sahastra jojan par bhanu । \nLeelyo tahi madhur phaal janu ॥",
        hiChoupai:
            "जुग सहस्त्र जोजन पर भानु । \nलील्यो ताहि मधुर फल जानू ॥ १८ ॥",
        meaning:
            "जो सूर्यदेव हजारों युग मील दूर हैं, आपने उनको एक मीठा फल समझकर निगल लिया।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa20.mp3",
        enChoupai:
            "Prabhu mudrika meli mukh mahi । \nJaladi langhi gaye achraj nahi ॥",
        hiChoupai:
            "प्रभु मुद्रिका मेलि मुख माहीं । \nजलधि लाँघि गये अचरज नाहीं ॥ १९ ॥",
        meaning:
            "आपने भगवान श्री राम जी की अंगूठी को अपने मुख में रख कर समुद्र पार कर लिया, इसमें कोई आश्चर्य नहीं है।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa21.mp3",
        enChoupai: "Durgaam kaj jagat ke jete । \nSugam anugraha tumhre tete ॥",
        hiChoupai:
            "दुर्गम काज जगत के जेते । \nसुगम अनुग्रह तुम्हरे तेते ॥ २० ॥",
        meaning:
            "आपकी कृपा से इस संसार के कठिन से कठिन कार्य भी सहज हो जाते हैं।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa22.mp3",
        enChoupai: "Ram duwaare tum rakhvare । \nHoat na adyna binu paisare ॥",
        hiChoupai: "राम दुआरे तुम रखवारे । \nहोत न आज्ञा बिनु पैसारे ॥ २१ ॥",
        meaning:
            "प्रभु श्री राम जी के द्वार के आप द्वारपाल हैं। आपकी अनुमति के बिना वहाँ किसी का भी प्रवेश निषेध है, अर्थात भगवान राम के दर्शन आपके आशीर्वाद से ही संभव हैं।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa23.mp3",
        enChoupai:
            "Sab sukh lahe tumhari sarna । \nTum rakshak kahu ko darna ॥",
        hiChoupai:
            "सब सुख लहै तुम्हारी सरना । \nतुम रच्छक काहू को डर ना ॥ २२ ॥",
        meaning:
            "जो आपकी शरण लेते हैं, उन्हें सर्व सुख प्राप्त होते हैं। जब आप रक्षक हैं, तब डर भय का कोई अस्तित्त्व ही नहीं है।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa24.mp3",
        enChoupai: "Aapan tej samharo aape । \nTeenho lok hank teh kanpe ॥",
        hiChoupai: "आपन तेज सम्हारो आपै । \nतीनों लोक हाँक तें काँपै ॥ २३ ॥",
        meaning:
            "आपके तेज को आप स्वयं ही संभाल सकते हैं। आपके गरजने से तीनों लोक काँप उठते हैं।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa25.mp3",
        enChoupai:
            "Bhoot pisaach nikat nahin aave । \nMahabir jab naam sunave ॥",
        hiChoupai: "भूत पिसाच निकट नहिं आवै । \nमहाबीर जब नाम सुनावै ॥ २४ ॥",
        meaning:
            "हे महावीर! आपका नाम स्मरण करने से ही, भूत और पिशाच निकट नहीं आते।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa26.mp3",
        enChoupai:
            "Nase rog hare sab peera । \nJapat nirantar Hanumant beera ॥",
        hiChoupai: "नासै रोग हरै सब पीरा । \nजपत निरन्तर हनुमत बीरा ॥ २५ ॥",
        meaning:
            "हे वीर हनुमान जी, आपके नाम का निरन्तर जप करने से, सब प्रकार के रोग, पीड़ा और कष्ट नष्ट हो जाते हैं।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa27.mp3",
        enChoupai:
            "Sankat se Hanuman chudave । \nMan karam bachan dyan jo lave ॥",
        hiChoupai:
            "संकट तें हनुमान छुडावे । \nमन क्रम बचन ध्यान जो लावै ॥ २६ ॥",
        meaning:
            "जो लोग अपने मन, क्रम और वचनों में भगवान् श्री हनुमान जी का ध्यान मनन करते हैं, वे उनके द्वारा जीवन की सभी कठिनाइयों से मुक्ति पाते हैं।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa28.mp3",
        enChoupai: "Sab par Ram tapasvee raja । \nTeen ke kaj sakal tum saja ॥",
        hiChoupai: "सब पर राम तपस्वी राजा । \nतिन के काज सकल तुम साजा ॥ २७ ॥",
        meaning:
            "तपस्वी राजा भगवान श्री राम जी सबसे श्रेष्ठ हैं और आप उन सभी लोगों के कार्य पूर्ण करते हैं, जो प्रभु श्री राम जी की शरणागति हैं।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa29.mp3",
        enChoupai: "Aur manorath jo koi lave । \nSoee amit jeevan phal pave ॥",
        hiChoupai: "और मनोरथ जो कोई लावै । \nसोई अमित जीवन फल पावै ॥ २८ ॥",
        meaning:
            "जो कोई भी आपके समक्ष अपनी इच्छा लाता है, वे अन्ततः जीवन में असीमित, उच्चतम फल प्राप्त करता है।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa30.mp3",
        enChoupai:
            "Charo yug partap tumhara । \nHoee parasiddha jagat ujiyara ॥",
        hiChoupai: "चारो जुग परताप तुम्हारा । \nहै परसिद्ध जगत उजियारा ॥ २९ ॥",
        meaning:
            "आपकी महिमा चारों युगों में विद्यमान् है। आपकी महानता बहुत प्रसिद्ध है और सम्पूर्ण ब्रह्माण्ड में प्रकाशमान् है।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa31.mp3",
        enChoupai:
            "Sadhu sant ke tum rakhware । \nAsur nikanandan Ram dulare ॥",
        hiChoupai: "साधु सन्त के तुम रखवारे । \nअसुर निकन्दन राम दुलारे ॥ ३० ॥",
        meaning:
            "आप साधु-सन्तों के रखवाले और असुरों का वध करने वाले हैं और प्रभु श्री राम जी के अत्यन्त प्रिय, दुलारे हैं"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa32.mp3",
        enChoupai:
            "Ashta-sidhi nav nidhi ke daata । \nAsabar deen Janki mata ॥",
        hiChoupai: "अष्टसिद्धि नौ निधि के दाता । \nअस बर दीन जानकी माता ॥ ३१ ॥",
        meaning:
            "आपको माता जानकी से ऐसा वरदान प्राप्त है कि आप किसी को भी आठों सिद्धियाँ और नौ निधियाँ दे सकते हैं।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa33.mp3",
        enChoupai:
            "Ram rasayan tumhare pasa । \nSada raho Raghupati ke dasa ॥32॥",
        hiChoupai: "राम रसायन तुम्हरे पासा । \nसदा रहो रघुपति के दासा ॥ ३२ ॥",
        meaning:
            "आपके पास श्री राम नाम का रसायन (भक्ति रस) है। आप सदैव रघुपति (प्रभु श्री राम जी) के भक्त बने रहें।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa34.mp3",
        enChoupai:
            "Tumhare bhajan Ram ko paave । \nJanam-janam ke dukh bisrave ॥",
        hiChoupai: "तुम्हरे भजन राम को पावै । \nजनम जनम के दुख बिसरावै ॥ ३३ ॥",
        meaning:
            "आपके स्मरण मात्र से स्वयं भगवान श्री राम प्राप्त होते हैं क्योंकि जो कोई भी आपका स्मरण करता है, वह श्री राम प्रभु को अत्यन्त प्रिय होता है तथा उसको जन्म-जन्मान्तर के कष्टों से मुक्ति मिल जाती है।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa35.mp3",
        enChoupai:
            "Anth-kaal Raghubar pur jaee । \nJaha janma Hari-bhakht kahaee ॥",
        hiChoupai: "अन्त काल रघुबर पुर जाई । \nजहाँ जन्म हरिभक्त कहाई ॥ ३४ ॥",
        meaning:
            "आपकी स्तुति करने वाले अपने अंत समय में रघुनाथ जी के धाम को जाते हैं और यदि फिर कहीं भी जन्म लेते हैं तो राम भक्त ही कहलाते हैं।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa36.mp3",
        enChoupai:
            "Aur devta chitta na dharaee । \nHanumanth se he sarba sukh karaee ॥",
        hiChoupai: "और देवता चित्त न धरई । \nहनुमत सेही सर्ब सुख करई ॥ ३५ ॥",
        meaning:
            "यहाँ तक कि किसी अन्य देवता को पूजे बिना, केवल श्री हनुमान जी को पूजने मात्र से ही सर्व सुख प्राप्त हो जाते हैं।"),

    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa37.mp3",
        enChoupai:
            "Sankat kate-mite sab peera । \nJo sumire Hanumat balbeera ॥",
        hiChoupai: "संकट कटै मिटै सब पीरा । \nजो सुमिरे हनुमत बलबीरा ॥ ३६ ॥",
        meaning:
            "हे वीर हनुमान, जो व्यक्ति आपका स्मरण करता है, उसके सभी संकट दूर हो जाते हैं और उसकी सभी पीड़ा मिट जाती है।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa38.mp3",
        enChoupai:
            "Jai Jai Jai Hanuman gosaee । \nKrupa karahu gurudev ki naee ॥",
        hiChoupai:
            "जय जय जय हनुमान गोसाईं । \nकृपा करहु गुरुदेव की नाईं ॥ ३७ ॥",
        meaning:
            "हे मेरे स्वामी, श्री हनुमान जी! आपकी जय हो, जय हो, जय हो! हमारे परम गुरु के रूप में अपनी कृपा से हमें कृतार्थ कीजिये, आशीर्वाद दीजिये।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa39.mp3",
        enChoupai:
            "Jo sath baar paath kar koi । \nChuthee bandhi maha sukh hoee ॥",
        hiChoupai: "जो सत बार पाठ कर कोई । \nछूटहि बन्दि महा सुख होई ॥ ३८ ॥",
        meaning:
            "जो कोई हनुमान चालीसा का सौ बार पाठ करता है, वह सभी बंधनों से मुक्त हो जाता है और उसे परम आनंद की प्राप्ति होती है।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa40.mp3",
        enChoupai:
            "Jo yaha padhe Hanuman Chalisa । \nHoye Siddhi Sakhi Gaurisa ॥",
        hiChoupai: "जो यह पढ़ै हनुमान चालीसा । \nहोय सिद्धि साखी गौरीसा ॥ ३९ ॥",
        meaning:
            "जो इस हनुमान चालीसा को पढ़ता है, उसके सभी कार्य सिद्ध होते हैं। भगवान शिव स्वयं इसके साक्षी हैं।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa41.mp3",
        enChoupai:
            "Tulsidas sada Hari chera । \nKeeje nath hridaye maha dera ॥",
        hiChoupai: "तुलसीदास सदा हरि चेरा । \nकीजै नाथ हृदय मह डेरा ॥ ४० ॥",
        meaning:
            "तुलसीदास कहते हैं, हे हनुमान जी, मैं हमेशा भगवान श्री राम का सेवक और भक्त बना रहूँ। और आप सदा मेरे हृदय में निवास करें।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa42.mp3",
        enChoupai:
            "Pavan tanay sankat harana mangal murti roop । \nRam Lakhan Sita sahit hriday basau sur bhuup ॥",
        hiChoupai:
            "पवनतनय संकट हरन मंगल मुर्ति रूप । \nराम लखन सीता सहित हृदय बसहु सुर भूप ॥",
        meaning:
            "हे पवनपुत्र, आप सभी दुखों का नाश करने वाले हैं, आप सौभाग्य और समृद्धि के स्वरुप हैं।\nआप भगवान श्री राम जी, श्री लक्ष्मण जी और माता सीता के संग मेरे हृदय में निवास कीजिये।"),
    HanumanChalisaModel(
        audioUrl: "assets/hanuman_chalisa_audio/hanumanchalisa43.mp3",
        enChoupai: "Bol Bajarangabali ki jai । \nPavan putra Hanuman ki hai ॥",
        hiChoupai: "बोल बजरंगबली की जय । \nपवन पुत्र हनुमान की जय ॥",
        meaning: "॥जय श्री राम ॥"),
  ];

  // Dummy URLs for music tracks
  final List<ChalisaMusiclistModel> _musicUrls = [
    ChalisaMusiclistModel(
        musicArtist: " हनुमान चालीसा ",
        musicImage:
            "https://5.imimg.com/data5/ANDROID/Default/2021/9/QN/ZH/DE/13910760/product-jpeg-500x500.jpg",
        musicTtile: " 2:00 ",
        musicUrl: "assets/hanuman_chalisa_audio/fast_chalisa.mp3"),
    ChalisaMusiclistModel(
        musicArtist: " हनुमान चालीसा ",
        musicImage:
            "https://img.freepik.com/premium-photo/statue-lord-hanuman-ji_1074273-21935.jpg",
        musicTtile: " 9:05 ",
        musicUrl: "assets/hanuman_chalisa_audio/chalisa_male_version.mp3"),
    ChalisaMusiclistModel(
        musicArtist: " हनुमान चालीसा ",
        musicImage:
            "https://5.imimg.com/data5/ANDROID/Default/2021/9/QN/ZH/DE/13910760/product-jpeg-500x500.jpg",
        musicTtile: " 10:00 ",
        musicUrl: "assets/hanuman_chalisa_audio/medium_sound_chalisa.mp3"),
    ChalisaMusiclistModel(
        musicArtist: " हनुमान चालीसा ",
        musicImage:
            "https://5.imimg.com/data5/ANDROID/Default/2021/9/QN/ZH/DE/13910760/product-jpeg-500x500.jpg",
        musicTtile: " 9:00 ",
        musicUrl: "assets/hanuman_chalisa_audio/chalisa_male_version.mp3"),
    //ChalisaMusiclistModel(musicArtist: " हनुमान चालीसा ",musicImage: "https://5.imimg.com/data5/ANDROID/Default/2021/9/QN/ZH/DE/13910760/product-jpeg-500x500.jpg",musicTtile: " 12:00 ",musicUrl: "assets/hanuman_chalisa_audio/male_version_chalisa.mp3"),
  ];

  void _showMusicDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(
            child: Text(
          "✿ Hanuman Chalisa Music ✿",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        )),
        content: SizedBox(
          height: 310,
          width: 300, // Adjust as needed
          child: Consumer<ListChalisaPlayer>(
            builder: (BuildContext context, listChalisaPlayer, Widget? child) {
              return Column(
                children: [
                  // Padding(
                  //   padding:EdgeInsets.symmetric(vertical: 3),
                  //   child: Container(
                  //     height: 5,
                  //     width: double.infinity,
                  //     child: SliderTheme(
                  //       data: SliderThemeData(
                  //         activeTrackColor: Colors.orange,
                  //         trackHeight: 1.5,
                  //         trackShape: const RectangularSliderTrackShape(),
                  //         inactiveTrackColor: Colors.grey.withOpacity(0.5),
                  //         overlayColor: CustomColors.clrwhite.withOpacity(0.7),
                  //         valueIndicatorColor: CustomColors.clrwhite,
                  //       ),
                  //       child: Slider(
                  //         min: 0.0,
                  //         max: listChalisaPlayer.totalDuration.inSeconds.toDouble(),
                  //         value: listChalisaPlayer.currentDuration.inSeconds.toDouble(),
                  //         onChanged: (double value) {
                  //          listChalisaPlayer.seekTo(Duration(seconds: value.toInt()));
                  //         //  listChalisaPlayer.;
                  //         },
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  SizedBox(
                    height: 250,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: _musicUrls.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Row(
                          children: [
                            listChalisaPlayer.isPlaying &&
                                    listChalisaPlayer.currentTrack ==
                                        _musicUrls[index]
                                ? Container(
                                    height: 35,
                                    width: 35,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            _musicUrls[index].musicImage ?? ''),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                      child: const Image(
                                        image: NetworkImage(
                                          "https://cdn.pixabay.com/animation/2023/10/22/03/31/03-31-40-761_512.gif",
                                        ),
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 35,
                                    width: 35,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                _musicUrls[index].musicImage ??
                                                    ''),
                                            fit: BoxFit.cover)),
                                  ),
                            const SizedBox(
                              width: 4,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  _musicUrls[index].musicArtist ?? '',
                                  style: const TextStyle(color: Colors.black),
                                ),
                                Text(
                                  _musicUrls[index].musicTtile ?? '',
                                  style: const TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Icon(
                          listChalisaPlayer.isPlaying &&
                                  listChalisaPlayer.currentTrack ==
                                      _musicUrls[index]
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          color: Colors.orange,
                          size: 30,
                        ),
                        onTap: () {
                          listChalisaPlayer.playTrack(index);
                          setState(() {
                            showMusicBar = true;
                          });
                          Provider.of<ChalisaPlayer>(context, listen: false)
                              .stopChalisaAudio();
                          Provider.of<AudioPlayerManager>(context,
                                  listen: false)
                              .stopMusic();
                        },
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.red),
                      child: const Center(
                          child: Text(
                        "Close",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16),
                      )),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        //   actions: [
        //   TextButton(
        //     onPressed: () => Navigator.pop(context),
        //     child: const Text("Close",style: TextStyle(fontWeight: FontWeight.bold),),
        //   ),
        // ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollTimer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        // Stop the music when the back button is pressed
        Provider.of<ChalisaPlayer>(context, listen: false).stopChalisaAudio();
        Provider.of<ListChalisaPlayer>(context, listen: false).stop();
        return true;
      },
      child: Scaffold(
          backgroundColor: _isBlackBackground ? Colors.black : Colors.white,
          appBar: AppBar(
              title: Text(
                "Hanuman Chalisa",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.05,
                    color: Colors.white),
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
              backgroundColor: Theme.of(context).primaryColor,
              leading: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  )),
              actions: [
                Consumer<ChalisaPlayer>(
                  builder:
                      (BuildContext context, chalisaPlayer, Widget? child) {
                    return BouncingWidgetInOut(
                      onPressed: () {
                        setState(() {
                          isShuffle = !isShuffle;
                          _showShuffleOptionsDialog(context, chalisaPlayer);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2.0),
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0),
                            color:
                                isShuffle ? Colors.white : Colors.transparent,
                            border: Border.all(
                                color: isShuffle
                                    ? Colors.transparent
                                    : Colors.white,
                                width: 2)),
                        child: Center(
                            child: Icon(
                          Icons.shuffle,
                          color: isShuffle ? Colors.black : Colors.white,
                          size: 20,
                        )),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 5),
                BouncingWidgetInOut(
                  onPressed: () {
                    setState(() {
                      isTransLate = !isTransLate;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.0),
                        color: isTransLate ? Colors.white : Colors.transparent,
                        border: Border.all(
                            color:
                                isTransLate ? Colors.transparent : Colors.white,
                            width: 2)),
                    child: Center(
                        child: Icon(
                      Icons.translate,
                      color: isTransLate ? Colors.black : Colors.white,
                      size: 20,
                    )),
                  ),
                ),
                const SizedBox(width: 10)
              ]),
          body: SingleChildScrollView(
            controller: _scrollController,
            child: isBookFormate
                ? Column(children: [
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: hunumanChalisa.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            (index == 0 || index == 1)
                                ? Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    height: 2,
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.yellow, // Start color
                                          Colors.red, // Middle color
                                          Colors.yellow, // End color
                                        ],
                                        begin: Alignment
                                            .topLeft, // Starting point of the gradient
                                        end: Alignment
                                            .bottomRight, // Ending point of the gradient
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            Center(
                                child: Text(
                              index == 0
                                  ? " || दोहा || "
                                  : (index == 1 ? " ✤  चौपाई  ✤  " : ""),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.05,
                                  color: _isBlackBackground
                                      ? Colors.white
                                      : Colors.black),
                            )),
                            (index == 0 || index == 1)
                                ? Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    height: 2,
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.yellow, // Start color
                                          Colors.red, // Middle color
                                          Colors.yellow, // End color
                                        ],
                                        begin: Alignment
                                            .topLeft, // Starting point of the gradient
                                        end: Alignment
                                            .bottomRight, // Ending point of the gradient
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            Center(
                                child: Text(
                              "${isTransLate ? hunumanChalisa[index].hiChoupai : hunumanChalisa[index].enChoupai} \n",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      screenWidth * 0.04 * _textScaleFactor,
                                  color: Colors.orange),
                            )),
                          ],
                        );
                      },
                    ),
                  ])
                : Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        //padding: EdgeInsets.all(10),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: hunumanChalisa.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 360,
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.all(10),
                            // height: 400,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                //color: Colors.black
                                border:
                                    Border.all(color: Colors.grey.shade300)),
                            child: Column(
                              children: [
                                (index == 0 || index == 1)
                                    ? Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        height: 2,
                                        width: double.infinity,
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.yellow, // Start color
                                              Colors.red, // Middle color
                                              Colors.yellow, // End color
                                            ],
                                            begin: Alignment
                                                .topLeft, // Starting point of the gradient
                                            end: Alignment
                                                .bottomRight, // Ending point of the gradient
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                Center(
                                    child: Text(
                                  index == 0
                                      ? " || दोहा || "
                                      : (index == 1 ? " ✤  चौपाई  ✤  " : ""),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.05,
                                      color: _isBlackBackground
                                          ? Colors.white
                                          : Colors.black),
                                )),
                                (index == 0 || index == 1)
                                    ? Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        height: 2,
                                        width: double.infinity,
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.yellow, // Start color
                                              Colors.red, // Middle color
                                              Colors.yellow, // End color
                                            ],
                                            begin: Alignment
                                                .topLeft, // Starting point of the gradient
                                            end: Alignment
                                                .bottomRight, // Ending point of the gradient
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),

                                // Container(
                                //   margin: const EdgeInsets.symmetric(vertical: 10),
                                //   height: 2,
                                //   width: double.infinity,
                                //   decoration: const BoxDecoration(
                                //     gradient: LinearGradient(
                                //       colors: [
                                //         Colors.yellow, // Start color
                                //         Colors.red, // Start color
                                //         Colors.yellow, // End color
                                //       ],
                                //       begin: Alignment.topLeft, // Starting point of the gradient
                                //       end: Alignment.bottomRight, // Ending point of the gradient
                                //     ),
                                //   ),
                                // ),

                                const SizedBox(
                                  height: 10,
                                ),

                                isTransLate
                                    ? Text(
                                        "${hunumanChalisa[index].hiChoupai}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: screenWidth *
                                                0.04 *
                                                _textScaleFactor,
                                            color: Colors.blue),
                                      )
                                    : Text(
                                        "${hunumanChalisa[index].enChoupai}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: screenWidth *
                                                0.04 *
                                                _textScaleFactor,
                                            color: Colors.blue),
                                      ),

                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  height: 2,
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.yellow, // Start color
                                        Colors.red, // Start color
                                        Colors.yellow, // End color
                                      ],
                                      begin: Alignment
                                          .topLeft, // Starting point of the gradient
                                      end: Alignment
                                          .bottomRight, // Ending point of the gradient
                                    ),
                                  ),
                                ),

                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'अर्थ - ', // '\n' adds a new line
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: screenWidth *
                                                0.04 *
                                                _textScaleFactor,
                                            color: _isBlackBackground
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                      TextSpan(
                                          text:
                                              '${hunumanChalisa[index].meaning}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: screenWidth *
                                                  0.04 *
                                                  _textScaleFactor,
                                              color: Colors.orange)),
                                    ],
                                  ),
                                  style: const TextStyle(fontFamily: 'Roboto'),
                                  textAlign: TextAlign
                                      .center, // Overall style for the text
                                ),

                                //  Text("अर्थ- श्री गुरु महाराज के चरण कमलों की धूलि से अपने मन रूपी दर्पण को पवित्र करके श्री रघुवीर के निर्मल यश का वर्णन करता हूं, जो चारों फल धर्म, अर्थ, काम और मोक्ष को देने वाला है।",textAlign:TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: screenWidth * 0.03,color: Colors.orange),),

                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.02),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                  builder: (context) =>
                                                      ShareChalisa(
                                                    chaupaiMeaning:
                                                        hunumanChalisa[index]
                                                                .meaning ??
                                                            '',
                                                    hanumanChaupai:
                                                        hunumanChalisa[index]
                                                                .hiChoupai ??
                                                            '',
                                                    chalisaModel:
                                                        hunumanChalisa[index],
                                                  ),
                                                ));
                                          },
                                          child: Icon(
                                            Icons.share,
                                            color: _isBlackBackground
                                                ? Colors.white
                                                : Colors.black,
                                            size: screenWidth * 0.07,
                                          )),
                                      const Spacer(),
                                      // Icon(Icons.play_circle,size: screenWidth * 0.08,color: _isBlackBackground ? Colors.white : Colors.black)

                                      Consumer<ChalisaPlayer>(
                                        builder: (BuildContext context,
                                            chalisaPlayer, Widget? child) {
                                          bool isCurrentSongPlaying =
                                              chalisaPlayer.isPlaying &&
                                                  chalisaPlayer
                                                          .currentChalisaAudio ==
                                                      hunumanChalisa[index];

                                          return IconButton(
                                            onPressed: () {
                                              chalisaPlayer
                                                  .setPlaylist(hunumanChalisa);
                                              //chalisaPlayer.setPlaylist(hunumanChalisa);

                                              if (isCurrentSongPlaying) {
                                                // Pause the current song
                                                chalisaPlayer.togglePlayPause();
                                                Provider.of<AudioPlayerManager>(
                                                        context,
                                                        listen: false)
                                                    .stopMusic();
                                                Provider.of<ListChalisaPlayer>(
                                                        context,
                                                        listen: false)
                                                    .stop();
                                              } else {
                                                if (chalisaPlayer
                                                        .currentChalisaAudio ==
                                                    hunumanChalisa[index]) {
                                                  // Resume the current song
                                                  chalisaPlayer
                                                      .togglePlayPause();
                                                  Provider.of<AudioPlayerManager>(
                                                          context,
                                                          listen: false)
                                                      .stopMusic();
                                                  Provider.of<ListChalisaPlayer>(
                                                          context,
                                                          listen: false)
                                                      .stop();
                                                } else {
                                                  // Play the selected song
                                                  // chalisaPlayer.playchalisaAudio(hunumanChalisa[index]);
                                                  chalisaPlayer
                                                      .playChalisaAudio(
                                                          hunumanChalisa[
                                                              index]);
                                                  Provider.of<AudioPlayerManager>(
                                                          context,
                                                          listen: false)
                                                      .stopMusic();
                                                  Provider.of<ListChalisaPlayer>(
                                                          context,
                                                          listen: false)
                                                      .stop();

                                                  print(
                                                      "$isCurrentSongPlaying");

                                                  print(
                                                      "Song clicked and played");
                                                }
                                              }

                                              // Debugging: Print current state for verification
                                              print(
                                                  'isPlaying: ${chalisaPlayer.isPlaying}');
                                              print(
                                                  'currentMusic: ${chalisaPlayer.currentChalisaAudio}');
                                            },
                                            icon: Icon(
                                                // Determine icon based on the state of the current song
                                                isCurrentSongPlaying
                                                    ? Icons.pause_circle
                                                    : Icons.play_circle,
                                                size: screenWidth * 0.09,
                                                color: _isBlackBackground
                                                    ? Colors.white
                                                    : Colors.black),
                                          );
                                        },
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      )
                    ],
                  ),
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              showMusicBar
                  ? Consumer<ListChalisaPlayer>(
                      builder: (BuildContext context, listChalisaPlayer,
                          Widget? child) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 1000),
                          height: 73.0, // Adjust as needed
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5),
                              topLeft: Radius.circular(5),
                            ),
                            color: Colors.deepOrange,
                          ),
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.02),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: screenWidth * 0.09,
                                          height: screenWidth * 0.09,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  listChalisaPlayer
                                                          .currentTrack!
                                                          .musicImage ??
                                                      ''),
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),

                                        SizedBox(
                                          width: screenWidth * 0.03,
                                        ),
                                        Expanded(
                                          child: SizedBox(
                                            width: screenWidth * 0.24,
                                            child: Text(
                                              listChalisaPlayer.currentTrack!
                                                      .musicArtist ??
                                                  '',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: screenWidth * 0.07,
                                        ),

                                        GestureDetector(
                                            onTap: () {
                                              Provider.of<ListChalisaPlayer>(
                                                      context,
                                                      listen: false)
                                                  .togglePlayPause();
                                              Provider.of<AudioPlayerManager>(
                                                      context,
                                                      listen: false)
                                                  .stopMusic();
                                            },
                                            child: Icon(
                                              listChalisaPlayer.isPlaying
                                                  ? Icons.pause
                                                  : Icons.play_circle,
                                              color: Colors.white,
                                              size: screenWidth * 0.08,
                                            )),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        // Remove Music Bar
                                        IconButton(
                                          onPressed: () {
                                            Provider.of<ListChalisaPlayer>(
                                                    context,
                                                    listen: false)
                                                .stop();
                                            setState(() {
                                              showMusicBar = false;
                                            });
                                          },
                                          icon: Icon(
                                            Icons.cancel,
                                            color: Colors.white,
                                            size: screenWidth * 0.07,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 3),
                                    child: SizedBox(
                                      height: 5,
                                      width: double.infinity,
                                      child: SliderTheme(
                                        data: SliderThemeData(
                                          activeTrackColor: Colors.black,
                                          trackHeight: 1.5,
                                          trackShape:
                                              const RectangularSliderTrackShape(),
                                          inactiveTrackColor: Colors.white,
                                          overlayColor: CustomColors.clrwhite
                                              .withOpacity(0.7),
                                          valueIndicatorColor:
                                              CustomColors.clrwhite,
                                        ),
                                        child: Slider(
                                          min: 0.0,
                                          max: listChalisaPlayer
                                              .totalDuration.inSeconds
                                              .toDouble(),
                                          value: listChalisaPlayer
                                              .currentDuration.inSeconds
                                              .toDouble(),
                                          onChanged: (double value) {
                                            listChalisaPlayer.seekTo(Duration(
                                                seconds: value.toInt()));
                                            //  listChalisaPlayer.;
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        );
                      },
                    )
                  : const SizedBox.shrink(),
              if (_currentIndex == 5)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    children: [
                      Text(
                        "Adjust Scroll Speed",
                        style: TextStyle(
                            color: _isBlackBackground
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w500),
                      ),
                      Slider(
                        value: _scrollSpeed,
                        activeColor: Colors.orange,
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
              Consumer<ListChalisaPlayer>(
                builder:
                    (BuildContext context, listChalisaPlayer, Widget? child) {
                  return BottomNavigationBar(
                    currentIndex: _currentIndex,
                    selectedItemColor: Colors.orange,
                    onTap: _onBottomNavTap,
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.sunny,
                            color: _currentIndex == 0
                                ? Colors.orange
                                : Colors.black),
                        label: 'Theme',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.text_increase_outlined,
                            color: _currentIndex == 1
                                ? Colors.orange
                                : Colors.black),
                        label: 'Zoom In',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.text_decrease,
                            color: _currentIndex == 2
                                ? Colors.orange
                                : Colors.black),
                        label: 'Zoom Out',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.share,
                            color: _currentIndex == 3
                                ? Colors.orange
                                : Colors.black),
                        label: "Share",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.description,
                            color: _currentIndex == 4
                                ? Colors.orange
                                : Colors.black),
                        label: 'Book',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.slideshow,
                            color: _currentIndex == 5
                                ? Colors.orange
                                : Colors.black),
                        label: 'Slide',
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          floatingActionButton: isBookFormate
              ? Consumer<ChalisaPlayer>(
                  builder:
                      (BuildContext context, chalisaPlayer, Widget? child) {
                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.black),
                      ),
                      child: GestureDetector(
                          onTap: () {
                            _showMusicDialog();
                            //  showComingSoonDialog(context);
                            //  print("it works");
                            Provider.of<ListChalisaPlayer>(context,
                                    listen: false)
                                .setChalisaList(_musicUrls);
                            // chalisaPlayer.playFullChalisa();
                            // Provider.of<AudioPlayerManager>(context).stopMusic();
                          },
                          child: Icon(
                            Icons.queue_music,
                            size: screenWidth * 0.07,
                          )),
                    );
                  },
                )
              : Container()),
    );
  }
}

class ShuffleOptionsDialog extends StatefulWidget {
  final ChalisaPlayer chalisaPlayer;

  const ShuffleOptionsDialog({
    super.key,
    required this.chalisaPlayer,
  });

  @override
  _ShuffleOptionsDialogState createState() => _ShuffleOptionsDialogState();
}

class _ShuffleOptionsDialogState extends State<ShuffleOptionsDialog> {
  int _currentSelectedIndex = 0;

  List<int> indexSelected = [0, 1, 2];

  @override
  void initState() {
    super.initState();
    _loadSelectedIndex();
  }

  _loadSelectedIndex() async {
    final prefs = await SharedPreferences.getInstance();
    int selectedIndex = prefs.getInt('selectedIndex') ?? 0;
    setState(() {
      _currentSelectedIndex = selectedIndex;
    });
  }

  _saveSelectedIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('selectedIndex', index);
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return BottomSheet(
      onClosing: () {},
      builder: (context) {
        return Container(
          height: 210,
          width: double.infinity,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05, vertical: screenWidth * 0.02),
            child: Column(
              children: [
                Text(
                  'How to listen to Hanuman Chalisa?',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CustomColors.clrblack,
                      fontSize: screenWidth * 0.05),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: 2,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.yellow, // Start color
                        Colors.red, // Start color
                        Colors.yellow, // End color
                      ],
                      begin:
                          Alignment.topLeft, // Starting point of the gradient
                      end:
                          Alignment.bottomRight, // Ending point of the gradient
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.fiber_smart_record_outlined,
                            color: CustomColors.clrorange,
                            size: screenWidth * 0.05),
                        SizedBox(width: screenWidth * 0.05),
                        Text('Play Next',
                            style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                color: CustomColors.clrblack)),
                        const Spacer(),
                        Radio<int>(
                          value: indexSelected[0],
                          groupValue: _currentSelectedIndex,
                          activeColor: CustomColors.clrorange,
                          onChanged: (int? value) {
                            setState(() {
                              _currentSelectedIndex = value!;
                            });
                            _saveSelectedIndex(value!);
                            widget.chalisaPlayer
                                .setShuffleMode(ShuffleMode.playNext);
                            // Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.looks_one_outlined,
                            color: CustomColors.clrorange,
                            size: screenWidth * 0.05),
                        SizedBox(width: screenWidth * 0.05),
                        Text('Play Once and Close',
                            style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                color: CustomColors.clrblack)),
                        const Spacer(),
                        Radio<int>(
                          value: indexSelected[1],
                          groupValue: _currentSelectedIndex,
                          activeColor: CustomColors.clrorange,
                          onChanged: (int? value) {
                            setState(() {
                              _currentSelectedIndex = value!;
                            });
                            _saveSelectedIndex(value!);
                            widget.chalisaPlayer
                                .setShuffleMode(ShuffleMode.playOnceAndClose);
                            // Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    Row(children: [
                      Icon(Icons.loop,
                          color: CustomColors.clrorange,
                          size: screenWidth * 0.05),
                      SizedBox(width: screenWidth * 0.05),
                      Text('Play on Loop',
                          style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                              color: CustomColors.clrblack)),
                      const Spacer(),
                      Radio<int>(
                        value: indexSelected[2],
                        groupValue: _currentSelectedIndex,
                        activeColor: CustomColors.clrorange,
                        onChanged: (int? value) {
                          setState(() {
                            _currentSelectedIndex = value!;
                          });
                          _saveSelectedIndex(value!);
                          widget.chalisaPlayer
                              .setShuffleMode(ShuffleMode.playOnLoop);
                          //  Navigator.pop(context);
                        },
                      ),
                    ]),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
