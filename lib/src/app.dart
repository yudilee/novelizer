import 'package:flutter/material.dart';

import './blocs/bloc-provider.dart';
import './blocs/downloader-bloc.dart';
import './views/homepage.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: DownloadManagerBloc(),
      child: app(),
    );
  }

  Widget app() {
    return MaterialApp(
      title: 'Novelizer',
      theme: ThemeData(
        primarySwatch: Colors.grey[100],
      ),
      onGenerateRoute: (settings) {
        return HomePage().buildRoute(settings) ?? buildUnknownRoute(settings);
      },
    );
  }

  MaterialPageRoute buildUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.error, size: 96.0),
                SizedBox(height: 10.0),
                Text(
                  settings.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.blueGrey,
                    fontSize: 20.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5.0),
                Text(
                  'This page is not available yet',
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    color: Colors.red,
                    fontSize: 20.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
