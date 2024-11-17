import 'package:flutter/material.dart';

enum Expiry {
  expired('expired') ,
  nearExpiry('near expiry'),
  valid('valid');

  const Expiry(this.value);
  final String value;
}

extension ExpirationStatusExtension on Expiry {
  Color get color {
    switch (this) {
      case Expiry.expired:
        return Colors.red;
      case Expiry.nearExpiry:
        return Colors.orange;
      case Expiry.valid:
        return Colors.green;
    }
  }
}