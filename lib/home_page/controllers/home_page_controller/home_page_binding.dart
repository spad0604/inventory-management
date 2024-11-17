import 'package:get/get.dart';
import 'package:la_tech/camera/controllers/camera_controller/camera_controller.dart';
import 'package:la_tech/home_page/controllers/home_page_controller/home_page_controller.dart';

class HomePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(HomePageController.new);

    Get.put(AppCameraController.new);
  }
}