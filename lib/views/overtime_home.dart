// lib/views/overtime_home.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int _currentIndex = 0;

  String userName = '';
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

   String name =  prefs.getString("userName") ?? "";
    log("user name : $userName");
    setState(() {
      userName = name;
    });
  }
  Future<void> _showAddDialog() async {
    DateTime selectedDate = DateTime.now();
    final hoursController = TextEditingController(text: '2.0');

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
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
                const SizedBox(height: 16),
                TextField(
                  controller: hoursController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Hours',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final hours = double.tryParse(hoursController.text) ?? 0.0;
                  if (hours <= 0) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('Please enter valid hours')),
                    );
                    return;
                  }

                  final exists = widget.controller.entries.any((e) =>
                  e.date.year == selectedDate.year &&
                      e.date.month == selectedDate.month &&
                      e.date.day == selectedDate.day);

                  if (exists) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('Already logged for this date')),
                    );
                    return;
                  }

                  Navigator.pop(dialogContext, true); // success
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );

    // Only proceed if user pressed Add and everything was valid
    if (result == true) {
      final hours = double.tryParse(hoursController.text) ?? 0.0;
      await widget.controller.addEntry(selectedDate, hours);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Overtime added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // Same pattern for Edit
  Future<void> _showEditDialog(int index, OvertimeEntry entry) async {
    DateTime selectedDate = entry.date;
    final hoursController = TextEditingController(text: entry.hours.toString());

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
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
                          firstDate: DateTime(2020),
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
                const SizedBox(height: 16),
                TextField(
                  controller: hoursController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Hours',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final hours = double.tryParse(hoursController.text) ?? 0.0;
                  if (hours <= 0) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('Enter valid hours')),
                    );
                    return;
                  }
                  Navigator.pop(dialogContext, true);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );

    if (result == true) {
      final hours = double.tryParse(hoursController.text) ?? 0.0;
      await widget.controller.editEntry(index, selectedDate, hours);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Updated successfully!'), backgroundColor: Colors.green),
        );
      }
    }
  }

  Widget _buildEntryTile(int index, OvertimeEntry e) {
    final isLead = widget.controller.role == 'Lead';

    return ListTile(
      leading: Icon(
        e.status == OvertimeStatus.approved ? Icons.check_circle : Icons.access_time,
        color: e.status == OvertimeStatus.approved ? Colors.green : Colors.orange,
      ),
      title: Text('${_df.format(e.date)} — ${e.hours} hours'),
      subtitle: Text(
        e.status == OvertimeStatus.pending ? 'Pending' : 'Approved',
        style: TextStyle(
          color: e.status == OvertimeStatus.pending ? Colors.orange : Colors.green,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLead && e.status == OvertimeStatus.pending)
            TextButton(
              onPressed: () => widget.controller.approveEntry(index),
              child: const Text('Approve', style: TextStyle(color: Colors.green)),
            ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'Edit') {
                await _showEditDialog(index, e);
              } else if (value == 'Delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete Entry'),
                    content: const Text('Are you sure?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) await widget.controller.deleteEntry(index);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'Edit', child: Row(children: [Icon(Icons.edit), SizedBox(width: 8), Text('Edit')])),
              const PopupMenuItem(value: 'Delete', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
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
    return Center(child: HoursPieChart(controller: widget.controller, size: 240));
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final role = widget.controller.role;
    final isDeveloper = role == 'Developer';

    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, $userName", style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
     GestureDetector(
       onTap: () async {
         final prefs = await SharedPreferences.getInstance();
         await prefs.clear();
         if (!mounted) return;
         Navigator.pushReplacementNamed(context, '/login');
       },
       child: Text("Logout",style: const TextStyle(color: Colors.white),),
     )
        ],
      ),
      body: _currentIndex == 0 ? _homeView() : _chartView(),
      floatingActionButton: isDeveloper && _currentIndex == 0
          ? FloatingActionButton(onPressed: _showAddDialog, child: const Icon(Icons.add))
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Entries'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Chart'),
        ],
      ),
    );
  }
}