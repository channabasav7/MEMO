import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
	final FirebaseAuth _auth = FirebaseAuth.instance;

	Stream<User?> get authStateChanges => _auth.authStateChanges();

	User? get currentUser => _auth.currentUser;

	Future<UserCredential> signUp({required String email, required String password}) async {
		return await _auth.createUserWithEmailAndPassword(email: email, password: password);
	}

	Future<UserCredential> login({required String email, required String password}) async {
		return await _auth.signInWithEmailAndPassword(email: email, password: password);
	}

	Future<void> logout() async {
		await _auth.signOut();
	}

	Future<void> sendPasswordResetEmail(String email) async {
		await _auth.sendPasswordResetEmail(email: email);
	}

	Future<void> updateDisplayName(String displayName) async {
		final user = _auth.currentUser;
		if (user != null) {
			await user.updateDisplayName(displayName);
			await user.reload();
		}
	}
}
