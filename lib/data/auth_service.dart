import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/app_constants.dart';
import '../core/app_exceptions.dart' hide AuthException, mapFirebaseAuthError;
import 'user_model.dart';

abstract class AuthService {
  Future<AppUser> login(String email, String password);
  Future<AppUser> register(String name, String email, String password);
  Future<void> logout();
  Stream<User?> get authStateChanges;
  User? get currentUser;
  Future<AppUser?> getCachedUser();
}

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FlutterSecureStorage _storage;

  FirebaseAuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    required FlutterSecureStorage storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<AppUser> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;
      final doc = await _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .get();
      final user = AppUser.fromMap({...doc.data()!, 'uid': uid});
      await _cacheUser(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(mapFirebaseAuthError(e.code), code: e.code);
    } catch (_) {
      throw const AuthException('Login failed. Please try again.');
    }
  }

  @override
  Future<AppUser> register(String name, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;
      await credential.user!.updateDisplayName(name.trim());
      final user = AppUser(uid: uid, name: name.trim(), email: email.trim());
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .set(user.toMap());
      await _cacheUser(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(mapFirebaseAuthError(e.code), code: e.code);
    } catch (_) {
      throw const AuthException('Registration failed. Please try again.');
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    await _storage.deleteAll();
  }

  @override
  Future<AppUser?> getCachedUser() async {
    final uid = await _storage.read(key: StorageKeys.userId);
    final name = await _storage.read(key: StorageKeys.userName);
    final email = await _storage.read(key: StorageKeys.userEmail);
    if (uid == null || name == null || email == null) return null;
    return AppUser(uid: uid, name: name, email: email);
  }

  Future<void> _cacheUser(AppUser user) async {
    await _storage.write(key: StorageKeys.userId, value: user.uid);
    await _storage.write(key: StorageKeys.userName, value: user.name);
    await _storage.write(key: StorageKeys.userEmail, value: user.email);
  }
}