import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/data/datasource/remote/http/httpClient.dart';
import 'package:mahakal/features/rashi_fal/rsahi_fal_screen.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_animation_transition/animations/right_to_left_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';
import '../../localization/language_constrants.dart';
import '../../utill/color_resources.dart';
import '../../utill/custom_themes.dart';
import '../../utill/dimensions.dart';
import '../Tickit_Booking/view/tickit_booking_home.dart';
import '../all_pandit/All_Pandit.dart';
import '../explore/rashifalModel.dart';
import '../hotels/view/hotels_home_page.dart';
import '../janm_kundli/screens/kundliForm.dart';
import '../kundli_milan/kundalimatching.dart';
import '../lalkitab/lalkitabform.dart';
import '../maha_bhandar/model/city_model.dart';
import '../numerology/numerohome.dart';
import '../self_drive/self_form_screen.dart';
import 'component/astro_consultation.dart';
import 'component/astrodetailspage.dart';
import 'component/maha_vimshottri_model.dart';
import 'component/pdf_details_screen.dart';
import 'component/shubhmuhurat.dart';
import 'model/consultation_model.dart';
import 'model/janam_items.dart';
import 'model/pdfmodel.dart';
import 'model/shubhmuhuratmodel.dart';
import '../hotels/view/hotel_bottom_bar.dart';

class AstrologyView extends StatefulWidget {
  const AstrologyView({super.key});

  @override
  State<AstrologyView> createState() => _AstrologyViewState();
}

class _AstrologyViewState extends State<AstrologyView> {
  @override
  void initState() {
    super.initState();
    // getRashiList();
    getPfdData();
    getConsultaionData();
    getmuhuratData();
  }

  // Future<void> getRashiList() async {
  //   var res = await HttpService().getApi(AppConstants.rashiListURL);
  //   if(res["status"] == 200) {
  //     setState(() {
  //       List data = res["rashi"];
  //       rashiList.addAll(data.map((e) => RashiComponentModel.fromJson(e)));
  //     });
  //   }
  // }

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _dateController = TextEditingController();

  final TextEditingController _timeController = TextEditingController();

  final TextEditingController countryController = TextEditingController();

  final ScrollController scrollController = ScrollController();
  String? latitude;
  String? longitude;
  String? timeHour;
  String? timeMinute;
  String formTitle = 'Form';
  int dialogIndex = 0;
  int _maleValue = 1;
  List<MahaVimshottari> mahaVimshottariModelList = <MahaVimshottari>[];
  bool translateBtn = true;
  String translateEn = 'en';
  // orignal number data
  String orignalNo = '';
  //Rashi namak data
  String rashinamakRashi = '';
  String rashinamakAlphabet = '';
  //Pryayer data
  String poojasuggestion = '';
  //Kaal sarp data
  String kaalSarpDoshline = '';
  // Pitr dosh data
  String pitrConclusion = '';
  String pitrTrueFalse = '';
  String pitrmessage = '';
  //ratna suggestion data life gems
  String lifeGemsName = '';
  String lifeGemsFinger = '';
  String lifeGemsWeight = '';
  String lifeGemsDay = '';
  String lifeGemsDeity = '';
  String lifeGemsMetal = '';
  //ratna suggestion data benefic gems
  String beneficGemsName = '';
  String beneficGemsFinger = '';
  String beneficGemsWeight = '';
  String beneficGemsDay = '';
  String beneficGemsDeity = '';
  String beneficGemsMetal = '';
  //ratna suggestion data lucky gems
  String luckyGemsName = '';
  String luckyGemsFinger = '';
  String luckyGemsWeight = '';
  String luckyGemsDay = '';
  String luckyGemsDeity = '';
  String luckyGemsMetal = '';
  // rudraksha data
  String rudrakshaImage = '';
  String rudrakshaName = '';
  String rudrakshaRecommend = '';
  String rudrakshaDetail = '';
  // Vimshottari data
  String vimshottariPlanet1 = '';
  String vimshottariPlanet2 = '';
  String vimshottariPlanet3 = '';
  String vimshottariPlanet4 = '';
  String vimshottariPlanet5 = '';
  String vimshottariStart1 = '';
  String vimshottariStart2 = '';
  String vimshottariStart3 = '';
  String vimshottariStart4 = '';
  String vimshottariStart5 = '';
  String vimshottariEnd1 = '';
  String vimshottariEnd2 = '';
  String vimshottariEnd3 = '';
  String vimshottariEnd4 = '';
  String vimshottariEnd5 = '';
  //Manglik data
  List manglikBased_on_aspect = [];
  List manglikBased_on_house = [];
  String manglikStatus = '';
  String manglikPercent = '';
  String manglikReport = '';
  bool isLoading = false;
  bool isTranslate = false;
  DateTime birthDate = DateTime.now();
  String birthHour = '';
  String birthMinute = '';
  String anukulMantraVar = '';
  String anukulTimeVar = '';
  String subhVratVar = '';
  String anukulDev = '';
  String calculatorLat = '';
  String calculatorLong = '';
  String janmJankariLat = '';
  String janmJankariLong = '';
  String selectedGender = 'Gender';
  List<CityPickerModel> cityListModel = <CityPickerModel>[];
  List<Rashi> rashiList = <Rashi>[];

  final numeroFormKey = GlobalKey<FormState>();

  List<JanamItems> janmitems = [
    JanamItems(
        img:
            'https://s3-alpha-sig.figma.com/img/dd22/8424/15c5e6b8d9c6d497e5ef138fb548a9e6?Expires=1720396800&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=e2QeOu9VUanx3coXRhD8KCChH3Lxd7MqvR-jqQsJp~bp8FRSXSs6ZcQ3zIp233gRO8SFZgAYbzn6efBfducCpGWdtMGbpqktyAKRiy7FBxLvJxZ4d1WlUWeB6CGTzA7DK0gaB2zcNWosTqQ2C~y4OnHAPFrnDobPVpAyB717uFGckabt6ga5fZ3HHcmEh9McwAv4J7b34a3EpesMnDvfilJTpdNyWaB5xfTv4n2~yMGMOK26xPatH8Up62OVEos~LSAa-GRcqygHi~zfG-VP3zoRmwihfCcn6auIRh5V3aLDX3e6KEaER3prFTf~fNPWxjKAT4NFeW~cuxBFIFKoCA__',
        janmtxt: 'Anukul \nMantra'),
    JanamItems(
        img:
            'https://s3-alpha-sig.figma.com/img/dd22/8424/15c5e6b8d9c6d497e5ef138fb548a9e6?Expires=1720396800&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=e2QeOu9VUanx3coXRhD8KCChH3Lxd7MqvR-jqQsJp~bp8FRSXSs6ZcQ3zIp233gRO8SFZgAYbzn6efBfducCpGWdtMGbpqktyAKRiy7FBxLvJxZ4d1WlUWeB6CGTzA7DK0gaB2zcNWosTqQ2C~y4OnHAPFrnDobPVpAyB717uFGckabt6ga5fZ3HHcmEh9McwAv4J7b34a3EpesMnDvfilJTpdNyWaB5xfTv4n2~yMGMOK26xPatH8Up62OVEos~LSAa-GRcqygHi~zfG-VP3zoRmwihfCcn6auIRh5V3aLDX3e6KEaER3prFTf~fNPWxjKAT4NFeW~cuxBFIFKoCA__',
        janmtxt: 'Shubh \nVrat'),
    JanamItems(
        img:
            'https://s3-alpha-sig.figma.com/img/dd22/8424/15c5e6b8d9c6d497e5ef138fb548a9e6?Expires=1720396800&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=e2QeOu9VUanx3coXRhD8KCChH3Lxd7MqvR-jqQsJp~bp8FRSXSs6ZcQ3zIp233gRO8SFZgAYbzn6efBfducCpGWdtMGbpqktyAKRiy7FBxLvJxZ4d1WlUWeB6CGTzA7DK0gaB2zcNWosTqQ2C~y4OnHAPFrnDobPVpAyB717uFGckabt6ga5fZ3HHcmEh9McwAv4J7b34a3EpesMnDvfilJTpdNyWaB5xfTv4n2~yMGMOK26xPatH8Up62OVEos~LSAa-GRcqygHi~zfG-VP3zoRmwihfCcn6auIRh5V3aLDX3e6KEaER3prFTf~fNPWxjKAT4NFeW~cuxBFIFKoCA__',
        janmtxt: 'Anukul \nDev'),
    JanamItems(
        img:
            'https://s3-alpha-sig.figma.com/img/dd22/8424/15c5e6b8d9c6d497e5ef138fb548a9e6?Expires=1720396800&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=e2QeOu9VUanx3coXRhD8KCChH3Lxd7MqvR-jqQsJp~bp8FRSXSs6ZcQ3zIp233gRO8SFZgAYbzn6efBfducCpGWdtMGbpqktyAKRiy7FBxLvJxZ4d1WlUWeB6CGTzA7DK0gaB2zcNWosTqQ2C~y4OnHAPFrnDobPVpAyB717uFGckabt6ga5fZ3HHcmEh9McwAv4J7b34a3EpesMnDvfilJTpdNyWaB5xfTv4n2~yMGMOK26xPatH8Up62OVEos~LSAa-GRcqygHi~zfG-VP3zoRmwihfCcn6auIRh5V3aLDX3e6KEaER3prFTf~fNPWxjKAT4NFeW~cuxBFIFKoCA__',
        janmtxt: 'Gayatri \nMantra'),
  ];

  List<CityPickerModel> cityListModelList = <CityPickerModel>[];

  List<Pdf> pdfListModelList = <Pdf>[];

  void getPfdData() async {
    var res = await HttpService()
        .postApi(AppConstants.getBirthJournal, {'birth_journal_id': '1'});
    setState(() {
      pdfListModelList.clear();
      List pdfList = res['data'];
      pdfListModelList.addAll(pdfList.map((e) => Pdf.fromJson(e)));
    });
    print('pdf print >>> $res');
  }

