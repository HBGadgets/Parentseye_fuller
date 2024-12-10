import 'package:flutter/material.dart';

class ParentStudentModel {
  final ParentDetails parentDetails;
  final List<StudentDetails> children;

  ParentStudentModel({
    required this.parentDetails,
    required this.children,
  });

  factory ParentStudentModel.fromJson(Map<String, dynamic> json) {
    debugPrint('Parent details JSON: ${json['parent']}');
    return ParentStudentModel(
      parentDetails:
          ParentDetails.fromJson(json['parent'] as Map<String, dynamic>),
      children: (json['children'] as List<dynamic>)
          .map(
            (child) => StudentDetails.fromJson(child as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parent': parentDetails.toJson(),
      'children': children.map((child) => child.toJson()).toList(),
    };
  }
}

class ParentDetails {
  final String parentId;
  final String parentName;
  final String email;
  final String phone;

  ParentDetails({
    required this.parentId,
    required this.parentName,
    required this.email,
    required this.phone,
  });

  factory ParentDetails.fromJson(Map<String, dynamic> json) {
    return ParentDetails(
      parentName: json['parentName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      parentId: json['parentId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parentName': parentName,
      'email': email,
      'phone': phone,
      'parentId': parentId,
    };
  }
}

class StudentDetails {
  final String deviceId;
  final String childId;
  final String childName;
  final String childAge;
  final String className;
  final String rollno;
  final String section;
  final String schoolName;
  final String gender;
  final String dateOfBirth;
  final String pickupPoint;
  final String deviceName;
  final String branchName;
  final String driverMobile;
  final String schoolMobile;

  StudentDetails({
    required this.deviceId,
    required this.childId,
    required this.childName,
    required this.childAge,
    required this.className,
    required this.rollno,
    required this.section,
    required this.schoolName,
    required this.gender,
    required this.dateOfBirth,
    required this.pickupPoint,
    required this.deviceName,
    required this.branchName,
    required this.driverMobile,
    required this.schoolMobile,
  });

  factory StudentDetails.fromJson(Map<String, dynamic> json) {
    return StudentDetails(
      deviceId: json['deviceId'] ?? 'NA',
      childId: json['_id'] ?? '',
      childName: json['childName'] ?? '',
      childAge: json['childAge'].toString(),
      className: json['class'] ?? '',
      rollno: json['rollno'] ?? '',
      section: json['section'] ?? '',
      schoolName: json['schoolName'] ?? '',
      gender: json['gender'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      pickupPoint: json["pickupPoint"] ?? '',
      deviceName: json["deviceName"] ?? '',
      branchName: json['branchName'] ?? '',
      driverMobile: json['driverMobile'] ?? '',
      schoolMobile: json['schoolMobile'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': childId,
      'childName': childName,
      'childAge': childAge,
      'class': className,
      'rollno': rollno,
      'section': section,
      'schoolName': schoolName,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'pickupPoint': pickupPoint,
      'deviceName': deviceName,
      'branchName': branchName,
      'deviceId': deviceId,
      'driverMobile': driverMobile,
      'schoolMobile': schoolMobile,
    };
  }
}
