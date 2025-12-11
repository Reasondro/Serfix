import 'package:serfix/features/auth/domain/entities/user_role.dart';

class AppUser {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final String? avatarUrl;
  final String? licenseNumber;
  final UserRole role;

  AppUser({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    this.avatarUrl,
    this.licenseNumber,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'license_number': licenseNumber,
        'role': role.name,
      };

  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    try {
      final id = jsonUser['id'];
      final email = jsonUser['email'];
      final userMetadata = jsonUser['user_metadata'];

      if (id == null || id is! String) {
        throw FormatException(
          "Invalid or missing 'id' $id in user JSON: $jsonUser",
        );
      }
      if (email == null || email is! String) {
        throw FormatException(
          "Invalid or missing 'email' $email in user JSON: $jsonUser",
        );
      }

      if (userMetadata == null || userMetadata is! Map<String, dynamic>) {
        throw FormatException(
          "Invalid or missing 'user_metadata' $userMetadata in user JSON: $jsonUser",
        );
      }

      final username = userMetadata['username'];
      final fullName = userMetadata['full_name'];
      final avatarUrl = userMetadata['avatar_url'];
      final licenseNumber = userMetadata['license_number'];
      final roleString = userMetadata['role'];

      if (username == null || username is! String) {
        throw FormatException(
          "Invalid or missing 'username' ($username) in user_metadata: $userMetadata",
        );
      }
      if (fullName == null || fullName is! String) {
        throw FormatException(
          "Invalid or missing 'full_name' ($fullName) in user_metadata: $userMetadata",
        );
      }
      if (avatarUrl != null && avatarUrl is! String) {
        throw FormatException(
          "Invalid 'avatar_url' type (${avatarUrl.runtimeType}) in user_metadata: $userMetadata",
        );
      }

      if (roleString == null || roleString is! String) {
        throw FormatException(
          "Invalid or missing 'role' ($roleString) in user_metadata: $userMetadata",
        );
      }

      final UserRole role;
      try {
        role = UserRole.fromString(roleString);
      } catch (e) {
        throw FormatException(
          "Failed to parse 'role' ($roleString) in user_metadata: $e",
        );
      }

      return AppUser(
        id: id,
        email: email,
        username: username,
        fullName: fullName,
        avatarUrl: avatarUrl,
        licenseNumber: licenseNumber,
        role: role,
      );
    } catch (e) {
      throw Exception("Failed to parse AppUser data: $e");
    }
  }
}
