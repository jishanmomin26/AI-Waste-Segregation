class UserProfileModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String location;
  final String joinedDate;
  final int ecoPoints;
  final int totalScans;
  final int successfulScans;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.joinedDate,
    required this.ecoPoints,
    required this.totalScans,
    required this.successfulScans,
  });

  String get displayName {
    final trimmedName = name.trim();
    if (trimmedName.isNotEmpty) return trimmedName;
    return email.isNotEmpty ? email : 'Eco User';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'joinedDate': joinedDate,
      'ecoPoints': ecoPoints,
      'totalScans': totalScans,
      'successfulScans': successfulScans,
    };
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      location: json['location'] as String? ?? '',
      joinedDate: json['joinedDate'] as String? ?? '',
      ecoPoints: (json['ecoPoints'] as num?)?.toInt() ?? 0,
      totalScans: (json['totalScans'] as num?)?.toInt() ?? 0,
      successfulScans: (json['successfulScans'] as num?)?.toInt() ?? 0,
    );
  }

  UserProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? location,
    String? joinedDate,
    int? ecoPoints,
    int? totalScans,
    int? successfulScans,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      joinedDate: joinedDate ?? this.joinedDate,
      ecoPoints: ecoPoints ?? this.ecoPoints,
      totalScans: totalScans ?? this.totalScans,
      successfulScans: successfulScans ?? this.successfulScans,
    );
  }
}

