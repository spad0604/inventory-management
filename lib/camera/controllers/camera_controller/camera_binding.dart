import 'package:get/get.dart';
import 'package:la_tech/camera/controllers/image_preview_controller/image_preview_controller.dart';

import 'camera_controller.dart';

class CameraBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(AppCameraController.new);

    Get.lazyPut(ImagePreviewController.new);
  }
}