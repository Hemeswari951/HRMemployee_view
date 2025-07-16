import 'package:flutter/material.dart';
import 'sidebar.dart';

class EmployeeDirectoryPage extends StatefulWidget {
  @override
  EmployeeDirectoryPageState createState() => EmployeeDirectoryPageState();
}

class EmployeeDirectoryPageState extends State<EmployeeDirectoryPage> {
  final List<Map<String, String>> employees = [
    {
      'name': 'D.Hemeswari',
      'role': 'Tech Trainee',
      'image': 'assets/emp-directory/Hemeswari D-Tech Trainee.jpg',
    },
    {
      'name': 'B.Hariprasad',
      'role': 'Tech Trainee',
      'image': 'assets/emp-directory/Hariprasad B-Tech Trainee.jpg',
    },
    {
      'name': 'K.Karthick',
      'role': 'Tech Trainee',
      'image': 'assets/emp-directory/Karthick K-Tech Trainee.jpg',
    },
    {
      'name': 'M.Udaykiran',
      'role': 'Tech Trainee',
      'image': 'assets/emp-directory/Uday kiran M - Tech Trainee.jpg',
    },
    {
      'name': 'K.Karthik',
      'role': 'BDE',
      'image': 'assets/emp-directory/Karthik K - BDE.jpg',
    },
    {
      'name': 'Vishal',
      'role': 'UXD',
      'image': 'assets/emp-directory/Vishal - UXD - Intern.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Sidebar(
      title: 'Employee Directory',
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Search + Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _searchBox('Search employee...', 200),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white24,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    "Employee List",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ✅ Scrollable Grid of Employee Cards
            Expanded(
              child: GridView.builder(
                itemCount: employees.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95, // Shorter cards
                ),
                itemBuilder: (context, index) {
                  final emp = employees[index];
                  return _employeeCard(
                    emp['name']!,
                    emp['role']!,
                    emp['image']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Employee Card with updated height & avatar size
  Widget _employeeCard(String name, String role, String imagePath) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 80, // Increased from 40 to 45
              backgroundColor: Colors.grey[200],
              backgroundImage: AssetImage(imagePath),
              onBackgroundImageError: (_, __) {
                debugPrint('Image load error for $imagePath');
              },
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              role,
              style: const TextStyle(
                fontSize: 15.5,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Icon(Icons.email, size: 25, color: Colors.deepPurple),
                Icon(Icons.message, size: 25, color: Colors.deepPurple),
                Icon(Icons.phone, size: 25, color: Colors.deepPurple),
                Icon(Icons.video_call, size: 25, color: Colors.deepPurple),
                Icon(Icons.info_outline, size: 25, color: Colors.deepPurple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Search Box
  Widget _searchBox(String hint, double width) {
    return SizedBox(
      width: width,
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF2D2F41),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
