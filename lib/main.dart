 // dart
 import 'package:flutter/material.dart';
 import 'controllers/overtime_controllers.dart';
import 'views/overtime_home.dart';

 void main() {
   runApp(const OvertimeLoggerApp());
 }

 class OvertimeLoggerApp extends StatelessWidget {
   const OvertimeLoggerApp({super.key});

   @override
   Widget build(BuildContext context) {
     final controller = OvertimeController();
     return MaterialApp(
debugShowCheckedModeBanner: false,
       title: 'Overtime Logger',
       theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
       home: OvertimeHome(controller: controller),
     );
   }
 }