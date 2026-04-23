import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../../../tour_and_travells/model/city_details_model.dart';
import '../../../tour_and_travells/view/tour_packages/city_tour_type.dart';
import '../../../tour_and_travells/view/tour_packages/special_tour_type.dart';
import '../../../tour_and_travells/view/tour_packages/usetypethree.dart';
import '../../../tour_and_travells/view/tour_packages/myfourthtour.dart';
import '../../../tour_and_travells/view/tour_packages/user_selection_tour.dart';

class InvoiceViewer extends StatefulWidget {
  final String pdfPath;
  final String invoiceUrl;
  final String typeText;
  final String tourLink;
  CityDetailsModel? delhiModal;
  final List<PackageList>? hotelList;
  final List<PackageList>? foodList;
  final bool isTour;
  final dynamic tourId;
  final String translateEn;

  InvoiceViewer({
    super.key,
    required this.pdfPath,
    required this.invoiceUrl,
    this.typeText = "View Invoice",
    this.tourLink = "",
    this.isTour = false,
    this.tourId = "",
    this.delhiModal,
    this.hotelList,
    this.foodList,
    this.translateEn = "",
  });

  @override
  State<InvoiceViewer> createState() => _InvoiceViewerState();
}

class _InvoiceViewerState extends State<InvoiceViewer> {

  // Tour actions function (same as before)
  void handleAction(String value) {
    switch (value) {
    /// City Tour(Per Person Done)   GST Correction Completed
      case "0":
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => CityTourType(
                services: widget.delhiModal!.data!.services,
                cabsquantity: widget.delhiModal!.data!.cabList,
                hotelList: widget.hotelList!,
                foodList: widget.foodList!,
                tourId: widget.tourId,
                packageId: widget.delhiModal!.data!.packageList.isNotEmpty
                    ? widget.delhiModal!.data!.packageList[0].packageId
                    : "0",
                translateEn: widget.translateEn,
                timeSlot: widget.delhiModal?.data?.timeSlot,
                exDistance: widget.delhiModal?.data?.exDistance,
                useDate: "${widget.delhiModal?.data?.useDate}",
                isPersonUse: widget.delhiModal!.data!.isPersonUse,
                tourGst: widget.delhiModal?.data?.tourGst,
                transPortGst: widget.delhiModal?.data?.transportGst,
                tourName: widget.translateEn == "en"
                    ? widget.delhiModal!.data!.enTourName
                    : widget.delhiModal!.data!.hiTourName,
                hotelTypeList: widget.delhiModal!.data!.hotelTypeList.isNotEmpty
                    ? widget.delhiModal!.data!.hotelTypeList
                    : [],
                locationName: '${widget.delhiModal?.data?.citiesName}',
              ),
            ));
        break;

