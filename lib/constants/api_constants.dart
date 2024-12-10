class ApiConstants {
  static const String baseUrl = 'http://63.142.251.13:4000';
  static const String register = '$baseUrl/parent/register';
  static const String login = '$baseUrl/parent/login';
  static const String getParentData = '$baseUrl/parent/get-parent-data';
  static const String updateParent = '$baseUrl/parent/update-parent';
  static const String getChildData = '$baseUrl/parent/getchilddata';
  static const String addChild = '$baseUrl/parent/add-child';
  static const String updateChild = '$baseUrl/parent/update-child';
  static const String pickupPoint = '$baseUrl/parent/update-pickup-point';
  static const String request = '$baseUrl/request/create-request';
  static const String requestHistory = '$baseUrl/parent/getrequests';
  static const String childPickDropStatus = '$baseUrl/parent/status/';
  static String updateParentWithId(String parentId) =>
      '$updateParent/$parentId';
  static String updateChildWithId(String childId) => '$updateChild/$childId';
  static const String geofencesUrl = '$baseUrl/geofence';
  static const String geofenceIsCrossed = '$baseUrl/geofence/isCrossed';
  static const String getSchoolUrl = '$baseUrl/parent/getSchools';
  static const String getDriverMobile = '$baseUrl/parent/driver-mobile';
  static const String getSchoolMobile = '$baseUrl/parent/school-mobile';
  static const String getSchoolDevices = '$baseUrl/parent/get-devices';
  static const String deleteAccount = '$baseUrl/parent/delete';
  static const String updateFcmToken = '$baseUrl/parent/update-fcm-token';

  static const String baseLiveTrackingUrl = 'https://rocketsalestracker.com';
  static const String positionsUrl = '$baseLiveTrackingUrl/api/positions';
  static const String devicesUrl = '$baseLiveTrackingUrl/api/devices';
  static const String eventsUrl = '$baseLiveTrackingUrl/api/reports/events';
}
