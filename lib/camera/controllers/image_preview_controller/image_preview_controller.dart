import 'dart:core';

import 'package:camera/camera.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:la_tech/firebase_service/firebase_service.dart';
import 'package:la_tech/home_page/controllers/home_page_controller/home_page_controller.dart';
import 'package:la_tech/model/item_model.dart';

import '../../../env/app_navigator.dart';
import '../../../model/expiry_enum.dart';
import '../camera_controller/camera_controller.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

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

  //Capture Item
  late CameraController cameraController;
  late List<CameraDescription> cameras;
  Rxn<XFile> captureImage = Rxn<XFile>();
  RxBool isCameraInitialized = false.obs;
  Rx<bool> cameraStatus = false.obs;
  Rx<int> cameraStatusValue = 0.obs;

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

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> captureAndRecognizeText() async {
    image.value = appCameraController.image.value;
    try {
      if (image.value != null) {
        final inputImage = InputImage.fromFilePath(image.value!.path);
        final recognizedTextResult =
            await textRecognizer.processImage(inputImage);

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

  void saveToDatabase() async {
    EasyLoading.show(status: 'Loading...');
    DateTime expiryDate =
        firebaseService.parseExpiryDate(expiryController.text);

    Expiry status = firebaseService.getExpirationStatus(expiryDate);

    if (productNameController.text.isEmpty) {
      productNameController.text = 'null';
    }

    final ItemModel itemModel = ItemModel(
        areaController.text,
        productNameController.text,
        expiryController.text,
        status,
        int.parse(orderController.text),
        null);
    firebaseService.addItem(itemModel);

    if (captureImage.value != null) {
      final imageUrl =
          await uploadImageToCloudinary(File(captureImage.value!.path));
      debugPrint('Image URL: $imageUrl');
    } else {
      deleteImageFromCloudinary(areaController.text, int.parse(orderController.text));
    }
    EasyLoading.dismiss();

    N.toHomePage();
  }

  void backToHomePage() {
    N.toHomePage();
  }

  void toCaptureItem() async {
    N.toCaptureItem();

    await initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      cameras = await availableCameras();
      cameraController = CameraController(cameras[0], ResolutionPreset.high);
      await cameraController.initialize();
      isCameraInitialized.value = true;
    } catch (e) {
      isCameraInitialized.value = false;
    }
  }

  Future<void> takeAPicture() async {
    if (isCameraInitialized.value == false) {
      return;
    }
    try {
      captureImage.value = await cameraController.takePicture();
    } catch (e) {
      debugPrint('Error taking picture: $e');
    } finally {
      Get.back();
    }
  }

  void onTapOpenFlash() async {
    cameraStatus.value = !cameraStatus.value;
    if (cameraStatus.value == true) {
      await cameraController.setFlashMode(FlashMode.torch);
    } else {
      await cameraController.setFlashMode(FlashMode.off);
    }
  }

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    const String cloudName = "dhhdd4pkl";
    const String uploadPreset = "Inventor";

    const String uploadUrl =
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

    try {
      // Tên file đơn giản: area_order (VD: A_1, B_2, C_3)
      String fileName = '${areaController.text}_${orderController.text}';

      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
        ..fields['upload_preset'] = uploadPreset
        ..fields['public_id'] = fileName
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseData);
        return jsonResponse['secure_url'];
      } else {
        print("Failed to upload image: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<bool> deleteImageFromCloudinary(String area, int order) async {
    const String cloudName = "dhhdd4pkl";
    const String uploadPreset = "Inventor";
    const String apiKey = "919668245813367"; // Cần API Key để xóa
    const String apiSecret = "UEkNEm7d4cUChmbtxYAOXequn3A"; // Cần API Secret để xóa

    final String publicId = '${area}_${order}'; // Tên file cần xóa
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Tạo signature để xác thực
    final String signature = generateSignature(publicId, timestamp, apiSecret);

    const String deleteUrl =
        "https://api.cloudinary.com/v1_1/$cloudName/image/destroy";

    try {
      final response = await http.post(
        Uri.parse(deleteUrl),
        body: {
          'public_id': publicId,
          'api_key': apiKey,
          'timestamp': timestamp.toString(),
          'signature': signature,
        },
      );

      if (response.statusCode == 200) {
        print("Image deleted successfully");
        return true;
      } else {
        print("Failed to delete image: ${response.statusCode}");
        print("Response: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error deleting image: $e");
      return false;
    }
  }
  String generateSignature(String publicId, int timestamp, String apiSecret) {
    final String strToSign =
        'public_id=$publicId&timestamp=$timestamp$apiSecret';
    final bytes = utf8.encode(strToSign);
    final digest = sha1.convert(bytes);
    return digest.toString();
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
  void onResumed() {
    if (!isCameraInitialized.value) {
      initializeCamera();
    }
  }
}
