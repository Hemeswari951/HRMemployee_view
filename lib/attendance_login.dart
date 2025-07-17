import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'attendance_status.dart';
import 'sidebar.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';

class AttendanceLoginPage extends StatelessWidget {
  const AttendanceLoginPage({super.key});

  // Replace this with your Render backend URL
  final String baseUrl = 'https://employee-backend.onrender.com';

  Future<void> markAttendance({
    required BuildContext context,
    required String status,
  }) async {
    final employeeId = Provider.of<UserProvider>(context, listen: false).employeeId;

    if (employeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Employee ID not found'), backgroundColor: Colors.red),
      );
      return;
    }

    final Uri url = Uri.parse('$baseUrl/attendance/mark');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'employeeId': employeeId,
          'status': status, // "login" or "logout"
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Marked $status successfully'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed: ${response.body}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sidebar(
      title: 'Attendance System',
      body: Column(
        children: [
          const SizedBox(height: 50),
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 50,
                      ),
                      children: [
                        TextSpan(
                          text: 'Mark ',
                          style: TextStyle(
                            color: Color.fromARGB(255, 105, 45, 208),
                            shadows: [
                              Shadow(
                                offset: Offset(5.5, 3.5),
                                blurRadius: 3.0,
                                color: Color.fromARGB(255, 82, 21, 187),
                              ),
                            ],
                          ),
                        ),
                        TextSpan(
                          text: 'Attendance',
                          style: TextStyle(
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(5.5, 3.5),
                                blurRadius: 5.0,
                                color: Color.fromARGB(255, 98, 45, 189),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await markAttendance(context: context, status: 'login');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AttendanceScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF692DD0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Colors.black),
                        ),
                        elevation: 6,
                      ),
                      child: const Text(
                        'LOGIN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          shadows: [
                            Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 3.0,
                              color: Colors.deepPurple,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                    ElevatedButton(
                      onPressed: () async {
                        await markAttendance(context: context, status: 'logout');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF692DD0),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Colors.black),
                        ),
                        elevation: 6,
                      ),
                      child: const Text(
                        'LOGOUT',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 2.0,
                              color: Colors.deepPurple,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
