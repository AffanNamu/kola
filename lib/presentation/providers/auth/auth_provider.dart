import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../../data/models/user/user_model.dart';
import '../../../data/remote/firestore/user_firestore.dart';

const _googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
const _superAdminUid = 'L5E8FXohf6Y7HLify4ITu6eMvIZ2';

final firebaseAuthProvider = Provider<fb.FirebaseAuth>((ref) {
  return fb.FirebaseAuth.instance;
});

final userFirestoreProvider = Provider<UserFirestore>((ref) {
  return const UserFirestore();
});

String authErrorMessage(Object error) {
  if (error is fb.FirebaseAuthException) {
    switch (error.code) {
      case 'google-config-missing':
        return 'Google sign-in setup is incomplete. Add the Web OAuth client ID as GOOGLE_SERVER_CLIENT_ID in GitHub Actions variables, then rebuild.';
      case 'sign-in-cancelled':
        return 'Google sign-in was cancelled.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'The email or password is incorrect. Use the same email address you registered with.';
      case 'email-already-in-use':
        return 'An account already exists with this email. Sign in instead.';
      case 'weak-password':
        return 'Choose a stronger password with at least 8 characters.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled in Firebase Authentication. Enable it in the Firebase Console.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a little and try again.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection and try again.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }
  if (error is fb.FirebaseException && error.code == 'permission-denied') {
    return 'Firebase denied access to the user profile. Check the Firestore security rules.';
  }
  return error.toString();
}

final authStateProvider = StreamProvider<UserModel?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final userFs = ref.watch(userFirestoreProvider);

  // Bridge: FirebaseAuth user -> Firestore user model (with role)
  final controller = StreamController<UserModel?>();

  StreamSubscription? sub;

  sub = auth.authStateChanges().listen((fbUser) async {
    if (fbUser == null) {
      controller.add(null);
      return;
    }

    final uid = fbUser.uid;
    UserModel? existing;
    try {
      existing = await userFs.getUser(uid);
    } catch (_) {
      // Authentication must remain usable when the profile document is unavailable.
    }

    final model = (existing ??
            UserModel(
              uid: uid,
              email: fbUser.email ?? '',
              displayName: fbUser.displayName ?? '',
              phoneNumber: fbUser.phoneNumber ?? '',
              photoUrl: fbUser.photoURL ?? '',
              role: fbUser.isAnonymous ? FirestoreConstants.roleGuest : FirestoreConstants.roleCustomer,
              isEmailVerified: fbUser.emailVerified,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ))
        .copyWith(
      email: fbUser.email ?? existing?.email ?? '',
      displayName: fbUser.displayName ?? existing?.displayName ?? '',
      photoUrl: fbUser.photoURL ?? existing?.photoUrl ?? '',
      phoneNumber: fbUser.phoneNumber ?? existing?.phoneNumber ?? '',
      role: fbUser.uid == _superAdminUid
          ? FirestoreConstants.roleAdmin
          : (fbUser.isAnonymous ? FirestoreConstants.roleGuest : (existing?.role ?? FirestoreConstants.roleCustomer)),
      isEmailVerified: fbUser.emailVerified,
      updatedAt: DateTime.now(),
    );

    try {
      await userFs.createOrUpdateUser(model);
    } catch (_) {
      // Do not block a valid Firebase session on profile synchronization.
    }
    controller.add(model);
  });

  ref.onDispose(() async {
    await sub?.cancel();
    await controller.close();
  });

  return controller.stream;
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this.ref) : super(const AsyncData(null));
  final Ref ref;

  fb.FirebaseAuth get _auth => ref.read(firebaseAuthProvider);
  UserFirestore get _userFs => ref.read(userFirestoreProvider);

  Future<void> signInEmail(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    });
  }

  Future<void> signUpEmail(String name, String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await cred.user?.updateDisplayName(name);
      await cred.user?.sendEmailVerification();

      final uid = cred.user!.uid;
      try {
        await _userFs.createOrUpdateUser(
          UserModel(
            uid: uid,
            email: email,
            displayName: name,
            role: FirestoreConstants.roleCustomer,
            isEmailVerified: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      } catch (_) {
        // Account creation and email verification should not be rolled back
        // because the optional Firestore profile write failed.
      }
    });
  }

  Future<void> sendPasswordReset(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _auth.sendPasswordResetEmail(email: email);
    });
  }

  Future<void> resendEmailVerification() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = _auth.currentUser;
      if (user == null) return;
      await user.sendEmailVerification();
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _auth.signOut();
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (_googleServerClientId.isEmpty) {
        throw fb.FirebaseAuthException(
          code: 'google-config-missing',
          message: 'Google sign-in is not configured yet. Add GOOGLE_SERVER_CLIENT_ID to the app build settings.',
        );
      }
      final googleUser = await GoogleSignIn(
        serverClientId: _googleServerClientId,
      ).signIn();
      if (googleUser == null) {
        throw fb.FirebaseAuthException(
          code: 'sign-in-cancelled',
          message: 'Google sign-in was cancelled.',
        );
      }
      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
    });
  }

  Future<void> signInAnonymously() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _auth.signInAnonymously();
    });
  }
}
