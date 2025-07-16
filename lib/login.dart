import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'employee_dashboard.dart';
import 'user_provider.dart';

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginPage();
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController employeeIdController = TextEditingController();
  final TextEditingController employeeNameController = TextEditingController();
  final TextEditingController positionController = TextEditingController();

  bool isLoading = false;

  Future<void> sendLoginDetails() async {
    if (employeeIdController.text.isEmpty ||
        employeeNameController.text.isEmpty ||
        positionController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Missing Details"),
          content: const Text("Please fill all fields."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/employee-login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'employeeId': employeeIdController.text.trim(),
          'employeeName': employeeNameController.text.trim(),
          'position': positionController.text.trim(),
        }),
      );

      if (response.statusCode == 201) {
        print('✅ Login Successful');

        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setEmployeeId(employeeIdController.text.trim());

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EmployeeDashboard()),
        );
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Invalid Credentials ❌"),
            content: const Text("Please check your Employee ID, Name, or Position."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Server Error"),
            content: Text("Status Code: ${response.statusCode}"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('❌ Network Error: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Network Error"),
          content: Text("Error: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171A30),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double loginBoxWidth = screenWidth > 1000 ? 500 : screenWidth * 0.8;
          double imageWidth = screenWidth > 1000 ? 400 : screenWidth * 0.4;
          double spacing = screenWidth > 1000 ? 80 : 30;

          return Column(
            children: [
              // ✅ Top Navbar (Search bar removed)
              Container(
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF171A30),
                  border: Border(
                    top: BorderSide(color: Colors.black, width: 2),
                    bottom: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const FaIcon(FontAwesomeIcons.chevronLeft, color: Colors.white, size: 30),
                    const SizedBox(width: 16),
                    const FaIcon(FontAwesomeIcons.chevronRight, color: Colors.white, size: 30),
                    const SizedBox(width: 18),
                    const Image(image: AssetImage('assets/logo_z.png'), width: 40, height: 40),
                    const SizedBox(width: 70),
                    const Spacer(),
                    const Image(image: AssetImage('assets/logo_zeai.png'), width: 140, height: 140),
                    const Spacer(),
                    const SizedBox(width: 16),
                  ],
                ),
              ),

              // ✅ Main Body
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/png1.png',
                          width: imageWidth,
                          height: 350,
                        ),
                        SizedBox(width: spacing),

                        Container(
                          width: loginBoxWidth,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromARGB(255, 158, 27, 219),
                                blurRadius: 12,
                                offset: Offset(6, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Employee Login',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF171A30),
                                ),
                              ),
                              const SizedBox(height: 24),
                              buildTextFieldRow('Employee ID :', 'Enter_id', employeeIdController),
                              const SizedBox(height: 16),
                              buildTextFieldRow('Employee Name :', 'Enter_Name', employeeNameController),
                              const SizedBox(height: 16),
                              buildTextFieldRow('Position :', 'Enter_position', positionController),
                              const SizedBox(height: 30),

                              SizedBox(
                                width: 100,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : sendLoginDetails,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF171A30),
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Login',
                                          style: TextStyle(fontSize: 16, color: Colors.white),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildTextFieldRow(String label, String hint, TextEditingController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color.fromRGBO(53, 64, 85, 0.77),
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color.fromARGB(255, 183, 181, 181),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
