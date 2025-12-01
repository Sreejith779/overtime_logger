// dart
import 'package:flutter/foundation.dart';

enum OvertimeStatus { pending, approved }

class OvertimeEntry {
  final DateTime date;
  final double hours;
  OvertimeStatus status;

  OvertimeEntry({
    required this.date,
    required this.hours,
    this.status = OvertimeStatus.pending,
  });

  OvertimeEntry copyWith({DateTime? date, double? hours, OvertimeStatus? status}) {
    return OvertimeEntry(
      date: date ?? this.date,
      hours: hours ?? this.hours,
      status: status ?? this.status,
    );
  }
}