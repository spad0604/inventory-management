import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:la_tech/home_page/controllers/home_page_controller/home_page_controller.dart';
import 'package:la_tech/home_page/views/home_page_views/home_page_view.dart';

import 'env/app_route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBxuEflztZGUb7VAGyXbxGAX-NWbAjo1kQ',
      appId: '1:43603538044:android:8abc3962a9b845059c59f9',
      messagingSenderId: '43603538044',
      projectId: 'inventory-management-e4022',
      storageBucket: 'inventory-management-e4022.firebasestorage.app',
      databaseURL:
          'https://inventory-management-e4022-default-rtdb.firebaseio.com',
    ),
  );
  Get.put(HomePageController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(fontFamily: 'Poppins'),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoute.HOME_PAGE,
      getPages: AppRoute.generateGetPages,
      home: const HomePageView(),
    );
  }
}