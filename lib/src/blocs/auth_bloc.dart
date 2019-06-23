import 'package:flutter/material.dart';
import 'bloc_provider.dart';

class AuthBloc extends BlocBase {
  static AuthBloc of(BuildContext context) => BlocProvider.of(context);

  @override
  void dispose() {
    //
  }
}
