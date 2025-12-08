// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/overtime_controllers.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  final Map<String, Map<String, dynamic>> testCredentials = {
    'dev1': {
      'password': 'dev123',
      'name': 'John',
      'role': 'Developer',
      'icon': '👨‍💻',
      'color': Color(0xFF3B82F6),
    },
    'lead1': {
      'password': 'lead123',
      'name': 'Sarah',
      'role': 'Lead',
      'icon': '👩‍💼',
      'color': Color(0xFFA855F7),
    },
  };

  Future<void> handleLogin() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => errorMessage = 'Please enter username and password');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final controller = context.read<OvertimeController>();

    try {
      // Try backend login first
      final response = await controller.loginWithCredentials(username, password);

      if (response.success) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        if (mounted) {
          setState(() => errorMessage = response.message);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => errorMessage = 'Login failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF0F172A),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header
                  SizedBox(height: 40),
                  Icon(
                    Icons.access_time,
                    size: 48,
                    color: Color(0xFF60A5FA),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'OvertimeTracker',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Login to your account',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  SizedBox(height: 60),

                  // Login Form
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF1E293B).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Color(0xFF334155),
                        width: 1,
                      ),
                    ),
                    padding: EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Username Field
                        Text(
                          'Username',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: usernameController,
                          enabled: !isLoading,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Enter username',
                            hintStyle: TextStyle(color: Color(0xFF64748B)),
                            filled: true,
                            fillColor: Color(0xFF0F172A),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF334155)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF334155)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF3B82F6)),
                            ),
                            prefixIcon: Icon(
                              Icons.person,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Password Field
                        Text(
                          'Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: passwordController,
                          enabled: !isLoading,
                          obscureText: true,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Enter password',
                            hintStyle: TextStyle(color: Color(0xFF64748B)),
                            filled: true,
                            fillColor: Color(0xFF0F172A),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF334155)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF334155)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF3B82F6)),
                            ),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Error Message
                        if (errorMessage != null)
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFFDC2626).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Color(0xFFDC2626)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Color(0xFFDC2626),
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    errorMessage!,
                                    style: TextStyle(
                                      color: Color(0xFFDC2626),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (errorMessage != null) SizedBox(height: 20),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF3B82F6),
                              disabledBackgroundColor: Color(0xFF3B82F6).withOpacity(0.5),
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isLoading
                                ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                                : Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40),

                  // Test Credentials Box
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF1E293B).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFF334155),
                        width: 1,
                      ),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.shield,
                              color: Color(0xFFFCD34D),
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Test Credentials',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        // Developer Credentials
                        _buildCredentialRow(
                          icon: '👨‍💻',
                          role: 'Developer',
                          username: 'dev1',
                          password: 'dev123',
                        ),
                        SizedBox(height: 12),
                        // Lead Credentials
                        _buildCredentialRow(
                          icon: '👩‍💼',
                          role: 'Lead',
                          username: 'lead1',
                          password: 'lead123',
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40),

                  // Footer
                  Text(
                    'Demo Version • Overtime Management System',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCredentialRow({
    required String icon,
    required String role,
    required String username,
    required String password,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF0F172A).withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Text(
                role,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person, color: Color(0xFF94A3B8), size: 16),
              SizedBox(width: 8),
              Text(
                'Username: ',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
              SelectableText(
                username,
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 12,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.lock, color: Color(0xFF94A3B8), size: 16),
              SizedBox(width: 8),
              Text(
                'Password: ',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
              SelectableText(
                password,
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 12,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}