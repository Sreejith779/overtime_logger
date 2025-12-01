 // dart
 import 'package:flutter/foundation.dart';
 import '../models/overtime_entry.dart';

 class OvertimeController extends ChangeNotifier {
   final List<OvertimeEntry> _entries = [];

   List<OvertimeEntry> get entries => List.unmodifiable(_entries);

   void addEntry(OvertimeEntry entry) {
     _entries.add(entry);
     notifyListeners();
   }

   void deleteEntry(int index) {
     _entries.removeAt(index);
     notifyListeners();
   }

   void editEntry(int index, DateTime newDate, double newHours) {
     _entries[index] = _entries[index].copyWith(
       date: newDate,
       hours: newHours,
     );
     notifyListeners();
   }


   void approveEntry(int index) {
     if (index >= 0 && index < _entries.length) {
       _entries[index].status = OvertimeStatus.approved;
       notifyListeners();
     }
   }

   void clearAll() {
     _entries.clear();
     notifyListeners();
   }

   // New helpers for the chart
   double get totalApprovedHours {
     return _entries
         .where((e) => e.status == OvertimeStatus.approved)
         .fold(0.0, (sum, e) => sum + e.hours);
   }

   double get totalPendingHours {
     return _entries
         .where((e) => e.status == OvertimeStatus.pending)
         .fold(0.0, (sum, e) => sum + e.hours);
   }

   double get totalHours => totalApprovedHours + totalPendingHours;
 }