

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import 'payslip.dart';
import 'sidebar.dart';
import 'user_provider.dart';

class EmpPayroll extends StatefulWidget {
  const EmpPayroll({super.key});

  @override
  State<EmpPayroll> createState() => _EmpPayrollState();
}

class _EmpPayrollState extends State<EmpPayroll> {
  String? selectedYear;
  List<bool> checkedList = List<bool>.filled(12, false);

  static const List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const List<String> monthKeys = [
    'jan', 'feb', 'mar', 'apr', 'may', 'jun',
    'jul', 'aug', 'sep', 'oct', 'nov', 'dec',
  ];

  Future<void> _downloadAllCheckedPayslips() async {
    final employeeId = Provider.of<UserProvider>(context, listen: false).employeeId;

    if (employeeId == null || selectedYear == null || !checkedList.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select year and at least one month')),
      );
      return;
    }

    final selectedMonths = <String>[];
    for (int i = 0; i < checkedList.length; i++) {
      if (checkedList[i]) {
        selectedMonths.add(monthKeys[i]);
      }
    }

    try {
      final response = await http.post(
        Uri.parse('http://employee-backend.onrender.com/get-multiple-payslips'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'year': selectedYear,
          'months': selectedMonths,
          'employee_id': employeeId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final employee = Map<String, dynamic>.from(data['employeeInfo']);
        final pdf = pw.Document();

        final imageLogo = pw.MemoryImage(
          (await rootBundle.load('assets/logo_zeai.png')).buffer.asUint8List(),
        );

        for (final monthKey in selectedMonths) {
          final monthIndex = monthKeys.indexOf(monthKey);
          final earnings = Map<String, dynamic>.from(data['months'][monthKey]['earnings']);
          final deductions = Map<String, dynamic>.from(data['months'][monthKey]['deductions']);

          pdf.addPage(
            pw.Page(
              build: (pw.Context context) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Center(child: pw.Image(imageLogo, height: 50)),
                    pw.SizedBox(height: 10),
                    pw.Center(
                      child: pw.Text(
                        'Payslip for ${months[monthIndex]} $selectedYear',
                        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text('Employee Details:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 5),
                    pw.Column(
                      children: [
                        _twoColumnRow('Name', employee['name'] ?? '', 'Employee ID', employee['employee_id'] ?? ''),
                        _twoColumnRow('Designation', employee['designation'] ?? '', 'No.of.Workdays', employee['no_of_workdays'] ?? ''),
                        _twoColumnRow('Date of Join', employee['date_of_join'] ?? '', 'Bank Name', employee['bank_name'] ?? ''),
                        _twoColumnRow('Branch Name', employee['branch'] ?? '', 'Account No', employee['account_no'] ?? ''),
                        _twoColumnRow('IFSC Code', employee['ifsc_code'] ?? '', 'LOP', employee['lop'] ?? ''),
                      ],
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text('Earnings:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 5),
                    pw.Table(
                      border: pw.TableBorder.all(),
                      children: [
                        pw.TableRow(
                          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#9F71F8')),
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(10),
                              child: pw.Text('Component', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(10),
                              child: pw.Text('Amount (Rs)', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                            ),
                          ],
                        ),
                        ...earnings.entries.map((e) => pw.TableRow(
                          children: [
                            pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(e.key)),
                            pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(e.value.toString())),
                          ],
                        )),
                      ],
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text('Deductions:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 5),
                    pw.Table(
                      border: pw.TableBorder.all(),
                      children: [
                        pw.TableRow(
                          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#9F71F8')),
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(10),
                              child: pw.Text('Component', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(10),
                              child: pw.Text('Amount (Rs)', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                            ),
                          ],
                        ),
                        ...deductions.entries.map((e) => pw.TableRow(
                          children: [
                            pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(e.key)),
                            pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(e.value.toString())),
                          ],
                        )),
                      ],
                    ),
                  ],
                );
              },
            ),
          );
        }

        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save(),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${response.body}')));
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exception: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sidebar(
      title: 'Payroll Management',
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C314A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PayslipScreen()),
                        );
                      },
                      child: const Text('Payslip'),
                    ),
                    SizedBox(
                      width: 180,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: DropdownButton<String>(
                          value: selectedYear,
                          hint: const Text('Select Year', style: TextStyle(color: Colors.black)),
                          dropdownColor: Colors.white,
                          icon: const Icon(Icons.arrow_drop_up),
                          isExpanded: true,
                          underline: Container(),
                          items: [
                            for (int year = 2020; year <= DateTime.now().year; year++)
                              DropdownMenuItem(
                                value: year.toString(),
                                child: Text(year.toString(), style: const TextStyle(color: Colors.black)),
                              ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedYear = value;
                            });
                          },
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C314A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: _downloadAllCheckedPayslips,
                      child: const Text('Download all'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Expanded(
                      flex: 5,
                      child: Text('Months', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text('View/Download', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('Check Box', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(thickness: 2, color: Colors.white),
                Expanded(
                  child: ListView.builder(
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(months[index], style: const TextStyle(color: Colors.white)),
                            ),
                            Expanded(
                              flex: 4,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const PayslipScreen()),
                                  );
                                },
                                child: Row(
                                  children: const [
                                    Icon(Icons.remove_red_eye, color: Colors.white),
                                    SizedBox(width: 10),
                                    Icon(Icons.download, color: Colors.white),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Checkbox(
                                value: checkedList[index],
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkedList[index] = value!;
                                  });
                                },
                                checkColor: Colors.black,
                                fillColor: MaterialStateProperty.all(Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

pw.Widget _twoColumnRow(String label1, dynamic value1, String label2, dynamic value2) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(
          child: pw.Text('$label1: ${value1.toString()}', maxLines: 1, overflow: pw.TextOverflow.clip),
        ),
        pw.SizedBox(width: 20),
        pw.Expanded(
          child: pw.Text('$label2: ${value2.toString()}', maxLines: 1, overflow: pw.TextOverflow.clip),
        ),
      ],
    ),
  );
}