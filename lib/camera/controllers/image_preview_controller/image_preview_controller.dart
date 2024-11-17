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

        debugPrint(recognizedTextResult.text);
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
    final regex = RegExp(r'HSD: (\d{2}/\d{2}/\d{4})');
    final match = regex.firstMatch(text);

    if (match != null) {
      return match.group(1) ?? "Không tìm thấy hạn sử dụng";
    } else {
      return "Không tìm thấy hạn sử dụng";
    }
  }

  void saveToDatabase() {
    DateTime expiryDate = firebaseService.parseExpiryDate(expiryController.text);

    Expiry status = firebaseService.getExpirationStatus(expiryDate);

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
