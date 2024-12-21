import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:la_tech/login_page/login_page_controller/login_page_controller.dart';
import 'package:la_tech/login_page/login_page_view/login_page_screen.dart';
import 'package:workmanager/workmanager.dart';

import 'env/app_route.dart';
import 'home_page/controllers/home_page_controller/home_page_controller.dart';
import 'home_page/views/home_page_views/home_page_view.dart';

const String taskCheckExpiry = "checkExpiryTask";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBxuEflztZGUb7VAGyXbxGAX-NWbAjo1kQ',
      appId: '1:43603538044:android:8abc3962a9b845059c59f9',
      messagingSenderId: '43603538044',
      projectId: 'inventory-management-e4022',
      storageBucket: 'inventory-management-e4022.appspot.com',
      databaseURL:
          'https://inventory-management-e4022-default-rtdb.firebaseio.com',
    ),
  );

  // Khởi tạo WorkManager
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  // Đăng ký tác vụ lặp lại
  Workmanager().registerPeriodicTask(
    taskCheckExpiry,
    taskCheckExpiry,
    frequency: const Duration(minutes: 15), // Thay đổi tùy yêu cầu
  );

  Get.lazyPut(() => LoginPageController());
  runApp(const MyApp());
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == taskCheckExpiry) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyBxuEflztZGUb7VAGyXbxGAX-NWbAjo1kQ',
          appId: '1:43603538044:android:8abc3962a9b845059c59f9',
          messagingSenderId: '43603538044',
          projectId: 'inventory-management-e4022',
          storageBucket: 'inventory-management-e4022.appspot.com',
          databaseURL:
              'https://inventory-management-e4022-default-rtdb.firebaseio.com',
        ),
      );

      final databaseRef = FirebaseDatabase.instance.ref();
      final FlutterLocalNotificationsPlugin notificationsPlugin =
          FlutterLocalNotificationsPlugin();

      // Initialize notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
      notificationsPlugin.initialize(initializationSettings);

      // Check product expiry logic
      String notification = "";
      List<String> notifications = [];

      final snapshot = await databaseRef.child('/data').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final now = DateTime.now();
        data.forEach((key, value) {
          final expiryString = value['expiry'] as String?;
          if (expiryString != null) {
            final expiryDate = DateFormat("dd/MM/yyyy").parse(expiryString);
            final difference = expiryDate.difference(now).inDays;

            if (difference < 0) {
              notifications.add(
                  'Sản phẩm "${value['productName']}" ở kệ "${value['className']}" thứ tự "${value['order']}" đã hết hạn vào ngày ${expiryString}.\n');
            } else if (difference < 30) {
              notifications.add(
                  'Sản phẩm "${value['productName']}" ở kệ "${value['className']}" thứ tự "${value['order']}" sắp hết hạn vào ngày ${expiryString}.\n');
            }
          }
        });
      }

      if (notifications.isNotEmpty) {
        notification = notifications.join('\n');
        notificationsPlugin.show(
          0,
          'Product Expiry Alert',
          notification,
          NotificationDetails(
            android: AndroidNotificationDetails(
              vibrationPattern:
                  Int64List.fromList([0, 5000, 1000, 2000, 1000, 2000]),
              'expiry_channel',
              'Expiry Alerts',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              styleInformation: BigTextStyleInformation(
                notification,
                contentTitle: 'Product Expiry Alert',
                summaryText:
                    'Multiple products are expiring soon or have expired',
              ),
            ),
          ),
        );
      }
    }
    return Future.value(true);
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(fontFamily: 'Poppins'),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoute.LOGIN_PAGE,
      getPages: AppRoute.generateGetPages,
      home: LoginPageScreen(),
      builder: EasyLoading.init(),
    );
  }
}
