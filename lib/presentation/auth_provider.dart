import 'package:flutter/foundation.dart';
import '../core/app_exceptions.dart';
import '../data/user_model.dart';
import '../data/auth_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthStatus _status = AuthStatus.initial;
  AppUser? _user;
  String? _errorMessage;

  AuthProvider(this._authService) {
    _init();
  }

  AuthStatus get status => _status;
  AppUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  void _init() {
    // Safety net: if Firebase stream never emits within 6s, go to unauthenticated
    Future.delayed(const Duration(seconds: 6), () {
      if (_status == AuthStatus.initial) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      }
    });

    _authService.authStateChanges.listen(
          (firebaseUser) async {
        if (firebaseUser != null) {
          _user = await _authService.getCachedUser();
          _status = AuthStatus.authenticated;
        } else {
          _user = null;
          _status = AuthStatus.unauthenticated;
        }
        notifyListeners();
      },
      onError: (_) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      },
    );
  }

  Future<bool> login(String email, String password) async {
    _setLoading();
    try {
      _user = await _authService.login(email, password);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _setLoading();
    try {
      _user = await _authService.register(name, email, password);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }
}