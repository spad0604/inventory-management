import 'package:get/get.dart';
import 'package:la_tech/camera/controllers/camera_controller/camera_controller.dart';
import 'package:la_tech/camera/controllers/image_preview_controller/image_preview_controller.dart';
import 'package:la_tech/home_page/controllers/home_page_controller/home_page_controller.dart';

class ImagePreviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(ImagePreviewController.new);

    Get.put(AppCameraController.new);

    Get.put(HomePageController.new);
  }
}