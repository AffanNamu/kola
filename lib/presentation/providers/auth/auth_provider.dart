import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../../data/models/user/user_model.dart';
import '../../../data/remote/firestore/user_firestore.dart';

final firebaseAuthProvider = Provider<fb.FirebaseAuth>((ref) {
  return fb.FirebaseAuth.instance;
});

final userFirestoreProvider = Provider<UserFirestore>((ref) {
  return const UserFirestore();
});

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
    final existing = await userFs.getUser(uid);

    final model = (existing ??
            UserModel(
              uid: uid,
              email: fbUser.email ?? '',
              displayName: fbUser.displayName ?? '',
              phoneNumber: fbUser.phoneNumber ?? '',
              photoUrl: fbUser.photoURL ?? '',
              role: FirestoreConstants.roleCustomer,
              isEmailVerified: fbUser.emailVerified,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ))
        .copyWith(
      email: fbUser.email ?? existing?.email ?? '',
      displayName: fbUser.displayName ?? existing?.displayName ?? '',
      photoUrl: fbUser.photoURL ?? existing?.photoUrl ?? '',
      phoneNumber: fbUser.phoneNumber ?? existing?.phoneNumber ?? '',
      isEmailVerified: fbUser.emailVerified,
      updatedAt: DateTime.now(),
    );

    await userFs.createOrUpdateUser(model);
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

  Future<void> signInAnonymously() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final cred = await _auth.signInAnonymously();
      final uid = cred.user!.uid;

      await _userFs.createOrUpdateUser(
        UserModel(
          uid: uid,
          email: '',
          displayName: 'Guest',
          role: FirestoreConstants.roleGuest,
          isEmailVerified: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    });
  }
}
