import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

// ── Auth Service ──────────────────────────────────────────────────────────────

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Stream of auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current signed-in user (may be null or anonymous).
  User? get currentUser => _auth.currentUser;

  /// True if a real (non-anonymous) user is signed in.
  bool get isSignedInWithIdentity =>
      _auth.currentUser != null && !(_auth.currentUser!.isAnonymous);

  /// Sign in with Email and Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided.');
      }
      throw Exception(e.message ?? 'An error occurred during sign in.');
    } catch (e) {
      throw Exception('An unknown error occurred.');
    }
  }

  /// Sign up with Email, Password, and Display Name
  Future<User?> signUpWithEmail(String email, String password, String displayName) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(displayName);
      await credential.user?.sendEmailVerification();
      await credential.user?.reload();
      return _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email.');
      }
      throw Exception(e.message ?? 'An error occurred during sign up.');
    } catch (e) {
      throw Exception('An unknown error occurred.');
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Check if the user is verified
  bool get isEmailVerified {
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// Reload the current user
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  /// Sign in with Google account.
  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      print('Google Sign-In Error: $e'); // Added for debugging
      rethrow;
    }
  }

  /// Sign out from all providers.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// The display name to use for Pass the Aux (guaranteed non-null).
  String get displayName {
    final user = _auth.currentUser;
    if (user == null) return 'Guest';
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    return user.email?.split('@').first ?? 'User';
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Stream of the current Firebase user (null = signed out).
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authServiceProvider).authStateChanges;
});

/// Convenience: true when a user (any kind) is logged in.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(authStateProvider);
  return userAsync.valueOrNull != null;
});

/// The display name of the current user for Pass the Aux.
final displayNameProvider = Provider<String>((ref) {
  return ref.read(authServiceProvider).displayName;
});

/// Generate a random guest nickname suggestion.
String generateGuestNickname() {
  const adjectives = [
    'Groovy', 'Chill', 'Funky', 'Mellow', 'Smooth', 'Vibe',
    'Bass', 'Treble', 'Retro', 'Neon', 'Echo', 'Sync',
  ];
  const nouns = [
    'Listener', 'DJ', 'Mixer', 'Rider', 'Wave', 'Beat',
    'Drop', 'Tune', 'Riff', 'Note', 'Track', 'Groove',
  ];
  final rng = Random();
  return '${adjectives[rng.nextInt(adjectives.length)]}${nouns[rng.nextInt(nouns.length)]}';
}
