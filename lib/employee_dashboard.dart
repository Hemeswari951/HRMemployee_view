import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'user_provider.dart';
import 'sidebar.dart';
import 'apply_leave.dart';
import 'todo_planner.dart';
import 'emp_payroll.dart';
import 'company_events.dart';
import 'notification.dart';
import 'attendance_login.dart';
import 'event_banner_slider.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  String? employeeName;

  @override
  void initState() {
    super.initState();
    fetchEmployeeName();
  }

  Future<void> fetchEmployeeName() async {
    final employeeId = Provider.of<UserProvider>(context, listen: false).employeeId;

    if (employeeId == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://employee-backend.onrender.com/get-employee-name/$employeeId'), // replace with your actual IP in real devices
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          employeeName = data['employeeName'];
        });
      } else {
        print('❌ Failed to fetch name: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching employee name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sidebar(
      title: 'Dashboard',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Welcome, ${employeeName ?? '...'}!',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            _buildQuickActions(context),
            const SizedBox(height: 40),
            _buildCardLayout(context),
            const SizedBox(height: 40),
            const EventBannerSlider(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 90,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: [
          _quickActionButton('Apply Leave', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) =>  ApplyLeave()));
          }),
          _quickActionButton('Download Payslip', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const EmpPayroll()));
          }),
          _quickActionButton('Mark Attendance', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceLoginPage()));
          }),
          _quickActionButton('Notifications Preview', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage()));
          }),
          _quickActionButton('Company Events', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CompanyEventsScreen()));
          }),
        ],
      ),
    );
  }

  Widget _quickActionButton(String title, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 214, 226, 231),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
      ),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  Widget _buildCardLayout(BuildContext context) {
    final currentDate = DateTime.now();
    final formattedDate = '${currentDate.day}/${currentDate.month}/${currentDate.year}';
    final currentTime = TimeOfDay.now().format(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 60,
          runSpacing: 20,
          children: [
            _dashboardTile(
              icon: Icons.lightbulb,
              title: currentTime,
              subtitle: 'Today: $formattedDate',
              buttonLabel: 'To Do List',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ToDoPlanner()));
              },
            ),
            _leaveCardTile(
              icon: Icons.beach_access,
              title: 'Casual Leave',
              subtitle: 'Used: 10/12\nRemaining: 2',
              buttonLabel: 'View',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) =>  ApplyLeave()));
              },
            ),
            _leaveCardTile(
              icon: Icons.local_hospital,
              title: 'Sick Leave',
              subtitle: 'Used: 9/12\nRemaining: 3',
              buttonLabel: 'View',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) =>  ApplyLeave()));
              },
            ),
            _leaveCardTile(
              icon: Icons.mood_bad,
              title: 'Sad Leave',
              subtitle: 'Used: 5/12\nRemaining: 7',
              buttonLabel: 'View',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) =>  ApplyLeave()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    VoidCallback? onTap,
  }) {
    return Container(
      width: 200,
      height: 250,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(0.6),
            blurRadius: 18,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: Colors.deepPurple),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }

  Widget _leaveCardTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    VoidCallback? onTap,
  }) {
    return _dashboardTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      buttonLabel: buttonLabel,
      onTap: onTap,
    );
  }
}
