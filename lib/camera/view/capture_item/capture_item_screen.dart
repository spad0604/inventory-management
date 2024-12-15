import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:la_tech/camera/controllers/image_preview_controller/image_preview_controller.dart';

class CaptureItemScreen extends GetView<ImagePreviewController> {
  const CaptureItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Obx(
            () => controller.isCameraInitialized.value
                ? SizedBox.expand(
                    child: CameraPreview(controller.cameraController),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          Obx(
            () => _cameraExtension(
              flashMode: controller.onTapOpenFlash,
              flashStatus: controller.cameraStatus.value,
              takePhoto: controller.takeAPicture,
              context: context,
            ),
          )
        ],
      ),
    );
  }

  Widget _cameraExtension({
    required bool flashStatus,
    required Function takePhoto,
    required Function flashMode,
    required BuildContext context,
  }) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 20),
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: Get.back,
                      child: const Icon(
                        Icons.clear,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        flashMode();
                      },
                      child: Icon(
                        flashStatus ? Icons.flash_on : Icons.flash_off,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                takePhotoButton(takePhoto: takePhoto),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget takePhotoButton({required Function takePhoto}) {
    return GestureDetector(
      onTap: () {
        takePhoto();
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.withOpacity(0.5),
          border: Border.all(
            color: Colors.white,
            width: 6,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.01),
          ),
        ),
      ),
    );
  }
}
