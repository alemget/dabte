class Client {
  final int? id;
  final String name;
  final String? phone;
  final DateTime? createdAt;

  const Client({this.id, required this.name, this.phone, this.createdAt});

  Client copyWith({int? id, String? name, String? phone, DateTime? createdAt}) => Client(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        createdAt: createdAt ?? this.createdAt,
      );

  factory Client.fromMap(Map<String, dynamic> map) => Client(
        id: map['id'] as int?,
        name: map['name'] as String,
        phone: map['phone'] as String?,
        createdAt: map['createdAt'] != null 
            ? DateTime.tryParse(map['createdAt'] as String) 
            : null,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'createdAt': createdAt?.toIso8601String(),
      };
}
