import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../gita_chapter/gitastatic.dart';
import '../hanuman_chalisa/hanuman_chalisa_screen.dart';
import '../sahitya_pages/bhai_dooj_vrat.dart';
import '../sahitya_pages/chath_pooja.dart';
import '../sahitya_pages/dasha_mata.dart';
import '../sahitya_pages/gangaur_katha.dart';
import '../sahitya_pages/govardhan_pooja.dart';
import '../sahitya_pages/hartalika_teej.dart';
import '../sahitya_pages/haryali_teej.dart';
import '../sahitya_pages/holi_vrat.dart';
import '../sahitya_pages/janmaasthami.dart';
import '../sahitya_pages/kartik_purneema.dart';
import '../sahitya_pages/karwa_choth.dart';
import '../sahitya_pages/mangalvar_vrat.dart';
import '../sahitya_pages/nag_panchmi.dart';
import '../sahitya_pages/narshima_vrat.dart';
import '../sahitya_pages/pashupati_vrat.dart';
import '../sahitya_pages/rishi_panchami.dart';
import '../sahitya_pages/shanivar_vrat.dart';
import '../sahitya_pages/sharad_purneema.dart';
import '../sahitya_pages/sheetla_mata.dart';
import '../sahitya_pages/shravan_somawar.dart';
import '../sahitya_pages/shri_suktam.dart';
import '../sahitya_pages/sundarkand.dart';
import '../sahitya_pages/vaibhav_laxmi.dart';
import '../sahitya_pages/vat_savitri_katha.dart';

void handleSahityaAction(String value, BuildContext context) {
  final normalized = value.trim().toUpperCase();

  final navigationMap = <String, Widget>{
    "BHAGAVAD GITA": const SahityaChapters(),
    "HANUMAN CHALISA": const HanumanChalisaScreen(),
    "CHHATH PUJA KATHA": const ChhathPuja(),
    "JANMASHTAMI VRAT KATHA": const Janmashtami(),
    "DASHA MATA VRAT KATHA": const Dasha_mata(),
    "HARIYALI TEEJ VRAT KATHA": const HariyaliTeej(),
    "HARTALIKA TEEJ VRAT KATHA": const HartalikaTeej(),
    "KARWA CHAUTH VRAT KATHA": const KarwaChauth(),
    "SHEETALA SAPTAMI VRAT KATHA": const SheetlaSaptmi(),
    "SHRAVAN (SAWAN) SOMVAR VRAT KATHA": const Shravan(),
    "GANGAUR KATHA": const GangaurKatha(),
    "VAT SAVITRI VRAT KATHA": const VatSavitriVrat(),
    "GOVARDHAN PUJA VRAT KATHA": const GovardhanPuja(),
    "VAIBHAV LAXMI VRAT KATHA": const VaibhavLaxmi(),
    "SRI SUKTAM PAATH": const ShriSuktam(),
    "SHARAD PURNIMA VRAT KATHA": const SharadPurnima(),
    "SHANIVAR (SATURDAY) VRAT KATHA": const ShanivaarVrat(),
    "RISHI PANCHAMI VRAT KATHA": const RishiPanchmi(),
    "PASHUPATINATH VRAT KATHA": const PashupatiVrat(),
    "NARSINGH JAYANTI VRAT KATHA": const Narasimha(),
    "NAG PANCHAMI KATHA": const NagPanchmi(),
    "SUNDERKAND": const Sundarkand(),
    "MANGALVAR VRAT KATHA": const MangalvarVrat(),
    "KARTIK PURNIMA VRAT KATHA": const KartikPurnima(),
    "HOLI VRAT KATHA": const HoliVrat(),
    "BHAI DOOJ VRAT KATHA": const BhaiDooj(),
  };

  final widget = navigationMap[normalized];

  if (widget != null) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => widget),
    );
  } else {
    showComingSoonDialog(context);
  }
}

void showComingSoonDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.temple_hindu, color: Colors.orange, size: 50),
          const SizedBox(height: 20),
          const Text("Coming Soon",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown)),
          const SizedBox(height: 10),
          Text(
            "Stay tuned! We're working on something divine for you.",
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}
