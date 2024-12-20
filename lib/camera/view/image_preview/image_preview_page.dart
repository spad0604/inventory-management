import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:la_tech/camera/controllers/image_preview_controller/image_preview_controller.dart';
import 'package:la_tech/camera/view/camera_view/camera_view.dart';
import 'package:la_tech/camera/view/widget/camera_view_extension.dart';

class ImagePreviewPage extends GetView<ImagePreviewController> {
  const ImagePreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppBarWidget(
                pageName: 'Preview',
                arrowBack: () {
                  controller.backToCamera();
                },
              ),
              Container(
                height: Get.height,
                color: const Color(0xFFF8F6F7),
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(() {
                        if (controller.image.value != null) {
                          return SizedBox(
                            child:
                                Image.file(File(controller.image.value!.path)),
                          );
                        } else {
                          return const Text("No image captured");
                        }
                      }),
                      const SizedBox(
                        height: 40,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Obx(() => CustomLargeTextField(
                                readOnly: controller.readOnly.value,
                                textFieldName: 'HSD',
                                hintText: 'HSD',
                                isConstrain: true,
                                textEditingController:
                                    controller.expiryController)),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              controller.expiryController.text = '';
                              controller.readOnly.value =
                                  !controller.readOnly.value;
                            },
                            child: const Icon(
                              Icons.edit,
                              color: Colors.black,
                              size: 30,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomLargeTextField(
                          readOnly: true,
                          textFieldName: 'Area Name',
                          hintText: 'Area Name',
                          isConstrain: true,
                          textEditingController: controller.areaController),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomLargeTextField(
                          readOnly: true,
                          textFieldName: 'Order',
                          hintText: 'Order',
                          isConstrain: true,
                          textEditingController: controller.orderController),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomLargeTextField(
                          readOnly: false,
                          textFieldName: 'Product Name',
                          hintText: 'Enter Product Name',
                          isConstrain: true,
                          textEditingController:
                              controller.productNameController),
                      const SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            controller.toCaptureItem();
                          },
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            child: Obx(
                              () => Center(
                                  child: controller.captureImage.value == null
                                      ? (const Icon(
                                          Icons.image,
                                          size: 50,
                                          color: Colors.black54,
                                        ))
                                      : Image.file(File(controller
                                          .captureImage.value!.path))),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                controller.isActiveButton.value == true
                                    ? controller.saveToDatabase()
                                    : null;
                              },
                              child: Obx(
                                () => Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      color: controller.isActiveButton.value ==
                                              true
                                          ? Colors.lightBlue
                                          : Colors.black54),
                                  height: 50,
                                  child: const Center(
                                    child: Text(
                                      'Save',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                controller.backToHomePage();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: Colors.grey),
                                height: 50,
                                child: const Center(
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                        color: Colors.black26,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
