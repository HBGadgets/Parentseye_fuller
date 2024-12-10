class Device {
  final int id;
  final Map<String, dynamic> attributes;
  final int groupId;
  final int calendarId;
  final String name;
  final String uniqueId;
  final String status;
  final DateTime? lastUpdate;
  final int positionId;
  final String? phone;
  final String? model;
  final String? contact;
  final String? category;
  final bool disabled;
  final DateTime expirationTime;

  Device({
    required this.id,
    required this.attributes,
    required this.groupId,
    required this.calendarId,
    required this.name,
    required this.uniqueId,
    required this.status,
    this.lastUpdate,
    required this.positionId,
    this.phone,
    this.model,
    this.contact,
    this.category,
    required this.disabled,
    required this.expirationTime,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      attributes: json['attributes'] ?? {},
      groupId: json['groupId'],
      calendarId: json['calendarId'],
      name: json['name'],
      uniqueId: json['uniqueId'],
      status: json['status'],
      lastUpdate: json['lastUpdate'] != null
          ? DateTime.parse(json['lastUpdate'])
          : null,
      positionId: json['positionId'],
      phone: json['phone'],
      model: json['model'],
      contact: json['contact'],
      category: json['category'],
      disabled: json['disabled'],
      expirationTime: DateTime.parse(json['expirationTime']),
    );
  }
}
