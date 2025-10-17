import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

// Note: This class uses the Provider pattern for state management.
// You must have the 'provider' package in your pubspec.yaml.

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  // Public accessors for UI to listen to
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthService() {
    // Initial check for anonymous sign-in or existing sessions for collaborative environment
    _initialAuthCheck();
  }

  // --- Utility Functions ---

  void _setLoading(bool status) {
    _isLoading = status;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
  
  // --- Core Authentication Methods ---

  // Attempts to sign in anonymously if no user is present (important for the Canvas)
  Future<void> _initialAuthCheck() async {
    // Check if the current user is a placeholder user (provided via a global token)
    // or if no user exists. The specific environment token logic is complex 
    // but here we ensure a session is always present.
    if (_auth.currentUser == null) {
      try {
        await _auth.signInAnonymously();
        print("Signed in anonymously for initial session.");
      } catch (e) {
        _setError('Initial session failed: ${e.toString()}');
      }
    }
  }

  // 1. Email/Password Sign-In
  Future<bool> signInWithEmailPassword(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _updateUserProfile(userCredential.user!);
      return true;
    } on FirebaseAuthException catch (e) {
      String msg;
      if (e.code == 'user-not-found') {
        msg = 'No user found. Please check your email or sign up.';
      } else if (e.code == 'wrong-password') {
        msg = 'Invalid password.';
      } else {
        msg = 'Login failed: ${e.message}';
      }
      _setError(msg);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 2. Google Sign-In
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _setError(null);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in flow
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      await _updateUserProfile(userCredential.user!);
      return true;

    } on FirebaseAuthException catch (e) {
       _setError('Google sign-in failed: ${e.message}');
       return false;
    } catch (e) {
       _setError('An unknown error occurred: ${e.toString()}');
       return false;
    } finally {
      _setLoading(false);
    }
  }

  // 3. Sign Out
  Future<void> signOut() async {
    _setLoading(true);
    _setError(null);
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      // Revert to anonymous session after explicit sign out
      await _auth.signInAnonymously(); 
    } catch (e) {
      _setError('Sign out failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // 4. Firestore Profile Update/Creation (Upsert)
  Future<void> _updateUserProfile(User user) async {
    // Using a placeholder app ID since the actual one is not passed in Flutter code
    const String appIdPlaceholder = 'moc-erahspans'; 
    final userRef = _db.doc('artifacts/$appIdPlaceholder/users/${user.uid}/profile/main');
    
    final userData = {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName ?? 'SnapSharer',
      'photoURL': user.photoURL,
      'lastSignIn': FieldValue.serverTimestamp(),
    };

    // Use setDoc with merge to ensure non-destructive updates
    await userRef.set(userData, SetOptions(merge: true));
  }
}
