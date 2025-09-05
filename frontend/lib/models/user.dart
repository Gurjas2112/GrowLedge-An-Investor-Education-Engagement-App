class AppUser {
  final String uid;
  final String name;
  final String email;
  final String preferredLanguage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> badges;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.preferredLanguage,
    required this.createdAt,
    required this.updatedAt,
    this.badges = const [],
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      preferredLanguage: json['preferred_language'] ?? 'English',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      badges: List<String>.from(json['badges'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'preferred_language': preferredLanguage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'badges': badges,
    };
  }

  AppUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? preferredLanguage,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? badges,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      badges: badges ?? this.badges,
    );
  }
}
