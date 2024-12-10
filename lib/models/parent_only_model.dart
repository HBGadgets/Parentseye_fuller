class Parent {
  final String id;
  final String parentName;
  final String email;
  final String phone;
  final List<String> children;
  final int v;

  Parent({
    required this.id,
    required this.parentName,
    required this.email,
    required this.phone,
    required this.children,
    required this.v,
  });

  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(
      id: json['_id'],
      parentName: json['parentName'],
      email: json['email'],
      phone: json['phone'],
      children: List<String>.from(json['children'] ?? []),
      v: json['__v'],
    );
  }
}
