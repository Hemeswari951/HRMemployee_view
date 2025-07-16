

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'sidebar.dart';
import 'leave_management.dart';

class ApplyLeave extends StatefulWidget {
  final Map<String, dynamic>? existingLeave;

  const ApplyLeave({super.key, this.existingLeave});

  @override
  State<ApplyLeave> createState() => _ApplyLeaveState();
}

class _ApplyLeaveState extends State<ApplyLeave> {
  String? selectedLeaveType;
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  final TextEditingController reasonController = TextEditingController();
  String? employeeName;

  @override
  void initState() {
    super.initState();
    final employeeId = Provider.of<UserProvider>(context, listen: false).employeeId;
    if (employeeId != null) {
      fetchEmployeeName(employeeId);
    }

    // Pre-fill data if editing
    if (widget.existingLeave != null) {
      selectedLeaveType = widget.existingLeave!['leaveType'];
      reasonController.text = widget.existingLeave!['reason'] ?? '';
      fromDate = DateTime.tryParse(widget.existingLeave!['fromDate']) ?? fromDate;
      toDate = DateTime.tryParse(widget.existingLeave!['toDate']) ?? toDate;
    }
  }

  Future<void> fetchEmployeeName(String employeeId) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/get-employee-name/$employeeId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          employeeName = data['employeeName'];
        });
      } else {
        debugPrint('❌ Employee not found');
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch employee name: $e');
    }
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? fromDate : toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  void _submitLeave() async {
    final employeeId = Provider.of<UserProvider>(context, listen: false).employeeId;

    if (selectedLeaveType == null ||
        reasonController.text.trim().isEmpty ||
        employeeId == null ||
        employeeName == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.'), backgroundColor: Colors.red),
      );
      return;
    }

    final leaveData = {
      "employeeId": employeeId,
      "employeeName": employeeName,
      "leaveType": selectedLeaveType,
      "approver": "Hari Bhaskar",
      "fromDate": "${fromDate.year}-${fromDate.month}-${fromDate.day}",
      "toDate": "${toDate.year}-${toDate.month}-${toDate.day}",
      "reason": reasonController.text.trim(),
    };

    final isEditing = widget.existingLeave != null;
    final leaveId = widget.existingLeave?['_id'];
    final url = isEditing
        ? 'http://localhost:5000/apply/update/$employeeId/$leaveId'
        : 'http://localhost:5000/apply/apply-leave';

    final response = await (isEditing
        ? http.put(Uri.parse(url), headers: {"Content-Type": "application/json"}, body: jsonEncode(leaveData))
        : http.post(Uri.parse(url), headers: {"Content-Type": "application/json"}, body: jsonEncode(leaveData)));

    if (!mounted) return;

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? '✅ Leave updated successfully!' : '✅ Leave applied successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LeaveManagement()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: ${response.body}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingLeave != null;

    return Sidebar(
      title: isEditing ? 'Edit Leave' : 'Apply Leave',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              isEditing ? 'EDIT LEAVE' : 'APPLY LEAVE',
              style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            if (employeeName != null) ...[
              const SizedBox(height: 10),
              Text(
                'Welcome, $employeeName',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Leave Type', style: TextStyle(color: Colors.white)),
                      const SizedBox(height: 5),
                      DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        value: selectedLeaveType,
                        items: ['Sad', 'Sick', 'Casual']
                            .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                            .toList(),
                        onChanged: (value) => setState(() => selectedLeaveType = value),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Approver', style: TextStyle(color: Colors.white)),
                      SizedBox(height: 5),
                      TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                          hintText: 'Hari Bhaskar',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('From', style: TextStyle(color: Colors.white)),
                      const SizedBox(height: 5),
                      TextField(
                        readOnly: true,
                        controller: TextEditingController(
                          text: '${fromDate.day}/${fromDate.month}/${fromDate.year}',
                        ),
                        onTap: () => _selectDate(context, true),
                        decoration: InputDecoration(
                          suffixIcon: const Icon(Icons.calendar_today),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('To', style: TextStyle(color: Colors.white)),
                      const SizedBox(height: 5),
                      TextField(
                        readOnly: true,
                        controller: TextEditingController(
                          text: '${toDate.day}/${toDate.month}/${toDate.year}',
                        ),
                        onTap: () => _selectDate(context, false),
                        decoration: InputDecoration(
                          suffixIcon: const Icon(Icons.calendar_today),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Reason for Leave', style: TextStyle(color: Colors.white)),
                const SizedBox(height: 5),
                TextField(
                  controller: reasonController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 240, 239, 243),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _submitLeave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 240, 239, 243),
                  ),
                  child: Text(isEditing ? 'Update' : 'Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}