import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import '../../../env/app_navigator.dart';

class AppCameraController extends SuperController {
  late CameraController cameraController;
  late List<CameraDescription> cameras;
  Rxn<XFile> image = Rxn<XFile>();
  RxBool isCameraInitialized = false.obs;
  Rx<bool> cameraStatus = false.obs;

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      cameras = await availableCameras();
      cameraController = CameraController(cameras[0], ResolutionPreset.medium);
      await cameraController.initialize();
      isCameraInitialized.value = true;
    } catch (e) {
      isCameraInitialized.value = false;
    }
  }

  Future<void> takeAPicture() async {
    if (!isCameraInitialized.value) {
      return;
    }
    try {
      image.value = await cameraController.takePicture();

      final imageFile = File(image.value!.path);
      final img.Image? capturedImage = img.decodeImage(await imageFile.readAsBytes());

      if (capturedImage != null) {
        int cropWidth = 210;
        int cropHeight = 70;
        int centerX = (capturedImage.width / 2).round() - 10;
        int centerY = (capturedImage.height / 2).round() - 10;
        int startX = (centerX - cropWidth / 2).round();
        int startY = (centerY - cropHeight / 2).round();

        final img.Image croppedImage = img.copyCrop(
          capturedImage,
          x: startX,
          y: startY,
          width: cropWidth,
          height: cropHeight,
        );

        final croppedImagePath = '${imageFile.parent.path}/cropped_image.jpg';
        final croppedFile = await File(croppedImagePath).writeAsBytes(img.encodeJpg(croppedImage));

        image.value = XFile(croppedFile.path);

        N.toImagePreview();
      }
    } catch (e) {
    }
  }

  void resetData() {
    image.value = null;
  }

  @override
  void onResumed() {
    if (!isCameraInitialized.value) {
      initializeCamera();
    } else {
      resetData();
    }
  }

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }

  void onTapOpenFlash() async {
    cameraStatus.value = !cameraStatus.value;
    if(cameraStatus.value == true) {
      await cameraController.setFlashMode(FlashMode.torch);
    } else {
      await cameraController.setFlashMode(FlashMode.off);
    }
  }

  @override
  void onDetached() {}
  @override
  void onHidden() {}
  @override
  void onInactive() {}
  @override
  void onPaused() {}
}
