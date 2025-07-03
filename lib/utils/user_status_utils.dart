import 'package:flutter/material.dart';
import '../models/user_status.dart';

Color getUserStatusColor(UserStatus status) {
  switch (status) {
    case UserStatus.safe:
      return Colors.green;
    case UserStatus.needsHelp:
      return Colors.red;
    case UserStatus.unknown:
    default:
      return Colors.grey;
  }
}

IconData getUserStatusIcon(UserStatus status) {
  switch (status) {
    case UserStatus.safe:
      return Icons.check;
    case UserStatus.needsHelp:
      return Icons.warning;
    case UserStatus.unknown:
    default:
      return Icons.person;
  }
}
