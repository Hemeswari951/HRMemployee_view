import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'models/employee.dart';
import 'sidebar.dart';
import 'user_provider.dart';

class EmployeeProfilePage extends StatefulWidget {
  const EmployeeProfilePage({super.key});

  @override
  State<EmployeeProfilePage> createState() => _EmployeeProfilePageState();
}

class _EmployeeProfilePageState extends State<EmployeeProfilePage> {
  Employee? employee;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Delay fetch until after build so context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchEmployee();
    });
  }

  Future<void> fetchEmployee() async {
    final employeeId = Provider.of<UserProvider>(context, listen: false).employeeId;

    if (employeeId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final response = await http.get(Uri.parse('http://localhost:5000/profile/$employeeId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        employee = Employee.fromJson(data);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sidebar(
      title: 'Employee Profile',
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : employee == null
                ? const Text("Failed to load profile", style: TextStyle(color: Colors.white))
                : ListView(
                    children: [
                      const Text(
                        "Employee Profile",
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 48, color: Colors.white),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(employee!.fullName,
                                  style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                              Text("Employee ID: ${employee!.id}", style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _plainInfo("DOB: ${employee!.dob}"),
                                _plainInfo("Father Name: ${employee!.fatherName}"),
                                _plainInfo("Occupation: ${employee!.fatherOccupation}"),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _plainInfo("Aadhar: ${employee!.aadhar}"),
                                _plainInfo("Address: ${employee!.address}"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _plainInfo(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}
