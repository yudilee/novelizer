import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'bloc_provider.dart';

class ConfigBloc extends BlocBase {
  final FirebaseDatabase db = FirebaseDatabase.instance;

  static ConfigBloc of(BuildContext context) => BlocProvider.of(context);

  @override
  void initState(BuildContext context) {
    db.setPersistenceEnabled(true);
  }

  @override
  void dispose() {
    //
  }

  DatabaseReference userConfig(String uid) {
    return db.reference().child('users').child(uid).child('configs');
  }
}
