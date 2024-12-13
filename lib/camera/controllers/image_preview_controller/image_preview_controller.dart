import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:la_tech/firebase_service/firebase_service.dart';
import 'package:la_tech/home_page/controllers/home_page_controller/home_page_controller.dart';
import 'package:la_tech/model/item_model.dart';

import '../../../env/app_navigator.dart';
import '../../../model/expiry_enum.dart';
import '../camera_controller/camera_controller.dart';

class ImagePreviewController extends SuperController {
  final FirebaseService firebaseService = FirebaseService();
  final AppCameraController appCameraController = Get.find();
  final HomePageController homePageController = Get.find();

  final textRecognizer = TextRecognizer();

  TextEditingController expiryController = TextEditingController();
  TextEditingController productNameController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController orderController = TextEditingController();

  Rx<bool> readOnly = true.obs;

  Rxn<String> recognizedText = Rxn<String>();
  Rxn<XFile> image = Rxn<XFile>();

  @override
  void onInit() async {
    super.onInit();
    areaController.text = homePageController.areaValue.value!;
    orderController.text = homePageController.orderValue.value.toString();

    image.value = null;
    expiryController.clear();
    recognizedText.value = null;
    await captureAndRecognizeText();
  }

  Future<void> captureAndRecognizeText() async {
    image.value = appCameraController.image.value;
    try {
      if (image.value != null) {
        final inputImage = InputImage.fromFilePath(image.value!.path);
        final recognizedTextResult = await textRecognizer.processImage(inputImage);

        debugPrint('olla ${recognizedTextResult.text}');

        recognizedText.value = expiryFormat(recognizedTextResult.text);
        expiryController.text = recognizedText.value ?? '';
      } else {
        print("No image found for text recognition.");
      }
    } catch (e) {
      print("Error recognizing text: $e");
    }
  }

  void backToCamera() {
    appCameraController.resetData();
    image.value = null;
    Get.back();
  }

  String expiryFormat(String text) {
    final regex = RegExp(r'(\d{2}[./\s]\d{2}[./\s]\d{2,4})');

    final matches = regex.allMatches(text);

    if (matches.isNotEmpty) {
      DateTime? latestDate;
      String? latestDateString;

      for (final match in matches) {
        String rawDate = normalizeDate(match.group(0)!);

        DateTime currentDate = parseDate(rawDate);

        if (latestDate == null || currentDate.isAfter(latestDate)) {
          latestDate = currentDate;
          latestDateString = rawDate;
        }
      }

      return latestDateString ?? "Không tìm thấy hạn sử dụng";
    } else {
      return "Không tìm thấy hạn sử dụng";
    }
  }

  String normalizeDate(String date) {
    date = date.replaceAll(RegExp(r'[.\s]'), '/');

    final parts = date.split('/');
    if (parts.length == 3) {
      String day = parts[0];
      String month = parts[1];
      String year = parts[2];

      if (year.length == 2) {
        year = '20$year';
      }
      return "$day/$month/$year";
    }
    return date;
  }

  DateTime parseDate(String date) {
    final parts = date.split('/');
    if (parts.length == 3) {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      return DateTime(year, month, day);
    } else {
      return DateTime.now();
    }
  }

  void saveToDatabase() {
    DateTime expiryDate = firebaseService.parseExpiryDate(expiryController.text);

    Expiry status = firebaseService.getExpirationStatus(expiryDate);

    if (productNameController.text.isEmpty) {
      productNameController.text = 'null';
    }

    final ItemModel itemModel = ItemModel(areaController.text, productNameController.text, expiryController.text, status, int.parse(orderController.text));
    firebaseService.addItem(itemModel);

    N.toHomePage();
  }

  void backToHomePage() {
    N.toHomePage();
  }

  @override
  void onDetached() {}
  @override
  void onHidden() {}
  @override
  void onInactive() {}
  @override
  void onPaused() {}
  @override
  void onResumed() {}
}
