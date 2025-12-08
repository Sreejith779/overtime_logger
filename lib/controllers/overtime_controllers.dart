// lib/controllers/overtime_controller.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/overtime_entry.dart';

class OvertimeController extends ChangeNotifier {
  static const String baseUrl = "http://10.0.2.2:5002/api"; // Android emulator
  // Use your PC IP if testing on physical device: "http://192.168.1.100:5000/api"

  List<OvertimeEntry> _entries = [];
  List<OvertimeEntry> get entries => _entries;

  String? userId;
  String? userName;
  String role = 'Developer';

  // SharedPreferences keys
  static const String _userIdKey = 'userId';
  static const String userNameKey = 'userName';
  static const String _roleKey = 'role';

  // Call once at app start
  Future<void> init() async {
    await _loadSavedLogin();
    if (userId != null) await loadEntries();
  }

  // Test logins
  Future<void> loginAsDev() async => await login("dev1", "John", "Developer");
  Future<void> loginAsLead() async => await login("lead1", "Sarah", "Lead");

  // Login method that handles both test and actual backend logins
  Future<void> login(String id, String name, String selectedRole) async {
    userId = id;
    userName = name;
    role = selectedRole;

    final prefs = await SharedPreferences.getInstance();

    // Store user data as JSON object
    final userData = {
      'userId': id,
      'userName': name,
      'role': selectedRole,
    };

    await prefs.setString(_userIdKey, id);
    await prefs.setString(userNameKey, name);
    await prefs.setString(_roleKey, selectedRole);

    print("✅ USER DATA SAVED TO PREFS:");
    print(jsonEncode(userData));

    notifyListeners();
    await loadEntries();
  }

  // Backend login - call from UI layer
  Future<LoginResponse> loginWithCredentials(String username, String password) async {
    try {
      print("➡️ LOGIN REQUEST:");
      print("URL: $baseUrl/auth/login");
      print("BODY: username=$username");

      final resp = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      print("⬅️ LOGIN RESPONSE:");
      print("STATUS: ${resp.statusCode}");
      print("BODY: ${resp.body}");

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);

        // Store the response data in SharedPreferences
        final userId = data['userId'] ?? username;
        final userName = data['userName'] ?? username;
        final userRole = data['role'] ?? 'Developer';

        await login(userId, userName, userRole);

        return LoginResponse(
          success: true,
          message: 'Login successful',
          userId: userId,
          userName: userName,
          role: userRole,
        );
      } else if (resp.statusCode == 401) {
        return LoginResponse(
          success: false,
          message: 'Invalid username or password',
        );
      } else {
        return LoginResponse(
          success: false,
          message: 'Login failed: ${resp.statusCode}',
        );
      }
    } catch (e) {
      return LoginResponse(
        success: false,
        message: 'Login error: $e',
      );
    }
  }

  // Load saved login from SharedPreferences
  Future<void> _loadSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();

    userId = prefs.getString(_userIdKey);
    userName = prefs.getString(userNameKey);
    role = prefs.getString(_roleKey) ?? 'Developer';

    if (userId != null) {
      print("✅ LOADED SAVED USER DATA:");
      print({
        'userId': userId,
        'userName': userName,
        'role': role,
      });
    } else {
      print("❌ NO SAVED USER DATA FOUND");
    }

    notifyListeners();
  }

  // Check if user is logged in
  bool get isLoggedIn => userId != null && userId!.isNotEmpty;

  // Logout method
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_userIdKey);
    await prefs.remove(userNameKey);
    await prefs.remove(_roleKey);

    userId = null;
    userName = null;
    role = 'Developer';
    _entries = [];

    print("✅ USER LOGGED OUT - DATA CLEARED");
    notifyListeners();
  }

  // Load all entries from backend
  Future<void> loadEntries() async {
    try {
      print("➡️ LOAD ENTRIES REQUEST:");
      print("URL: $baseUrl/entries?userId=$userId&role=$role");

      final response = await http.get(
        Uri.parse('$baseUrl/entries?userId=$userId&role=$role'),
      );

      print("⬅️ LOAD ENTRIES RESPONSE:");
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final List jsonList = json.decode(response.body);

        _entries = jsonList.map((j) => OvertimeEntry(
          date: DateTime.parse(j['date']),
          hours: j['hours'].toDouble(),
          status: j['status'] == 'approved'
              ? OvertimeStatus.approved
              : OvertimeStatus.pending,
        )).toList();

        _entries.sort((a, b) => b.date.compareTo(a.date));
        notifyListeners();
      }
    } catch (e) {
      print("❌ LOAD ERROR: $e");
    }
  }

  // ADD
  Future<void> addEntry(DateTime date, double hours) async {
    try {
      print("➡️ ADD ENTRY REQUEST:");
      print("URL: $baseUrl/entries");
      print("BODY: ${json.encode({
        'userId': userId,
        'userName': userName,
        'date': date.toIso8601String(),
        'hours': hours,
      })}");

      final res = await http.post(
        Uri.parse('$baseUrl/entries'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'userName': userName,
          'date': date.toIso8601String(),
          'hours': hours,
        }),
      );

      print("⬅️ ADD ENTRY RESPONSE:");
      print("STATUS: ${res.statusCode}");
      print("BODY: ${res.body}");
    } catch (e) {
      print('❌ ADD ERROR: $e');
    }

    await loadEntries();
  }

  // EDIT
  Future<void> editEntry(int index, DateTime newDate, double newHours) async {
    try {
      final List serverList = await _getAllEntriesFromServer();
      final String entryId = serverList[index]['_id'];

      final response = await http.patch(
        Uri.parse('$baseUrl/entries/$entryId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'date': newDate.toIso8601String(),
          'hours': newHours,
        }),
      );

      if (response.statusCode == 200) {
        await loadEntries();
      }
    } catch (e) {
      debugPrint("Edit error: $e");
    }
  }

  // APPROVE
  Future<void> approveEntry(int index) async {
    final List serverList = await _getAllEntriesFromServer();
    final String entryId = serverList[index]['_id'];
    await http.patch(Uri.parse('$baseUrl/entries/$entryId/approve'));
    await loadEntries();
  }

  // DELETE
  Future<void> deleteEntry(int index) async {
    final List serverList = await _getAllEntriesFromServer();
    final String entryId = serverList[index]['_id'];
    await http.delete(Uri.parse('$baseUrl/entries/$entryId'));
    await loadEntries();
  }

  // Helper
  Future<List> _getAllEntriesFromServer() async {
    final res = await http.get(Uri.parse('$baseUrl/entries?userId=$userId&role=$role'));
    return json.decode(res.body);
  }

  // Chart helpers
  double get totalApprovedHours =>
      _entries.where((e) => e.status == OvertimeStatus.approved).fold(0.0, (s, e) => s + e.hours);

  double get totalPendingHours =>
      _entries.where((e) => e.status == OvertimeStatus.pending).fold(0.0, (s, e) => s + e.hours);

  double get totalHours => totalApprovedHours + totalPendingHours;
}

// Response class for login
class LoginResponse {
  final bool success;
  final String message;
  final String? userId;
  final String? userName;
  final String? role;

  LoginResponse({
    required this.success,
    required this.message,
    this.userId,
    this.userName,
    this.role,
  });
}