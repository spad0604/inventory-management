import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpiryChecker {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final FirebaseDatabase database;
  final _prefs = SharedPreferences.getInstance();
  static const _lastNotifyKey = 'last_notification_time';

  ExpiryChecker({
    required this.flutterLocalNotificationsPlugin,
    required this.database,
  });

  Future<void> checkExpiryDates() async {
    try {
      // Kiểm tra thời gian thông báo cuối
      final prefs = await _prefs;
      final lastNotifyTime = prefs.getInt(_lastNotifyKey) ?? 0;
      final now = DateTime.now();
      
      // Chỉ thông báo nếu đã qua 6 tiếng kể từ lần cuối
      if (now.millisecondsSinceEpoch - lastNotifyTime < const Duration(minutes: 1).inMilliseconds) {
        return;
      }

      final snapshot = await database.ref().get();
      
      // Tạo list để gom nhóm thông báo
      List<Map<String, String>> expiredProducts = [];
      List<Map<String, String>> nearExpiryProducts = [];

      for (var child in snapshot.children) {
        final product = child.value as Map<dynamic, dynamic>;
        
        if (product['expiry'] != null) {
          try {
            // Convert int to String if needed
            final expiryString = product['expiry'] is int 
                ? DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(product['expiry']))
                : product['expiry'] as String;
                
            final expiryDate = DateFormat('dd/MM/yyyy').parse(expiryString);
            final difference = expiryDate.difference(now);
            final hoursLeft = difference.inHours;

            final productInfo = {
              'name': product['productName'].toString(),
              'shelf': product['className'].toString(),
              'position': product['order'].toString(),
              'days': (hoursLeft / 24).abs().ceil().toString()
            };
            if (hoursLeft < 0) {
              expiredProducts.add(Map<String, String>.from(productInfo));
            } else if (hoursLeft <= 240) {
              nearExpiryProducts.add(Map<String, String>.from(productInfo));
            }
          } catch (e) {
            print('Lỗi xử lý ngày hết hạn: $e');
          }
        }
      }

      // Gửi thông báo gom nhóm
      if (expiredProducts.isNotEmpty) {
        _showGroupNotification(
          'Có ${expiredProducts.length} sản phẩm đã hết hạn!',
          _formatProductList(expiredProducts, isExpired: true),
          1
        );
      }

      if (nearExpiryProducts.isNotEmpty) {
        _showGroupNotification(
          'Có ${nearExpiryProducts.length} sản phẩm sắp hết hạn!',
          _formatProductList(nearExpiryProducts, isExpired: false),
          2
        );
      }

      // Lưu thời gian thông báo
      await prefs.setInt(_lastNotifyKey, now.millisecondsSinceEpoch);
    } catch (e) {
      print('Lỗi kiểm tra hết hạn: $e');
    }
  }

  String _formatProductList(List<Map<String, String>> products, {required bool isExpired}) {
    return products.map((p) => 
      '${p['name']} (kệ ${p['shelf']}, vị trí ${p['position']}) ' +
      (isExpired ? 'đã hết hạn ${p['days']} ngày' : 'sẽ hết hạn trong ${p['days']} ngày')
    ).join('\n');
  }

  Future<void> _showGroupNotification(String title, String body, int id) async {
    const androidDetails = AndroidNotificationDetails(
      'expiry_checker_channel',
      'Expiry Notifications',
      channelDescription: 'Notifications for product expiry dates',
      importance: Importance.high,
      priority: Priority.high,
      groupKey: 'expiry_group',
      setAsGroupSummary: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }
}
