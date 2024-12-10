class ContactInfo {
  final String driverMobile;
  final String schoolMobile;

  ContactInfo({required this.driverMobile, required this.schoolMobile});

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      driverMobile: json['driverMobile'] ?? '',
      schoolMobile: json['schoolMobile'] ?? '',
    );
  }
}
