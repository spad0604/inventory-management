// ignore_for_file: non_constant_identifier_names
import 'package:get/get.dart';
import 'package:la_tech/camera/controllers/image_preview_controller/image_preview_binding.dart';
import 'package:la_tech/camera/view/camera_view/camera_view.dart';
import 'package:la_tech/camera/view/capture_item/capture_item_screen.dart';
import 'package:la_tech/camera/view/image_preview/image_preview_page.dart';
import 'package:la_tech/home_page/views/home_page_views/home_page_view.dart';
import 'package:la_tech/login_page/login_page_controller/login_page_binding.dart';
import 'package:la_tech/login_page/login_page_view/login_page_screen.dart';

import '../camera/controllers/camera_controller/camera_binding.dart';
import '../home_page/controllers/home_page_controller/home_page_binding.dart';

class AppRoute {
  static String LOGIN_PAGE = '/login_page';

  static String HOME_PAGE = "/home_page";

  static String CAMERA_VIEW = '/camera_view';

  static String IMAGE_PREVIEW = '/image_preview';

  static String CAPTURE_ITEM = '/capture_item';

  static List<GetPage> generateGetPages = [
    GetPage(
        name: LOGIN_PAGE,
        page: LoginPageScreen.new,
        binding: LoginPageBinding()),
    GetPage(
        name: HOME_PAGE, page: HomePageView.new, binding: HomePageBinding()),
    GetPage(name: CAMERA_VIEW, page: CameraView.new, binding: CameraBinding()),
    GetPage(
        name: IMAGE_PREVIEW,
        page: ImagePreviewPage.new,
        binding: ImagePreviewBinding()),
    GetPage(
        name: CAPTURE_ITEM,
        page: CaptureItemScreen.new,
        binding: ImagePreviewBinding()),
  ];

  static GetPage? getPage(String name) {
    return generateGetPages.firstWhereOrNull((e) => e.name == name);
  }
}
