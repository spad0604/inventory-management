import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:la_tech/env/app_navigator.dart';
import 'package:la_tech/firebase_service/firebase_service.dart';
import 'package:la_tech/model/item_model.dart';

import '../../../camera/view/widget/delete_popup.dart';
import '../../../model/expiry_enum.dart';

class HomePageController extends SuperController {
  final FirebaseService firebaseService = FirebaseService();

  List<int> tickClassA = List.filled(6, 0);
  List<int> tickClassB = List.filled(6, 0);
  List<int> tickClassC = List.filled(6, 0);

  Rxn<int> orderValue = Rxn<int>();
  Rxn<String> areaValue = Rxn<String>();

  RxList<ItemModel> listItemClassA = <ItemModel>[].obs;
  RxList<ItemModel> listItemClassB = <ItemModel>[].obs;
  RxList<ItemModel> listItemClassC = <ItemModel>[].obs;

  @override
  void onInit() async {
    await loadData();
    super.onInit();
  }

  Future<void> loadData() async {
    tickClassA.fillRange(0, 6, 0);
    tickClassB.fillRange(0, 6, 0);
    tickClassC.fillRange(0, 6, 0);

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
    for (ItemModel itemModel in listItemClassA) {
      tickClassA[itemModel.order]++;
    }

    for (int i = 1; i <= 5; i++) {
      if (tickClassA[i] == 0) {
        ItemModel itemModel = ItemModel('A', '', '', Expiry.valid, i);
        listItemClassA.add(itemModel);
      }
    }

    listItemClassA.sort((a, b) => a.order.compareTo(b.order));
  }

  void classBService() {
    for (ItemModel itemModel in listItemClassB) {
      tickClassB[itemModel.order]++;
    }

    for (int i = 1; i <= 5; i++) {
      if (tickClassB[i] == 0) {
        ItemModel itemModel = ItemModel('B', '', '', Expiry.valid, i);
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

  void deleteItem(ItemModel itemModel) async {
    firebaseService.deleteItem(itemModel);

    loadData();

    Get.back();
  }

  void classCService() {
    for (ItemModel itemModel in listItemClassC) {
      tickClassC[itemModel.order]++;
    }

    for (int i = 1; i <= 5; i++) {
      if (tickClassC[i] == 0) {
        ItemModel itemModel = ItemModel('C', '', '', Expiry.valid, i);
        listItemClassC.add(itemModel);
      }
    }

    listItemClassC.sort((a, b) => a.order.compareTo(b.order));
  }

  void toCameraView(String area, int order) {
    orderValue.value = order;
    areaValue.value = area;
    N.toCameraView();
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
