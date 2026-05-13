import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => _firebaseAuth.currentUser != null;

  /// Get current user ID
  String? get userId => _firebaseAuth.currentUser?.uid;

  /// Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Login with email and password
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Logout
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    String? displayName,
  }) async {
    try {
      await _firebaseAuth.currentUser?.updateDisplayName(displayName);
      await _firebaseAuth.currentUser?.reload();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Handle FirebaseAuthException and convert to readable message
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password provided is too weak.';
      case 'email-already-in-use':
        return 'Account already exists for that email.';
      case 'invalid-email':
        return 'Email address is not valid.';
      case 'operation-not-allowed':
        return 'Operation not allowed.';
      case 'user-disabled':
        return 'User account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'too-many-requests':
        return 'Too many login attempts. Try again later.';
      case 'invalid-credential':
        return 'The supplied auth credential is malformed or has expired.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
