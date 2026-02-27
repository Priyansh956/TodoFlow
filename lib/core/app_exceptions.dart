class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection.']);
}

class ServerException extends AppException {
  const ServerException([super.message = 'A server error occurred. Please try again.']);
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found.']);
}

class UnknownException extends AppException {
  const UnknownException([super.message = 'An unexpected error occurred.']);
}

String mapFirebaseAuthError(String code) {
  switch (code) {
    case 'user-not-found':
      return 'No account found with this email.';
    case 'wrong-password':
      return 'Incorrect password. Please try again.';
    case 'email-already-in-use':
      return 'An account already exists with this email.';
    case 'weak-password':
      return 'Password must be at least 6 characters.';
    case 'invalid-email':
      return 'Please enter a valid email address.';
    case 'network-request-failed':
      return 'Network error. Please check your connection.';
    case 'too-many-requests':
      return 'Too many attempts. Please try again later.';
    default:
      return 'Authentication failed. Please try again.';
  }
}