    /// Special Tour (Ye Sahi h) GST Calculation Completed
      case "1":
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => SpecialTourType(
                services: widget.delhiModal!.data!.services,
                extraTransportPrice:
                widget.delhiModal?.data!.exTransportPrice ?? [],
                cabsquantity: widget.delhiModal!.data!.cabList,
                hotelList: widget.hotelList!,
                foodList: widget.foodList!,
                tourId: widget.tourId,
                packageAmount:
                widget.delhiModal!.data!.tourPackageTotalPrice ?? 0,
                packageId: widget.delhiModal!.data!.packageList.isNotEmpty
                    ? widget.delhiModal!.data!.packageList[0].packageId
                    : "0",
                translateEn: widget.translateEn,
                pickTime: widget.delhiModal?.data?.pickupTime ?? '',
                exDistance: widget.delhiModal?.data?.exDistance,
                useDate: "${widget.delhiModal?.data?.useDate}",
                isPersonUse: widget.delhiModal!.data!.isPersonUse,
                tourGst: widget.delhiModal?.data?.tourGst,
                transPortGst: widget.delhiModal?.data?.transportGst,
                tourName: widget.translateEn == "en"
                    ? widget.delhiModal!.data!.enTourName
                    : widget.delhiModal!.data!.hiTourName,
                hotelTypeList: widget.delhiModal!.data!.hotelTypeList.isNotEmpty
                    ? widget.delhiModal!.data!.hotelTypeList
                    : [],
                locationName: '${widget.delhiModal?.data?.citiesName}',
                customizedDates: widget.delhiModal?.data!.customizedDates,
                customizedType: widget.delhiModal?.data!.customizedType ?? '',
                pickLat: '${widget.delhiModal?.data?.pickupLat}',
                pickLong: '${widget.delhiModal?.data?.pickupLong}',
                tourDate: widget.delhiModal?.data!.date ?? '',

              ),
            ));
        break;

    /// User Selection Tour(Also Done by Per person ) GST Correction Completed
      case "2":
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => UseTypeTwo(
                services: widget.delhiModal!.data!.services,
                packageList: widget.delhiModal!.data!.packageList.isNotEmpty
                    ? widget.delhiModal!.data!.packageList
                    : [],
                cabsquantity: widget.delhiModal!.data!.cabList,
                hotelList: widget.hotelList!,
                foodList: widget.foodList!,
                tourId: widget.tourId,
                packageId: widget.delhiModal!.data!.packageList.isNotEmpty
                    ? widget.delhiModal!.data!.packageList[0].packageId
                    : "0",
                translateEn: widget.translateEn,
                timeSlot: widget.delhiModal?.data!.timeSlot,
                exDistance: widget.delhiModal!.data!.exDistance,
                tourName: widget.delhiModal!.data!.enTourName,
                hiTourName: widget.delhiModal!.data!.hiTourName,
                packageAmount:
                widget.delhiModal!.data!.tourPackageTotalPrice ?? 0,
                locationName: widget.delhiModal!.data!.pickupLocation ?? '',
                pickLong: widget.delhiModal!.data!.pickupLong ?? '',
                pickLat: widget.delhiModal!.data!.pickupLat ?? '',
                useDate: "${widget.delhiModal?.data!.useDate}",
                isPersonUse: widget.delhiModal!.data!.isPersonUse,
                tourGst: widget.delhiModal?.data!.tourGst,
                transPortGst: widget.delhiModal?.data!.transportGst,
                extraTransportPrice:
                widget.delhiModal?.data!.exTransportPrice ?? [],
                hotelTypeList: widget.delhiModal!.data!.hotelTypeList.isNotEmpty
                    ? widget.delhiModal!.data!.hotelTypeList
                    : [],
              ),
            ));
        break;

    /// My FistTour(This Alos Done there is no per person)
      case "3":
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => UseTypeThree(
                services: widget.delhiModal!.data!.services,
                packageList: widget.delhiModal!.data!.packageList.isNotEmpty
                    ? widget.delhiModal!.data!.packageList
                    : [],
                cabsquantity: widget.delhiModal!.data!.cabList,
                hotelList: widget.hotelList!,
                foodList: widget.foodList!,
                tourId: widget.tourId,
                packageId: widget.delhiModal!.data!.packageList.isNotEmpty
                    ? widget.delhiModal!.data!.packageList[0].packageId
                    : "0",
                translateEn: widget.translateEn,
                timeSlot: widget.delhiModal?.data!.timeSlot,
                exDistance: widget.delhiModal!.data!.exDistance,
                tourName: widget.delhiModal?.data!.enTourName ?? '',
                hiTourName: widget.delhiModal!.data!.hiTourName,
                packageAmount:
                widget.delhiModal!.data!.tourPackageTotalPrice ?? 0,
                useDate: "${widget.delhiModal?.data!.useDate}",
                locationName: "${widget.delhiModal?.data!.citiesName}",
                transPortGst: widget.delhiModal?.data!.transportGst,
                tourGst: widget.delhiModal?.data!.tourGst,
              ),
            ));
        break;

    /// GST Calculation Complete
    /// Fourth type Tour(Per person done)(Date and Time User dega , No, of person Increase hoga, Address ayega )
      case "4":
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => UseTypeFour(
                services: widget.delhiModal!.data!.services,
                packageList: widget.delhiModal!.data!.packageList,
                cabsquantity: widget.delhiModal!.data!.cabList,
                hotelList: widget.hotelList!,
                foodList: widget.foodList!,
                tourId: widget.tourId,
                packageId: widget.delhiModal!.data!.packageList.isNotEmpty
                    ? widget.delhiModal!.data!.packageList[0].packageId
                    : "0",
                translateEn: widget.translateEn,
                timeSlot: widget.delhiModal?.data!.timeSlot,
                exDistance: widget.delhiModal!.data!.exDistance,
                tourName: widget.delhiModal!.data!.enTourName,
                hiTourName: widget.delhiModal!.data!.hiTourName,
                packageAmount:
                widget.delhiModal!.data!.tourPackageTotalPrice ?? 0,
                locationName: widget.delhiModal!.data!.pickupLocation ?? '',
                pickLat: widget.delhiModal!.data!.pickupLat ?? '',
                pickLong: widget.delhiModal!.data!.pickupLong ?? '',
                useDate: "${widget.delhiModal?.data!.useDate}",
                isPersonUse: widget.delhiModal!.data!.isPersonUse,
                //isPersonUse: 0,
                tourGst: widget.delhiModal?.data!.tourGst,
                transPortGst: widget.delhiModal?.data!.transportGst,
                extraTransportPrice:
                widget.delhiModal?.data!.exTransportPrice ?? [],
                hotelTypeList: widget.delhiModal!.data!.hotelTypeList.isNotEmpty
                    ? widget.delhiModal!.data!.hotelTypeList
                    : [],
              ),
            ));
        break;
    }
  }

  // Download state variables
  late PdfControllerPinch _pdfController;
  bool isDownloading = false;
  bool showDownloadOverlay = false;
  double downloadProgress = 0.0;
  String? downloadFileName;
  int? fileSize;
  int? downloadedBytes;
  int? totalBytes;
  String? downloadSpeed;
  DateTime? lastUpdateTime;
  int? lastDownloadedBytes;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openFile(widget.pdfPath),
    );
    print("📄 Opening PDF: ${widget.pdfPath}");
  }

  // Professional download method with progress
  Future<void> _downloadPDFWithProgress() async {
    if (isDownloading) return;

    setState(() {
      isDownloading = true;
      showDownloadOverlay = true;
      downloadProgress = 0.0;
      downloadedBytes = 0;
      totalBytes = 0;
      downloadSpeed = null;
      downloadFileName = 'Invoice_${DateTime.now().millisecondsSinceEpoch}.pdf';
      lastUpdateTime = DateTime.now();
      lastDownloadedBytes = 0;
    });

    try {
      print("🚀 Starting download with progress...");
      print("📥 URL: ${widget.invoiceUrl}");

      if (widget.invoiceUrl.isEmpty) {
        throw Exception("Download URL is empty");
      }

      // Get file info first
      final dio = Dio();
      final headResponse = await dio.head(widget.invoiceUrl);
      final contentLength = headResponse.headers.value('content-length');

      if (contentLength != null) {
        totalBytes = int.tryParse(contentLength);
        fileSize = totalBytes;
        print("📊 File size: ${_formatFileSize(fileSize!)}");
      }

      // Get download directory
      String savePath;
      if (Platform.isAndroid) {
        savePath = '/storage/emulated/0/Download';
        final dir = Directory(savePath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
      } else {
        final dir = await getApplicationDocumentsDirectory();
        savePath = dir.path;
      }

      final filePath = '$savePath/$downloadFileName';
      print("💾 Saving to: $filePath");

      // Start download with progress tracking
      await dio.download(
        widget.invoiceUrl,
        filePath,
        onReceiveProgress: (received, total) {
          final now = DateTime.now();

          // Calculate download speed
          if (lastUpdateTime != null && lastDownloadedBytes != null) {
            final timeDiff = now.difference(lastUpdateTime!).inMilliseconds;
            if (timeDiff > 500) { // Update speed every 500ms
              final bytesDiff = received - lastDownloadedBytes!;
              final speedKBs = bytesDiff / timeDiff * 1000 / 1024; // KB/s
              downloadSpeed = '${speedKBs.toStringAsFixed(1)} KB/s';

              lastUpdateTime = now;
              lastDownloadedBytes = received;
            }
          }

          if (mounted) {
            setState(() {
              downloadedBytes = received;
              totalBytes = total;
              if (total != -1) {
                downloadProgress = (received / total * 100);
              }
            });
          }

          print("📈 Progress: ${downloadProgress.toStringAsFixed(1)}%");
          print("📊 Downloaded: ${_formatFileSize(received)} / ${_formatFileSize(total)}");
        },
        deleteOnError: true,
        options: Options(
          receiveTimeout: const Duration(minutes: 5),
          sendTimeout: const Duration(minutes: 5),
        ),
      );

      // Download successful
      print("✅ Download completed successfully!");
      print("💾 File saved: $filePath");

      // Show success state
      _showDownloadComplete();

    } on DioException catch (e) {
      print("❌ Download error: ${e.message}");
      _showDownloadError("Download failed: ${e.message ?? 'Network error'}");
    } catch (e) {
      print("❌ General error: $e");
      _showDownloadError("Download failed: $e");
    }
  }

  void _showDownloadComplete() {
    if (!mounted) return;

    // Show success overlay
    setState(() {
      downloadProgress = 100.0;
    });

    // Wait 2 seconds then hide overlay and show success snackbar
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showDownloadOverlay = false;
          isDownloading = false;
        });

        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Row(
        //       children: [
        //         const Icon(Icons.check_circle, color: Colors.white),
        //         const SizedBox(width: 10),
        //         Expanded(
        //           child: Text(
        //             '✅ Downloaded: $downloadFileName',
        //             style: const TextStyle(color: Colors.white),
        //           ),
        //         ),
        //       ],
        //     ),
        //     backgroundColor: Colors.green,
        //     duration: const Duration(seconds: 3),
        //     action: SnackBarAction(
        //       label: 'OPEN',
        //       textColor: Colors.white,
        //       onPressed: () {
        //         // TODO: Open file
        //         print("📂 Open file: $downloadFileName");
        //       },
        //     ),
        //   ),
        // );
      }
    });
  }

  void _showDownloadError(String error) {
    if (!mounted) return;

    setState(() {
      isDownloading = false;
      showDownloadOverlay = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(error)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'RETRY',
          textColor: Colors.white,
          onPressed: _downloadPDFWithProgress,
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  // Download confirmation dialog - Optimized for Android & iOS
void showDownloadConfirmationDialog() {
  final isIOS = Platform.isIOS;
  
  if (isIOS) {
    _showCupertinoDialog();
  } else {
    _showMaterialDialog();
  }
}

void _showMaterialDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Row(
        children: [
          Icon(Icons.download, color: Colors.blue, size: 28),
          SizedBox(width: 12),
          Text(
            "Download Invoice",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: const Text(
        "This PDF will be saved to your Downloads folder. You can access it from your Files app.",
        style: TextStyle(fontSize: 15, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Text(
            "CANCEL",
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.pop(dialogContext);
            await _handleDownloadWithPermission();
          },
          style: FilledButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "DOWNLOAD",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    ),
  );
}

void _showCupertinoDialog() {
  showCupertinoDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => CupertinoAlertDialog(
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.arrow_down_circle_fill, color: CupertinoColors.systemOrange),
          SizedBox(width: 8),
          Text("Download Invoice"),
        ],
      ),
      content: const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text(
          "This PDF will be saved to your Files app. You can access it from the Downloads folder.",
          style: TextStyle(fontSize: 14),
        ),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(dialogContext),
          isDefaultAction: true,
          child: const Text("Cancel"),
        ),
        CupertinoDialogAction(
          onPressed: () async {
            Navigator.pop(dialogContext);
            await _handleDownloadWithPermission();
          },
          isDestructiveAction: false,
          child: const Text(
            "Download",
            style: TextStyle(color: CupertinoColors.systemOrange),
          ),
        ),
      ],
    ),
  );
}

