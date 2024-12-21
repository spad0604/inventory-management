import 'package:get/get.dart';
import 'package:la_tech/firebase_service/authencation_service.dart';
import 'package:la_tech/login_page/login_page_controller/login_page_controller.dart';

class LoginPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginPageController());

    Get.lazyPut(() => AuthenticationService());
  }
}