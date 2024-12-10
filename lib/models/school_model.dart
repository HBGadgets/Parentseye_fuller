class School {
  final String schoolName;
  final List<Branch> branches;

  School({required this.schoolName, required this.branches});

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      schoolName: json['schoolName'] ?? '',
      branches: (json['branches'] as List<dynamic>?)
              ?.map((branch) => Branch.fromJson(branch))
              .toList() ??
          [],
    );
  }
}

class Branch {
  final String branchName;

  Branch({required this.branchName});

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      branchName: json['branchName'] ?? '',
    );
  }
}
