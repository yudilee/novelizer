import 'package:flutter/material.dart';

import './blocs/bloc_provider.dart';
import './blocs/auth_bloc.dart';
import './blocs/downloader_bloc.dart';
import './views/common/error_widget.dart';
import './views/homepage.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: AuthBloc(),
      child: BlocProvider(
        bloc: DownloaderBloc(),
        child: app(),
      ),
    );
  }

  Widget app() {
    return MaterialApp(
      title: 'Novelizer',
//      darkTheme: ThemeData.dark(),
      onGenerateRoute: (settings) {
        return HomePage().buildRoute(settings) ?? buildUnknownRoute(settings);
      },
    );
  }

  MaterialPageRoute buildUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) {
        return BadPageWidget(
          errorMessage: settings.name,
          errorDetails: 'This page is not available',
        );
      },
    );
  }
}
