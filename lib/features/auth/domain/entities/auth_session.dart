import 'user.dart';

/// Session = user + token JWT.
class AuthSession {
  const AuthSession({required this.user, required this.accessToken});
  final User user;
  final String accessToken;
}