  //Calculator Widget's
  void showOriginalNo() {
    print('object $orignalNo');
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
              height: 500, // Adjust height as needed
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey, blurRadius: 4.0, spreadRadius: 2)
                  ]),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Text(
                      'Original Number',
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                          child: Image.asset(
                              'assets/images/calculator/mulk_ank.png')),
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                            child: Text(
                                '${_nameController.text} Your Mulank reveals your destiny, guiding you to success! ✨'))),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade400,
                            Colors.orange.shade900
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          orignalNo,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ));
  }

  void showRashi() {
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
              height: 500, // Adjust height as needed
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey, blurRadius: 4.0, spreadRadius: 2)
                  ]),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Text(
                      'Rashi Namkshar',
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                          child: Image.asset(
                              'assets/images/calculator/Rashi_namaakshar.gif')),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text('${_nameController.text} Rashi Namkshar'),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8.0),
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.0)),
                            child: const Center(
                                child: Text(
                              'Your Raashi',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8.0),
                            height: 50,
                            width: 100,
                            decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4.0)),
                            child: Center(
                                child: Text(
                              rashinamakRashi,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8.0),
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.0)),
                            child: const Center(
                                child: Text(
                              'Your Naamaakshar',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8.0),
                            height: 50,
                            width: 100,
                            decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4.0)),
                            child: Center(
                                child: Text(
                              rashinamakAlphabet,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ));
  }

  void showKaalsarp() {
    showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        context: context,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter modalSetter) {
              return Container(
                height: 500, // Adjust height as needed
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey, blurRadius: 4.0, spreadRadius: 2)
                    ]),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              _nameController.clear();
                              _dateController.clear();
                              _timeController.clear();
                              countryController.clear();
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                          ),
                          BouncingWidgetInOut(
                            onPressed: () {
                              modalSetter(() {
                                isTranslate = !isTranslate;
                                getKaalsarp(modalSetter);
                              });
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 7),
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: isTranslate
                                      ? Colors.orange
                                      : Colors.transparent,
                                  border: Border.all(
                                      color: isTranslate
                                          ? Colors.transparent
                                          : Colors.orange,
                                      width: 2)),
                              child: Icon(
                                Icons.translate,
                                color:
                                    isTranslate ? Colors.white : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Kaalsarp Dosh',
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                            child: Image.asset(
                                'assets/images/calculator/kaal_sarp_dosh.png')),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Text('Kaalsarp dosh'),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8.0)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8.0),
                              height: 40,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4.0)),
                              child: Center(
                                  child: Text(
                                '${_nameController.text} Kaalsarp dosh',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )),
                            ),
                            const Text(
                              'Is Kalsarpa Dosha Present ?',
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              kaalSarpDoshline,
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  void showPitrdosh() {
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
              height: 500, // Adjust height as needed
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey, blurRadius: 4.0, spreadRadius: 2)
                  ]),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Text(
                      'Pitr Dosh',
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                          child: Image.asset(
                              'assets/images/calculator/pitra_dosh.png')),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Text('Pitr dosh'),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8.0),
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.0),
                                color: Colors.white),
                            child: Center(
                                child: Text(
                              '${_nameController.text} Pitr dosh',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )),
                          ),
                          Text(
                            pitrConclusion,
                            textAlign: TextAlign.center,
                          ),
                          const Divider(
                            color: Colors.grey,
                          ),
                          Text(
                            pitrmessage,
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ));
  }

  void showManglikdosh() {
    showMaterialModalBottomSheet(
        backgroundColor: Colors.white,
        expand: true,
        context: context,
        builder: (context) => Container(
              height: 600, // Adjust height as needed
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey, blurRadius: 4.0, spreadRadius: 2)
                  ]),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Text(
                      'Manglik Dosh',
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                          child: Image.asset(
                              'assets/images/calculator/mandlik_dosh.gif')),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Text('Manglik dosh'),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8.0),
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.0)),
                            child: Center(
                                child: Text(
                              '${_nameController.text} Manglik dosh',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )),
                          ),
                          Center(
                              child: Text(
                                  'Manglik Dosha Percentage : $manglikPercent')),
                          const SizedBox(
                            height: 20.0,
                          ),
                          const Center(
                              child: Text(
                            'जन्म कुंडली ग्रह भाव पर आधारित',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: manglikBased_on_aspect
                                .length, // Number of items in the list
                            itemBuilder: (BuildContext context, int index) {
                              // itemBuilder function returns a widget for each item in the list
                              return Text(manglikBased_on_aspect[index]);
                            },
                          ),
                          const Divider(
                            color: Colors.grey,
                          ),
                          const Center(
                              child: Text(
                            'जन्म कुंडली ग्रह दृष्टि पर आधारित',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: manglikBased_on_house
                                .length, // Number of items in the list
                            itemBuilder: (BuildContext context, int index) {
                              // itemBuilder function returns a widget for each item in the list
                              return Text(manglikBased_on_house[index]);
                            },
                          ),
                          const Divider(
                            color: Colors.grey,
                          ),
                          const Center(
                              child: Text(
                            'मांगलिक विश्लेषण',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                          Text(manglikReport),
                          const Divider(
                            color: Colors.grey,
                          ),
                          const Text(
                            'मांगलिक प्रभाव',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(manglikStatus),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ));
  }

  void showRudraksha() {
    showMaterialModalBottomSheet(
        backgroundColor: Colors.white,
        expand: true,
        context: context,
        builder: (context) => Container(
              height: 600, // Adjust height as needed
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey, blurRadius: 4.0, spreadRadius: 2)
                  ]),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Text(
                      'Rudraksha Suggestion',
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                          child: Image.asset(
                              'assets/images/calculator/rudraksha_suzhav.png')),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Text('Rudraksha Suggestion'),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8.0),
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.0)),
                            child: Center(
                                child: Text(
                              '${_nameController.text} Rudraksha Suggestion',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 100,
                              // child: Image.network("https://dev-mahakal.rizrv.in${rudrakshaImage}"),),
                              child: Image.network(
                                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTqLtZalAz6VmhsVzCyO2GNcZ5oUOTgzA-HMA&s'),
                            ),
                          ),
                          Text(
                            rudrakshaName,
                            textAlign: TextAlign.center,
                          ),
                          const Text(
                            'You are recommended to wear',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            rudrakshaRecommend,
                            textAlign: TextAlign.center,
                          ),
                          const Divider(
                            color: Colors.grey,
                          ),
                          Text(
                            rudrakshaDetail,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ));
  }

  void showVimshottri() {
    showMaterialModalBottomSheet(
      backgroundColor: Colors.white,
      expand: true,
      context: context,
      builder: (context) => DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const SizedBox(height: 30),
            Row(
              children: [
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Text(
              'Vimshottrai Dasha ',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                  child: Image.asset(
                      'assets/images/calculator/vishmottri_dasa.gif')),
            ),
            const SizedBox(height: 10.0),
            const Text('Vimshottari Dasha'),
            const SizedBox(height: 10.0), // Added SizedBox for spacing
            const TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.white,
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.black,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: Colors.orange,
              tabs: [
                Tab(text: 'Vartaman Vimshottari Dasha'),
                Tab(text: 'Vimshottari Maha Dasha'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(8.0)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8.0),
                                height: 40,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4.0)),
                                child: Center(
                                    child: Text(
                                  '${_nameController.text} Vimshottri dosh',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                )),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 40,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Center(
                                        child: Text(
                                      vimshottariPlanet1,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    )),
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Mahadasha',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '$vimshottariStart1 - $vimshottariEnd1',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 40,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Center(
                                        child: Text(
                                      vimshottariPlanet2,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    )),
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Mahadasha',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '$vimshottariStart2 - $vimshottariEnd2',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 40,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Center(
                                        child: Text(
                                      vimshottariPlanet3,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    )),
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Mahadasha',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '$vimshottariStart3 - $vimshottariEnd3',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 40,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Center(
                                        child: Text(
                                      vimshottariPlanet4,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    )),
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Mahadasha',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '$vimshottariStart4 - $vimshottariEnd4',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 40,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Center(
                                        child: Text(
                                      vimshottariPlanet5,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    )),
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Mahadasha',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '$vimshottariStart5 - $vimshottariEnd5',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.orange, width: 1.5),
                            borderRadius: BorderRadius.circular(8.0),
                            image: const DecorationImage(
                                image: AssetImage('assets/images/framebg.png')),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          color: Colors.purple.shade100,
                                          border:
                                              Border.all(color: Colors.orange),
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(7.0))),
                                      child: const Center(
                                          child: Text(
                                        'Planet',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          color: Colors.orange.shade100,
                                          border:
                                              Border.all(color: Colors.orange)),
                                      child: const Center(
                                          child: Text(
                                        'Start date',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          color: Colors.orange.shade100,
                                          border:
                                              Border.all(color: Colors.orange),
                                          borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(7.0))),
                                      child: const Center(
                                          child: Text(
                                        'End Date',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        'Moon',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: const BoxDecoration(
                                        border: Border.symmetric(
                                            horizontal:
                                                BorderSide(color: Colors.grey)),
                                      ),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        'Moon',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: const BoxDecoration(
                                        border: Border.symmetric(
                                            horizontal:
                                                BorderSide(color: Colors.grey)),
                                      ),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        'Moon',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: const BoxDecoration(
                                        border: Border.symmetric(
                                            horizontal:
                                                BorderSide(color: Colors.grey)),
                                      ),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        'Moon',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: const BoxDecoration(
                                        border: Border.symmetric(
                                            horizontal:
                                                BorderSide(color: Colors.grey)),
                                      ),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        'Moon',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: const BoxDecoration(
                                        border: Border.symmetric(
                                            horizontal:
                                                BorderSide(color: Colors.grey)),
                                      ),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        'Moon',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: const BoxDecoration(
                                        border: Border.symmetric(
                                            horizontal:
                                                BorderSide(color: Colors.grey)),
                                      ),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        'Moon',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: const BoxDecoration(
                                        border: Border.symmetric(
                                            horizontal:
                                                BorderSide(color: Colors.grey)),
                                      ),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        'Moon',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: const BoxDecoration(
                                        border: Border.symmetric(
                                            horizontal:
                                                BorderSide(color: Colors.grey)),
                                      ),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius: const BorderRadius.only(
                                              bottomLeft:
                                                  Radius.circular(7.0))),
                                      child: const Center(
                                          child: Text(
                                        'Moon',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: const BoxDecoration(
                                        border: Border.symmetric(
                                            horizontal:
                                                BorderSide(color: Colors.grey)),
                                      ),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius: const BorderRadius.only(
                                              bottomRight:
                                                  Radius.circular(7.0))),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showRatna() {
    showMaterialModalBottomSheet(
      backgroundColor: Colors.white,
      expand: true,
      context: context,
      builder: (context) => DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const SizedBox(height: 30),
            Row(
              children: [
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Text(
              'Ratna Suggestion',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                  child:
                      Image.asset('assets/images/calculator/ratna_suzhav.gif')),
            ),
            const SizedBox(height: 10.0),
            const Text('Ratna Suggestion'),
            const SizedBox(height: 10.0), // Added SizedBox for spacing
            const TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.white,
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.black,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: Colors.orange,
              tabs: [
                Tab(text: 'Life Ratna'),
                Tab(text: 'Profit Ratna'),
                Tab(text: 'Fortune Ratna'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                          height: 100,
                          width: 100,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                'https://blog.brilliance.com/wp-content/uploads/2017/06/perfect-diamond-isolated-on-shiny-background.jpg',
                                fit: BoxFit.fill,
                              ))),
                      const Text(
                        'Diamond',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.shade400, width: 1),
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.transparent,
                        ),
                        child: Table(
                          border: const TableBorder(
                            horizontalInside: BorderSide(color: Colors.cyan),
                          ),
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          columnWidths: const {
                            0: FlexColumnWidth(),
                            1: FlexColumnWidth(),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(7.0),
                                      topLeft: Radius.circular(7.0))),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Substitude',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        lifeGemsName, // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Finger',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        lifeGemsFinger, // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Weight',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        lifeGemsWeight, // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Day',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        lifeGemsDay, // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Deity',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        lifeGemsDeity, // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(7.0),
                                    bottomLeft: Radius.circular(7.0)),
                                color: Colors.white,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Metal',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        lifeGemsMetal, // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                          height: 100,
                          width: 100,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSEHmTdlvOK1kDEOHR51zFqVO4mQlemylYl4uwJXsJr_w&s',
                                fit: BoxFit.fill,
                              ))),
                      const Text(
                        'Diamond',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.shade400, width: 1),
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.transparent,
                        ),
                        child: Table(
                          border: const TableBorder(
                            horizontalInside: BorderSide(color: Colors.cyan),
                          ),
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          columnWidths: const {
                            0: FlexColumnWidth(),
                            1: FlexColumnWidth(),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(7.0),
                                      topLeft: Radius.circular(7.0))),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Substitude',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        beneficGemsName, // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Finger',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        beneficGemsFinger, // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Weight',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        beneficGemsWeight, // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Day',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        beneficGemsDay, // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Deity',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        beneficGemsDeity, // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(7.0),
                                    bottomLeft: Radius.circular(7.0)),
                                color: Colors.white,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Metal',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        beneficGemsMetal, // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                          height: 100,
                          width: 100,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                'https://img1.exportersindia.com/product_images/bc-full/2021/7/8764740/green-diamond-1625890677-5814848.jpeg',
                                fit: BoxFit.fill,
                              ))),
                      const Text(
                        'Diamond',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.shade400, width: 1),
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.transparent,
                        ),
                        child: Table(
                          border: const TableBorder(
                            horizontalInside: BorderSide(color: Colors.cyan),
                          ),
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          columnWidths: const {
                            0: FlexColumnWidth(),
                            1: FlexColumnWidth(),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(7.0),
                                      topLeft: Radius.circular(7.0))),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Substitude',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        luckyGemsName, // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Finger',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        luckyGemsFinger, // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Weight',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        luckyGemsWeight, // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Day',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        luckyGemsDay, // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Deity',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        luckyGemsDeity, // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(7.0),
                                    bottomLeft: Radius.circular(7.0)),
                                color: Colors.white,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Metal',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        luckyGemsMetal, // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showPooja() {
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
              height: 500, // Adjust height as needed
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey, blurRadius: 4.0, spreadRadius: 2)
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Text(
                    'Pooja Suggestion',
                    style: TextStyle(
                        color: Colors.orange,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                        child: Image.asset(
                            'assets/images/calculator/puja_suzhav.gif')),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  const Text('Pooja Suggestion'),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8.0)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8.0),
                          height: 40,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.0)),
                          child: Center(
                              child: Text(
                            '${_nameController.text} Pooja Suggestions',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )),
                        ),
                        Text(
                          poojasuggestion,
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ));
  }

  //Janm Jankari Widget's
  void anukulMantra() {
    showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        context: context,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter modalSetter) {
              return Container(
                height: 500, // Adjust height as needed
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey, blurRadius: 4.0, spreadRadius: 2)
                    ]),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              _nameController.clear();
                              _dateController.clear();
                              _timeController.clear();
                              countryController.clear();
                              selectedGender = 'Gender';
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                          ),
                          BouncingWidgetInOut(
                            onPressed: () {
                              modalSetter(() {
                                isTranslate = !isTranslate;
                                getAnukulMantra(modalSetter);
                              });
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 7),
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: isTranslate
                                      ? Colors.orange
                                      : Colors.transparent,
                                  border: Border.all(
                                      color: isTranslate
                                          ? Colors.transparent
                                          : Colors.orange,
                                      width: 2)),
                              child: Icon(
                                Icons.translate,
                                color:
                                    isTranslate ? Colors.white : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Janm Jankari Se Janiye',
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                            child: Image.asset(
                                'assets/images/allcategories/anukul_mantra_icon_animation.gif')),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Text('Anukul Mantra'),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8.0)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4.0)),
                              child: Center(
                                  child: Text(
                                anukulMantraVar,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  void anukulTime() {
    showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        context: context,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter modalSetter) {
              return Container(
                height: 500, // Adjust height as needed
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey, blurRadius: 4.0, spreadRadius: 2)
                    ]),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              _nameController.clear();
                              _dateController.clear();
                              _timeController.clear();
                              countryController.clear();
                              selectedGender = 'Gender';
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                          ),
                          BouncingWidgetInOut(
                            onPressed: () {
                              modalSetter(() {
                                isTranslate = !isTranslate;
                                getAnukulTime(modalSetter);
                              });
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 7),
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: isTranslate
                                      ? Colors.orange
                                      : Colors.transparent,
                                  border: Border.all(
                                      color: isTranslate
                                          ? Colors.transparent
                                          : Colors.orange,
                                      width: 2)),
                              child: Icon(
                                Icons.translate,
                                color:
                                    isTranslate ? Colors.white : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Janm Jankari Se Janiye',
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                            child: Image.asset(
                                'assets/images/allcategories/anukul_time icon_animation.gif')),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Text('Anukul Time'),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8.0)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4.0)),
                              child: Center(
                                  child: Text(
                                anukulTimeVar,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  void shubhVrat() {
    showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        context: context,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter modalSetter) {
              return Container(
                height: 500, // Adjust height as needed
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey, blurRadius: 4.0, spreadRadius: 2)
                    ]),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              _nameController.clear();
                              _dateController.clear();
                              _timeController.clear();
                              countryController.clear();
                              selectedGender = 'Gender';
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                          ),
                          BouncingWidgetInOut(
                            onPressed: () {
                              modalSetter(() {
                                isTranslate = !isTranslate;
                                getShubhVrat(modalSetter);
                              });
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 7),
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: isTranslate
                                      ? Colors.orange
                                      : Colors.transparent,
                                  border: Border.all(
                                      color: isTranslate
                                          ? Colors.transparent
                                          : Colors.orange,
                                      width: 2)),
                              child: Icon(
                                Icons.translate,
                                color:
                                    isTranslate ? Colors.white : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Janm Jankari Se Janiye',
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                            child: Image.asset(
                                'assets/images/allcategories/vrat and thoyahar icon.png')),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Text('Shubh Vrat'),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8.0)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4.0)),
                              child: Center(
                                  child: Text(
                                subhVratVar,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  void anukulDevWidget() {
    showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        context: context,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter modalSetter) {
              return Container(
                height: 500, // Adjust height as needed
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey, blurRadius: 4.0, spreadRadius: 2)
                    ]),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              _nameController.clear();
                              _dateController.clear();
                              _timeController.clear();
                              countryController.clear();
                              selectedGender = 'Gender';
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                          ),
                          BouncingWidgetInOut(
                            onPressed: () {
                              modalSetter(() {
                                isTranslate = !isTranslate;
                                getAnukulDev(modalSetter);
                              });
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 7),
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: isTranslate
                                      ? Colors.orange
                                      : Colors.transparent,
                                  border: Border.all(
                                      color: isTranslate
                                          ? Colors.transparent
                                          : Colors.orange,
                                      width: 2)),
                              child: Icon(
                                Icons.translate,
                                color:
                                    isTranslate ? Colors.white : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Janm Jankari Se Janiye',
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                            child: Image.asset(
                                'assets/images/allcategories/Anukul dev icon.png')),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Text('Anukul Dev'),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8.0)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4.0)),
                              child: Center(
                                  child: Text(
                                anukulDev,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  //rashi namak
  void getRashiNamak(StateSetter modalSetter) async {
    modalSetter(() => isLoading = true);
    var res = await HttpService().postApi(AppConstants.rashiNamakUrl, {
      'date': _dateController.text,
      'time': '$birthHour:$birthMinute',
      'latitude': calculatorLong,
      'longitude': calculatorLat,
      'timezone': '5.5',
      'language': isTranslate ? 'en' : 'hi'
    });
    print(res);
    modalSetter(() {
      if (res['status'] == 200) {
        rashinamakRashi = res['rashiNamakshar']['sign'].toString();
        rashinamakAlphabet = res['rashiNamakshar']['name_alphabet'].toString();
        _nameController.clear();
        Navigator.pop(context);
        _dateController.clear();
        countryController.clear();
        _timeController.clear();
        showRashi();
        modalSetter(() => isLoading = false);
      } else {
        modalSetter(() => isLoading = false);
        print('error msg');
      }
    });
  }

  //original number API
  void calculateMulank(StateSetter modalSetter, String dob) {
    // Extract digits from the DOB and sum them
    int sum = dob
        .replaceAll(RegExp(r'[^0-9]'), '') // Remove non-numeric characters
        .split('')
        .map(int.parse)
        .reduce((a, b) => a + b);

    // Reduce to a single digit
    while (sum > 9) {
      sum = sum.toString().split('').map(int.parse).reduce((a, b) => a + b);
    }
    Navigator.pop(context);
    modalSetter(() => isLoading = false);
    _nameController.clear();
    _dateController.clear();
    countryController.clear();
    _timeController.clear();
    showOriginalNo();
    setState(() {
      orignalNo = sum.toString();
    });
    // return sum;
  }

  void getOrignalNumber(StateSetter modalSetter) async {
    modalSetter(() => isLoading = true);
    var res = await HttpService().postApi(AppConstants.orignalNumberUrl, {
      'date': _dateController.text,
      'time': '$birthHour:$birthMinute',
      'latitude': calculatorLong,
      'longitude': calculatorLat,
      'timezone': '5.5',
      'language': isTranslate ? 'en' : 'hi'
    });
    print(res);
    setState(() {
      if (res['status'] == 200) {
        orignalNo = res['moolAnk']['name_number'].toString();
        Navigator.pop(context);
        modalSetter(() => isLoading = false);
        _nameController.clear();
        _dateController.clear();
        countryController.clear();
        _timeController.clear();
        showOriginalNo();
      } else {
        print('error msg');
      }
    });
  }

  // Pooja get Api
  void getPooja(StateSetter modalSetter) async {
    modalSetter(() => isLoading = true);
    var res = await HttpService().postApi(AppConstants.prayerSugestionUrl, {
      'date': _dateController.text,
      'time': '$birthHour:$birthMinute',
      'latitude': calculatorLong,
      'longitude': calculatorLat,
      'timezone': '5.5',
      'language': isTranslate ? 'en' : 'hi'
    });
    print(res);
    setState(() {
      if (res['status'] == 200) {
        poojasuggestion = res['prayerSuggestion']['summary'].toString();
        Navigator.pop(context);
        modalSetter(() => isLoading = false);
        _nameController.clear();
        _dateController.clear();
        countryController.clear();
        _timeController.clear();
        showPooja();
      } else {
        print('error msg');
      }
    });
  }

  //Kaalsarp dosh
  void getKaalsarp(StateSetter modalSetter) async {
    modalSetter(() => isLoading = true);
    var res = await HttpService().postApi(AppConstants.kaalSarpUrl, {
      'date': _dateController.text,
      'time': '$birthHour:$birthMinute',
      'latitude': calculatorLong,
      'longitude': calculatorLat,
      'timezone': '5.5',
      'language': isTranslate ? 'en' : 'hi'
    });
    print(res);
    setState(() {
      if (res['status'] == 200) {
        kaalSarpDoshline = res['kalsarpDosha']['one_line'].toString();
        Navigator.pop(context);
        modalSetter(() => isLoading = false);
        showKaalsarp();
      } else {
        print('error msg');
      }
    });
  }

  //PitrDosh dosh
  void getPitrDosh(StateSetter modalSetter) async {
    modalSetter(() => isLoading = true);
    var res = await HttpService().postApi(AppConstants.pitrDoshUrl, {
      'date': _dateController.text,
      'time': '$birthHour:$birthMinute',
      'latitude': calculatorLong,
      'longitude': calculatorLat,
      'timezone': '5.5',
      'language': isTranslate ? 'en' : 'hi'
    });
    print(res);
    setState(() {
      if (res['status'] == 200) {
        pitrConclusion = res['pitraDosha']['conclusion'].toString();
        pitrmessage = res['pitraDosha']['what_is_pitri_dosha'].toString();
        pitrTrueFalse = res['pitraDosha']['is_pitri_dosha_present'].toString();
        print(pitrTrueFalse);
        Navigator.pop(context);
        modalSetter(() => isLoading = false);
        _nameController.clear();
        _dateController.clear();
        _timeController.clear();
        countryController.clear();
        showPitrdosh();
      } else {
        print('error msg');
      }
    });
  }

  // Gems Suggestion
  void getGemsSuggestion(StateSetter modalSetter) async {
    modalSetter(() => isLoading = true);
    var res = await HttpService().postApi(AppConstants.gemSuggestionUrl, {
      'date': _dateController.text,
      'time': '$birthHour:$birthMinute',
      'latitude': calculatorLong,
      'longitude': calculatorLat,
      'timezone': '5.5',
      'language': isTranslate ? 'en' : 'hi'
    });
    print(res);
    setState(() {
      if (res['status'] == 200) {
        // life data
        lifeGemsName = res['gemSuggestion']['LIFE']['name'].toString();
        lifeGemsFinger = res['gemSuggestion']['LIFE']['wear_finger'].toString();
        lifeGemsWeight =
            res['gemSuggestion']['LIFE']['weight_caret'].toString();
        lifeGemsDay = res['gemSuggestion']['LIFE']['wear_day'].toString();
        lifeGemsDeity = res['gemSuggestion']['LIFE']['gem_deity'].toString();
        lifeGemsMetal = res['gemSuggestion']['LIFE']['wear_metal'].toString();
        // benefic data
        beneficGemsName = res['gemSuggestion']['BENEFIC']['name'].toString();
        beneficGemsFinger =
            res['gemSuggestion']['BENEFIC']['wear_finger'].toString();
        beneficGemsWeight =
            res['gemSuggestion']['BENEFIC']['weight_caret'].toString();
        beneficGemsDay = res['gemSuggestion']['BENEFIC']['wear_day'].toString();
        beneficGemsDeity =
            res['gemSuggestion']['BENEFIC']['gem_deity'].toString();
        beneficGemsMetal =
            res['gemSuggestion']['BENEFIC']['wear_metal'].toString();
        // lucky data
        luckyGemsName = res['gemSuggestion']['LUCKY']['name'].toString();
        luckyGemsFinger =
            res['gemSuggestion']['LUCKY']['wear_finger'].toString();
        luckyGemsWeight =
            res['gemSuggestion']['LUCKY']['weight_caret'].toString();
        luckyGemsDay = res['gemSuggestion']['LUCKY']['wear_day'].toString();
        luckyGemsDeity = res['gemSuggestion']['LUCKY']['gem_deity'].toString();
        luckyGemsMetal = res['gemSuggestion']['LUCKY']['wear_metal'].toString();
        Navigator.pop(context);
        modalSetter(() => isLoading = false);
        _nameController.clear();
        _dateController.clear();
        _timeController.clear();
        countryController.clear();
        print(pitrTrueFalse);
        showRatna();
      } else {
        print('error msg');
      }
    });
  }

  //Rudraksh dosh
  void getRudraksh(StateSetter modalSetter) async {
    modalSetter(() => isLoading = true);
    var res = await HttpService().postApi(AppConstants.rudrakshSugestionUrl, {
      'date': _dateController.text,
      'time': '$birthHour:$birthMinute',
      'latitude': calculatorLong,
      'longitude': calculatorLat,
      'timezone': '5.5',
      'language': isTranslate ? 'en' : 'hi'
    });
    print(res);
    setState(() {
      if (res['status'] == 200) {
        rudrakshaImage = res['rudrakshaSuggestion']['img_url'].toString();
        rudrakshaName = res['rudrakshaSuggestion']['name'].toString();
        rudrakshaRecommend = res['rudrakshaSuggestion']['recommend'].toString();
        rudrakshaDetail = res['rudrakshaSuggestion']['detail'].toString();
        Navigator.pop(context);
        modalSetter(() => isLoading = false);
        _nameController.clear();
        countryController.clear();
        _dateController.clear();
        _timeController.clear();
        showRudraksha();
      } else {
        print('error msg');
      }
    });
  }

  //Rudraksh dosh
  void getVimshottari(StateSetter modalSetter) async {
    modalSetter(() => isLoading = true);
    var res = await HttpService().postApi(AppConstants.vimshottariUrl, {
      'date': _dateController.text,
      'time': '$birthHour:$birthMinute',
      'latitude': calculatorLong,
      'longitude': calculatorLat,
      'timezone': '5.5',
      'language': isTranslate ? 'en' : 'hi'
    });
    print(res);
    setState(() {
      if (res['status'] == 200) {
        // Planet data
        vimshottariPlanet1 =
            res['vimshottariDasha']['major']['planet'].toString();
        vimshottariPlanet2 =
            res['vimshottariDasha']['minor']['planet'].toString();
        vimshottariPlanet3 =
            res['vimshottariDasha']['sub_minor']['planet'].toString();
        vimshottariPlanet4 =
            res['vimshottariDasha']['sub_sub_minor']['planet'].toString();
        vimshottariPlanet5 =
            res['vimshottariDasha']['sub_sub_sub_minor']['planet'].toString();

        // start time data
        vimshottariStart1 =
            res['vimshottariDasha']['major']['start'].toString();
        vimshottariStart2 =
            res['vimshottariDasha']['minor']['start'].toString();
        vimshottariStart3 =
            res['vimshottariDasha']['sub_minor']['start'].toString();
        vimshottariStart4 =
            res['vimshottariDasha']['sub_sub_minor']['start'].toString();
        vimshottariStart5 =
            res['vimshottariDasha']['sub_sub_sub_minor']['start'].toString();

        // start time data
        vimshottariEnd1 = res['vimshottariDasha']['major']['end'].toString();
        vimshottariEnd2 = res['vimshottariDasha']['minor']['end'].toString();
        vimshottariEnd3 =
            res['vimshottariDasha']['sub_minor']['end'].toString();
        vimshottariEnd4 =
            res['vimshottariDasha']['sub_sub_minor']['end'].toString();
        vimshottariEnd5 =
            res['vimshottariDasha']['sub_sub_sub_minor']['end'].toString();
        Navigator.pop(context);
        modalSetter(() => isLoading = false);
        _nameController.clear();
        countryController.clear();
        _dateController.clear();
        _timeController.clear();
        showVimshottri();
      } else {
        print('error msg');
      }
    });
  }

  //Manglik dosh
  void getManglikDosh(StateSetter modalSetter) async {
    modalSetter(() => isLoading = true);
    var res = await HttpService().postApi(AppConstants.manglikDoshUrl, {
      'date': _dateController.text,
      'time': '$birthHour:$birthMinute',
      'latitude': calculatorLong,
      'longitude': calculatorLat,
      'timezone': '5.5',
      'language': isTranslate ? 'en' : 'hi'
    });
    print(res);
    setState(() {
      if (res['status'] == 200) {
        manglikBased_on_aspect =
            res['manglikDosh']['manglik_present_rule']['based_on_aspect'];
        manglikBased_on_house =
            res['manglikDosh']['manglik_present_rule']['based_on_house'];
        manglikStatus = res['manglikDosh']['manglik_status'].toString();
        manglikPercent =
            res['manglikDosh']['percentage_manglik_present'].toString();
        manglikReport = res['manglikDosh']['manglik_report'].toString();
        print(manglikBased_on_aspect);
        Navigator.pop(context);
        modalSetter(() => isLoading = false);
        _nameController.clear();
        _dateController.clear();
        _timeController.clear();
        countryController.clear();
        showManglikdosh();
      } else {
        print('error msg');
      }
    });
  }

  //Anukul Mantra API
  void getAnukulMantra(StateSetter modalSetter) async {
    print('Anukul Mantra');
    modalSetter(() => isLoading = true);
    var res = await HttpService().postApi(AppConstants.anukulMantra, {
      'date': _dateController.text,
      'time': '$birthHour:$birthMinute',
      'latitude': calculatorLong,
      'longitude': calculatorLat,
      'timezone': '5.5',
      'language': isTranslate ? 'en' : 'hi'
    });
    print(res);
    modalSetter(() {
      if (res['status'] == 200) {
        anukulMantraVar = res['favMantra']['description'].toString();
        Navigator.pop(context);
        modalSetter(() => isLoading = false);
        anukulMantra();
      } else {
        print('error msg');
      }
    });
  }

  //Anukul Mantra API
  void getAnukulTime(StateSetter modalSetter) async {
    print('Anukul Mantra');
    modalSetter(() => isLoading = true);
    var res = await HttpService().postApi(AppConstants.anukulTime, {
      'date': _dateController.text,
      'time': '$birthHour:$birthMinute',
      'latitude': calculatorLong,
      'longitude': calculatorLat,
      'timezone': '5.5',
      'language': isTranslate ? 'en' : 'hi'
    });
    print(res);
    modalSetter(() {
      if (res['status'] == 200) {
        anukulTimeVar = res['favTime']['description'].toString();
        Navigator.pop(context);
        modalSetter(() => isLoading = false);
        anukulTime();
      } else {
        print('error msg');
      }
    });
  }

  //Shubh Vrat API API
  void getShubhVrat(StateSetter modalSetter) async {
    print('Shubh Vrat');
    modalSetter(() => isLoading = true);
    var res = await HttpService().postApi(AppConstants.shubhVrat, {
      'date': _dateController.text,
      'time': '$birthHour:$birthMinute',
      'latitude': calculatorLong,
      'longitude': calculatorLat,
      'timezone': '5.5',
      'language': isTranslate ? 'en' : 'hi'
    });
    print(res);
    modalSetter(() {
      if (res['status'] == 200) {
        subhVratVar = res['fasts']['description'].toString();
        Navigator.pop(context);
        modalSetter(() => isLoading = false);
        shubhVrat();
      } else {
        print('error msg');
      }
    });
  }

  //Shubh Vrat API API
  void getAnukulDev(StateSetter modalSetter) async {
    print('AnukulDev');
    modalSetter(() => isLoading = true);
    var res = await HttpService().postApi(AppConstants.anukulDev, {
      'date': _dateController.text,
      'time': '$birthHour:$birthMinute',
      'latitude': calculatorLong,
      'longitude': calculatorLat,
      'timezone': '5.5',
      'language': isTranslate ? 'en' : 'hi'
    });
    print(res);
    modalSetter(() {
      if (res['status'] == 200) {
        anukulDev = res['favLord']['description'].toString();
        Navigator.pop(context);
        modalSetter(() => isLoading = false);
        anukulDevWidget();
      } else {
        print('error msg');
      }
    });
  }

  //Country Picker
  final Country _selectedCountry = Country(
    phoneCode: '91',
    countryCode: 'IN',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'India',
    example: '9123456789',
    displayName: 'India',
    displayNameNoCountryCode: 'India',
    e164Key: '91-IN-0',
  );

  //Serach box
  bool searchbox = false;

  List<Muhurat> muhuratModelList = <Muhurat>[];
  List<Astroconsultant> consultaionModelList = <Astroconsultant>[];

  void getConsultaionData() async {
    var res = await HttpService().getApi(AppConstants.consultaionUrl);
    if (res['status'] == 200) {
      setState(() {
        consultaionModelList.clear();
        List consultationList = res['data'];
        consultaionModelList
            .addAll(consultationList.map((e) => Astroconsultant.fromJson(e)));
      });
      print(res);
    } else {
      print('Failed Api Response');
    }
  }

  void getmuhuratData() async {
    var res = await HttpService().getApi(AppConstants.shubhmuhuratUrl);
    if (res['status'] == 200) {
      setState(() {
        muhuratModelList.clear();
        List shubhmuhuratList = res['data'];
        muhuratModelList
            .addAll(shubhmuhuratList.map((e) => Muhurat.fromJson(e)));
      });
      print(res);
    } else {
      print('Failed Api Response');
    }
  }

  // country picker api
  void getCityPick(String value) async {
    print('Entered value: $value');
    print('object');
    cityListModel.clear();
    var response = await http.post(
      Uri.parse('https://geo.vedicrishi.in/places/'),
      body: {
        'country': _selectedCountry.name,
        'name': countryController.text,
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        var result = json.decode(response.body);
        print('Api response $result');
        List listLocation = result;
        cityListModel
            .addAll(listLocation.map((e) => CityPickerModel.fromJson(e)));
        searchbox = true;
        print(searchbox);
      });
    } else {
      print('Failed Api Rresponse');
      setState(() {
        searchbox = false;
      });
      print(searchbox);
    }
  }

  void getMahaVimshottari() async {
    var res = await HttpService().postApi(AppConstants.vimshottariMahaUrl, {
      'date': _dateController.text,
      'time': '$timeHour:$timeMinute',
      'latitude': latitude,
      'longitude': longitude,
      'timezone': '5.5',
      'language': translateEn
    });
    print(res);
    setState(() {
      if (res['status'] == 200) {
        mahaVimshottariModelList.clear();
        List mahaVimshottariList = res['mahaVimshottari'];
        mahaVimshottariModelList.addAll(
            mahaVimshottariList.map((e) => MahaVimshottari.fromJson(e)));
        print(mahaVimshottariList);
      } else {
        print('error msg');
      }
    });
  }

  Route kundliRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const KundliForm(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(2.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.bounceIn;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          transformHitTests: true,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
      reverseTransitionDuration: const Duration(milliseconds: 800),
    );
  }

  Route numeroRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const NumeroFormView(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(2.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.bounceIn;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          transformHitTests: true,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
      reverseTransitionDuration: const Duration(milliseconds: 800),
    );
  }

  Route lalKitabRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const LalKitabForm(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(2.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.bounceIn;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          transformHitTests: true,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
      reverseTransitionDuration: const Duration(milliseconds: 800),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> pdfNameList = [
      getTranslated('download_pdf_1', context) ?? 'pdf',
      getTranslated('download_pdf_2', context) ?? 'pdf',
      getTranslated('download_pdf_3', context) ?? 'pdf',
      getTranslated('download_pdf_4', context) ?? 'pdf',
    ];

    final List<Rashi> calculatorList = [
      Rashi(
          image: 'assets/images/calculator/mulk_ank.png',
          name: getTranslated('mul_ank', context) ?? 'Mul-Ank'),
      Rashi(
          image: 'assets/images/calculator/Rashi_namaakshar.gif',
          name: getTranslated('rashi_namakshar', context) ?? 'Rashi Namakshar'),
      Rashi(
          image: 'assets/images/calculator/kaal_sarp_dosh.png',
          name: getTranslated('kalsarp_dosh', context) ?? 'Kalsarp Dosh'),
      Rashi(
          image: 'assets/images/calculator/mandlik_dosh.gif',
          name: getTranslated('manglik_dosh', context) ?? 'Manglik Dosh'),
      Rashi(
          image: 'assets/images/calculator/pitra_dosh.png',
          name: getTranslated('pitra_dosh', context) ?? 'Pitra Dosh'),
      Rashi(
          image: 'assets/images/calculator/vishmottri_dasa.gif',
          name: getTranslated('vimshotri_dasha', context) ?? 'Vimshotri Dasha'),
      Rashi(
          image: 'assets/images/calculator/ratna_suzhav.gif',
          name: getTranslated('ratna_sujhaw', context) ?? 'Ratna Sujhaw'),
      Rashi(
          image: 'assets/images/calculator/rudraksha_suzhav.png',
          name: getTranslated('rudraksh_sujhaw', context) ?? 'Rudraksh Sujhaw'),
      Rashi(
          image: 'assets/images/calculator/puja_suzhav.gif',
          name: getTranslated('pooja_sujhaw', context) ?? 'Pooja Sujhaw')
    ];

    final List<Rashi> rashiList = [
      Rashi(
          image: 'assets/testImage/rashifall/aries.jpg',
          name: getTranslated('mesh', context) ?? 'Mesh'),
      Rashi(
          image: 'assets/testImage/rashifall/taurus.jpg',
          name: getTranslated('vrashab', context) ?? 'Vrashab'),
      Rashi(
          image: 'assets/testImage/rashifall/gemini.jpg',
          name: getTranslated('mithun', context) ?? 'Mithun'),
      Rashi(
          image: 'assets/testImage/rashifall/cancer.jpg',
          name: getTranslated('kark', context) ?? 'Kark'),
      Rashi(
          image: 'assets/testImage/rashifall/leo.jpg',
          name: getTranslated('singh', context) ?? 'Singh'),
      Rashi(
          image: 'assets/testImage/rashifall/vergo.jpg',
          name: getTranslated('kanya', context) ?? 'Kanya'),
      Rashi(
          image: 'assets/testImage/rashifall/tula.gif',
          name: getTranslated('tula', context) ?? 'Tula'),
      Rashi(
          image: 'assets/testImage/rashifall/scorpio.gif',
          name: getTranslated('vrashik', context) ?? 'Vrashik'),
      Rashi(
          image: 'assets/testImage/rashifall/sagittarius.gif',
          name: getTranslated('dhanu', context) ?? 'Dhanu'),
      Rashi(
          image: 'assets/testImage/rashifall/capricorn.jpg',
          name: getTranslated('makar', context) ?? 'Makar'),
      Rashi(
          image: 'assets/testImage/rashifall/Aquarius.jpg',
          name: getTranslated('kumbh', context) ?? 'Kumbh'),
      Rashi(
          image: 'assets/testImage/rashifall/min.gif',
          name: getTranslated('meen', context) ?? 'Meen'),
    ];
    final size = MediaQuery.of(context).size;
    //category Widget
    Widget categoryWidget(
        {required String image, required String name, required Color color}) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image,
            height: 45,
            width: 45,
          ),
          const SizedBox(height: 3),
          Center(
              child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: titleHeader.copyWith(
                color: color,
                fontSize: Dimensions.fontSizeSmall,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600),
          )),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Astrology',
          style: TextStyle(color: Colors.orange),
        ),
        centerTitle: true,
        actions: [
          BouncingWidgetInOut(
            onPressed: () {
              setState(() {
                translateBtn = !translateBtn;
              });
            },
            bouncingType: BouncingType.bounceInAndOut,
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: translateBtn ? Colors.white : Colors.orange,
                  border: Border.all(color: Colors.orange, width: 2)),
              child: Center(
                child: Icon(Icons.translate,
                    color: translateBtn ? Colors.orange : Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Vedic Astrology
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.purple.shade50,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Container(
                            height: 20,
                            width: 3,
                            color: Colors.orange,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            getTranslated('vaidik_astrology', context) ?? '',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 1000,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: size.width * 0.5,
                              width: size.width * 0.5,
                              child: Card(
                                surfaceTintColor: Colors.white,
                                elevation: 10,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  PageAnimationTransition(
                                                      page: const KundliForm(),
                                                      pageAnimationType:
                                                          RightToLeftTransition()));
                                            },
                                            child: categoryWidget(
                                                image:
                                                    'assets/testImage/categories/janamKundli.png',
                                                name: getTranslated(
                                                        'janm_kundli',
                                                        context) ??
                                                    'Jnam\nKundli',
                                                color: Colors.black)),
                                        Container(
                                          height: size.width * 0.235,
                                          width: 0.7,
                                          color: Colors.grey,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                PageAnimationTransition(
                                                    page:
                                                        const KundaliMatchingView(),
                                                    pageAnimationType:
                                                        RightToLeftTransition()));
                                          },
                                          child: categoryWidget(
                                              image:
                                                  'assets/animated/kundliMilan.gif',
                                              name: getTranslated(
                                                      'kundli_milan',
                                                      context) ??
                                                  'Kundli\nMilan',
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                    const Divider(
                                      height: 0,
                                      color: ColorResources.grey,
                                      thickness: 3,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                PageAnimationTransition(
                                                    page:
                                                        const NumeroFormView(),
                                                    pageAnimationType:
                                                        RightToLeftTransition()));
                                          },
                                          child: SizedBox(
                                              width: size.width * 0.115,
                                              child: categoryWidget(
                                                  image:
                                                      'assets/images/allcategories/Newmrology.png',
                                                  name: getTranslated(
                                                          'numerology',
                                                          context) ??
                                                      'Numerology',
                                                  color: Colors.black)),
                                        ),
                                        Container(
                                          height: size.width * 0.22,
                                          width: 0.7,
                                          color: Colors.grey,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                PageAnimationTransition(
                                                    page: const LalKitabForm(),
                                                    pageAnimationType:
                                                        RightToLeftTransition()));
                                          },
                                          child: SizedBox(
                                              width: size.width * 0.115,
                                              child: categoryWidget(
                                                  image:
                                                      'assets/images/allcategories/LalKitab_icon.png',
                                                  name: getTranslated(
                                                          'lal_kitab',
                                                          context) ??
                                                      'lal kitab',
                                                  color: Colors.black)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            SizedBox(
                              height: size.width * 0.5,
                              width: size.width * 0.5,
                              child: Card(
                                elevation: 2,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      'assets/images/shubh_mahurat_banner.jpg',
                                      fit: BoxFit.cover,
                                    )),
                              ),
                            ),
                            const SizedBox(width: 5),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),



        const SizedBox(
                height: 10,
              ),
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(7),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Container(
                        height: 15,
                        width: 4,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        getTranslated('kundalipdf', context) ?? 'pdf',
                        style: TextStyle(
                            fontSize: Dimensions.fontSizeLarge,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  )),
              const SizedBox(height: 15),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  itemCount: pdfListModelList.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => PdfDetailsView(
                                      pdfId:
                                          pdfListModelList[index].id.toString(),
                                      pdfType: pdfListModelList[index].name,
                                    )));
                      },
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        width: 280,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              spreadRadius: 1,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image with modern styling
                            Stack(
                              children: [
                                Container(
                                  height: 130,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(20)),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.blue.shade50,
                                        Colors.purple.shade50
                                      ],
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(10)),
                                    child: CachedNetworkImage(
                                      imageUrl: pdfListModelList[index].image,
                                      fit: BoxFit.fill,
                                      placeholder: (context, url) => Center(
                                        child: SizedBox(
                                          width: 28,
                                          height: 28,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.blue.shade300,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        color: Colors.grey.shade100,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.insert_drive_file,
                                                  size: 48,
                                                  color: Colors.blue.shade200),
                                              const SizedBox(height: 10),
                                              Text(
                                                'PDF Document',
                                                style: TextStyle(
                                                  color: Colors.blue.shade300,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Modern overlay with corner accent
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    width: 60,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(20),
                                      ),
                                      color: Colors.orange.shade600
                                          .withOpacity(0.9),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.picture_as_pdf,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),

                                // Bottom gradient overlay replicate
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      height: 80,
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20)),
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black45,
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            // // Content area with modern spacing
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title with modern typography
                                  Text(
                                    translateBtn
                                        ? pdfNameList[index]
                                        : pdfNameList[index],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey.shade900,
                                      height: 1.25,
                                      letterSpacing: -0.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const Spacer(),
                                  const Icon(Icons.keyboard_arrow_right,
                                      color: Colors.deepOrange, size: 18)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),

              //Calculator
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(7),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Container(
                        height: 15,
                        width: 4,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        getTranslated('calculator', context) ?? 'Calculator',
                        style: TextStyle(
                            fontSize: Dimensions.fontSizeLarge,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  )),
              const SizedBox(height: 15),
              SizedBox(
                height: size.width * 0.3,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  itemCount: calculatorList.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          dialogIndex = index;
                          calculatorForm(context, index);
                        },
                        child: Column(children: [
                          Container(
                              padding: const EdgeInsets.all(4),
                              margin: const EdgeInsets.only(left: 15),
                              height: size.width / 5.9,
                              width: size.width / 5.9,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context).primaryColor),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Image.asset(calculatorList[index].image)),
                          const SizedBox(
                              height: Dimensions.paddingSizeExtraExtraSmall),
                          Center(
                              child: SizedBox(
                                  width: size.width / 6.5,
                                  child: Text(calculatorList[index].name,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: textRegular.copyWith(
                                          letterSpacing: 0.7,
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: ColorResources.getTextTitle(
                                              context)))))
                        ]));
                  },
                ),
              ),

              // Shubh Mahurat
              Container(
                  color: Colors.orange.shade50,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Container(
                              height: 20,
                              width: 3,
                              color: Colors.orange,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text(
                              'Shubh Muhurat',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            const Spacer(),
                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) =>
                                            const ShubhMuhuratView()),
                                  );
                                },
                                child: const Text(
                                  'View All',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange),
                                ))
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            Container(
                              margin: const EdgeInsets.all(5.0),
                              height: 180,
                              width: 140,
                              decoration: const BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/shubhmuhurat.png'),
                                      fit: BoxFit.fill)),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            muhuratModelList.isEmpty
                                ? shimmerScreen()
                                : SizedBox(
                                    height: 205,
                                    child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: muhuratModelList.length,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (context) =>
                                                        AstroDetailsView(
                                                          productId:
                                                              muhuratModelList[
                                                                      index]
                                                                  .id!,
                                                          isProduct: false,
                                                        )));
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                right: 5, bottom: 10),
                                            width: 140,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                    color: Colors.grey.shade300,
                                                    width: 1.5),
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                      height: 130,
                                                      width: 130,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        color: Colors
                                                            .grey.shade300,
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl:
                                                              '${muhuratModelList[index].thumbnail}',
                                                          fit: BoxFit.cover,
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              const Icon(
                                                                  Icons.error),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Expanded(
                                                      flex: 0,
                                                      child: Text(
                                                        '${translateBtn ? muhuratModelList[index].hiName : muhuratModelList[index].enName}',
                                                        style: const TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black),
                                                        maxLines: 1,
                                                      )),
                                                  Text.rich(TextSpan(children: [
                                                    TextSpan(
                                                        text:
                                                            '₹${muhuratModelList[index].counsellingSellingPrice} ',
                                                        style: const TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.orange)),
                                                    TextSpan(
                                                        text:
                                                            '₹${muhuratModelList[index].counsellingMainPrice}',
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough)),
                                                  ]))
                                                ],
                                              ),
                                            ),
                                          ),

                                          // Container(
                                          //   margin: const EdgeInsets.only(right: 5,bottom: 10),
                                          //   width: 140,
                                          //   decoration: BoxDecoration(
                                          //       color: Colors.white,
                                          //       border: Border.all(color :Colors.grey.shade300,width: 1.5),
                                          //     borderRadius: BorderRadius.circular(4.0)
                                          //   ),
                                          //   child: Padding(
                                          //     padding: const EdgeInsets.all(8.0),
                                          //     child: Column(
                                          //       crossAxisAlignment: CrossAxisAlignment.start,
                                          //       children: [
                                          //         const SizedBox(height: 5,),
                                          //         Center(
                                          //           child: Container(
                                          //             height: 90,
                                          //             width: 130,
                                          //             decoration: BoxDecoration(
                                          //                 borderRadius: BorderRadius.circular(4),
                                          //                 color: Colors.grey.shade300
                                          //             ),
                                          //             child:  Image.network("${muhuratModelList[index].thumbnail}",fit: BoxFit.cover,)
                                          //           ),
                                          //         ),
                                          //
                                          //         Spacer(),
                                          //         Text('${translateBtn ? muhuratModelList[index].hiName : muhuratModelList[index].enName}',style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.black),maxLines: 2,),
                                          //
                                          //         Spacer(),
                                          //         Text.rich(
                                          //             TextSpan(
                                          //                 children: [
                                          //                   TextSpan(
                                          //                       text:'₹${muhuratModelList[index].counsellingSellingPrice} ',style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color:Colors.blue)
                                          //                   ),
                                          //                   TextSpan(
                                          //                       text:'₹${muhuratModelList[index].counsellingMainPrice}',style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.black,decoration: TextDecoration.lineThrough)
                                          //                   ),
                                          //                 ]
                                          //             )
                                          //         )
                                          //
                                          //       ],
                                          //     ),
                                          //   ),
                                          // ),
                                        );
                                      },
                                    ),
                                  ),
                            const SizedBox(
                              width: 10,
                            )
                          ],
                        ),
                      ),
                    ],
                  )),
              const SizedBox(
                height: 15,
              ),

              //Rashifal
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(7),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Container(
                        height: 15,
                        width: 4,
                        decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        getTranslated('rashifal', context) ?? 'Rashifal',
                        style: TextStyle(
                            fontSize: Dimensions.fontSizeLarge,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  )),
              const SizedBox(
                height: 10,
              ),

              SizedBox(
                height: size.width / 3.7,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  itemCount: rashiList.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          Navigator.push(
                              context,
                              PageAnimationTransition(
                                  page: RashiFallView(
                                    rashiNameList: rashiList,
                                    rashiName: rashiList[index].name,
                                    index: index,
                                    context: context,
                                  ),
                                  pageAnimationType: RightToLeftTransition()));
                        },
                        child: Column(children: [
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              radius: 31,
                              child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.white,
                                  backgroundImage:
                                      AssetImage(rashiList[index].image)),
                            ),
                          ),
                          const SizedBox(
                              height: Dimensions.paddingSizeExtraExtraSmall),
                          Center(
                              child: SizedBox(
                                  width: size.width / 6.5,
                                  child: Text(rashiList[index].name,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: textRegular.copyWith(
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.7,
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: ColorResources.getTextTitle(
                                              context)))))
                        ]));
                  },
                ),
              ),
              const SizedBox(
                height: 5,
              ),

              // AStrolofy Consultration
              Container(
                  //color: Color(0xffD1D3FF),
                  color: Colors.deepOrange.shade50,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return const LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.black,
                                    Colors.black,
                                    Colors.transparent,
                                  ],
                                  stops: [0.4, 0.7, 0.9, 1.0],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.dstIn,
                              child: SizedBox(
                                height: 120,
                                width: double.infinity,
                                child: Image.asset(
                                  'assets/images/astrology_banner_image.jpg',
                                  fit: BoxFit.fill,
                                ),
                              )),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Row(
                              children: [
                                Container(
                                  height: 15,
                                  width: 4,
                                  decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  getTranslated('jyotish_paramarsh', context) ??
                                      '',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                const Spacer(),
                                TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (context) =>
                                                const AstroConsultationView()),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2.0, horizontal: 10.0),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          color: Colors.white54),
                                      child: Text(
                                        getTranslated('VIEW_ALL', context) ??
                                            '',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ))
                              ],
                            ),
                          ),
                          Positioned(
                              top: 60,
                              left: 10,
                              right: 10,
                              bottom: 10,
                              child: Text(
                                getTranslated('astrology_consultaion_text',
                                        context) ??
                                    '',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              )),
                        ],
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              height: 205,
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: consultaionModelList.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                              builder: (context) =>
                                                  AstroDetailsView(
                                                      productId:
                                                          consultaionModelList[
                                                                  index]
                                                              .id!,
                                                      isProduct: true)));
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          top: 5, right: 5, bottom: 10),
                                      width: 140,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: Colors.grey.shade300,
                                              width: 1.5),
                                          borderRadius:
                                              BorderRadius.circular(8.0)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Container(
                                                height: 130,
                                                width: 130,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color: Colors.grey.shade300,
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        '${consultaionModelList[index].thumbnail}',
                                                    fit: BoxFit.cover,
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        const Icon(Icons.error),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Expanded(
                                                flex: 0,
                                                child: Text(
                                                  '${translateBtn ? consultaionModelList[index].hiName : consultaionModelList[index].enName}',
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black),
                                                  maxLines: 1,
                                                )),
                                            Text.rich(TextSpan(children: [
                                              TextSpan(
                                                  text:
                                                      '₹${consultaionModelList[index].counsellingSellingPrice} ',
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.orange)),
                                              TextSpan(
                                                  text:
                                                      '₹${consultaionModelList[index].counsellingMainPrice}',
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                      decoration: TextDecoration
                                                          .lineThrough)),
                                            ]))
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Container(
                                    //   margin: const EdgeInsets.only(right: 5,bottom: 10),
                                    //   width: 140,
                                    //   decoration: BoxDecoration(
                                    //       color: Colors.white,
                                    //       border: Border.all(color :Colors.grey.shade300,width: 1.5),
                                    //     borderRadius: BorderRadius.circular(4.0)
                                    //   ),
                                    //   child: Padding(
                                    //     padding: const EdgeInsets.all(8.0),
                                    //     child: Column(
                                    //       crossAxisAlignment: CrossAxisAlignment.start,
                                    //       children: [
                                    //         const SizedBox(height: 5,),
                                    //         Center(
                                    //           child: Container(
                                    //             height: 90,
                                    //             width: 130,
                                    //             decoration: BoxDecoration(
                                    //                 borderRadius: BorderRadius.circular(4),
                                    //                 color: Colors.grey.shade300
                                    //             ),
                                    //             child:  Image.network("${muhuratModelList[index].thumbnail}",fit: BoxFit.cover,)
                                    //           ),
                                    //         ),
                                    //
                                    //         Spacer(),
                                    //         Text('${translateBtn ? muhuratModelList[index].hiName : muhuratModelList[index].enName}',style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.black),maxLines: 2,),
                                    //
                                    //         Spacer(),
                                    //         Text.rich(
                                    //             TextSpan(
                                    //                 children: [
                                    //                   TextSpan(
                                    //                       text:'₹${muhuratModelList[index].counsellingSellingPrice} ',style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color:Colors.blue)
                                    //                   ),
                                    //                   TextSpan(
                                    //                       text:'₹${muhuratModelList[index].counsellingMainPrice}',style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.black,decoration: TextDecoration.lineThrough)
                                    //                   ),
                                    //                 ]
                                    //             )
                                    //         )
                                    //
                                    //       ],
                                    //     ),
                                    //   ),
                                    // ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            )
                          ],
                        ),
                      ),
                    ],
                  )),
              const SizedBox(
                height: 15,
              ),

              //JanmJankari
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(7),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Container(
                        height: 15,
                        width: 4,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        getTranslated('janm_jankari', context) ??
                            'Janm Jankari Se Janiye',
                        style: TextStyle(
                            fontSize: Dimensions.fontSizeLarge,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  )),
              const SizedBox(
                height: 10,
              ),

              Container(
                margin: const EdgeInsets.all(7),
                width: double.infinity,
                child: Card(
                  surfaceTintColor: Colors.white,
                  elevation: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                          onTap: () => janmJankariForm(context, 0),
                          child: categoryWidget(
                              image:
                                  'assets/images/allcategories/Ankul mantra icon.png',
                              name: getTranslated('anukul_mantra', context) ??
                                  'Anukul\nMantra',
                              color: Colors.black)),
                      Container(
                        height: 95,
                        width: 0.7,
                        color: Colors.grey,
                      ),
                      InkWell(
                          onTap: () => janmJankariForm(context, 1),
                          child: categoryWidget(
                              image:
                                  'assets/images/allcategories/vrat and thoyahar icon.png',
                              name: getTranslated('shubh_vrat', context) ??
                                  'Shubh\nVrat',
                              color: Colors.black)),
                      Container(
                        height: 95,
                        width: 0.7,
                        color: Colors.grey,
                      ),
                      InkWell(
                          onTap: () {
                            janmJankariForm(context, 2);
                          },
                          child: categoryWidget(
                              image:
                                  'assets/images/allcategories/Anukul time.png',
                              name: getTranslated('gayatri_mantra', context) ??
                                  'Anukul\nMantra',
                              color: Colors.black)),
                      Container(
                        height: 95,
                        width: 0.7,
                        color: Colors.grey,
                      ),
                      InkWell(
                          onTap: () => janmJankariForm(context, 3),
                          child: categoryWidget(
                              image:
                                  'assets/images/allcategories/Anukul dev icon.png',
                              name: getTranslated('anukul_dev', context) ??
                                  'Gayatri\nMantra',
                              color: Colors.black)),
                    ],
                  ),
                ),
              ),

              // Banner
              InkWell(
                onTap: (){
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const TripBookingPage(type: 'one-way',),
                    ),
                  );
                },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [

                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                            child: Image.asset('assets/images/astrology_banner_.jpg')),

                        if(AppConstants.baseUrl ==  'https://sit.resrv.in')
                          Positioned(
                            top: 12,
                            left: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets
                                  .symmetric(
                                  horizontal: 10,
                                  vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black
                                    .withOpacity(
                                    0.6), // semi-transparent bg
                                borderRadius:
                                BorderRadius
                                    .circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(
                                        0.4),
                                    blurRadius: 6,
                                    offset:
                                    const Offset(
                                        2, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: const Text(
                                  'Self drive',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                    FontWeight.bold,
                                    color: Colors
                                        .amberAccent, // highlighted text
                                    shadows: [
                                      Shadow(
                                        blurRadius: 4,
                                        color:
                                        Colors.black,
                                        offset:
                                        Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
              ),

              InkWell(
                  onTap: (){
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const HotelBottomBar(pageIndex: 0,),
                        )
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset('assets/images/e_comm_banner.jpg')),

                        if(AppConstants.baseUrl ==  'https://sit.resrv.in')
                          Positioned(
                            top: 12,
                            left: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets
                                  .symmetric(
                                  horizontal: 10,
                                  vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black
                                    .withOpacity(
                                    0.6), // semi-transparent bg
                                borderRadius:
                                BorderRadius
                                    .circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(
                                        0.4),
                                    blurRadius: 6,
                                    offset:
                                    const Offset(
                                        2, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: const Text(
                                  'Hotel',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                    FontWeight.bold,
                                    color: Colors
                                        .amberAccent, // highlighted text
                                    shadows: [
                                      Shadow(
                                        blurRadius: 4,
                                        color:
                                        Colors.black,
                                        offset:
                                        Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
              ),

              InkWell(
                  onTap: (){
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => AllPanditPage(isEngView: true, scrollController: scrollController, isHome: true,),
                        )
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset('assets/images/e_comm_banner.jpg')),

                        if(AppConstants.baseUrl ==  'https://sit.resrv.in')
                          Positioned(
                            top: 12,
                            left: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets
                                  .symmetric(
                                  horizontal: 10,
                                  vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black
                                    .withOpacity(
                                    0.6), // semi-transparent bg
                                borderRadius:
                                BorderRadius
                                    .circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(
                                        0.4),
                                    blurRadius: 6,
                                    offset:
                                    const Offset(
                                        2, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: const Text(
                                  'Gururji',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                    FontWeight.bold,
                                    color: Colors
                                        .amberAccent, // highlighted text
                                    shadows: [
                                      Shadow(
                                        blurRadius: 4,
                                        color:
                                        Colors.black,
                                        offset:
                                        Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
              ),

              InkWell(
                  onTap: (){
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const TickitBookingHome(),
                        ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset('assets/images/e_comm_banner.jpg')),

                        if(AppConstants.baseUrl ==  'https://sit.resrv.in')
                          Positioned(
                            top: 12,
                            left: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets
                                  .symmetric(
                                  horizontal: 10,
                                  vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black
                                    .withOpacity(
                                    0.6), // semi-transparent bg
                                borderRadius:
                                BorderRadius
                                    .circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(
                                        0.4),
                                    blurRadius: 6,
                                    offset:
                                    const Offset(
                                        2, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: const Text(
                                  'Ticket',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                    FontWeight.bold,
                                    color: Colors
                                        .amberAccent, // highlighted text
                                    shadows: [
                                      Shadow(
                                        blurRadius: 4,
                                        color:
                                        Colors.black,
                                        offset:
                                        Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void calculatorForm(BuildContext context, int bottomSheetIndex) {
    //Country Picker
    Country selectedCountry = Country(
      phoneCode: '91',
      countryCode: 'IN',
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: 'India',
      example: '9123456789',
      displayName: 'India',
      displayNameNoCountryCode: 'India',
      e164Key: '91-IN-0',
    );

    final List calculatorTitleList = [
      getTranslated('mul_ank', context) ?? 'Mul-Ank',
      getTranslated('rashi_namakshar', context) ?? 'Rashi Namakshar',
      getTranslated('kalsarp_dosh', context) ?? 'Kalsarp Dosh',
      getTranslated('manglik_dosh', context) ?? 'Manglik Dosh',
      getTranslated('pitra_dosh', context) ?? 'Pitra Dosh',
      getTranslated('vimshotri_dasha', context) ?? 'Vimshotri Dasha',
      getTranslated('ratna_sujhaw', context) ?? 'Ratna Sujhaw',
      getTranslated('rudraksh_sujhaw', context) ?? 'Rudraksh Sujhaw',
      getTranslated('pooja_sujhaw', context) ?? 'Pooja Sujhaw'
    ];

    //Serach box
    bool searchbox = false;

    void searchBox(StateSetter modalSetter) {
      if (countryController.text.length > 1) {
        modalSetter(() {
          searchbox = true;
        });
      } else if (countryController.text.isEmpty) {
        modalSetter(() {
          searchbox = false;
        });
      }
      print('serchbox $searchbox');
    }

    // country picker api
    void getCityPick(StateSetter modalSetter) async {
      print('object');
      cityListModel.clear();
      var response = await http.post(
        Uri.parse('https://geo.vedicrishi.in/places/'),
        body: {
          'country': selectedCountry.name,
          'name': countryController.text,
        },
      );
      if (response.statusCode == 200) {
        modalSetter(() {
          var result = json.decode(response.body);
          print('Api response $result');
          List listLocation = result;
          cityListModel
              .addAll(listLocation.map((e) => CityPickerModel.fromJson(e)));
        });
      } else {
        print('Failed Api Rresponse');
      }
    }

    // button functionality
    void submitForm(StateSetter modalSetter) {
      if (dialogIndex == 1) {
        getRashiNamak(modalSetter);
      } else if (dialogIndex == 2) {
        getKaalsarp(modalSetter);
      } else if (dialogIndex == 3) {
        getManglikDosh(modalSetter);
      } else if (dialogIndex == 4) {
        getPitrDosh(modalSetter);
      } else if (dialogIndex == 5) {
        getVimshottari(modalSetter);
      } else if (dialogIndex == 0) {
        calculateMulank(modalSetter, _dateController.text);
      } else if (dialogIndex == 6) {
        getGemsSuggestion(modalSetter);
      } else if (dialogIndex == 7) {
        getRudraksh(modalSetter);
      } else if (dialogIndex == 8) {
        getPooja(modalSetter);
      }
    }

    final List<String> genderOptions = ['Gender', 'Male', 'Female', 'Others'];

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter modalSetter) {
            return Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                            strokeWidth: 3,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.document_scanner_outlined,
                                  color: Colors.orange,
                                ),
                                const SizedBox(
                                  width: 8.0,
                                ),
                                Text(
                                  '${calculatorTitleList[bottomSheetIndex]}',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            // name
                            TextField(
                              cursorColor: Theme.of(context).primaryColor,
                              controller: _nameController,
                              style:
                                  const TextStyle(fontFamily: 'Roboto-Regular'),
                              decoration: InputDecoration(
                                hintText: 'Name',
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 1),
                                ),
                                suffixIcon: const Icon(Icons.person_outline,
                                    color: Colors.grey, size: 25),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            //Gender
                            // Container(
                            //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            //   margin: const EdgeInsets.only(top: 2, bottom: 10),
                            //   width: double.infinity,
                            //   decoration: BoxDecoration(
                            //     color: Colors.white,
                            //     borderRadius: BorderRadius.circular(8),
                            //     border: Border.all(color: Theme.of(context).primaryColor),
                            //   ),
                            //   child: DropdownButtonHideUnderline(
                            //     child: DropdownButton<String>(
                            //       value: selectedGender,
                            //       hint: const Text('Select Gender'),
                            //       items: genderOptions.map((String value) {
                            //         return DropdownMenuItem<String>(
                            //           value: value,
                            //           child: Text(value),
                            //         );
                            //       }).toList(),
                            //       onChanged: (String? newValue) {
                            //         modalSetter(() {
                            //           selectedGender = newValue!;
                            //         });
                            //       },
                            //     ),
                            //   ),
                            // ),

                            const Text(
                              'Gender',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Radio(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  activeColor: Colors.orange,
                                  value: 1, // Value assigned to "Male"
                                  groupValue: _maleValue,
                                  onChanged: (value) {
                                    modalSetter(() {
                                      _maleValue = value
                                          as int; // Cast as int for safety
                                    });
                                  },
                                ),
                                const Row(
                                  children: [
                                    Text('Male'),
                                    Icon(
                                      Icons.male,
                                      size: 15,
                                    )
                                  ],
                                ),
                                Radio(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  value: 2, // Value assigned to "Female"
                                  activeColor: Colors.orange,
                                  groupValue: _maleValue,
                                  onChanged: (value) {
                                    modalSetter(() {
                                      _maleValue = value
                                          as int; // Cast as int for safety
                                    });
                                  },
                                ),
                                const Row(
                                  children: [
                                    Text('Female'),
                                    Icon(
                                      Icons.female,
                                      size: 15,
                                    )
                                  ],
                                ),
                                Radio(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  value: 3, // Value assigned to "Female"
                                  activeColor: Colors.orange,
                                  groupValue: _maleValue,
                                  onChanged: (value) {
                                    modalSetter(() {
                                      _maleValue = value
                                          as int; // Cast as int for safety
                                    });
                                  },
                                ),
                                const Row(
                                  children: [
                                    Text('Others'),
                                    Icon(
                                      Icons.person_2_outlined,
                                      size: 15,
                                    )
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            // Birth Date
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Theme.of(context).primaryColor),
                              ),
                              child: TextButton(
                                onPressed: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1901),
                                    lastDate: DateTime.now(),
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: ThemeData.light().copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: Colors.white,
                                            onPrimary:
                                                Theme.of(context).primaryColor,
                                            surface: const Color(0xFFFFF7EC),
                                            onSurface:
                                                Theme.of(context).primaryColor,
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Theme.of(context)
                                                  .primaryColor,
                                              backgroundColor: Colors.white,
                                            ),
                                          ),
                                          dialogTheme: const DialogThemeData(
                                              backgroundColor:
                                                  Color(0xFFFFF7EC)),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (pickedDate != null) {
                                    modalSetter(() {
                                      _dateController.text =
                                          DateFormat('dd/MM/yyyy')
                                              .format(pickedDate);
                                    });
                                  }
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  alignment: Alignment.centerLeft,
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _dateController.text.isEmpty
                                        ? const Text(
                                            'Select DOB',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          )
                                        : Text(
                                            _dateController.text,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                    const Icon(Icons.calendar_month_outlined,
                                        color: Colors.grey, size: 25),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8.0),

                            // Birth Timing
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Theme.of(context).primaryColor),
                              ),
                              child: TextButton(
                                onPressed: () async {
                                  TimeOfDay? pickedTime = await showTimePicker(
                                    initialTime: TimeOfDay.now(),
                                    context: context,
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: ThemeData.light().copyWith(
                                          timePickerTheme: TimePickerThemeData(
                                            dialHandColor: Colors.black12,
                                            dialTextStyle: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            dialTextColor:
                                                Theme.of(context).primaryColor,
                                            dialBackgroundColor: Colors.white,
                                            dayPeriodColor: Colors.white,
                                            dayPeriodTextColor:
                                                Theme.of(context).primaryColor,
                                            backgroundColor:
                                                const Color(0xFFFFF7EC),
                                            hourMinuteTextColor:
                                                Theme.of(context).primaryColor,
                                            hourMinuteColor: Colors.white,
                                            inputDecorationTheme:
                                                InputDecorationTheme(
                                              border: InputBorder.none,
                                              filled: true,
                                              fillColor: Colors.white,
                                              hintStyle: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                              labelStyle: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                            ),
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Theme.of(context)
                                                  .primaryColor,
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                            ),
                                          ),
                                          dialogTheme: const DialogThemeData(
                                              backgroundColor: Colors.white),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (pickedTime != null) {
                                    modalSetter(() {
                                      birthHour = pickedTime.hour.toString();
                                      birthMinute =
                                          pickedTime.minute.toString();
                                      _timeController.text =
                                          pickedTime.format(context);
                                    });
                                  }
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  alignment: Alignment.centerLeft,
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _timeController.text.isEmpty
                                        ? const Text(
                                            'Select Time',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          )
                                        : Text(
                                            _timeController.text,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                    const Icon(Icons.timelapse_outlined,
                                        color: Colors.grey, size: 25),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8.0),

                            // country city
                            Row(
                              children: [
                                // location
                                Expanded(
                                  flex: 1,
                                  child: InkWell(
                                    onTap: () {
                                      showCountryPicker(
                                        context: context,
                                        showPhoneCode:
                                            false, // optional. Shows phone code before the country name.
                                        onSelect: (Country country) {
                                          modalSetter(() {
                                            selectedCountry = country;
                                          });
                                        },
                                      );
                                    },
                                    child: Container(
                                      height: 50,
                                      margin: const EdgeInsets.only(top: 2),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                      child: Center(
                                        child: Text(
                                          selectedCountry != null
                                              ? selectedCountry.flagEmoji
                                              : 'No country selected',
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width: 6.0,
                                ),
                                // country
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    controller: countryController,
                                    onChanged: (value) {
                                      getCityPick(modalSetter);
                                      searchBox(modalSetter);
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Search City',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 10.0),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 1),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 1),
                                      ),
                                      suffixIcon: const Icon(Icons.location_pin,
                                          color: Colors.grey, size: 25),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            //location box
                            AnimatedContainer(
                              duration: const Duration(
                                  milliseconds:
                                      600), // Adjust animation duration for smooth transition
                              curve: Curves
                                  .easeInCirc, // Customize animation curve if needed
                              padding: const EdgeInsets.all(8.0),
                              height: searchbox == false ? 0 : 160,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Theme.of(context).primaryColor),
                                  borderRadius: BorderRadius.circular(6.0)),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: cityListModel
                                    .length, // Number of items in the list
                                itemBuilder: (BuildContext context, int index) {
                                  // itemBuilder function returns a widget for each item in the list
                                  return SingleChildScrollView(
                                    child: InkWell(
                                      onTap: () {
                                        modalSetter(() {
                                          countryController.text =
                                              cityListModel[index]
                                                  .place
                                                  .toString();
                                          searchbox = false;
                                        });
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.location_pin,
                                                  size: 20,
                                                  color: Colors.black54),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.3,
                                                child: Text(
                                                  cityListModel[index].place,
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontSize: 16),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider(
                                            color: Colors.grey,
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            // button
                            ElevatedButton(
                              onPressed: () {
                                if (_nameController.text.isEmpty ||
                                    _dateController.text.isEmpty ||
                                    countryController.text.isEmpty ||
                                    _timeController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Incorrect Form Details',
                                          style:
                                              TextStyle(fontSize: 20)), // Text
                                      backgroundColor: Colors.red,
                                      dismissDirection: DismissDirection.up,
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height -
                                              150,
                                          left: 10,
                                          right: 10), // EdgeInsets.only
                                    ),
                                  );
                                } else {
                                  submitForm(modalSetter);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.black,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Continue',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.28),
                              ),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                          ],
                        ),
                ),
              ),
            );
          });
        });
  }

  void janmJankariForm(BuildContext context, int bottomSheetIndex) {
    //Country Picker
    Country selectedCountry = Country(
      phoneCode: '91',
      countryCode: 'IN',
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: 'India',
      example: '9123456789',
      displayName: 'India',
      displayNameNoCountryCode: 'India',
      e164Key: '91-IN-0',
    );

    final List calculatorTitleList = [
      'Anukul Mantra',
      'Shubh Vrat',
      'Anukul Time',
      'Anukul Dev',
    ];

    //Serach box
    bool searchbox = false;

    void searchBox(StateSetter modalSetter) {
      if (countryController.text.length > 1) {
        modalSetter(() {
          searchbox = true;
        });
      } else if (countryController.text.isEmpty) {
        modalSetter(() {
          searchbox = false;
        });
      }
      print('serchbox $searchbox');
    }

    // country picker api
    void getCityPick(StateSetter modalSetter) async {
      print('object');
      cityListModel.clear();
      var response = await http.post(
        Uri.parse('https://geo.vedicrishi.in/places/'),
        body: {
          'country': selectedCountry.name,
          'name': countryController.text,
        },
      );
      if (response.statusCode == 200) {
        modalSetter(() {
          var result = json.decode(response.body);
          print('Api response $result');
          List listLocation = result;
          cityListModel
              .addAll(listLocation.map((e) => CityPickerModel.fromJson(e)));
        });
      } else {
        print('Failed Api Rresponse');
      }
    }

    void submitForm(StateSetter modalSetter) {
      switch (bottomSheetIndex) {
        case 0:
          getAnukulMantra(modalSetter);
          break;
        case 1:
          getShubhVrat(modalSetter);
          break;
        case 2:
          getAnukulTime(modalSetter);
          break;
        case 3:
          getAnukulDev(modalSetter);
          break;
      }
    }

    final List<String> genderOptions = ['Gender', 'Male', 'Female', 'Others'];

    // button functionality
    // void submitForm(StateSetter modalSetter) {
    //   if (dialogIndex == 0) {
    //     getAnukulMantra(modalSetter);
    //   } else if (dialogIndex == 1) {
    //     print("shubhVrat");
    //     shubhVrat();
    //   } else if (dialogIndex == 2) {
    //     shubhVrat();
    //   } else if (dialogIndex == 3) {
    //     getAnukulDev(modalSetter);
    //   }
    // }

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter modalSetter) {
            return Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                            strokeWidth: 3,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.document_scanner_outlined,
                                  color: Colors.orange,
                                ),
                                const SizedBox(
                                  width: 8.0,
                                ),
                                Text(
                                  '${calculatorTitleList[bottomSheetIndex]}',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            // name
                            TextField(
                              cursorColor: Theme.of(context).primaryColor,
                              controller: _nameController,
                              style:
                                  const TextStyle(fontFamily: 'Roboto-Regular'),
                              decoration: InputDecoration(
                                hintText: 'Name',
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 1),
                                ),
                                suffixIcon: const Icon(Icons.person_outline,
                                    color: Colors.grey, size: 25),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            //Gender
                            // Container(
                            //   padding:
                            //       const EdgeInsets.symmetric(horizontal: 10.0),
                            //   margin: const EdgeInsets.only(top: 2, bottom: 10),
                            //   width: double.infinity,
                            //   decoration: BoxDecoration(
                            //     color: Colors.white,
                            //     borderRadius: BorderRadius.circular(8),
                            //     border: Border.all(
                            //         color: Theme.of(context).primaryColor),
                            //   ),
                            //   child: DropdownButtonHideUnderline(
                            //     child: DropdownButton<String>(
                            //       value: selectedGender,
                            //       hint: Text('Select Gender'),
                            //       items: genderOptions.map((String value) {
                            //         return DropdownMenuItem<String>(
                            //           value: value,
                            //           child: Text(value),
                            //         );
                            //       }).toList(),
                            //       onChanged: (String? newValue) {
                            //         modalSetter(() {
                            //           selectedGender = newValue!;
                            //         });
                            //       },
                            //     ),
                            //   ),
                            // ),

                            const Text(
                              'Gender',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Radio(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  activeColor: Colors.orange,
                                  value: 1, // Value assigned to "Male"
                                  groupValue: _maleValue,
                                  onChanged: (value) {
                                    modalSetter(() {
                                      _maleValue = value
                                          as int; // Cast as int for safety
                                    });
                                  },
                                ),
                                const Row(
                                  children: [
                                    Text('Male'),
                                    Icon(
                                      Icons.male,
                                      size: 15,
                                    )
                                  ],
                                ),
                                Radio(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  value: 2, // Value assigned to "Female"
                                  activeColor: Colors.orange,
                                  groupValue: _maleValue,
                                  onChanged: (value) {
                                    modalSetter(() {
                                      _maleValue = value
                                          as int; // Cast as int for safety
                                    });
                                  },
                                ),
                                const Row(
                                  children: [
                                    Text('Female'),
                                    Icon(
                                      Icons.female,
                                      size: 15,
                                    )
                                  ],
                                ),
                                Radio(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  value: 3, // Value assigned to "Female"
                                  activeColor: Colors.orange,
                                  groupValue: _maleValue,
                                  onChanged: (value) {
                                    modalSetter(() {
                                      _maleValue = value
                                          as int; // Cast as int for safety
                                    });
                                  },
                                ),
                                const Row(
                                  children: [
                                    Text('Others'),
                                    Icon(
                                      Icons.person_2_outlined,
                                      size: 15,
                                    )
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),

                            // Birth Date
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Theme.of(context).primaryColor),
                              ),
                              child: TextButton(
                                onPressed: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1901),
                                    lastDate: DateTime(2101),
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: ThemeData.light().copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: Colors.white,
                                            onPrimary:
                                                Theme.of(context).primaryColor,
                                            surface: const Color(0xFFFFF7EC),
                                            onSurface:
                                                Theme.of(context).primaryColor,
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Theme.of(context)
                                                  .primaryColor,
                                              backgroundColor: Colors.white,
                                            ),
                                          ),
                                          dialogTheme: const DialogThemeData(
                                              backgroundColor:
                                                  Color(0xFFFFF7EC)),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (pickedDate != null) {
                                    modalSetter(() {
                                      _dateController.text =
                                          DateFormat('dd/MM/yyyy')
                                              .format(pickedDate);
                                    });
                                  }
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  alignment: Alignment.centerLeft,
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _dateController.text.isEmpty
                                        ? const Text(
                                            'Select Date',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          )
                                        : Text(
                                            _dateController.text,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                    const Icon(Icons.calendar_month_outlined,
                                        color: Colors.grey, size: 25),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8.0),

                            // Birth Timing
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Theme.of(context).primaryColor),
                              ),
                              child: TextButton(
                                onPressed: () async {
                                  TimeOfDay? pickedTime = await showTimePicker(
                                    initialTime: TimeOfDay.now(),
                                    context: context,
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: ThemeData.light().copyWith(
                                          timePickerTheme: TimePickerThemeData(
                                            dialHandColor: Colors.black12,
                                            dialTextStyle: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            dialTextColor:
                                                Theme.of(context).primaryColor,
                                            dialBackgroundColor: Colors.white,
                                            dayPeriodColor: Colors.white,
                                            dayPeriodTextColor:
                                                Theme.of(context).primaryColor,
                                            backgroundColor:
                                                const Color(0xFFFFF7EC),
                                            hourMinuteTextColor:
                                                Theme.of(context).primaryColor,
                                            hourMinuteColor: Colors.white,
                                            inputDecorationTheme:
                                                InputDecorationTheme(
                                              border: InputBorder.none,
                                              filled: true,
                                              fillColor: Colors.white,
                                              hintStyle: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                              labelStyle: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                            ),
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Theme.of(context)
                                                  .primaryColor,
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                            ),
                                          ),
                                          dialogTheme: const DialogThemeData(
                                              backgroundColor: Colors.white),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (pickedTime != null) {
                                    modalSetter(() {
                                      print(pickedTime);
                                      birthHour = pickedTime.hour.toString();
                                      birthMinute =
                                          pickedTime.minute.toString();
                                      _timeController.text =
                                          pickedTime.format(context);
                                    });
                                  }
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  alignment: Alignment.centerLeft,
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _timeController.text.isEmpty
                                        ? const Text(
                                            'Select Time',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          )
                                        : Text(
                                            _timeController.text,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                    const Icon(Icons.timelapse_outlined,
                                        color: Colors.grey, size: 25),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8.0),

                            // country city
                            Row(
                              children: [
                                // location
                                Expanded(
                                  flex: 1,
                                  child: InkWell(
                                    onTap: () {
                                      showCountryPicker(
                                        context: context,
                                        showPhoneCode:
                                            false, // optional. Shows phone code before the country name.
                                        onSelect: (Country country) {
                                          modalSetter(() {
                                            selectedCountry = country;
                                          });
                                        },
                                      );
                                    },
                                    child: Container(
                                      height: 50,
                                      margin: const EdgeInsets.only(top: 2),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                      child: Center(
                                        child: Text(
                                          selectedCountry != null
                                              ? selectedCountry.flagEmoji
                                              : 'No country selected',
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width: 6.0,
                                ),
                                // country
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    controller: countryController,
                                    onChanged: (value) {
                                      getCityPick(modalSetter);
                                      searchBox(modalSetter);
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Search City',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 10.0),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 1),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 1),
                                      ),
                                      suffixIcon: const Icon(Icons.location_pin,
                                          color: Colors.grey, size: 25),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            //location box
                            AnimatedContainer(
                              duration: const Duration(
                                  milliseconds:
                                      600), // Adjust animation duration for smooth transition
                              curve: Curves
                                  .easeInCirc, // Customize animation curve if needed
                              padding: const EdgeInsets.all(8.0),
                              height: searchbox == false ? 0 : 160,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Theme.of(context).primaryColor),
                                  borderRadius: BorderRadius.circular(6.0)),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: cityListModel
                                    .length, // Number of items in the list
                                itemBuilder: (BuildContext context, int index) {
                                  // itemBuilder function returns a widget for each item in the list
                                  return SingleChildScrollView(
                                    child: InkWell(
                                      onTap: () {
                                        modalSetter(() {
                                          calculatorLong = cityListModel[index]
                                              .latitude
                                              .toString();
                                          calculatorLat = cityListModel[index]
                                              .longitude
                                              .toString();
                                          countryController.text =
                                              cityListModel[index]
                                                  .place
                                                  .toString();
                                          searchbox = false;
                                        });
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.location_pin,
                                                  size: 20,
                                                  color: Colors.black54),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.3,
                                                child: Text(
                                                  cityListModel[index].place,
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontSize: 16),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider(
                                            color: Colors.grey,
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            // button
                            ElevatedButton(
                              onPressed: () {
                                if (_nameController.text.isEmpty ||
                                    _dateController.text.isEmpty ||
                                    countryController.text.isEmpty ||
                                    _timeController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Incorrect Form Details',
                                          style:
                                              TextStyle(fontSize: 20)), // Text
                                      backgroundColor: Colors.red,
                                      dismissDirection: DismissDirection.up,
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height -
                                              150,
                                          left: 10,
                                          right: 10), // EdgeInsets.only
                                    ),
                                  );
                                } else {
                                  submitForm(modalSetter);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.black,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Continue',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.28),
                              ),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                          ],
                        ),
                ),
              ),
            );
          });
        });
  }


  Widget shimmerScreen() {
    return SizedBox(
      height: 205,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: 5,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Theme.of(context).cardColor,
            highlightColor: Colors.grey[300]!,
            enabled: true,
            child: Container(
              margin: const EdgeInsets.only(right: 10, bottom: 10),
              width: 140,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  borderRadius: BorderRadius.circular(8.0)),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}