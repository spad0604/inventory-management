
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:la_tech/camera/view/widget/camera_view_extension.dart';

import '../../controllers/camera_controller/camera_controller.dart';

class CameraView extends GetView<AppCameraController> {
  const CameraView({super.key});

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
          _cameraFilter(context),
          _cameraExtension(
            flashStatus: true,
            takePhoto: controller.takeAPicture,
            context: context,
          )
        ],
      ),
    );
  }

  Widget _cameraExtension({
    required bool flashStatus,
    required Function takePhoto,
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

  Widget _cameraFilter(BuildContext context) {
    return Column(
      children: [
        Container(
          height: Get.size.height / 2 - 35,
          width: Get.size.width,
          color: Colors.black.withOpacity(0.75),
        ),
        Row(
          children: [
            Container(
              height: 70,
              width: Get.size.width / 2 - 105,
              color: Colors.black.withOpacity(0.75),
            ),
            Center(
              child: Container(
                height: 70,
                width: 210,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  color: Colors.transparent,
                ),
              ),
            ),
            Container(
              height: 70,
              width: Get.size.width / 2 - 105,
              color: Colors.black.withOpacity(0.75),
            ),
          ],
        ),
        Container(
          height: Get.size.height / 2 - 35,
          width: Get.size.width,
          color: Colors.black.withOpacity(0.75),
        ),
      ],
    );
  }
}

class AppBarWidget extends StatelessWidget {
  const AppBarWidget({
    required this.pageName,
    this.arrowBack,
    super.key
  });

  final String pageName;
  final Function()? arrowBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.only(bottom: 5),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F6F7),
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                child: Text(
                  pageName,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: arrowBack ?? Get.back,
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
