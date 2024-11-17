import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:la_tech/camera/view/camera_view/camera_view.dart';
import 'package:la_tech/home_page/controllers/home_page_controller/home_page_controller.dart';

import '../../../model/expiry_enum.dart';

class HomePageView extends GetView<HomePageController> {
  const HomePageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const AppBarWidget(pageName: 'Home Page'),
              Container(
                color: const Color(0xFFF8F6F7),
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Text(
                        'Area A',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Obx(
                          () => Row(
                            children: List.generate(
                              controller.listItemClassA.length,
                              (index) {
                                var item = controller.listItemClassA[index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: ShoppingItem(
                                    area: item.className,
                                    order: item.order,
                                    name: item.productName,
                                    status: item.status,
                                    expiry: item.expiry,
                                    scanFunction: controller.toCameraView,
                                    soldFunction: () {
                                      controller.showDeletePopup(
                                        context,
                                        () => controller.deleteItem(item),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Area B',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Obx(
                          () => Row(
                            children: List.generate(
                              controller.listItemClassB.length,
                              (index) {
                                var item = controller.listItemClassB[index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: ShoppingItem(
                                    area: item.className,
                                    order: item.order,
                                    name: item.productName,
                                    status: item.status,
                                    expiry: item.expiry,
                                    scanFunction: controller.toCameraView,
                                    soldFunction: () {
                                      controller.showDeletePopup(
                                        context,
                                        () => controller.deleteItem(item),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Area C',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Obx(
                          () => Row(
                            children: List.generate(
                              controller.listItemClassC.length,
                              (index) {
                                var item = controller.listItemClassC[index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: ShoppingItem(
                                    area: item.className,
                                    order: item.order,
                                    name: item.productName,
                                    status: item.status,
                                    expiry: item.expiry,
                                    scanFunction: (area, order) =>
                                        controller.toCameraView(area, order),
                                    soldFunction: () {
                                      controller.showDeletePopup(
                                        context,
                                        () => controller.deleteItem(item),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShoppingItem extends StatelessWidget {
  const ShoppingItem(
      {super.key,
      required this.name,
      this.status,
      this.scanFunction,
      this.soldFunction,
      this.expiry,
      required this.area,
      required this.order});

  final String name;
  final String area;
  final int order;
  final Expiry? status;
  final String? expiry;
  final Function(String, int)? scanFunction;
  final void Function()? soldFunction;

  @override
  Widget build(BuildContext context) {
    if (name == '') {
      return Container(
        height: 180,
        width: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.25),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: CustomPaint(
              size: const Size(50, 50),
              painter: DashRectPainter(),
              child: GestureDetector(
                onTap: () {
                  scanFunction!(area, order);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  color: Colors.white.withOpacity(0.5),
                  child: const Center(
                    child: Text(
                      '+',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              )),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(10),
        height: 180,
        width: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.25),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    soldFunction!();
                  },
                  child: const Icon(
                    Icons.clear,
                    size: 30,
                    color: Colors.blue,
                  ),
                ),
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      color: status?.color,
                      borderRadius: BorderRadius.circular(30)),
                )
              ],
            ),
            const SizedBox(height: 20),
            Center(
                child: Image.asset(
              'assets/images/png/item.png',
              width: 50,
              height: 50,
            )),
            const SizedBox(
              height: 5,
            ),
            Text(
              overflow: TextOverflow.ellipsis,
              name,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              overflow: TextOverflow.ellipsis,
              'HSD $expiry',
              style: const TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            )
          ],
        ),
      );
    }
  }
}

class DashRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double dashWidth = 5;
    double dashSpace = 3;
    double startX = 0;
    double startY = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }

    startX = size.width;
    startY = 0;

    while (startY < size.height) {
      canvas.drawLine(Offset(size.width, startY),
          Offset(size.width, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }

    startX = size.width;
    startY = size.height;
    while (startX > 0) {
      canvas.drawLine(Offset(startX, size.height),
          Offset(startX - dashWidth, size.height), paint);
      startX -= dashWidth + dashSpace;
    }

    startX = 0;
    startY = size.height;
    while (startY > 0) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY - dashWidth), paint);
      startY -= dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
