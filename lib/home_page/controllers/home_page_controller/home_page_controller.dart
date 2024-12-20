import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:la_tech/env/app_navigator.dart';
import 'package:la_tech/firebase_service/firebase_service.dart';
import 'package:la_tech/home_page/views/home_page_views/home_page_view.dart';
import 'package:la_tech/model/item_model.dart';

import '../../../camera/view/widget/delete_popup.dart';
import '../../../model/expiry_enum.dart';
import 'package:http/http.dart' as http;

class HomePageController extends SuperController {
  final FirebaseService firebaseService = FirebaseService();

  List<int> tickClassA = List.filled(11, 0);
  List<int> tickClassB = List.filled(11, 0);
  List<int> tickClassC = List.filled(11, 0);

  Rxn<int> orderValue = Rxn<int>();
  Rxn<String> areaValue = Rxn<String>();

  RxList<ItemModel> listItemClassA = <ItemModel>[].obs;
  RxList<ItemModel> listItemClassB = <ItemModel>[].obs;
  RxList<ItemModel> listItemClassC = <ItemModel>[].obs;

  RxList<ItemModel> nearExpiryClassA = <ItemModel>[].obs;
  RxList<ItemModel> nearExpiryClassB = <ItemModel>[].obs;
  RxList<ItemModel> nearExpiryClassC = <ItemModel>[].obs;

  // Add flag to track if popup has been shown
  bool _hasShownPopup = false;

  @override
  void onInit() async {
    await loadData();
    super.onInit();
  }

  Future<void> loadData() async {
    tickClassA.fillRange(0, 11, 0);
    tickClassB.fillRange(0, 11, 0);
    tickClassC.fillRange(0, 11, 0);

    firebaseService.getAllItemsStream().listen((items) {
      listItemClassA.clear();
      listItemClassB.clear();
      listItemClassC.clear();

      for (var item in items) {
        if (item.className == 'A') {
          listItemClassA.add(item);
        } else if (item.className == 'B') {
          listItemClassB.add(item);
        } else if (item.className == 'C') {
          listItemClassC.add(item);
        }
      }

      classAService();
      classBService();
      classCService();
      
      // Only show popup once when app starts
      if (!_hasShownPopup) {
        showNearExpiryPopup();
        _hasShownPopup = true;
      }
    });
  }

  void classAService() {
    nearExpiryClassA.clear();
    for (ItemModel itemModel in listItemClassA) {
      tickClassA[itemModel.order]++;

      if (itemModel.status == Expiry.nearExpiry ||
          itemModel.status == Expiry.expired) {
        nearExpiryClassA.add(itemModel);
      }
    }

    for (int i = 1; i <= 10; i++) {
      if (tickClassA[i] == 0) {
        ItemModel itemModel = ItemModel('A', '', '', Expiry.valid, i, null);
        listItemClassA.add(itemModel);
      }
    }

    listItemClassA.sort((a, b) => a.order.compareTo(b.order));
  }

  void classBService() {
    nearExpiryClassB.clear();
    for (ItemModel itemModel in listItemClassB) {
      tickClassB[itemModel.order]++;

      if (itemModel.status == Expiry.nearExpiry ||
          itemModel.status == Expiry.expired) {
        nearExpiryClassB.add(itemModel);
      }
    }

    for (int i = 1; i <= 10; i++) {
      if (tickClassB[i] == 0) {
        ItemModel itemModel = ItemModel('B', '', '', Expiry.valid, i, null);
        listItemClassB.add(itemModel);
      }
    }

    listItemClassB.sort((a, b) => a.order.compareTo(b.order));
  }

