import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:la_tech/env/app_navigator.dart';
import 'package:la_tech/firebase_service/authencation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPageController extends SuperController {
  final AuthenticationService authenticationService = Get.find();

  TextEditingController account = TextEditingController();
  TextEditingController password = TextEditingController();
  RxBool isShowPassword = true.obs;

  @override
  void onInit() async {
     SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
     if(sharedPreferences.getBool('isLogin') == true){
       account.text = sharedPreferences.getString('account') ?? '';
       password.text = sharedPreferences.getString('password') ?? '';
       await onPressedButton();
     }
    super.onInit();
  }

  Future<void> onPressedButton() async {
    EasyLoading.show(status: 'Login...');
    var result = await authenticationService.signInWithEmailAndPassword(
        account.text, password.text);
    if (result is UserCredential) {
      N.toHomePage();
      print("Đăng nhập thành công: ${result.user?.email}");
      Get.snackbar("Thành công", "Đăng nhập thành công",
          snackPosition: SnackPosition.BOTTOM);
    } else if (result is String) {
      // Đăng nhập thất bại, hiển thị thông báo lỗi
      print("Lỗi: $result");
      Get.snackbar("Lỗi", result, snackPosition: SnackPosition.BOTTOM);
    }
    EasyLoading.dismiss();
  }

  @override
  void onDetached() {
    // TODO: implement onDetached
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }

  @override
  void onPaused() {
    // TODO: implement onPaused
  }

  @override
  void onResumed() {
    // TODO: implement onResumed
  }
}
