

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'sidebar.dart';
import 'user_provider.dart'; // ⬅️ Import your provider class

class LeaveHistoryCancelled extends StatefulWidget {
  const LeaveHistoryCancelled({super.key});

  @override
  State<LeaveHistoryCancelled> createState() => _LeaveHistoryCancelledState();
}

class _LeaveHistoryCancelledState extends State<LeaveHistoryCancelled> {
  late Future<List<Map<String, dynamic>>> _cancelledLeavesFuture;

  static const String baseUrl = 'http://localhost:5000/apply/fetch';

  @override
  void initState() {
    super.initState();
    // Fetching is delayed until build because Provider can't be accessed in initState directly
  }

  Future<List<Map<String, dynamic>>> fetchCancelledLeaves(String employeeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$employeeId?status=Cancelled'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load cancelled leaves');
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final parsedDate = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = Provider.of<UserProvider>(context).employeeId;

    if (employeeId == null || employeeId.isEmpty) {
      return const Center(
        child: Text(
          'Employee ID not found. Please login again.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    _cancelledLeavesFuture = fetchCancelledLeaves(employeeId);

    return Sidebar(
      title: 'Leave Cancelled History',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Leave Cancelled History',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _cancelledLeavesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No cancelled leave history found.'));
                  } else {
                    return _buildLeaveTable(snapshot.data!);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveTable(List<Map<String, dynamic>> leaves) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: WidgetStateProperty.all(Colors.white),
          dataRowColor: WidgetStateProperty.all(Colors.white),
          border: TableBorder.all(width: 1, color: Colors.grey.shade300),
          columns: const [
            DataColumn(label: Text('Leave Type', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('From Date', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('To Date', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Reason', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: leaves.map((leave) {
            return DataRow(
              cells: [
                DataCell(Text(leave['leaveType'] ?? '')),
                DataCell(Text(formatDate(leave['fromDate']))),
                DataCell(Text(formatDate(leave['toDate']))),
                DataCell(Text(leave['reason'] ?? '')),
                DataCell(Text(leave['status'] ?? '')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}