import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'user_provider.dart';
import 'employee_dashboard.dart';
import 'leave_management.dart';
import 'emp_payroll.dart';
import 'employee_profile.dart';
import 'employee_directory.dart';
import 'reports.dart';
import 'notification.dart';
import 'attendance_login.dart';

class Sidebar extends StatefulWidget {
  final Widget body;
  final String title;

  const Sidebar({super.key, required this.body, required this.title});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  String employeeName = "Employee";
  String position = "Position";

  @override
  void initState() {
    super.initState();
    fetchEmployeeDetails();
  }

  Future<void> fetchEmployeeDetails() async {
    final employeeId = Provider.of<UserProvider>(
      context,
      listen: false,
    ).employeeId;

    if (employeeId == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/get-employee-name/$employeeId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          employeeName = data['employeeName'] ?? 'Employee';
          position = data['position'] ?? 'Position';
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
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF0F1020),
      drawer: _buildSidebar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 10),
            child: ElevatedButton.icon(
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              icon: const Icon(Icons.menu),
              label: const Text('Menu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(child: widget.body),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final Map<String, Widget> pageMap = {
      'Dashboard': const EmployeeDashboard(),
      'Leave Management': const LeaveManagement(),
      'Payroll Management': const EmpPayroll(),
      'Attendance System': AttendanceLoginPage(),
      'Reports & Analytics': ReportsAnalyticsPage(),
      'Employee Directory': EmployeeDirectoryPage(),
      'Notifications': NotificationsPage(),
      'Employee Profile': EmployeeProfilePage(),
    };

    final List<String> options = pageMap.keys.toList();

    return Container(
      height: 80,
      color: const Color(0xFF0F1020),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          // Left logo
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset('assets/logo_z.png', height: 40),
            ),
          ),
          // Center logo
          Expanded(
            flex: 2,
            child: Center(
              child: Image.asset('assets/logo_zeai.png', height: 70),
            ),
          ),
          // Right search bar
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 250,
                child: Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return options.where(
                      (String option) => option
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase()),
                    );
                  },
                  onSelected: (String selected) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => pageMap[selected]!,
                      ),
                    );
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onEditingComplete) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onEditingComplete: onEditingComplete,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search here...',
                        hintStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.search, color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF2D2F41),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        margin: const EdgeInsets.only(top: 10),
                        child: Material(
                          color: const Color(0xFF2D2F41),
                          elevation: 8,
                          borderRadius: BorderRadius.circular(10),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                return InkWell(
                                  onTap: () => onSelected(option),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      option,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Drawer(
      child: Container(
        width: 180,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: ListView(
          children: [
            const SizedBox(height: 40),
            ListTile(
              leading: const CircleAvatar(
                backgroundImage: AssetImage('assets/profile.png'),
              ),
              title: Text(
                employeeName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(position),
              // ⛔ Removed trailing three-dot icon
            ),
            const Divider(),
            _sidebarTile(Icons.dashboard, 'Dashboard', context, const EmployeeDashboard()),
            _sidebarTile(Icons.calendar_month, 'Leave Management', context, const LeaveManagement()),
            _sidebarTile(Icons.payments, 'Payroll Management', context, const EmpPayroll()),
            _sidebarTile(Icons.how_to_reg, 'Attendance System', context, AttendanceLoginPage()),
            _sidebarTile(Icons.analytics, 'Reports & Analytics', context, ReportsAnalyticsPage()),
            _sidebarTile(Icons.people, 'Employee Directory', context, EmployeeDirectoryPage()),
            _sidebarTile(Icons.notifications, 'Notifications', context, NotificationsPage()),
            _sidebarTile(Icons.person, 'Employee Profile', context, EmployeeProfilePage()),
          ],
        ),
      ),
    );
  }

  Widget _sidebarTile(
    IconData icon,
    String title,
    BuildContext context,
    Widget page,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Close drawer
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }
}
