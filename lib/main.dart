import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:la_tech/firebase_service/background_service.dart';
import 'package:la_tech/firebase_service/expiry_checker.dart';
import 'package:la_tech/home_page/controllers/home_page_controller/home_page_controller.dart';
import 'package:la_tech/home_page/views/home_page_views/home_page_view.dart';
import 'dart:io';
import 'package:workmanager/workmanager.dart';

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

  // Khởi tạo Workmanager
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true // set false khi release
  );

  // Đăng ký periodic task
  await Workmanager().registerPeriodicTask(
    "1", // unique ID
    expiryCheckerTask,
    frequency: const Duration(minutes: 15), // tối thiểu 15 phút
    constraints: Constraints(
      networkType: NetworkType.connected,
      requiresBatteryNotLow: true,
      requiresCharging: false,
      requiresDeviceIdle: false,
    ),
    existingWorkPolicy: ExistingWorkPolicy.keep,
  );

  // Khởi tạo notifications
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
      
  const initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
      
  const initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
      
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Request notification permissions
  if (Platform.isAndroid) {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
  }

  Get.lazyPut(() => HomePageController());

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late ExpiryChecker _expiryChecker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.put(HomePageController());
    });
    
    _expiryChecker = ExpiryChecker(
      flutterLocalNotificationsPlugin: FlutterLocalNotificationsPlugin(),
      database: FirebaseDatabase.instance,
    );

    // Thay vì kiểm tra ngay lập tức, delay một chút
    Future.delayed(const Duration(seconds: 2), () {
      _expiryChecker.checkExpiryDates();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Thêm delay khi app resume
      Future.delayed(const Duration(seconds: 1), () {
        _expiryChecker.checkExpiryDates();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

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
