import 'package:firebase_auth/firebase_auth.dart';
import 'package:favoriteplaces/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Auth Service Provider
final authServiceProvider = Provider((ref) => AuthService());

// Current User Provider
final currentUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// User ID Provider
final userIdProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider).value;
  return user?.uid;
});

// Auth State Provider
class AuthState {
  final bool isLoading;
  final bool isLoggedIn;
  final User? user;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.isLoggedIn = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    User? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    _checkAuthState();
  }

  void _checkAuthState() {
    final user = _authService.currentUser;
    state = state.copyWith(
      isLoggedIn: user != null,
      user: user,
    );
  }

  Future<void> signUp({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.signUp(email: email, password: password);
      state = state.copyWith(
        isLoading: false,
        isLoggedIn: true,
        user: _authService.currentUser,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.login(email: email, password: password);
      state = state.copyWith(
        isLoading: false,
        isLoggedIn: true,
        user: _authService.currentUser,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authService.logout();
      state = state.copyWith(
        isLoading: false,
        isLoggedIn: false,
        user: null,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.sendPasswordResetEmail(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
