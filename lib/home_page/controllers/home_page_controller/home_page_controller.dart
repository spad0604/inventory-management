import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:la_tech/env/app_navigator.dart';
import 'package:la_tech/firebase_service/firebase_service.dart';
import 'package:la_tech/home_page/views/home_page_views/home_page_view.dart';
import 'package:la_tech/model/item_model.dart';

import '../../../camera/view/widget/delete_popup.dart';
import '../../../model/expiry_enum.dart';

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

  void deleteItem(ItemModel itemModel, bool? isPopup) async {
    if (isPopup == null) {
      firebaseService.deleteItem(itemModel);
      loadData();
      Get.back();
    } else {
      firebaseService.deleteItem(itemModel);
      loadData();
      Get.back();
      Get.back();
    }
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

    showNearExpiryPopup();
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
