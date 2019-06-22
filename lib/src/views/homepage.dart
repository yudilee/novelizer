import 'package:flutter/material.dart';

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
        child: Text("Welcome!"),
      ),
    );
  }
}
