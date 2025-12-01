 // dart
 import 'package:flutter/material.dart';
 import 'package:intl/intl.dart';
 import '../controllers/overtime_controllers.dart';
import '../models/overtime_entry.dart';
 import 'overtime_chart.dart';

 class OvertimeHome extends StatefulWidget {
   final OvertimeController controller;
   const OvertimeHome({super.key, required this.controller});

   @override
   State<OvertimeHome> createState() => _OvertimeHomeState();
 }

 class _OvertimeHomeState extends State<OvertimeHome> {
   final DateFormat _df = DateFormat.yMMMd();
   String _role = 'Developer';
   int _currentIndex = 0;

   Future<void> _showAddDialog() async {
     DateTime selectedDate = DateTime.now();
     final hoursController = TextEditingController(text: '2.0');

     await showDialog(
       context: context,
       builder: (context) {
         return StatefulBuilder(
           builder: (context, setStateDialog) {
             return AlertDialog(
               title: const Text('Log Overtime'),
               content: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Row(
                     children: [
                       Expanded(child: Text('Date: ${_df.format(selectedDate)}')),
                       TextButton(
                         onPressed: () async {
                           final picked = await showDatePicker(
                             context: context,
                             initialDate: selectedDate,
                             firstDate: DateTime.now().subtract(const Duration(days: 365)),
                             lastDate: DateTime.now(),
                           );
                           if (picked != null) {
                             setStateDialog(() => selectedDate = picked);
                           }
                         },
                         child: const Text('Change'),
                       ),
                     ],
                   ),
                   TextField(
                     controller: hoursController,
                     keyboardType: const TextInputType.numberWithOptions(decimal: true),
                     decoration: const InputDecoration(labelText: 'Hours'),
                   ),
                 ],
               ),
               actions: [
                 TextButton(
                   onPressed: () => Navigator.of(context).pop(),
                   child: const Text('Cancel'),
                 ),
                 ElevatedButton(
                   onPressed: () {
                     final hours = double.tryParse(hoursController.text) ?? 0.0;

                     if (hours > 0) {
                       // Check for duplicate date
                       bool exists = widget.controller.entries.any((entry) =>
                       entry.date.year == selectedDate.year &&
                           entry.date.month == selectedDate.month &&
                           entry.date.day == selectedDate.day);

                       if (exists) {
                         // Show alert for duplicate
                         showDialog(
                           context: context,
                           builder: (context) {
                             return AlertDialog(
                               title: const Text("Entry Already Exists"),
                               content: Text(
                                   "You have already logged overtime for ${_df.format(selectedDate)}."),
                               actions: [
                                 TextButton(
                                   onPressed: () => Navigator.pop(context),
                                   child: const Text("OK"),
                                 ),
                               ],
                             );
                           },
                         );
                         return; // Stop further action
                       }

                       // Add entry if no duplicate
                       widget.controller.addEntry(
                         OvertimeEntry(date: selectedDate, hours: hours),
                       );
                     }

                     Navigator.of(context).pop();
                   },
                   child: const Text('Add'),
                 ),
               ],
             );
           },
         );
       },
     );
   }


   Widget _buildEntryTile(int index, OvertimeEntry e) {
     return ListTile(
       leading: Icon(
         e.status == OvertimeStatus.approved ? Icons.check_circle : Icons.access_time,
         color: e.status == OvertimeStatus.approved ? Colors.green : null,
       ),
       title: Text('${_df.format(e.date)} — ${e.hours} h'),
       subtitle: Text('Status: ${e.status == OvertimeStatus.pending ? 'Pending' : 'Approved'}',
       style: TextStyle(
         color: e.status == OvertimeStatus.pending ? Colors.orange : Colors.green
       ),),

       trailing: Row(
         mainAxisSize: MainAxisSize.min,
         children: [
           // Approve button only for Lead + pending
           if (_role == 'Lead' && e.status == OvertimeStatus.pending)
             TextButton(
               onPressed: () => widget.controller.approveEntry(index),
               child: const Text('Approve'),
             ),

           // 3-dot menu
           PopupMenuButton<String>(
             icon: const Icon(Icons.more_vert),
             onSelected: (value) {
               if (value == 'Delete') {
                 widget.controller.deleteEntry(index);  // <-- Create this in controller
               }else if(value == 'Edit'){
                 // Show edit dialog
                 DateTime selectedDate = e.date;
                 final hoursController = TextEditingController(text: e.hours.toString());

                 showDialog(
                   context: context,
                   builder: (context) {
                     return StatefulBuilder(
                       builder: (context, setStateDialog) {
                         return AlertDialog(
                           title: const Text('Edit Overtime'),
                           content: Column(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               Row(
                                 children: [
                                   Expanded(child: Text('Date: ${_df.format(selectedDate)}')),
                                   TextButton(
                                     onPressed: () async {
                                       final picked = await showDatePicker(
                                         context: context,
                                         initialDate: selectedDate,
                                         firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                         lastDate: DateTime.now().add(const Duration(days: 365)),
                                       );
                                       if (picked != null) {
                                         setStateDialog(() => selectedDate = picked);
                                       }
                                     },
                                     child: const Text('Change'),
                                   ),
                                 ],
                               ),
                               TextField(
                                 controller: hoursController,
                                 keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                 decoration: const InputDecoration(labelText: 'Hours'),
                               ),
                             ],
                           ),
                           actions: [
                             TextButton(
                               onPressed: () => Navigator.of(context).pop(),
                               child: const Text('Cancel'),
                             ),
                             ElevatedButton(
                               onPressed: () {
                                 final hours = double.tryParse(hoursController.text) ?? 0.0;

                                 if (hours > 0) {
                                   widget.controller.editEntry(index, selectedDate, hours);
                                 }

                                 Navigator.of(context).pop();
                               },
                               child: const Text('Save'),
                             ),
                           ],
                         );
                       },
                     );
                   },
                 );
               }
             },
             itemBuilder: (context) => [
               const PopupMenuItem(
                 value: 'Edit',
                 child: Row(
                   children: [
                     Icon(Icons.edit_outlined, color: Colors.black),
                     SizedBox(width: 8),
                     Text('Edit'),
                   ],
                 ),
               ),
               const PopupMenuItem(
                 value: 'Delete',
                 child: Row(
                   children: [
                     Icon(Icons.delete, color: Colors.black),
                     SizedBox(width: 8),
                     Text('Delete'),
                   ],
                 ),
               ),
             ],
           ),
         ],
       ),
     );
   }


   Widget _homeView() {
     return AnimatedBuilder(
       animation: widget.controller,
       builder: (context, _) {
         final entries = widget.controller.entries;
         if (entries.isEmpty) {
           return const Center(child: Text('No overtime logged yet.'));
         }
         return ListView.builder(
           itemCount: entries.length,
           itemBuilder: (context, i) => _buildEntryTile(i, entries[i]),
         );
       },
     );
   }

   Widget _chartView() {
     return Center(
       child: HoursPieChart(controller: widget.controller, size: 220),
     );
   }

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         title: const Text('Overtime Logger',
         style: TextStyle(
           color: Colors.white
         ),),
         backgroundColor: Colors.black,
         actions: [
           Padding(
             padding: const EdgeInsets.symmetric(horizontal: 8.0),
             child: Theme(
               data: Theme.of(context).copyWith(
                 canvasColor: Colors.black, // dropdown background COLOR
               ),
               child: DropdownButton<String>(
                 value: _role,
                 underline: const SizedBox.shrink(),

                 // Selected item text style
                 style: const TextStyle(
                   color: Colors.white,
                   fontSize: 16,
                 ),

                 items: const [
                   DropdownMenuItem(
                     value: 'Developer',
                     child: Text(
                       'Developer',
                       style: TextStyle(color: Colors.white), // dropdown item color
                     ),
                   ),
                   DropdownMenuItem(
                     value: 'Lead',
                     child: Text(
                       'Lead',
                       style: TextStyle(color: Colors.white), // dropdown item color
                     ),
                   ),
                 ],

                 onChanged: (v) {
                   if (v != null) setState(() => _role = v);
                 },
               ),
             )

           ),
         ],
       ),
       body: _currentIndex == 0 ? _homeView() : _chartView(),
       floatingActionButton: _role == 'Developer' && _currentIndex == 0
           ? FloatingActionButton(onPressed: _showAddDialog, tooltip: 'Log Overtime', child: const Icon(Icons.add))
           : null,
       bottomNavigationBar: BottomNavigationBar(
         currentIndex: _currentIndex,
         onTap: (i) => setState(() => _currentIndex = i),
         items: const [
           BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Home'),
           BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Chart'),
         ],
       ),
     );
   }
 }