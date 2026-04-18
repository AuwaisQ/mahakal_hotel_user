import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';

import '../../../data/datasource/remote/http/httpClient.dart';
import '../model/pdfmodel.dart';
import 'pdf_details_screen.dart';

class PdfDataView extends StatefulWidget {
  const PdfDataView({
    super.key,
  });

  @override
  State<PdfDataView> createState() => _PdfDataViewState();
}

class _PdfDataViewState extends State<PdfDataView> {
  int screenIndex = 0;
  bool translateBtn = true;

  List<Pdf> pdfListModelList = <Pdf>[];

  void getPfdData() async {
    var res = await HttpService()
        .postApi(AppConstants.getBirthJournal, {"birth_journal_id": "1"});
    setState(() {
      pdfListModelList.clear();
      List pdfList = res["data"];
      pdfListModelList.addAll(pdfList.map((e) => Pdf.fromJson(e)));
    });
    print("pdf print >>> $res");
  }

  @override
  void initState() {
    super.initState();
    // getRashiList();
    getPfdData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "PDF",
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
            child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
              child: GridView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: pdfListModelList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
                childAspectRatio: 1.3),
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => PdfDetailsView(
                                pdfId: pdfListModelList[index].id.toString(),
                                pdfType: pdfListModelList[index].name,
                              )));
                },
                child: Container(
                  margin: const EdgeInsets.all(5),
                  width: 120,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 7,
                            offset: const Offset(0, 6))
                      ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade300),
                        child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(8),
                                topLeft: Radius.circular(8)),
                            child: Image.network(pdfListModelList[index].image,
                                fit: BoxFit.fill)),
                      ),
                      Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(color: Colors.white),
                          child: Center(
                              child: Html(
                                  data: translateBtn
                                      ? pdfListModelList[index]
                                          .hiShortDescription
                                      : pdfListModelList[index]
                                          .enShortDescription))),
                    ],
                  ),
                ),
              );
            },
          )),
        )));
  }
}
