import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import 'env/app_route.dart';
import 'home_page/controllers/home_page_controller/home_page_controller.dart';
import 'home_page/views/home_page_views/home_page_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await requestNotificationPermission();
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

  await initializeService();

  Get.lazyPut(() => HomePageController());
  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
      iosConfiguration:
          IosConfiguration(onForeground: onStart, autoStart: true),
      androidConfiguration: AndroidConfiguration(
          onStart: onStart, isForegroundMode: true, autoStart: true));

  await service.startService();
}

void onStart(ServiceInstance service) async {
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

  // Initialize notifications here once
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  notificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null) {
        // Handle notification response if necessary
      }
    },
  );

  Timer.periodic(Duration(minutes: 15), (timer) async {
    String notification = "";
    List<String> notifications = []; // List to store multiple notifications

    final snapshot = await databaseRef.child('/').get();
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

    // Nếu có thông báo, hiển thị một thông báo tổng hợp
    for(int i = 0; i < notifications.length; i++) {
      notification += notifications[i];
    }
    if (notifications.isNotEmpty) {
  print(notifications);
  notificationsPlugin.show(
    0,
    'Product Expiry Alert',
    notification, // Hiển thị thông báo tổng hợp
    NotificationDetails(
      android: AndroidNotificationDetails(
        vibrationPattern: Int64List.fromList([0, 5000, 1000, 2000, 1000, 2000]),
        'expiry_channel',
        'Expiry Alerts',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        styleInformation: BigTextStyleInformation(
          notification, // Set the big text style
          contentTitle: 'Product Expiry Alert',
          summaryText: 'Multiple products are expiring soon or have expired',
        ),
      ),
    ),
  );
}

service.on('stopService').listen((event) {
  service.stopSelf();
});
  });

  service.on('stopService').listen((event) {
    service.stopSelf();
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
      initialRoute: AppRoute.HOME_PAGE,
      getPages: AppRoute.generateGetPages,
      home: const HomePageView(),
      builder: EasyLoading.init(),
    );
  }
}

Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    Permission.notification.request();
  }
}
