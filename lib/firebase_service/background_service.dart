import 'package:workmanager/workmanager.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';

// Định danh cho background task
const String expiryCheckerTask = "expiryCheckerTask";

// Callback phải là top-level function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (task != expiryCheckerTask) return Future.value(true);
      
      // Khởi tạo Firebase với options
      await Firebase.initializeApp();

      // Tăng delay lên để đảm bảo Firebase được khởi tạo hoàn toàn
      await Future.delayed(const Duration(seconds: 5));
      
      // Wrap phần notifications trong try-catch riêng
      try {
        final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();
        const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
        const initSettings = InitializationSettings(android: androidInitSettings);
        await notifications.initialize(
          initSettings,
          onDidReceiveNotificationResponse: (details) {}, // Thêm handler này
        );

        const androidDetails = AndroidNotificationDetails(
          'expiry_checker_channel',
          'Expiry Notifications',
          channelDescription: 'Notifications for product expiry dates',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        );

        // Kiểm tra sản phẩm
        final snapshot = await FirebaseDatabase.instance.ref().get();
        final now = DateTime.now();

        List<String> expiredMessages = [];
        List<String> nearExpiryMessages = [];

        for (var child in snapshot.children) {
          final product = child.value as Map<dynamic, dynamic>;
          
          if (product['expiry'] != null) {
            final expiryDate = DateFormat('dd/MM/yyyy').parse(product['expiry']);
            final difference = expiryDate.difference(now);
            final hoursLeft = difference.inHours;

            if (hoursLeft < 0) {
              final daysExpired = (hoursLeft / 24).abs().floor();
              expiredMessages.add('${product['productName']} đã hết hạn $daysExpired ngày');
            } else if (hoursLeft <= 240) { // 10 ngày
              final daysLeft = (hoursLeft / 24).ceil();
              nearExpiryMessages.add('${product['productName']} sẽ hết hạn trong $daysLeft ngày');
            }
          }
        }

        String notificationBody = '';
        if (expiredMessages.isNotEmpty) {
          notificationBody += 'Sản phẩm đã hết hạn:\n${expiredMessages.join('\n')}\n\n';
        }
        if (nearExpiryMessages.isNotEmpty) {
          notificationBody += 'Sản phẩm sắp hết hạn:\n${nearExpiryMessages.join('\n')}';
        }

        if (notificationBody.isNotEmpty) {
          await notifications.show(
            1, // Fixed ID to avoid multiple notifications
            'Thông báo hạn sử dụng sản phẩm',
            notificationBody.trim(),
            const NotificationDetails(android: androidDetails),
          );
        }
      } catch (notificationError) {
        print('Notification initialization error: $notificationError');
      }
      
      return Future.value(true);
    } catch (e) {
      print('Background task error: $e');
      print('Stack trace: ${StackTrace.current}');
      return Future.value(false);
    }
  });
}
