class DeviceRegModel {
  final String deviceId;
  final String deviceName;

  DeviceRegModel({
    required this.deviceId,
    required this.deviceName,
  });

  factory DeviceRegModel.fromJson(Map<String, dynamic> json) {
    return DeviceRegModel(
      deviceId: json['deviceId'] ?? '',
      deviceName: json['deviceName'] ?? '',
    );
  }
}