  void showDeletePopup(BuildContext context, Function() continueButton) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          content: DeletePopup(
            continueButton: continueButton,
          ),
        );
      },
    );
  }

    void classCService() {
    nearExpiryClassC.clear();
    for (ItemModel itemModel in listItemClassC) {
      tickClassC[itemModel.order]++;

      if (itemModel.status == Expiry.nearExpiry ||
          itemModel.status == Expiry.expired) {
        nearExpiryClassC.add(itemModel);
        print(itemModel.productName);
      }
    }

    for (int i = 1; i <= 10; i++) {
      if (tickClassC[i] == 0) {
        ItemModel itemModel = ItemModel('C', '', '', Expiry.valid, i, null);
        listItemClassC.add(itemModel);
      }
    }

    listItemClassC.sort((a, b) => a.order.compareTo(b.order));
  }

  Future<void> deleteItem(ItemModel itemModel, bool? isPopup) async {
    try {
      EasyLoading.show(status: 'Loading...'); 
      if (isPopup == null) {
        await firebaseService.deleteItem(itemModel);
        await deleteImageFromCloudinary(itemModel.className, itemModel.order);
        await loadData();
        Get.back();
      } else {
        await firebaseService.deleteItem(itemModel);
        await deleteImageFromCloudinary(itemModel.className, itemModel.order);
        await loadData();
        Get.back();
      }
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> deleteImageFromCloudinary(String area, int order) async {
    const String cloudName = "dhhdd4pkl";
    const String uploadPreset = "Inventor";
    const String apiKey = "919668245813367"; // Cần API Key để xóa
    const String apiSecret = "UEkNEm7d4cUChmbtxYAOXequn3A"; // Cần API Secret để xóa

    final String publicId = '${area}_${order}'; // Tên file cần xóa
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Tạo signature để xác thực
    final String signature = generateSignature(publicId, timestamp, apiSecret);

    const String deleteUrl =
        "https://api.cloudinary.com/v1_1/$cloudName/image/destroy";

    try {
      final response = await http.post(
        Uri.parse(deleteUrl),
        body: {
          'public_id': publicId,
          'api_key': apiKey,
          'timestamp': timestamp.toString(),
          'signature': signature,
        },
      );

      if (response.statusCode == 200) {
        print("Image deleted successfully");
        return true;
      } else {
        print("Failed to delete image: ${response.statusCode}");
        print("Response: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error deleting image: $e");
      return false;
    }
  }

  String generateSignature(String publicId, int timestamp, String apiSecret) {
    final String strToSign =
        'public_id=$publicId&timestamp=$timestamp$apiSecret';
    final bytes = utf8.encode(strToSign);
    final digest = sha1.convert(bytes);
    return digest.toString();
  }

  void showNearExpiryPopup() {
    for (ItemModel itemModel in nearExpiryClassC) {
      print(itemModel.productName);
    }
    Get.dialog(Dialog(
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: 600,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(
                  child: Text(
                    'Near Expiry',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Area A',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                Container(
                  height: 200,
                  child: Obx(
                    () => ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: nearExpiryClassA.length,
                        itemBuilder: (context, index) {
                          return ShoppingItem(
                            name: nearExpiryClassA[index].productName,
                            area: nearExpiryClassA[index].className,
                            order: nearExpiryClassA[index].order,
                            status: nearExpiryClassA[index].status,
                            expiry: nearExpiryClassA[index].expiry,
                            soldFunction: () {
                              showDeletePopup(
                                  context,
                                  () =>
                                      deleteItem(nearExpiryClassA[index], true));
                            },
                          );
                        }),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Area B',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                Container(
                  height: 200,
                  child: Obx(
                    () => ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: nearExpiryClassB.length,
                        itemBuilder: (context, index) {
                          return ShoppingItem(
                            name: nearExpiryClassB[index].productName,
                            area: nearExpiryClassB[index].className,
                            order: nearExpiryClassB[index].order,
                            status: nearExpiryClassB[index].status,
                            expiry: nearExpiryClassB[index].expiry,
                            soldFunction: () {
                              showDeletePopup(
                                  context,
                                  () =>
                                      deleteItem(nearExpiryClassB[index], true));
                            },
                          );
                        }),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Area C',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(
                  height: 200,
                  child: Obx(
                    () => ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: nearExpiryClassC.length,
                        itemBuilder: (context, index) {
                          return ShoppingItem(
                            name: nearExpiryClassC[index].productName,
                            area: nearExpiryClassC[index].className,
                            order: nearExpiryClassC[index].order,
                            status: nearExpiryClassC[index].status,
                            expiry: nearExpiryClassC[index].expiry,
                            soldFunction: () {
                              showDeletePopup(
                                  context,
                                  () =>
                                      deleteItem(nearExpiryClassC[index], true));
                            },
                          );
                        }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  void toCameraView(String area, int order) {
    orderValue.value = order;
    areaValue.value = area;
    N.toCameraView();
  }

  @override
  void onDetached() {}

  @override
  void onHidden() {}

  @override
  void onInactive() {}

  @override
  void onPaused() {}

  @override
  void onResumed() {}
}
