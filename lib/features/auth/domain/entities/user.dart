/// Utilisateur SOE — entité Domain pure (pas de json/freezed Flutter).
class User {
  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.civility,
    this.phone,
    this.lang,
    this.photoUrl,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String? civility;
  final String? phone;
  final String? lang;
  final String? photoUrl;

  String get fullName => '$firstName $lastName';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == id &&
          other.email == email &&
          other.firstName == firstName &&
          other.lastName == lastName &&
          other.role == role);

  @override
  int get hashCode => Object.hash(id, email, firstName, lastName, role);
}

enum UserRole { parent, tutor, simpleAdmin, superAdmin }

extension UserRoleX on UserRole {
  String get apiValue => switch (this) {
        UserRole.parent => 'parent',
        UserRole.tutor => 'tutor',
        UserRole.simpleAdmin => 'simple_admin',
        UserRole.superAdmin => 'super_admin',
      };

  static UserRole fromApi(String s) => switch (s) {
        'parent' => UserRole.parent,
        'tutor' => UserRole.tutor,
        'simple_admin' => UserRole.simpleAdmin,
        'super_admin' => UserRole.superAdmin,
        _ => UserRole.parent,
      };
}
