import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'sidebar.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ReportsAnalyticsPage extends StatefulWidget {
  const ReportsAnalyticsPage({super.key});

  @override
  State<ReportsAnalyticsPage> createState() => _ReportsAnalyticsPageState();
}

class _ReportsAnalyticsPageState extends State<ReportsAnalyticsPage> {
  List<dynamic> performanceList = [];
  int workProgress = 0;

  int leaveUsed = 0;
  String leavePercent = '0';
  String presentPercent = '100';

  @override
  void initState() {
    super.initState();
    fetchPerformanceReviews();
    fetchWorkProgress();
    fetchLeaveStats();
  }

  Future<void> fetchPerformanceReviews() async {
    //var url = Uri.parse('http://localhost:5000/perform/performance/list');
    var url = Uri.parse('http://employee-backend.onrender.com/perform/performance/list');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          performanceList = jsonDecode(response.body);
        });
      } else {
        print('❌ Error fetching performance reviews');
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  Future<void> fetchWorkProgress() async {
    //var url = Uri.parse('http://localhost:5000/todo_planner/todo/progress');
    var url = Uri.parse('http://employee-backend.onrender.com/todo_planner/todo/progress');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          workProgress = data['progress'] ?? 0;
        });
      } else {
        print('❌ Error fetching progress');
      }
    } catch (e) {
      print('❌ Progress Fetch Error: $e');
    }
  }

  Future<void> fetchLeaveStats() async {
    //var url = Uri.parse('http://localhost:5000/apply/leave-stats');
    var url = Uri.parse('http://employee-backend.onrender.com/apply/leave-stats');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          leaveUsed = data['totalLeavesUsed'];
          leavePercent = data['leavePercentage'];
          presentPercent = data['presentPercentage'];
        });
      } else {
        print('❌ Error fetching leave stats');
      }
    } catch (e) {
      print('❌ Leave Stats Fetch Error: $e');
    }
  }

  void showPerformancePopup(BuildContext context, Map<String, dynamic> data) {
    Color flagColor;
    String flag = (data['flag'] ?? '').toLowerCase();

    if (flag.contains('red')) {
      flagColor = Colors.red;
    } else if (flag.contains('yellow')) {
      flagColor = Colors.yellow;
    } else if (flag.contains('green')) {
      flagColor = Colors.green;
    } else {
      flagColor = Colors.grey;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: double.maxFinite,
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: flagColor, width: 8)),
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Performance Review - ${data['month'] ?? ''}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    buildDetailRow("Communication", data['communication']),
                    buildDetailRow("Attitude", data['attitude']),
                    buildDetailRow(
                      "Tech Knowledge",
                      data['technicalKnowledge'],
                    ),
                    buildDetailRow(
                      "Business Knowledge",
                      data['businessKnowledge'],
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    Text(
                      "Overall Comments:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(data['overallComment'] ?? ''),
                    const SizedBox(height: 10),
                    Text(
                      "Reviewed by: ${data['reviewer'] ?? ''}",
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget buildDetailRow(String title, String? content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(content ?? '')),
        ],
      ),
    );
  }

  Widget buildFlagCell(String? flagValue) {
    String flag = (flagValue ?? '').toLowerCase();
    Color color;
    IconData icon = Icons.flag;

    if (flag.contains('red')) {
      color = Colors.red;
    } else if (flag.contains('yellow')) {
      color = Colors.amber;
    } else if (flag.contains('green')) {
      color = Colors.green;
    } else {
      color = Colors.grey;
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Text(
          flagValue ?? 'Unknown',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget reportCard(String title, String percentText, String details) {
    double percent = double.tryParse(percentText.replaceAll('%', '')) ?? 0;
    Color color = percent >= 80
        ? Colors.green
        : percent >= 50
        ? Colors.orange
        : Colors.red;

    return Column(
      children: [
        CircularPercentIndicator(
          radius: 55.0,
          lineWidth: 10.0,
          percent: (percent / 100).clamp(0.0, 1.0),
          center: Text(
            "$percentText",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 255, 255, 255), // <- Make the text white
            ),
          ),

          progressColor: color,
          backgroundColor: Colors.grey.shade300,
          animation: true,
          animationDuration: 800,
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        const SizedBox(height: 4),
        Text(
          details,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Sidebar(
      title: 'Reports & Analytics',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Reports & Analytics',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                reportCard(
                  'Overall Attendance',
                  '$presentPercent%',
                  'Leave - $leavePercent%\nPresent - $presentPercent%',
                ),
                reportCard(
                  'Overall Leave',
                  '$leavePercent%',
                  'Used - $leaveUsed days\nOut of 36',
                ),
                reportCard(
                  'Overall Work Progress',
                  '$workProgress%',
                  'Working - $workProgress%\nPending - ${100 - workProgress}%',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              color: Colors.blueGrey.shade900,
              padding: const EdgeInsets.all(12),
              child: const Text(
                'Performance Review',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            Container(
              height: 300,
              width: double.infinity,
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  headingRowColor: MaterialStateColor.resolveWith(
                    (states) => const Color.fromARGB(255, 82, 39, 152),
                  ),
                  columnSpacing: 30,
                  dataRowHeight: 50,
                  horizontalMargin: 10,
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Reviewed By',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Month of Review',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Flag',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'More',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Status',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                  rows: performanceList.whereType<Map<String, dynamic>>().map((
                    data,
                  ) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            data['reviewer'] ?? '',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        DataCell(
                          Text(
                            data['month'] ?? '',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        DataCell(buildFlagCell(data['flag'])),
                        DataCell(
                          TextButton(
                            child: const Text('View'),
                            onPressed: () =>
                                showPerformancePopup(context, data),
                          ),
                        ),
                        DataCell(
                          Text(
                            data['status'] ?? 'Agree/Disagree',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
