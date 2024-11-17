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
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Obx(() {
                      if (controller.image.value != null) {
                        return SizedBox(
                          child: Image.file(File(controller.image.value!.path)),
                        );
                      } else {
                        return const Text("No image captured");
                      }
                    }),
                    const SizedBox(height: 40,),
                    CustomLargeTextField(
                        readOnly: true,
                        textFieldName: 'HSD',
                        hintText: 'Halo',
                        isConstrain: true,
                        textEditingController: controller.expiryController),
                    const SizedBox(
                      height: 20,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomLargeTextField(
                        readOnly: true,
                        textFieldName: 'Area Name',
                        hintText: 'Area Name',
                        isConstrain: true,
                        textEditingController: controller.areaController
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomLargeTextField(
                        readOnly: true,
                        textFieldName: 'Order',
                        hintText: 'Order',
                        isConstrain: true,
                        textEditingController: controller.orderController
                    ),
                    const SizedBox(height: 20,),
                    CustomLargeTextField(
                        readOnly: false,
                        textFieldName: 'Product Name',
                        hintText: 'Enter Product Name',
                        isConstrain: true,
                        textEditingController: controller.productNameController
                    ),
                    const SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            controller.saveToDatabase();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: Colors.lightBlue
                            ),
                            width: 150,
                            height: 50,
                            child: const  Center(
                              child: Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            controller.backToHomePage();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                color: Colors.grey
                            ),
                            width: 150,
                            height: 50,
                            child: const  Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                    color: Colors.black26,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
