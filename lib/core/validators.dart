class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  static String? taskTitle(String? value) {
    if (value == null || value.trim().isEmpty) return 'Title is required';
    if (value.trim().length > 100) return 'Title must be under 100 characters';
    return null;
  }

  static String? taskDescription(String? value) {
    if (value == null || value.trim().isEmpty) return 'Description is required';
    if (value.trim().length > 500) return 'Description must be under 500 characters';
    return null;
  }
}