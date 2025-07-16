import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'employee_dashboard.dart';
import 'apply_leave.dart';
import 'emp_payroll.dart';
import 'attendance_login.dart';
import 'notification.dart';
import 'login.dart';
import 'company_events.dart';
import 'attendance_status.dart';
import 'leave_list.dart';
import 'user_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee HRM',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/' : (context) => const LoginApp(),
        '/dashboard': (context) => const EmployeeDashboard(),
        '/applyLeave': (context) => const ApplyLeave(),
        '/emp_payroll': (context) => const EmpPayroll(),
        '/attendance-login': (context) => const AttendanceLoginPage(), 
        '/notification': (context) => NotificationsPage(),
        '/company_events': (context) => const CompanyEventsScreen(),
        '/attendance-status' :(context) => AttendanceScreen(),
        '/leave-list': (context) => const LeaveList(),
      },
    );
  }
}