import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class InfoDialog extends StatelessWidget {
  final String description;
  final String languageCode;
  final String title;

  const InfoDialog({
    super.key,
    required this.description,
    this.languageCode = "en",
    this.title = "Got it",
  });

  @override
  Widget build(BuildContext context) {
    final gotItText = languageCode == "en" ? "Got it" : "ठीक है";

    return AlertDialog(
      alignment: Alignment.bottomCenter,
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.only(bottom: 20, left: 15, right: 15),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Material(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: description.isNotEmpty
                      ? Text(
                          HtmlParser.parseHTML(description).text,
                          style: const TextStyle(fontSize: 16),
                        )
                      : const Text("Not Available")),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey, // Changed from grey to blue
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                gotItText,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to show the dialog
  static void show({
    required BuildContext context,
    required String description,
    String languageCode = "en",
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => InfoDialog(
        description: description,
        languageCode: languageCode,
      ),
    );
  }
}
