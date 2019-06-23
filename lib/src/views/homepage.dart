import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import './common/screen.dart';

class HomePage extends Screen {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  @override
  bool matchRoute(String route) => route == '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novelizer'),
      ),
      body: Center(
        child: StreamBuilder(
          stream: _auth.onAuthStateChanged,
          builder: (_, AsyncSnapshot<FirebaseUser> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return buildBody(snapshot.data);
          },
        ),
      ),
    );
  }

  Widget buildBody(FirebaseUser user) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text("Welcome!"),
        user == null ? SizedBox(height: 20.0) : buildUserView(user),
        FutureBuilder(
          future: _accessDatabase(user),
          builder: (_, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(child: CircularProgressIndicator());
            }
            return buildDataDisplay(snapshot.data);
          },
        ),
        SizedBox(height: 20.0),
        user == null
            ? RaisedButton(
                onPressed: () => _handleSignIn(),
                child: Text('Sign In'),
              )
            : RaisedButton(
                onPressed: () => _auth.signOut(),
                child: Text('Sign Out'),
              ),
      ],
    );
  }

  Widget buildUserView(FirebaseUser user) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Text(
        'diplayName = ${user.displayName}\n'
        'uid = ${user.uid}\n'
        'email = ${user.email}\n'
        'photoUrl = ${user.photoUrl}\n'
        'isAnonymous = ${user.isAnonymous}\n'
        'isEmailVerified = ${user.isEmailVerified}\n'
        'provider = ${user.providerId}\n'
        '\n${"-" * 35}\n\n'
        'db app name = ${_db.app?.name}\n'
        'database url = ${_db.databaseURL}\n'
        '\n${"-" * 35}',
        style: TextStyle(
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget buildDataDisplay(Map data) {
    return Text(
      (data?.entries ?? [])
          .map((entry) => '${entry.key} = ${entry.value}')
          .join('\n'),
      style: TextStyle(
        fontFamily: 'monospace',
      ),
    );
  }

  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user = await _auth.signInWithCredential(credential);
    print("signed in " + user.displayName);
    return user;
  }

  Future<Map> _accessDatabase(FirebaseUser user) async {
    final db = _db.reference().child('users').child(user.uid).child('configs');
    // write values to database
    await db.update(
      Map.fromEntries([
        MapEntry('gender', 'male'),
        MapEntry('birthday', 'April 6, 1993'),
        MapEntry('time', DateTime.now().toIso8601String()),
      ]),
    );
    // read from database
    final data = await db.once();
    return data.value;
  }
}
