import 'package:firebase_database/firebase_database.dart';
import 'package:la_tech/model/item_model.dart';
import 'package:intl/intl.dart';
import '../model/expiry_enum.dart';

class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  void addItem(ItemModel item) {
    _database.child('/data').push().set({
      'key': '${item.productName}_${item.className}_${item.order}',
      'productName': item.productName,
      'className': item.className,
      'order': item.order,
      'expiry': item.expiry,
    });
  }

  Future<void> deleteItem(ItemModel item) async {
    final snapshot = await _database.child('/data').get();
    if (snapshot.exists) {
      final data = snapshot.value as List<dynamic>;
      final updatedData = data.where((element) {
        if (element == null) return false; // Filter out null values
        final map = element as Map<dynamic, dynamic>;
        return !(map['key'] ==
            '${item.productName}_${item.className}_${item.order}');
      }).toList();
      await _database.child('/data').set(updatedData);
    }
  }

  Stream<List<ItemModel>> getAllItemsStream() {
    return _database.child('/data').onValue.map((event) {
      final rawData = event.snapshot.value;

      if (rawData is Map<dynamic, dynamic>) {
        // Xử lý khi dữ liệu là Map
        return rawData.entries.map((entry) {
          final value = entry.value as Map<dynamic, dynamic>;

          final String key = value['key'] ?? '';
          final String className = value['className'] ?? '';
          final String productName = value['productName'] ?? '';
          final String expiry = value['expiry'] ?? '';
          final int order = value['order'] ?? 0;

          DateTime expiryDate = parseExpiryDate(expiry);
          Expiry status = getExpirationStatus(expiryDate);

          return ItemModel(
            key,
            className,
            productName,
            expiry,
            status,
            order,
            null,
          );
        }).toList();
      } else if (rawData is List<dynamic>) {
        // Xử lý khi dữ liệu là List
        return rawData
            .map((item) {
              if (item is Map<dynamic, dynamic>) {
                final String key = item['key'] ?? '';
                final String className = item['className'] ?? '';
                final String productName = item['productName'] ?? '';
                final String expiry = item['expiry'] ?? '';
                final int order = item['order'] ?? 0;

                DateTime expiryDate = parseExpiryDate(expiry);
                Expiry status = getExpirationStatus(expiryDate);

                return ItemModel(
                  key,
                  className,
                  productName,
                  expiry,
                  status,
                  order,
                  null,
                );
              }
              return null; // Nếu item không phải là Map, bỏ qua
            })
            .whereType<ItemModel>()
            .toList(); // Lọc bỏ giá trị null
      } else {
        return []; // Trường hợp dữ liệu không hợp lệ
      }
    });
  }

  DateTime parseExpiryDate(String expiry) {
    return DateFormat('d/MM/yyyy').parse(expiry);
  }

  Expiry getExpirationStatus(DateTime expiryDate) {
    DateTime now = DateTime.now();
    int differenceInDays = expiryDate.difference(now).inDays;

    if (differenceInDays < 0) {
      return Expiry.expired;
    } else if (differenceInDays <= 30) {
      return Expiry.nearExpiry;
    } else {
      return Expiry.valid;
    }
  }
}
