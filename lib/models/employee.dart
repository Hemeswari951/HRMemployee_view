class Employee {
  final String id;
  final String fullName;
  final String dob;
  final String fatherName;
  final String fatherOccupation;
  final String aadhar;
  final String address;

  Employee({
    required this.id,
    required this.fullName,
    required this.dob,
    required this.fatherName,
    required this.fatherOccupation,
    required this.aadhar,
    required this.address,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      dob: json['dob'] ?? '',
      fatherName: json['father_name'] ?? '',
      fatherOccupation: json['father_occupation'] ?? '',
      aadhar: json['aadhar'] ?? '',
      address: json['address'] ?? '',
    );
  }
}
