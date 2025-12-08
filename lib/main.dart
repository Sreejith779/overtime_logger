import 'package:flutter/material.dart';
import 'package:overtime_logger/views/login_screen.dart';
import 'package:overtime_logger/views/overtime_home.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/overtime_controllers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance(); // important!

  runApp(const OvertimeLoggerApp());
}

class OvertimeLoggerApp extends StatelessWidget {
  const OvertimeLoggerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OvertimeController();

    return FutureBuilder(
      future: controller.init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ChangeNotifierProvider.value(
            value: controller,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Overtime Logger',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,
              ),
              // Check if user is logged in
              home: controller.isLoggedIn ? OvertimeHome(controller: controller) : LoginScreen(),
              routes: {
                '/login': (context) => LoginScreen(),
                '/home': (context) => OvertimeHome(controller: context.read<OvertimeController>()),
              },
            ),
          );
        }

        // Loading screen while initializing
        return const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}