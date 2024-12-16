import 'package:firebase_database/firebase_database.dart';
import 'package:la_tech/model/item_model.dart';
import 'package:intl/intl.dart';
import '../model/expiry_enum.dart';

class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  void addItem(ItemModel item) {
    _database.child('/${item.productName}_${item.className}_${item.order}').set({
      'productName': item.productName,
      'className': item.className,
      'order': item.order,
      'expiry': item.expiry,
    });
  }

  Future<void> deleteItem(ItemModel item) async {
    await _database.child('/${item.productName}_${item.className}_${item.order}').remove();
  }

  Stream<List<ItemModel>> getAllItemsStream() {
    return _database.child('/').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        return data.entries.map((entry) {
          final value = entry.value as Map<dynamic, dynamic>;
          final String className = value['className'];
          final String productName = value['productName'];
          final String expiry = value['expiry'];
          final int order = value['order'];

          DateTime expiryDate = parseExpiryDate(expiry);
          Expiry status = getExpirationStatus(expiryDate);

          return ItemModel(className, productName, expiry, status, order, null);
        }).toList();
      } else {
        return [];
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
