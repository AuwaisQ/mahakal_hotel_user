import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:mahakal/features/astrology/component/pdfForm_screen.dart';
import 'package:mahakal/features/astrology/component/pdfmilanForm.dart';
import 'package:provider/provider.dart';
import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../main.dart';
import '../../../utill/app_constants.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../profile/controllers/profile_contrroller.dart';
import '../model/pdfmodel.dart';
import 'package:http/http.dart' as http;

class PdfDetailsView extends StatefulWidget {
  final String pdfId;
  final String pdfType;
  const PdfDetailsView({
    super.key,
    required this.pdfId,
    required this.pdfType,
  });

  @override
  State<PdfDetailsView> createState() => _PdfDetailsViewState();
}

class _PdfDetailsViewState extends State<PdfDetailsView> {
  int screenIndex = 0;
  bool translateBtn = true;
  bool isLoading = true;
  String image = "";
  String name = "";
  String enDescription = "";
  String hiDescription = "";
  String shortDescription = "";
  String pages = "";
  String amount = "";
  String leadId = "";
  String userToken = "";
  String userId = "";

  // bool fontSizeChange = true;
  // double fontSizeDefault = 18.0;

  List<Pdf> pdfListModelList = <Pdf>[];

  void getPfdData(String id) async {
    var res = await HttpService()
        .postApi(AppConstants.getBirthByIdUrl, {"birth_journal_id": id});
    setState(() {
      name = res["data"]["name"];
      image = res["data"]["image"];
      enDescription = res["data"]["en_description"];
      hiDescription = res["data"]["hi_description"];
      shortDescription = res["data"]["hi_short_description"];
      pages = res["data"]["pages"].toString();
      amount = res["data"]["selling_price"].toString();
      isLoading = false;
    });
    print("pdf print >>> $res");
  }

  // Future<void> pdfLeadApi() async {
  //   final url = Uri.parse('${AppConstants.baseUrl}/api/v1/birth_journal/create-leads');
  //
  //   final Map<String, dynamic> data = {
  //     "user_id": userId,            // Ensure userId is valid
  //     "birth_journal_id": widget.pdfId,       // Ensure id is valid
  //     "amount": amount              // Ensure amount format matches the server's expectation
  //   };
  //
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Authorization": "Bearer $userToken",
  //       },
  //       body: jsonEncode(data),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       print('Data posted successfully: ${response.body}');
  //     } else {
  //       print('Failed to post data: Status ${response.statusCode}, Body: ${response.body}');
  //     }
  //   } catch (error) {
  //     print('Error posting data: $error');
  //   }
  // }

  void pdfLeadApi() async {
    const url = AppConstants.baseUrl + AppConstants.createPdfLeadsUrl;
    var token = userToken;
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({
      "user_id": userId,
      "birth_journal_id": widget.pdfId,
      "amount": amount,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );
      var res = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('Success: $res');
        leadId = res["data"]["lead_id"].toString();
        print(">>> lead api run $leadId $userId");
      } else {
        print('Error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // getRashiList();
    getPfdData(widget.pdfId);
    userId = Provider.of<ProfileController>(Get.context!, listen: false).userID;
    userToken =
        Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    print(">>>> token order $userId $userToken");
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container(
            color: Colors.white,
            child: const Center(
                child: CircularProgressIndicator(
              color: Colors.orange,
            )))
        : Scaffold(
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: widget.pdfType == "kundali"
                ? InkWell(
                    onTap: () {
                      pdfLeadApi();
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => PdfFormView(
                                    pageCount: pages,
                                    amount: amount,
                                    pdfDetail: shortDescription,
                                    birthJournalId: widget.pdfId,
                                    leadId: leadId,
                                  )));
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      height: 45,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Center(
                          child: Text(
                        "Get Your Kundali",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      )),
                    ),
                  )
                : InkWell(
                    onTap: () {
                      pdfLeadApi();
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => PdfMilanFormView(
                                    pageCount: pages,
                                    amount: amount,
                                    pdfDetail: shortDescription,
                                    birthJournalId: widget.pdfId,
                                    leadId: leadId,
                                  )));
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      height: 45,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Center(
                          child: Text(
                        "Get Your Kundali Milan",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      )),
                    ),
                  ),
            appBar: AppBar(
              title: Text(
                "PDF - Details",
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
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, left: 10, right: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const Center(
                      child: SizedBox(
                        width: 100,
                        child: Divider(
                          color: Colors.grey,
                          thickness: 3,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        " ✤ $name ✤ ".replaceAll('_', ' '),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(right: 15, left: 15, top: 10),
                    //   child: Text(
                    //     "⦿ ${isTranslate? widget.enDescription : widget.hiDescription}}",
                    //     style: TextStyle(
                    //       fontSize: screenHeight * 0.020,
                    //       fontWeight: FontWeight.bold,
                    //       color: Colors.black,
                    //     ),
                    //   ),
                    // ),

                    Padding(
                      padding: const EdgeInsets.only(
                        right: 10,
                        left: 10,
                      ),
                      child: Html(
                          data: translateBtn ? hiDescription : enDescription,
                          style: {
                            'p': Style(fontSize: FontSize(16)),
                            'li': Style(fontSize: FontSize(16)),
                            'ul': Style(fontSize: FontSize(16)),
                            'span': Style(fontSize: FontSize(16)),
                            'strong': Style(fontSize: FontSize(16)),
                          }),
                    ),
                    const SizedBox(
                      height: 80,
                    ),
                  ],
                ),
              ),
            ));
  }
}