// Handle permissions and download
Future<void> _handleDownloadWithPermission() async {
  try {
    // iOS doesn't need storage permission for app documents
    // Android 13+ (API 33+) uses granular media permissions
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      
      if (androidInfo.version.sdkInt >= 33) {
        // Android 13+ - use photos/media permission or manage external storage
        final status = await Permission.photos.request();
        if (status.isDenied) {
          _showPermissionDeniedSnackBar();
          return;
        }
      } else {
        // Android 12 and below - storage permission
        final status = await Permission.storage.request();
        if (status.isDenied) {
          _showPermissionDeniedSnackBar();
          return;
        }
      }
    }
    
    await _downloadPDFWithProgress();
    
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Download failed: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}

void _showPermissionDeniedSnackBar() {
  if (!mounted) return;
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text("Storage permission is required to download files"),
      backgroundColor: Colors.blue,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      action: SnackBarAction(
        label: "SETTINGS",
        textColor: Colors.white,
        onPressed: () => openAppSettings(),
      ),
    ),
  );
}

  // Share PDF function
  Future<void> _sharePDF() async {
    try {
      final file = File(widget.pdfPath);
      if (await file.exists()) {
        String shareText = "🧾 Check out my tour invoice PDF!\n\n"
            "Here's your travel summary and details for your trip.\n"
            "📍 View more at: ${widget.tourLink}";

        // Build the RenderBox for iOS share sheet positioning
        final box = context.findRenderObject() as RenderBox?;

        await Share.shareXFiles(
          [XFile(widget.pdfPath)],
          text: shareText,
          // Required for iOS/iPad - provides the anchor point for the share sheet
          sharePositionOrigin: box != null
              ? box.localToGlobal(Offset.zero) & box.size
              : null,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("PDF file not found!"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to share PDF: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Professional download overlay
  Widget _buildDownloadOverlay() {
    if (!showDownloadOverlay) return const SizedBox.shrink();

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.download,
                        color: Colors.blue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            downloadFileName ?? 'Invoice.pdf',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (fileSize != null)
                            Text(
                              _formatFileSize(fileSize!),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // Progress bar
                LinearProgressIndicator(
                  value: downloadProgress / 100,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    downloadProgress == 100 ? Colors.green : Colors.blue,
                  ),
                ),

                const SizedBox(height: 15),

                // Progress details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Percentage
                    Text(
                      '${downloadProgress.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: downloadProgress == 100 ? Colors.green : Colors.blue,
                      ),
                    ),

                    // Downloaded size
                    if (downloadedBytes != null && totalBytes != null && totalBytes! > 0)
                      Text(
                        '${_formatFileSize(downloadedBytes!)} / ${_formatFileSize(totalBytes!)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                // Download speed and time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (downloadSpeed != null)
                      Row(
                        children: [
                          Icon(Icons.speed, size: 16, color: Colors.green[700]),
                          const SizedBox(width: 5),
                          Text(
                            downloadSpeed!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    if (totalBytes != null && downloadedBytes != null && totalBytes! > 0)
                      Text(
                        _calculateRemainingTime(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 25),

                // Cancel button
                if (downloadProgress < 100)
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        showDownloadOverlay = false;
                        isDownloading = false;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'CANCEL DOWNLOAD',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),

                // Success message
                if (downloadProgress == 100)
                  Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 48,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        '✅ Download Complete!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showDownloadOverlay = false;
                            isDownloading = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'CLOSE',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _calculateRemainingTime() {
    if (downloadedBytes == null || totalBytes == null || totalBytes! <= 0) return '';
    if (downloadSpeed == null) return 'Calculating...';

    final remainingBytes = totalBytes! - downloadedBytes!;
    try {
      final speedKBs = double.parse(downloadSpeed!.replaceAll(' KB/s', ''));
      if (speedKBs <= 0) return 'Calculating...';

      final remainingSeconds = (remainingBytes / 1024 / speedKBs).toInt();

      if (remainingSeconds < 60) {
        return '$remainingSeconds seconds remaining';
      } else if (remainingSeconds < 3600) {
        final minutes = (remainingSeconds / 60).floor();
        return '$minutes minute${minutes > 1 ? 's' : ''} remaining';
      } else {
        final hours = (remainingSeconds / 3600).floor();
        return '$hours hour${hours > 1 ? 's' : ''} remaining';
      }
    } catch (e) {
      return 'Calculating...';
    }
  }

  // Floating action buttons for tour mode
  Widget _buildTourFloatingButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Book Now Button
          Expanded(
            child: ElevatedButton(
              onPressed: () => handleAction("${widget.delhiModal!.data!.useDate ?? ""}"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                "BOOK NOW",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Share Button
          _buildFloatingIconButton(
            icon: Icons.share,
            color: Colors.blue,
            onPressed: _sharePDF,
          ),
          const SizedBox(width: 12),
          // Download Button
          // isDownloading
          //     ? Container(
          //   padding: const EdgeInsets.all(12),
          //   decoration: BoxDecoration(
          //     color: Colors.blue.withOpacity(0.15),
          //     borderRadius: BorderRadius.circular(50),
          //   ),
          //   child: SizedBox(
          //     width: 24,
          //     height: 24,
          //     child: CircularProgressIndicator(
          //       value: downloadProgress / 100,
          //       strokeWidth: 3,
          //       backgroundColor: Colors.blue.shade100,
          //       color: Colors.blue,
          //     ),
          //   ),
          // )
          //     : _buildFloatingIconButton(
          //   icon: Icons.download,
          //   color: Colors.blue,
          //   onPressed: showDownloadConfirmationDialog,
          // ),
        ],
      ),
    );
  }

  // Floating action buttons for normal mode
  Widget _buildNormalFloatingButtons() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Share Button
          _buildFloatingIconButton(
            icon: Icons.share,
            color: Colors.blue,
            onPressed: _sharePDF,
            isLarge: true,
          ),

          const SizedBox(width: 16),

          // Download Button
          // isDownloading
          //     ? Container(
          //   padding: const EdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //     color: Colors.blue.withOpacity(0.15),
          //     borderRadius: BorderRadius.circular(50),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.blue.withOpacity(0.3),
          //         blurRadius: 10,
          //       ),
          //     ],
          //   ),
          //   child: Stack(
          //     alignment: Alignment.center,
          //     children: [
          //       SizedBox(
          //         width: 40,
          //         height: 40,
          //         child: CircularProgressIndicator(
          //           value: downloadProgress / 100,
          //           strokeWidth: 4,
          //           backgroundColor: Colors.blue.shade100,
          //           color: Colors.blue,
          //         ),
          //       ),
          //       Text(
          //         '${downloadProgress.toInt()}%',
          //         style: const TextStyle(
          //           fontSize: 10,
          //           fontWeight: FontWeight.bold,
          //           color: Colors.blue,
          //         ),
          //       ),
          //     ],
          //   ),
          // )
          //     :
          _buildFloatingIconButton(
            icon: Icons.download,
            color: Colors.blue,
            onPressed: showDownloadConfirmationDialog,
            isLarge: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool isLarge = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(50),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: isLarge ? 56 : 48,
            height: isLarge ? 56 : 48,
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: color,
              size: isLarge ? 28 : 24,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: widget.isTour
          ? _buildTourFloatingButtons()
          : _buildNormalFloatingButtons(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        title: Text(
          widget.typeText,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
      body: Stack(
        children: [
          PdfViewPinch(
            controller: _pdfController,
            scrollDirection: Axis.vertical,
            onDocumentLoaded: (details) {
              print("Total pages: ${details.pagesCount}");
            },
            onPageChanged: (page) {
              print("Page changed: $page");
            },
          ),

          // Download Overlay
          _buildDownloadOverlay(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }
}