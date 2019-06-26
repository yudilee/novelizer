import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

import 'bloc_provider.dart';

class AuthBloc extends BlocBase {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  static AuthBloc of(BuildContext context) => BlocProvider.of(context);

  @override
  void dispose() {
    //
  }

  Observable<FirebaseUser> get loginState => Observable(auth.onAuthStateChanged);

  Future<void> logout() async {
    await auth.signOut();
  }

  Future<FirebaseUser> loginGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final user = await auth.signInWithCredential(credential);
    return user;
  }

  Future<FirebaseUser> loginLocal(String email, String password) async {
    final user = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return user;
  }

  Future<FirebaseUser> registerLocal(String displayName, String email, String password) async {
    final user = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final update = UserUpdateInfo();
    update.displayName = displayName;
    await user.updateProfile(update);
    return user;
  }
}
