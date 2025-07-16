

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'sidebar.dart';
import 'user_provider.dart';

class PayslipScreen extends StatefulWidget {
  const PayslipScreen({super.key});

  @override
  State<PayslipScreen> createState() => _PayslipScreenState();
}

class _PayslipScreenState extends State<PayslipScreen> {
  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final List<String> _years = ['2024', '2025'];

  String selectedMonth = 'April';
  String selectedYear = '2025';

  Map<String, dynamic> earnings = {};
  Map<String, dynamic> deductions = {};
  Map<String, dynamic> employeeData = {};

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _fetchPayslipDetails);
  }

  Future<void> _fetchPayslipDetails() async {
    final employeeId = Provider.of<UserProvider>(
      context,
      listen: false,
    ).employeeId;

    if (employeeId == null) {
      print("❌ Employee ID is null");
      return;
    }

    final url = Uri.parse(
      'http://localhost:5000/get-payslip-details?employee_id=$employeeId&year=$selectedYear&month=$selectedMonth',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String formattedDate = '';
        final rawDate = data['date_of_join'];
        if (rawDate != null && rawDate is String && rawDate.isNotEmpty) {
          try {
            final parsedDate = DateTime.parse(rawDate);
            formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
          } catch (e) {
            formattedDate = rawDate;
          }
        }

        setState(() {
          earnings = data['earnings'] ?? {};
          deductions = data['deductions'] ?? {};
          employeeData = {
            'name': (data['name'] ?? '').toString(),
            'employee_id': (data['employee_id'] ?? '').toString(),
            'designation': (data['designation'] ?? '').toString(),
            'no_of_workdays': (data['no_of_workdays'] ?? '').toString(),
            'date_of_join': formattedDate,
            'bank_name': (data['bank_name'] ?? '').toString(),
            'branch': (data['branch'] ?? '').toString(),
            'account_no': (data['account_no'] ?? '').toString(),
            'ifsc_code': (data['ifsc_code'] ?? '').toString(),
            'lop': (data['lop'] ?? '').toString(),
          };
        });
      } else {
        print("❌ Failed to fetch payslip: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Network error: $e");
    }
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    final imageLogo = pw.MemoryImage(
      (await rootBundle.load('assets/logo_zeai.png')).buffer.asUint8List(),
    );

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
                  'Payslip for $selectedMonth $selectedYear',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              pw.Text(
                'Employee Details:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 15),
              pw.Wrap(
                spacing: 50, // Horizontal gap between columns
                runSpacing: 10, // Vertical gap between rows
                children: [
                  _detailText('Name', employeeData['name']),
                  _detailText('Employee ID', employeeData['employee_id']),
                  _detailText('Designation', employeeData['designation']),
                  _detailText(
                    'No. of Workdays',
                    employeeData['no_of_workdays'],
                  ),
                  _detailText('Date of Join', employeeData['date_of_join']),
                  _detailText('Bank Name', employeeData['bank_name']),
                  _detailText('Branch Name', employeeData['branch']),
                  _detailText('Account No', employeeData['account_no']),
                  _detailText('IFSC Code', employeeData['ifsc_code']),
                  _detailText('LOP', employeeData['lop']),
                ],
              ),
              pw.SizedBox(height: 20),

              pw.Text(
                'Earnings:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#9F71F8'),
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text(
                          'Component',
                          style: pw.TextStyle(color: PdfColors.white),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text(
                          'Amount (Rs)',
                          style: pw.TextStyle(color: PdfColors.white),
                        ),
                      ),
                    ],
                  ),
                  ...earnings.entries.map(
                    (e) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(e.key),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(e.value.toString()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Text(
                'Deductions:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#9F71F8'),
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text(
                          'Component',
                          style: pw.TextStyle(color: PdfColors.white),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text(
                          'Amount (Rs)',
                          style: pw.TextStyle(color: PdfColors.white),
                        ),
                      ),
                    ],
                  ),
                  ...deductions.entries.map(
                    (e) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(e.key),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(e.value.toString()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Sidebar(
      title: 'Payslip',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _monthYearDropdowns(),
            const SizedBox(height: 12),
            _payslipHeader(),
            const SizedBox(height: 12),
            _employeeDetails(),
            const SizedBox(height: 12),
            _salaryDetails(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _button(
                  Icons.picture_as_pdf,
                  'Payslips',
                  Colors.blueGrey,
                  _generatePdf,
                ),
                _outlinedButton(Icons.download, 'Download', _generatePdf),
                _filledButton('Send'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _monthYearDropdowns() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton<String>(
          value: selectedMonth,
          dropdownColor: Colors.black,
          items: _months.map((month) {
            return DropdownMenuItem(
              value: month,
              child: Text(month, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => selectedMonth = value!);
            _fetchPayslipDetails();
          },
        ),
        const SizedBox(width: 20),
        DropdownButton<String>(
          value: selectedYear,
          dropdownColor: Colors.black,
          items: _years.map((year) {
            return DropdownMenuItem(
              value: year,
              child: Text(year, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => selectedYear = value!);
            _fetchPayslipDetails();
          },
        ),
      ],
    );
  }

  Widget _payslipHeader() {
    return Center(
      child: Container(
        width: 505,
        height: 49,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Payslip for $selectedMonth $selectedYear',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _employeeDetails() {
    if (employeeData.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          _infoRow(
            'Name',
            employeeData['name'] ?? '',
            'Employee ID',
            employeeData['employee_id'] ?? '',
          ),
          const Divider(),
          _infoRow(
            'Designation',
            employeeData['designation'] ?? '',
            'No of Workdays',
            employeeData['no_of_workdays'] ?? '',
          ),
          const Divider(),
          _infoRow(
            'Date of Join',
            employeeData['date_of_join'] ?? '',
            'Bank Name',
            employeeData['bank_name'] ?? '',
          ),
          const Divider(),
          _infoRow(
            'Branch Name',
            employeeData['branch'] ?? '',
            'A/C NO',
            employeeData['account_no'] ?? '',
          ),
          const Divider(),
          _infoRow(
            'IFSC Code',
            employeeData['ifsc_code'] ?? '',
            'LOP',
            employeeData['lop'] ?? '',
          ),
        ],
      ),
    );
  }

  Widget _salaryDetails() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header('Earnings'),
                for (var entry in earnings.entries)
                  if (entry.key.toLowerCase() != 'gross_salary')
                    _payRow(entry.key, '₹ ${entry.value}'),
                const Divider(),
                _payRow(
                  'Gross Salary',
                  '₹ ${earnings['gross_salary'] ?? '-'}',
                  isBold: true,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 200, color: Colors.black12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header('Deductions'),
                for (var entry in deductions.entries)
                  if (entry.key.toLowerCase() != 'total_deductions' &&
                      entry.key.toLowerCase() != 'net_pay')
                    _payRow(entry.key, '₹ ${entry.value}'),
                const Divider(),
                _payRow(
                  'Total Deductions',
                  '₹ ${deductions['total_deductions'] ?? '-'}',
                  isBold: true,
                ),
                _payRow(
                  'Net Pay',
                  '₹ ${deductions['net_pay'] ?? '-'}',
                  isBold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label1, String value1, String label2, String value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label1: $value1',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              '$label2: $value2',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: const Color.fromARGB(129, 132, 26, 238),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _payRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _button(IconData icon, String text, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 41,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _outlinedButton(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 66,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            Text(text, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _filledButton(String text) {
    return Container(
      width: 80,
      height: 35,
      decoration: BoxDecoration(
        color: const Color(0xFF9F71F8),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

pw.Widget _detailText(String label, dynamic value) {
  return pw.Container(
    width: 200, // Adjust width as needed for proper column alignment
    child: pw.Text('$label: ${value ?? ''}'),
  );
}