import 'package:flutter/material.dart';
import 'sidebar.dart'; // ✅ Shared sidebar wrapper

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final Color darkBlue = const Color(0xFF0F1020);
  String selectedMonth = "January";

  final List<String> months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  final List<Map<String, String>> leaves = [
    {"message": "Your leave request has been approved", "time": "1mo ago"},
    {"message": "Your leave request is in pending", "time": "1mo ago"},
  ];

  @override
  Widget build(BuildContext context) {
    return Sidebar(
      title: 'Notifications',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Notifications",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              _dropdownMonth(),
            ],
          ),
          const SizedBox(height: 24),
          notificationCategory("Leaves", leaves),
      
        ],
      ),
    );
  }

  // Month dropdown widget
  Widget _dropdownMonth() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedMonth,
          icon: const Icon(Icons.arrow_drop_down),
          items: months.map((month) => DropdownMenuItem(value: month, child: Text(month))).toList(),
          onChanged: (value) {
            setState(() {
              selectedMonth = value!;
            });
          },
        ),
      ),
    );
  }

  // Notification category section
  Widget notificationCategory(String title, List<Map<String, String>> notifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 16, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        ...notifications.map((item) => notificationCard(item["message"]!, item["time"]!)).toList(),
      ],
    );
  }

  // Single notification card UI
  Widget notificationCard(String message, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(2, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(message, style: const TextStyle(fontSize: 14))),
          Row(
            children: [
              Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Mark as read", style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
