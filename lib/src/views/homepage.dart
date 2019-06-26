import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../blocs/auth_bloc.dart';
import '../blocs/config_bloc.dart';
import './common/screen.dart';

class HomePage extends Screen {
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
          stream: AuthBloc.of(context).loginState,
          builder: (_, AsyncSnapshot<FirebaseUser> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return buildBody(context, snapshot.data);
          },
        ),
      ),
    );
  }

  Widget buildBody(BuildContext context, FirebaseUser user) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text("Welcome!"),
        user == null ? SizedBox(height: 20.0) : buildUserView(user),
        FutureBuilder(
          future: _accessDatabase(context, user),
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
                onPressed: () => AuthBloc.of(context).loginGoogle(),
                child: Text('Sign In'),
              )
            : RaisedButton(
                onPressed: () => AuthBloc.of(context).logout(),
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
        '\n${"-" * 35}\n',
        style: TextStyle(
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget buildDataDisplay(Map data) {
    return Text(
      (data?.entries ?? []).map((entry) => '${entry.key} = ${entry.value}').join('\n'),
      style: TextStyle(
        fontFamily: 'monospace',
      ),
    );
  }

  Future<Map> _accessDatabase(BuildContext context, FirebaseUser user) async {
    final db = ConfigBloc.of(context).userConfig(user.uid);
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
