class RequestHistoryModel {
  final String childName;
  final String requestType;
  final String reason;
  final String? newRoute;
  final String? startDate;
  final String? endDate;
  final String requestDate;

  RequestHistoryModel({
    required this.childName,
    required this.requestType,
    required this.reason,
    this.newRoute,
    this.startDate,
    this.endDate,
    required this.requestDate,
  });

  factory RequestHistoryModel.fromJson(Map<String, dynamic> json) {
    return RequestHistoryModel(
      childName: json['childName'] ?? '',
      requestType: json['requestType'] ?? '',
      reason: json['reason'] ?? 'NA',
      newRoute: json['newRoute'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      requestDate: json['requestDate'] ?? '',
    );
  }
}
