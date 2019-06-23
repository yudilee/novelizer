import 'package:flutter/material.dart';

import 'bloc_provider.dart';

class DownloaderBloc extends BlocBase {
  static DownloaderBloc of(BuildContext context) => BlocProvider.of(context);

  @override
  void dispose() {
    //
  }
}
