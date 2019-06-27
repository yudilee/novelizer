import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'bloc_provider.dart';
import 'auth_bloc.dart';

class ConfigBloc extends BlocBase {
  final FirebaseDatabase db = FirebaseDatabase.instance;
  final BehaviorSubject<String> _userId = BehaviorSubject.seeded(null);

  static ConfigBloc of(BuildContext context) => BlocProvider.of(context);

  @override
  void initState(BuildContext context) {
    db.setPersistenceEnabled(true);
    AuthBloc.of(context).loginState.listen((user) {
      _userId.sink.add(user?.uid);
    });
  }

  @override
  void dispose() {
    _userId.close();
  }

  DatabaseReference userDB(String uid) {
    return db.reference().child('users').child(uid).child('configs');
  }

  Future<void> setConfig(String key, String value) async {
    String uid = _userId.stream.value;
    await userDB(uid).child(key).set(value);
  }

  Observable getConfig(String key) {
    return Observable.switchLatest(
      _userId.map(userDB).map((node) {
        return node.child(key).onValue.map((e) => e.snapshot.value);
      }),
    );
  }
}
