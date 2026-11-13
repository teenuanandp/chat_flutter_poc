
class AuthUserModel {
  final String id;
  final String userName;
  final String email;
  final String displayName;
  final String? about;
  final String status;
  final String? profilePhotoFileId;
  final List<String> roles;
  final List<String> permissions;
  final DateTime? createdAtUtc;

  const AuthUserModel({
    required this.id,
    required this.userName,
    required this.email,
    required this.displayName,
    this.about,
    required this.status,
    this.profilePhotoFileId,
    required this.roles,
    required this.permissions,
    this.createdAtUtc,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      about: json['about'] as String?,
      status: json['status'] as String? ?? '',
      profilePhotoFileId: json['profilePhotoFileId'] as String?,
      roles: List<String>.from(json['roles'] ?? []),
      permissions: List<String>.from(json['permissions'] ?? []),
      createdAtUtc: json['createdAtUtc'] == null
          ? null
          : DateTime.parse(json['createdAtUtc'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'email': email,
      'displayName': displayName,
      'about': about,
      'status': status,
      'profilePhotoFileId': profilePhotoFileId,
      'roles': roles,
      'permissions': permissions,
      'createdAtUtc': createdAtUtc?.toIso8601String(),
    };
  }
  
}
