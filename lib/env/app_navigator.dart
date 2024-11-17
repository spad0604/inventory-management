import 'package:get/get.dart';
import 'package:la_tech/env/route_type.dart';

import 'app_route.dart';

class N {
  static void popUntilRoot() {
    Get.until((route) => route.isFirst);
  }

  static void closeAllDialog() {
    Get.until((route) => Get.isDialogOpen == false);
  }

  static void toHomePage({RouteType type = RouteType.offAll}) {
    type.navigate(name: AppRoute.HOME_PAGE);
  }

  static void toCameraView({RouteType type = RouteType.to}) {
    type.navigate(name: AppRoute.CAMERA_VIEW);
  }

  static void toImagePreview({RouteType type = RouteType.to}) {
    type.navigate(name: AppRoute.IMAGE_PREVIEW);
  }
}