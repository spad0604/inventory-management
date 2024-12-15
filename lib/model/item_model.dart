import 'expiry_enum.dart';

class ItemModel {
  final String className;
  final String productName;
  final int order;
  final String expiry;
  final Expiry status;
  final String? imagePath;

  ItemModel(this.className, this.productName, this.expiry, this.status, this.order, this.imagePath);
}