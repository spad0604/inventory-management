import 'expiry_enum.dart';

class ItemModel {
  final String key;
  final String className;
  final String productName;
  final int order;
  final String expiry;
  final Expiry status;
  final String? imagePath;

  ItemModel(this.key, this.className, this.productName, this.expiry, this.status, this.order, this.imagePath);
}